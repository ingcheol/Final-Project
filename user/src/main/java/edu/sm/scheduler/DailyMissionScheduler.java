package edu.sm.scheduler;

import edu.sm.app.dto.Emr;
import edu.sm.app.dto.Iot;
import edu.sm.app.dto.Patient;
import edu.sm.app.service.EmrService;
import edu.sm.app.service.IotService;
import edu.sm.app.service.PatientService;
import edu.sm.app.springai.service.AiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.json.JSONObject; // JSON 파싱용
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.scheduling.annotation.Scheduled;
import org.springframework.stereotype.Component;

import java.util.List;

@Slf4j
@Component
@RequiredArgsConstructor
public class DailyMissionScheduler {

  private final PatientService patientService;
  private final IotService iotService;
  private final EmrService emrService;
  private final AiService aiService;
  private final SimpMessagingTemplate messagingTemplate;

  // 시간 설정 해야함 (테스트로 10초)
  @Scheduled(cron = "0/10 * * * * *")
  public void aiSelectAndSendMission() {
    log.info("=== AI 기반 환자 선별 및 미션 생성 시작 ===");
    try {
      List<Patient> patients = patientService.get();

      for (Patient p : patients) {
        // 1. 데이터 수집
        Emr recentEmr = emrService.getRecentEmr(p.getPatientId());
        List<Iot> recentBp = iotService.getRecentByVitalType(p.getPatientId(), "BP_SYSTOLIC", 1);
        List<Iot> recentSugar = iotService.getRecentByVitalType(p.getPatientId(), "BLOOD_SUGAR", 1);

        // 2. AI에게 판단 요청 (프롬프트 전송)
        String prompt = buildSelectionPrompt(p, recentEmr, recentBp, recentSugar);
        String jsonResponse = aiService.generateText(prompt); // AI가 JSON String 반환

        // 3. AI 응답 파싱 및 실행
        try {
          // AI가 가끔 마크다운 코드블럭(```json ... ```)을 포함할 수 있으므로 제거 처리
          jsonResponse = jsonResponse.replace("```json", "").replace("```", "").trim();

          JSONObject result = new JSONObject(jsonResponse);
          boolean isSelected = result.getBoolean("selected");

          if (isSelected) {
            String reason = result.getString("reason"); // 선별 이유 (로그용)
            String mission = result.getString("message"); // 환자에게 보낼 메시지

            log.info("대상 선정됨 [{}]: {} (메시지: {})", p.getPatientName(), reason, mission);

            // 웹소켓 발송
            messagingTemplate.convertAndSend("/send/mission/" + p.getPatientId(), mission);
          } else {
            log.info("PASS [{}]: 관리 대상 아님 (이유: {})", p.getPatientName(), result.getString("reason"));
          }
        } catch (Exception e) {
          log.error("AI 응답 파싱 실패 (환자: {}): {}", p.getPatientName(), e.getMessage());
        }
      }
    } catch (Exception e) {
      e.printStackTrace();
    }
  }

  // 선별(Selection)과 생성(Generation)을 동시에 요청하는 프롬프트
  private String buildSelectionPrompt(Patient p, Emr emr, List<Iot> bpList, List<Iot> sugarList) {
    StringBuilder sb = new StringBuilder();

    sb.append("역할: 당신은 환자의 건강 데이터를 분석하여 '실천 가능한 구체적인 행동 미션'을 제안하는 AI 건강 코치입니다.\n");
    sb.append("필수 조건: 추상적인 조언(예: '건강 관리하세요')은 금지합니다. 반드시 '무엇을 먹어라', '몇 분 걷자', '어떤 약을 챙겨라' 등 구체적인 행동을 지시하세요.\n\n");

    // [환자 데이터 입력]
    sb.append(String.format("- 환자명: %s (%s, %s)\n", p.getPatientName(), p.getPatientGender(), p.getPatientDob()));
    sb.append(String.format("- 기저질환: %s\n", p.getPatientMedicalHistory()));

    if (emr != null) {
      sb.append(String.format("- 최근 병원 진료: %s (진단: %s, 소견: %s)\n",
          emr.getCreatedAt(), emr.getPrescriptionDetails(), emr.getFinalRecord()));
    } else {
      sb.append("- 최근 병원 진료: 기록 없음\n");
    }

    if (!bpList.isEmpty()) sb.append(String.format("- 최신 혈압: %.0f (측정: %s)\n", bpList.get(0).getValue(), bpList.get(0).getMeasuredAt()));
    else sb.append("- 최신 혈압: 데이터 없음\n");

    if (!sugarList.isEmpty()) sb.append(String.format("- 최신 혈당: %.0f (측정: %s)\n", sugarList.get(0).getValue(), sugarList.get(0).getMeasuredAt()));
    else sb.append("- 최신 혈당: 데이터 없음\n");

    // [판단 기준 가이드]
    sb.append("\n[판단 기준]\n");
    sb.append("1. 'selected': true 인 경우:\n");
    sb.append("   - 수치가 '위험' 또는 '주의' 범위일 때\n");
    sb.append("   - 데이터가 오랫동안 없어 측정이 시급할 때\n");
    sb.append("   - 병원 진료 후 추적 관리가 필요하다고 판단될 때\n");
    sb.append("2. 'selected': false 인 경우:\n");
    sb.append("   - 모든 수치가 정상이고 건강 관리가 잘 되고 있을 때\n");

    sb.append("\n[미션 생성 규칙]\n");
    sb.append("1. 식사 미션: 혈당/혈압 상태에 맞춰 구체적인 메뉴 추천 (예: '오늘 점심은 짠 찌개 대신 두부 샐러드 어떠세요?')\n");
    sb.append("2. 운동 미션: 현재 컨디션에 맞춘 가벼운 활동 제안 (예: '식사 후 30분 동안 동네 한 바퀴 산책하세요.')\n");
    sb.append("3. 복약 미션: 처방 약물이 있다면 잊지 않도록 언급\n");
    sb.append("4. 말투: 어르신에게 말하듯 존댓말로, 다정하고 설득력 있게.\n");

    // [출력 형식 강제]
    sb.append("\n[반환 형식 (반드시 JSON만 출력)]\n");
    sb.append("{\n");
    sb.append("  \"selected\": true 또는 false,\n");
    sb.append("  \"reason\": \"선별 또는 제외한 의학적 이유와 미션 제안 이유\",\n");
    sb.append("  \"message\": \"환자에게 보낼 구체적인 건강 미션 (selected가 false면 빈 문자열)\"\n");
    sb.append("}");

    return sb.toString();
  }
}