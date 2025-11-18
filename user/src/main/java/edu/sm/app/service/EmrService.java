package edu.sm.app.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import edu.sm.app.dto.Emr;
import edu.sm.app.repository.EmrRepository;
import edu.sm.app.springai.service.AiSttService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.vectorstore.QuestionAnswerAdvisor;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;
import org.springframework.web.multipart.MultipartFile;

import java.time.LocalDateTime;
import java.util.Map;

@Service
@RequiredArgsConstructor
@Slf4j
public class EmrService {

  private final ChatClient.Builder chatClientBuilder;
  private final AiSttService aiSttService;
  private final VectorStore vectorStore;
  private final EmrRepository emrRepository;
  private final ObjectMapper objectMapper = new ObjectMapper();

  /**
   * STT + Few-Shot + RAG 기반 EMR 자동 생성 (DB 저장 안 함)
   */
  public Emr generateEmrFromAudio(
      Long consultationId,
      Long patientId,
      MultipartFile audioFile,
      String testResults,
      String prescriptionDetails) throws Exception {

    log.info("EMR 생성 시작 - consultationId: {}, patientId: {}", consultationId, patientId);

    // 1. STT: 음성 → 텍스트 변환
    String sttText = aiSttService.stt(audioFile);
    log.info("STT 변환 완료: {} 자", sttText.length());

    // 2. Few-Shot + RAG: EMR JSON 생성
    String emrJson = generateEmrJsonWithFewShot(sttText, testResults, prescriptionDetails);
    log.info("EMR JSON 생성 완료");

    // 3. JSON 파싱
    Emr emr = parseEmrJson(emrJson);
    emr.setConsultationId(consultationId);
    emr.setPatientId(patientId);
    emr.setPatientStatement(sttText);
    emr.setTestResults(testResults);
    emr.setPrescriptionDetails(prescriptionDetails);
    emr.setAiGeneratedDraft(emrJson);
    emr.setCreatedAt(LocalDateTime.now());

    return emr;
  }

  /**
   * Few-Shot 프롬프트로 구조화된 EMR JSON 생성
   */
  private String generateEmrJsonWithFewShot(
      String sttText,
      String testResults,
      String prescriptionDetails) {

    ChatClient chatClient = chatClientBuilder.build();

    String systemPrompt = """
            당신은 전문 의료 기록 작성 AI입니다.
            환자 상담 내용을 EMR JSON 형식으로 변환하세요.
            반드시 { 로 시작하고 } 로 끝나는 하나의 JSON 객체만 출력하세요.
            
            ### JSON 스키마 ###
            {
              "chiefComplaint": "주 호소",
              "presentIllness": "현병력",
              "diagnosis": "진단명",
              "treatmentPlan": "치료 계획",
              "counselingNote": "상담 기록"
            }
            
            ### 예시 1 ###
            입력:
            - STT: "어제부터 허리가 아파서 잠을 못 잤어요"
            - 검사: MRI - 요추 4-5번 추간판 팽윤
            - 처방: 소염진통제 1일 3회
            
            출력:
            {
              "chiefComplaint": "허리 통증",
              "presentIllness": "어제부터 허리 통증 시작, 수면 장애 동반",
              "diagnosis": "요추 추간판 탈출증 (L4-L5)",
              "treatmentPlan": "약물 치료 및 물리 치료 권장",
              "counselingNote": "통증 호전 없을 시 1주일 후 재방문"
            }
            """;

    String userPrompt = String.format("""
            입력:
            - STT: "%s"
            - 검사 결과: %s
            - 처방: %s
            
            위 정보를 바탕으로 EMR JSON을 생성하세요.
            """,
        sttText,
        testResults != null ? testResults : "검사 결과 없음",
        prescriptionDetails != null ? prescriptionDetails : "처방 없음");

    // RAG Advisor 추가
    SearchRequest searchRequest = SearchRequest.builder()
        .similarityThreshold(0.7)
        .topK(2)
        .filterExpression("type == 'emr_template'")
        .build();

    QuestionAnswerAdvisor ragAdvisor = QuestionAnswerAdvisor.builder(vectorStore)
        .searchRequest(searchRequest)
        .build();

    String response = chatClient.prompt()
        .system(systemPrompt)
        .user(userPrompt)
        .advisors(ragAdvisor)
        .call()
        .content();

    return extractJsonFromResponse(response);
  }

  /**
   * JSON 추출 (백틱을 직접 쓰지 않고 처리)
   */
  private String extractJsonFromResponse(String response) {
    if (response == null || response.isEmpty()) {
      return "{}";
    }

    String cleaned = response.trim();

    String codeBlockMarker = new String(new char[]{96, 96, 96});
    String codeBlockJson = codeBlockMarker + "json";

    if (cleaned.startsWith(codeBlockJson)) {
      cleaned = cleaned.substring(codeBlockJson.length()).trim();
    } else if (cleaned.startsWith(codeBlockMarker)) {
      cleaned = cleaned.substring(codeBlockMarker.length()).trim();
    }

    if (cleaned.endsWith(codeBlockMarker)) {
      cleaned = cleaned.substring(0, cleaned.length() - codeBlockMarker.length()).trim();
    }

    int startIdx = cleaned.indexOf('{');
    int endIdx = cleaned.lastIndexOf('}');

    if (startIdx >= 0 && endIdx > startIdx) {
      return cleaned.substring(startIdx, endIdx + 1).trim();
    }

    log.warn("JSON 추출 실패, 원본 응답: {}", response);
    return "{}";
  }

  /**
   * JSON 파싱하여 EMR 엔티티 생성
   */
  private Emr parseEmrJson(String jsonStr) throws Exception {
    JsonNode jsonNode = objectMapper.readTree(jsonStr);

    Emr emr = new Emr();
    StringBuilder finalRecord = new StringBuilder();

    if (jsonNode.has("chiefComplaint")) {
      finalRecord.append("[주 호소]\n")
          .append(jsonNode.get("chiefComplaint").asText())
          .append("\n\n");
    }

    if (jsonNode.has("presentIllness")) {
      finalRecord.append("[현병력]\n")
          .append(jsonNode.get("presentIllness").asText())
          .append("\n\n");
    }

    if (jsonNode.has("diagnosis")) {
      finalRecord.append("[진단명]\n")
          .append(jsonNode.get("diagnosis").asText())
          .append("\n\n");
    }

    if (jsonNode.has("treatmentPlan")) {
      finalRecord.append("[치료 계획]\n")
          .append(jsonNode.get("treatmentPlan").asText())
          .append("\n\n");
    }

    if (jsonNode.has("counselingNote")) {
      finalRecord.append("[상담 기록]\n")
          .append(jsonNode.get("counselingNote").asText());
    }

    emr.setFinalRecord(finalRecord.toString());
    return emr;
  }

//  EMR 최종 기록 분배용 프롬프트를 넣어서 호출
public String generateAiParsedJsonFromFinalRecord(String aiPrompt) {
  ChatClient chatClient = chatClientBuilder.build();
  String response = chatClient.prompt()
      .system("의료 기록 구조화 AI입니다.")
      .user(aiPrompt)
      .call()
      .content();
  return extractJsonFromResponse(response);
}

  public void saveEmrWithAIAutoParsing(Long consultationId, Long patientId, String finalRecord) throws Exception {
    // AI 프롬프트 작성
    String aiPrompt = """
    다음은 한 환자의 EMR 기록 전체입니다.
    각 항목(patient_statement, test_results, prescription_details, ai_generated_draft)으로 나눠 JSON으로 출력하세요.
    없는 항목은 빈 문자열로 하세요.
    [EMR 기록]
    """ + finalRecord;

    // AI 호출
    String aiResultJson = generateAiParsedJsonFromFinalRecord(aiPrompt);

    // JSON 파싱 후 Map 변환
    Map<String, String> fields = objectMapper.readValue(aiResultJson, Map.class);

    Emr emr = new Emr();
    emr.setConsultationId(consultationId);
    emr.setPatientId(patientId);
    emr.setPatientStatement(fields.getOrDefault("patient_statement", ""));
    emr.setTestResults(fields.getOrDefault("test_results", ""));
    emr.setPrescriptionDetails(fields.getOrDefault("prescription_details", ""));
    emr.setAiGeneratedDraft(fields.getOrDefault("ai_generated_draft", ""));
    emr.setFinalRecord(finalRecord);
    emr.setCreatedAt(LocalDateTime.now());
    emr.setUpdatedAt(LocalDateTime.now());

    emrRepository.insert(emr);
  }

  /**
   * EMR 조회
   */
  public Emr getEmr(Long emrId) throws Exception {
    return emrRepository.select(emrId);
  }
}
