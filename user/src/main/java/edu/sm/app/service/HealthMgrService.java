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

    String aiResponse = chatClient.prompt()
        .system(systemPrompt)
        .user(conversationContext.toString())
        .call()
        .content();

    log.info("AI 응답 생성 완료");
    return aiResponse;
  }

  private String buildSystemPrompt(Patient patient, Long patientId) throws Exception {
    StringBuilder prompt = new StringBuilder();
    prompt.append("당신은 전문적이고 친절한 AI 건강 상담사입니다.\n\n");
    prompt.append("=== 환자 기본 정보 ===\n");

    // 이름
    prompt.append(String.format("- 이름: %s\n",
        patient.getPatientName() != null ? patient.getPatientName() : "정보 없음"));

    // 나이 (null 체크)
    if (patient.getPatientDob() != null) {
      prompt.append(String.format("- 나이: %d세\n", calculateAge(patient.getPatientDob())));
    } else {
      prompt.append("- 나이: 정보 없음\n");
    }

    // 성별
    prompt.append(String.format("- 성별: %s\n",
        patient.getPatientGender() != null ? patient.getPatientGender() : "정보 없음"));

    // 선호 언어
    String preferredLanguage = patient.getLanguagePreference();
    if (preferredLanguage != null && !preferredLanguage.isEmpty()) {
      prompt.append(String.format("- 선호 언어: %s\n", preferredLanguage));
    } else {
      prompt.append("- 선호 언어: 한국어 (기본값)\n");
      preferredLanguage = "ko"; // 기본값 설정
    }

    // 병력
    if (patient.getPatientMedicalHistory() != null && !patient.getPatientMedicalHistory().isEmpty()) {
      prompt.append(String.format("- 병력: %s\n", patient.getPatientMedicalHistory()));
    } else {
      prompt.append("- 병력: 정보 없음\n");
    }

    // 생활습관
    if (patient.getPatientLifestyleHabits() != null && !patient.getPatientLifestyleHabits().isEmpty()) {
      prompt.append(String.format("- 생활습관: %s\n", patient.getPatientLifestyleHabits()));
    } else {
      prompt.append("- 생활습관: 정보 없음\n");
    }

    // EMR 기록
    prompt.append("\n=== 최근 진료 기록 ===\n");
    emrRepository.findTopByPatientIdOrderByCreatedAtDesc(patientId)
        .ifPresentOrElse(
            emr -> {
              prompt.append(String.format("진단: %s\n", emr.getFinalRecord()));
              prompt.append(String.format("처방: %s\n", emr.getPrescriptionDetails()));
            },
            () -> prompt.append("진료 기록이 없습니다.\n")
        );

    // 설문조사
    prompt.append("\n=== 최근 건강 설문 ===\n");
    surveyRepository.findTopByPatientIdOrderBySubmittedAtDesc(patientId)
        .ifPresentOrElse(
            survey -> prompt.append(String.format("설문 응답: %s\n", survey.getAnswers())),
            () -> prompt.append("설문 기록이 없습니다.\n")
        );

    // IoT 바이탈 데이터 (최근 7일)
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

    // 언어별 응답 지침
    prompt.append(String.format("7. 반드시 %s로 답변하세요.\n", getLanguageName(preferredLanguage)));

    return prompt.toString();
  }

  // 언어 코드를 언어 이름으로 변환하는 헬퍼 메서드
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
