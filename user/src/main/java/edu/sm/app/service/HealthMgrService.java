package edu.sm.app.service;

import edu.sm.app.dto.Iot;
import edu.sm.app.dto.Patient;
import edu.sm.app.repository.EmrRepository;
import edu.sm.app.repository.IotRepository;
import edu.sm.app.repository.PatientRepository;
import edu.sm.app.repository.SurveyRepository;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.client.advisor.vectorstore.QuestionAnswerAdvisor;
import org.springframework.ai.vectorstore.SearchRequest;
import org.springframework.ai.vectorstore.VectorStore;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.time.Period;
import java.util.List;
import java.util.Map;
import java.util.stream.Collectors;

@Service
@RequiredArgsConstructor
@Slf4j
public class HealthMgrService {

  private final ChatClient.Builder chatClientBuilder;
  private final PatientRepository patientRepository;
  private final EmrRepository emrRepository;
  private final SurveyRepository surveyRepository;
  private final IotRepository iotRepository;
  private final VectorStore vectorStore;

  public String processChat(Long patientId, String userMessage, List<Map<String, String>> chatHistory) throws Exception {
    log.info("AI 채팅 처리 - 환자 ID: {}", patientId);

    Patient patient = patientRepository.findByPatientId(patientId).orElse(null);
    if (patient == null) {
      return "환자 정보를 찾을 수 없습니다.";
    }

    String systemPrompt = buildSystemPrompt(patient, patientId);
    ChatClient chatClient = chatClientBuilder.build();

    StringBuilder conversationContext = new StringBuilder();
    for (Map<String, String> msg : chatHistory) {
      String role = msg.get("role");
      String content = msg.get("content");
      if ("user".equals(role)) {
        conversationContext.append("사용자: ").append(content).append("\n");
      } else if ("assistant".equals(role)) {
        conversationContext.append("AI: ").append(content).append("\n");
      }
    }

    conversationContext.append("사용자: ").append(userMessage).append("\n");
    conversationContext.append("AI: ");

    SearchRequest searchRequest = SearchRequest.builder()
        .query(conversationContext.toString())
        .topK(5)
        .similarityThreshold(0.5)
        .filterExpression("type == 'patient_" + patientId + "_diagnosis' OR type == 'patient_" + patientId + "_prescription'")
        .build();

    QuestionAnswerAdvisor ragAdvisor = QuestionAnswerAdvisor.builder(vectorStore)
        .searchRequest(searchRequest)
        .build();

    String aiResponse = chatClient.prompt()
        .system(systemPrompt)
        .user(conversationContext.toString())
        .advisors(ragAdvisor)
        .call()
        .content();

    log.info("AI 응답 생성 완료");
    return aiResponse;
  }

  public String predictDiseaseRisk(Long patientId) throws Exception {
    log.info("질환 예측 시작 - 환자 ID: {}", patientId);

    Patient patient = patientRepository.findByPatientId(patientId).orElse(null);
    if (patient == null) {
      return "환자 정보를 찾을 수 없습니다.";
    }

    StringBuilder predictionPrompt = new StringBuilder();
    predictionPrompt.append("# 질환 발생 가능성 예측 분석\n\n");
    predictionPrompt.append("## 환자 기본 정보\n");
    predictionPrompt.append(String.format("- 이름: %s\n", patient.getPatientName()));

    if (patient.getPatientDob() != null) {
      predictionPrompt.append(String.format("- 나이: %d세\n", calculateAge(patient.getPatientDob())));
    }

    predictionPrompt.append(String.format("- 성별: %s\n", patient.getPatientGender()));
    predictionPrompt.append(String.format("- 기존 질병: %s\n",
        patient.getPatientMedicalHistory() != null ? patient.getPatientMedicalHistory() : "없음"));
    predictionPrompt.append(String.format("- 생활습관: %s\n\n",
        patient.getPatientLifestyleHabits() != null ? patient.getPatientLifestyleHabits() : "정보 없음"));

    emrRepository.findTopByPatientIdOrderByCreatedAtDesc(patientId)
        .ifPresent(emr -> {
          predictionPrompt.append("## 최근 진료 기록\n");
          predictionPrompt.append(emr.getFinalRecord()).append("\n\n");
        });

    LocalDateTime monthAgo = LocalDateTime.now().minusDays(30);
    List<Iot> recentVitals = iotRepository
        .findByPatientIdAndMeasuredAtAfterOrderByMeasuredAtDesc(patientId, monthAgo);

    if (!recentVitals.isEmpty()) {
      predictionPrompt.append("## 최근 30일 바이탈 데이터 통계\n");
      Map<String, List<Iot>> vitalsByType = recentVitals.stream()
          .collect(Collectors.groupingBy(Iot::getVitalType));

      for (Map.Entry<String, List<Iot>> entry : vitalsByType.entrySet()) {
        String vitalType = entry.getKey();
        List<Iot> vitals = entry.getValue();

        double avg = vitals.stream().mapToDouble(Iot::getValue).average().orElse(0.0);
        double max = vitals.stream().mapToDouble(Iot::getValue).max().orElse(0.0);
        double min = vitals.stream().mapToDouble(Iot::getValue).min().orElse(0.0);
        long abnormalCount = vitals.stream().filter(Iot::getIsAbnormal).count();

        predictionPrompt.append(String.format("- %s: 평균 %.2f, 최대 %.2f, 최소 %.2f, 비정상 %d회\n",
            vitalType, avg, max, min, abnormalCount));
      }
      predictionPrompt.append("\n");
    }

    SearchRequest searchRequest = SearchRequest.builder()
        .query(predictionPrompt.toString())
        .topK(5)
        .similarityThreshold(0.6)
        .filterExpression("type == 'patient_" + patientId + "_diagnosis' OR type == 'patient_" + patientId + "_prescription'")
        .build();

    List<org.springframework.ai.document.Document> uploadedDocuments =
        vectorStore.similaritySearch(searchRequest);

    if (!uploadedDocuments.isEmpty()) {
      predictionPrompt.append("## 환자가 업로드한 진단서 및 처방전 내용 (벡터 DB)\n");
      predictionPrompt.append("**중요: 아래 내용을 반드시 질환 예측에 반영하세요**\n\n");

      for (org.springframework.ai.document.Document doc : uploadedDocuments) {
        predictionPrompt.append(doc.getFormattedContent()).append("\n\n");
      }

      log.info("벡터 DB에서 {}개의 문서를 검색했습니다.", uploadedDocuments.size());
    } else {
      predictionPrompt.append("## 업로드된 진단서/처방전\n");
      predictionPrompt.append("업로드된 문서가 없습니다.\n\n");
      log.warn("벡터 DB에서 문서를 찾을 수 없습니다.");
    }

    predictionPrompt.append("\n위 모든 정보를 바탕으로 다음을 분석해주세요:\n");
    predictionPrompt.append("1. 현재 건강 상태 종합 평가 (업로드된 진단서 내용 포함)\n");
    predictionPrompt.append("2. 발생 가능성이 높은 질환 (확률 포함, 진단서 기반)\n");
    predictionPrompt.append("3. 각 질환별 예방 방법 (진단서 약물 정보 활용)\n");
    predictionPrompt.append("4. 주의해야 할 증상\n");
    predictionPrompt.append("5. 권장 검진 항목\n\n");
    predictionPrompt.append("⚠️ 업로드된 진단서/처방전이 있다면 반드시 해당 내용을 인용하고 분석에 포함하세요.\n");
    predictionPrompt.append("반드시 한국어로 답변하고, 의학적으로 정확하게 작성해주세요.");

    // ✅ QuestionAnswerAdvisor 제거 (이미 검색 결과를 프롬프트에 포함)
    ChatClient chatClient = chatClientBuilder.build();

    String prediction = chatClient.prompt()
        .system("당신은 질환 예측 전문 AI입니다. 환자의 과거 진료 기록, 바이탈 데이터, 업로드된 진단서를 종합적으로 분석하여 질환 발생 가능성을 예측합니다. 업로드된 진단서나 처방전 내용이 있으면 반드시 해당 정보를 인용하고 분석에 포함해야 합니다.")
        .user(predictionPrompt.toString())
        .call()
        .content();

    log.info("질환 예측 완료");
    return prediction;
  }

  private String buildSystemPrompt(Patient patient, Long patientId) throws Exception {
    StringBuilder prompt = new StringBuilder();
    prompt.append("당신은 전문적이고 친절한 AI 건강 상담사입니다.\n\n");
    prompt.append("=== 환자 기본 정보 ===\n");

    prompt.append(String.format("- 이름: %s\n",
        patient.getPatientName() != null ? patient.getPatientName() : "정보 없음"));

    if (patient.getPatientDob() != null) {
      prompt.append(String.format("- 나이: %d세\n", calculateAge(patient.getPatientDob())));
    } else {
      prompt.append("- 나이: 정보 없음\n");
    }

    prompt.append(String.format("- 성별: %s\n",
        patient.getPatientGender() != null ? patient.getPatientGender() : "정보 없음"));

    String preferredLanguage = patient.getLanguagePreference();
    if (preferredLanguage != null && !preferredLanguage.isEmpty()) {
      prompt.append(String.format("- 선호 언어: %s\n", preferredLanguage));
    } else {
      prompt.append("- 선호 언어: 한국어 (기본값)\n");
      preferredLanguage = "ko";
    }

    if (patient.getPatientMedicalHistory() != null && !patient.getPatientMedicalHistory().isEmpty()) {
      prompt.append(String.format("- 병력: %s\n", patient.getPatientMedicalHistory()));
    } else {
      prompt.append("- 병력: 정보 없음\n");
    }

    if (patient.getPatientLifestyleHabits() != null && !patient.getPatientLifestyleHabits().isEmpty()) {
      prompt.append(String.format("- 생활습관: %s\n", patient.getPatientLifestyleHabits()));
    } else {
      prompt.append("- 생활습관: 정보 없음\n");
    }

    prompt.append("\n=== 최근 진료 기록 ===\n");
    emrRepository.findTopByPatientIdOrderByCreatedAtDesc(patientId)
        .ifPresentOrElse(
            emr -> {
              prompt.append(String.format("진단: %s\n", emr.getFinalRecord()));
              prompt.append(String.format("처방: %s\n", emr.getPrescriptionDetails()));
            },
            () -> prompt.append("진료 기록이 없습니다.\n")
        );

    prompt.append("\n=== 최근 건강 설문 ===\n");
    surveyRepository.findTopByPatientIdOrderBySubmittedAtDesc(patientId)
        .ifPresentOrElse(
            survey -> prompt.append(String.format("설문 응답: %s\n", survey.getAnswers())),
            () -> prompt.append("설문 기록이 없습니다.\n")
        );

    prompt.append("\n=== 최근 7일 바이탈 데이터 ===\n");
    LocalDateTime weekAgo = LocalDateTime.now().minusDays(7);
    List<Iot> recentVitals = iotRepository
        .findByPatientIdAndMeasuredAtAfterOrderByMeasuredAtDesc(patientId, weekAgo);

    if (!recentVitals.isEmpty()) {
      String vitalsString = recentVitals.stream()
          .map(iot -> String.format("%s: %.2f", iot.getVitalType(), iot.getValue()))
          .collect(Collectors.joining(", "));
      prompt.append(String.format("최근 7일 바이탈: %s\n", vitalsString));
    } else {
      prompt.append("최근 바이탈 데이터가 없습니다.\n");
    }

    prompt.append("\n=== 상담 가이드라인 ===\n");
    prompt.append("1. 환자의 정보가 부족한 경우, 정보가 없다고 명확히 안내해주세요.\n");
    prompt.append("2. 의료 정보를 제공할 때는 항상 전문의 상담을 권장하세요.\n");
    prompt.append("3. 환자의 현재 상태를 고려한 맞춤형 조언을 제공하세요.\n");
    prompt.append("4. 건강 데이터가 없는 경우, 일반적인 건강 관리 팁을 제공하세요.\n");
    prompt.append("5. 친절하고 이해하기 쉬운 언어를 사용하세요.\n");
    prompt.append("6. 긴급한 증상이 의심되면 즉시 병원 방문을 권장하세요.\n");
    prompt.append(String.format("7. 반드시 %s로 답변하세요.\n", getLanguageName(preferredLanguage)));

    return prompt.toString();
  }

  private String getLanguageName(String languageCode) {
    if (languageCode == null || languageCode.isEmpty()) {
      return "한국어";
    }

    switch (languageCode.toLowerCase()) {
      case "ko":
        return "한국어";
      case "en":
        return "영어 (English)";
      case "ja":
        return "일본어 (日本語)";
      case "zh":
        return "중국어 (中文)";
      case "es":
        return "스페인어 (Español)";
      case "fr":
        return "프랑스어 (Français)";
      default:
        return languageCode;
    }
  }

  private int calculateAge(java.time.LocalDate dob) {
    if (dob == null) {
      return 0;
    }
    return Period.between(dob, java.time.LocalDate.now()).getYears();
  }
}
