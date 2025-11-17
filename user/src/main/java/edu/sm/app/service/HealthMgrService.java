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
    log.info("AI 채팅 처리 시작 - 환자 ID: {}", patientId);

    // 환자 기본 정보
    Patient patient = patientRepository.findByPatientId(patientId).orElse(null);
    if (patient == null) {
      return "환자 정보를 찾을 수 없습니다.";
    }

    // 시스템 프롬프트 구성
    String systemPrompt = buildSystemPrompt(patient, patientId);

    // ChatClient 생성
    ChatClient chatClient = chatClientBuilder.build();

    // 대화 내역을 포함한 프롬프트 구성
    StringBuilder conversationContext = new StringBuilder();

    // 이전 대화 내역 추가
    for (Map<String, String> msg : chatHistory) {
      String role = msg.get("role");
      String content = msg.get("content");
      if ("user".equals(role)) {
        conversationContext.append("환자: ").append(content).append("\n");
      } else if ("assistant".equals(role)) {
        conversationContext.append("AI: ").append(content).append("\n");
      }
    }

    // 현재 사용자 메시지 추가
    conversationContext.append("환자: ").append(userMessage).append("\n");
    conversationContext.append("AI: ");

    // AI 호출
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

    prompt.append("당신은 친절한 재활 의학 및 영양학 전문 AI 건강 상담사입니다.\n\n");

    prompt.append("# 환자 기본 정보\n");
    prompt.append(String.format("- 이름: %s\n", patient.getPatientName()));
    prompt.append(String.format("- 나이: %d세\n", calculateAge(patient.getPatientDob())));
    prompt.append(String.format("- 성별: %s\n", patient.getPatientGender()));
    prompt.append(String.format("- 질병 이력: %s\n", patient.getPatientMedicalHistory()));
    prompt.append(String.format("- 생활습관: %s\n", patient.getPatientLifestyleHabits()));

    // 최근 진료 기록
    emrRepository.findTopByPatientIdOrderByCreatedAtDesc(patientId)
        .ifPresent(emr -> {
          prompt.append(String.format("\n## 최근 진단 기록\n%s\n", emr.getFinalRecord()));
          prompt.append(String.format("## 최근 처방 내역\n%s\n", emr.getPrescriptionDetails()));
        });

    // 최근 설문 결과
    surveyRepository.findTopByPatientIdOrderBySubmittedAtDesc(patientId)
        .ifPresent(survey -> {
          prompt.append(String.format("\n## 건강 설문 결과\n%s\n", survey.getAnswers()));
        });

    // 최근 7일 IoT 데이터
    LocalDateTime weekAgo = LocalDateTime.now().minusDays(7);
    List<Iot> recentVitals = iotRepository
        .findByPatientIdAndMeasuredAtAfterOrderByMeasuredAtDesc(patientId, weekAgo);

    if (!recentVitals.isEmpty()) {
      String vitalsString = recentVitals.stream()
          .map(iot -> String.format("%s: %.2f", iot.getVitalType(), iot.getValue()))
          .collect(Collectors.joining(", "));
      prompt.append(String.format("\n## 최근 바이탈 데이터 (7일간)\n%s\n", vitalsString));
    }

    prompt.append("\n# 역할 및 주의사항\n");
    prompt.append("1. 공감하고 친절한 톤으로 대화하세요\n");
    prompt.append("2. 환자의 질문에 명확하고 이해하기 쉽게 답변하세요\n");
    prompt.append("3. 필요시 추가 질문으로 상세 정보를 수집하세요\n");
    prompt.append("4. 운동 추천 시: 방법, 횟수, 빈도, 주의사항 포함\n");
    prompt.append("5. 식단 추천 시: 아침/점심/저녁 구성, 피해야 할 음식 명시\n");
    prompt.append("6. 위험 증상 감지 시 즉시 병원 방문 권유\n");
    prompt.append("7. 의학적 진단은 절대 하지 말 것\n");

    return prompt.toString();
  }

  private int calculateAge(java.time.LocalDate dob) {
    return Period.between(dob, java.time.LocalDate.now()).getYears();
  }
}
