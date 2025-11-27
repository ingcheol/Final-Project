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
      String prescriptionDetails,
      String language) throws Exception {

    log.info("EMR 생성 시작 - consultationId: {}, patientId: {}", consultationId, patientId);

    // 1. STT: 음성 → 텍스트 변환
    String sttText = aiSttService.stt(audioFile);
    log.info("STT 변환 완료: {} 자", sttText.length());

    // 2. Few-Shot + RAG: EMR JSON 생성
    String emrJson = generateEmrJsonWithFewShot(sttText, testResults, prescriptionDetails, language);
    log.info("EMR JSON 생성 완료");

    // 3. JSON 파싱
    Emr emr = parseEmrJson(emrJson, language);
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
      String prescriptionDetails,
      String language) {

    ChatClient chatClient = chatClientBuilder.build();

    String systemPrompt = switch (language) {
      case "en" -> """
            You are a professional medical records AI following Korea's EMR certification standards (F041).
            Generate medical records in English only in SOAP format.
            Output must be a single JSON object starting with { and ending with }.
            
            ### JSON Schema ###
            {
              "subjective": "Patient's subjective symptoms",
              "objective": "Objective examination findings",
              "assessment": "Assessment and diagnosis",
              "plan": "Treatment plan"
            }
            """;
      default -> """
            당신은 보건복지부 전자의무기록(EMR) 인증기준을 준수하는 의료 기록 작성 AI입니다.
            환자 상담 내용을 한국어로만 표준 의무기록 형식(SOAP)으로 구조화하여 출력하세요.
            반드시 { 로 시작하고 } 로 끝나는 하나의 JSON 객체만 출력하세요.
            
            ### JSON 스키마 ###
            {
              "subjective": "환자 주관적 증상 (S)",
              "objective": "객관적 검사 소견 (O)",
              "assessment": "평가 및 진단 (A)",
              "plan": "치료 계획 (P)"
            }
            """;
    };

    String userPrompt = String.format("""
          입력:
          - 환자 진술 (STT): "%s"
          - 검사 결과: %s
          - 처방 내역: %s
          
          위 정보를 SOAP 형식의 표준 의무기록 JSON으로 생성하세요.
          """,
        sttText,
        testResults != null ? testResults : "검사 없음",
        prescriptionDetails != null ? prescriptionDetails : "처방 없음");

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
  private Emr parseEmrJson(String jsonStr, String language) throws Exception {
    JsonNode jsonNode = objectMapper.readTree(jsonStr);
    Emr emr = new Emr();
    StringBuilder finalRecord = new StringBuilder();

    if ("en".equals(language)) {
      finalRecord.append("=== Electronic Medical Record (EMR) ===\n\n");

      if (jsonNode.has("subjective")) {
        finalRecord.append("[S - Subjective]\n")
            .append(jsonNode.get("subjective").asText()).append("\n\n");
      }

      if (jsonNode.has("objective")) {
        finalRecord.append("[O - Objective]\n")
            .append(jsonNode.get("objective").asText()).append("\n\n");
      }

      if (jsonNode.has("assessment")) {
        finalRecord.append("[A - Assessment]\n")
            .append(jsonNode.get("assessment").asText()).append("\n\n");
      }

      if (jsonNode.has("plan")) {
        finalRecord.append("[P - Plan]\n")
            .append(jsonNode.get("plan").asText());
      }
    } else {
      // 한국어 (기본값)
      finalRecord.append("=== 전자의무기록 (EMR) ===\n\n");

      if (jsonNode.has("subjective")) {
        finalRecord.append("[S - 주관적 증상]\n")
            .append(jsonNode.get("subjective").asText()).append("\n\n");
      }

      if (jsonNode.has("objective")) {
        finalRecord.append("[O - 객관적 소견]\n")
            .append(jsonNode.get("objective").asText()).append("\n\n");
      }

      if (jsonNode.has("assessment")) {
        finalRecord.append("[A - 평가]\n")
            .append(jsonNode.get("assessment").asText()).append("\n\n");
      }

      if (jsonNode.has("plan")) {
        finalRecord.append("[P - 계획]\n")
            .append(jsonNode.get("plan").asText());
      }
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
    String aiPrompt = """
        다음은 환자의 전자의무기록(EMR) 전체 내용입니다.
        각 항목을 아래 JSON 형식으로 정확히 분류하여 출력하세요.
        반드시 { 로 시작하고 } 로 끝나는 하나의 JSON만 출력하세요.
        
        {
          "patient_statement": "환자가 직접 진술한 내용",
          "test_results": "검사 결과 및 수치",
          "prescription_details": "처방된 약물 및 용법",
          "ai_generated_draft": "AI가 생성한 초안 기록"
        }
        
        [EMR 전체 기록]
        """ + finalRecord;

    String aiResultJson = generateAiParsedJsonFromFinalRecord(aiPrompt);
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
    log.info("EMR 최종 저장 완료 - emrId: {}", emr.getEmrId());
  }

  /**
   * EMR 조회
   */
  public Emr getRecentEmr(Long patientId) throws Exception {
    return emrRepository.findTopByPatientIdOrderByCreatedAtDesc(patientId)
        .orElse(null); // 데이터가 없으면 null 반환하여 스케줄러에서 처리
  }
}
