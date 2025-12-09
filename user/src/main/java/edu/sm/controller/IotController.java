package edu.sm.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import edu.sm.app.dto.Iot;
import edu.sm.app.service.IotService;
import lombok.extern.slf4j.Slf4j;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.http.MediaType;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.time.format.DateTimeFormatter;
import java.util.List;

@RestController
@RequestMapping("/iot")
@Slf4j
@CrossOrigin(
    origins = "https://127.0.0.1:8443",
    allowedHeaders = "*",
    methods = {RequestMethod.GET, RequestMethod.POST, RequestMethod.OPTIONS}
)
public class IotController {

  private final IotService iotService;
  private final ChatClient chatClient;
  private final ObjectMapper objectMapper;

  // ✅ 알림 전용 - 관리자 한 명만
  private SseEmitter adminEmitter = null;

  public IotController(IotService iotService,
                       ChatClient.Builder chatClientBuilder,
                       ObjectMapper objectMapper) {
    this.iotService = iotService;
    this.chatClient = chatClientBuilder.build();
    this.objectMapper = objectMapper;
  }

  /**
   * ✅ 알림 전용 SSE - 관리자 한 명만 연결 가능
   */
  @GetMapping(value = "/admin/subscribe", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
  public SseEmitter subscribeAdmin() {
    // 기존 연결이 있으면 닫기
    if (adminEmitter != null) {
      try {
        adminEmitter.complete();
      } catch (Exception e) {
        log.warn("기존 관리자 연결 종료 중 에러", e);
      }
    }

    adminEmitter = new SseEmitter(Long.MAX_VALUE);
    log.info("✅ 관리자 알림 구독 시작");

    adminEmitter.onCompletion(() -> {
      log.info("관리자 연결 종료");
      adminEmitter = null;
    });

    adminEmitter.onTimeout(() -> {
      log.info("관리자 연결 타임아웃");
      adminEmitter = null;
    });

    adminEmitter.onError((e) -> {
      log.error("관리자 연결 에러", e);
      adminEmitter = null;
    });

    try {
      adminEmitter.send(SseEmitter.event()
          .name("connect")
          .data("관리자 알림 구독 성공"));
    } catch (IOException e) {
      log.error("초기 메시지 전송 실패", e);
    }

    return adminEmitter;
  }

  /**
   * IoT 데이터 저장 + AI 분석 (GET/POST 모두 지원)
   */
  @RequestMapping(value = "/data", method = {RequestMethod.GET, RequestMethod.POST})
  public String saveData(
      @RequestParam("patientId") Long patientId,
      @RequestParam(value = "userId", required = false) Long userId,
      @RequestParam("deviceType") String deviceType,
      @RequestParam("vitalType") String vitalType,
      @RequestParam("value") Double value) {

    Long targetId = (patientId != null) ? patientId : userId;
    if (targetId == null) {
      log.error("Missing ID");
      return "fail";
    }

    try {
      List<Iot> recentData = iotService.getRecentByPatientId(targetId, 10);

      String prompt = buildAiPrompt(targetId, vitalType, value, recentData);
      String aiResponse = chatClient.prompt()
          .user(prompt)
          .call()
          .content();

      log.info("AI Response: {}", aiResponse);

      AiAnalysis analysis = parseAiResponse(aiResponse);

      Iot iot = Iot.builder()
          .patientId(targetId)
          .deviceType(deviceType)
          .vitalType(vitalType)
          .value(value)
          .isAbnormal(analysis.isAbnormal)
          .build();

      iotService.register(iot);

      // ✅ 비정상이면 관리자에게만 알림
      if (analysis.isAbnormal || analysis.isEmergency) {
        sendAdminAlert(targetId, vitalType, value, analysis);
      }

      return "ok";

    } catch (Exception e) {
      log.error("Error processing IoT data", e);
      return "fail";
    }
  }

  /**
   * ✅ 관리자에게만 알림 전송
   */
  private void sendAdminAlert(Long patientId, String vitalType, Double value, AiAnalysis analysis) {
    if (adminEmitter == null) {
      log.warn("⚠️ 관리자가 구독하지 않음 - 알림 전송 불가");
      return;
    }

    try {
      String alertType = analysis.isEmergency ? "emergency" : "warning";
      String emoji = analysis.isEmergency ? "🚨" : "⚠️";

      String message = String.format(
          "%s 환자 ID: %d | %s: %.1f | 심각도: %s\n사유: %s\n권장: %s",
          emoji, patientId, getVitalName(vitalType), value,
          analysis.severity, analysis.reason, analysis.recommendation
      );

      adminEmitter.send(SseEmitter.event()
          .name(alertType)
          .data(message));

      log.info("✅ 관리자 알림 전송 성공");

    } catch (IOException e) {
      log.error("❌ 관리자 알림 전송 실패", e);
      adminEmitter = null;
    }
  }

  /* 차트 데이터 조회 */
  @GetMapping("/chart")
  public List<Iot> getChartData(
      @RequestParam(value = "patientId", required = false) Long patientId,
      @RequestParam(value = "userId", required = false) Long userId,
      @RequestParam(value = "days", defaultValue = "1") int days) throws Exception {

    Long targetId = (patientId != null) ? patientId : userId;
    if (targetId == null) throw new IllegalArgumentException("ID Missing");

    log.info("차트 데이터 요청: patientId={}, days={}", targetId, days);
    return iotService.getByDateRange(targetId, days);
  }

  /* 실시간 데이터 조회  */
  @GetMapping("/getlive")
  public List<Iot> getLive(
      @RequestParam(value = "patientId", required = false) Long patientId,
      @RequestParam(value = "userId", required = false) Long userId
  ) throws Exception {

    Long targetId = (patientId != null) ? patientId : userId;
    if (targetId == null) throw new IllegalArgumentException("ID Missing");

    return iotService.getRecentByPatientId(targetId, 10);
  }

  private String getVitalName(String vitalType) {
    return switch (vitalType) {
      case "HEART_RATE" -> "심박수";
      case "TEMPERATURE" -> "체온";
      case "BLOOD_SUGAR" -> "혈당";
      case "BP_SYSTOLIC" -> "수축기 혈압";
      case "BP_DIASTOLIC" -> "이완기 혈압";
      default -> vitalType;
    };
  }

  private String buildAiPrompt(Long patientId, String vitalType, Double value, List<Iot> recentData) {
    StringBuilder prompt = new StringBuilder();
    prompt.append("당신은 의료 IoT 데이터 분석 전문 AI입니다.\n\n");

    prompt.append("### 중요 지침\n");
    prompt.append("⚠️ 오직 현재 측정된 ").append(getVitalName(vitalType)).append(" 값만 분석하세요.\n");
    prompt.append("⚠️ 과거 데이터의 다른 바이탈(체온, 혈압 등)은 무시하세요.\n");
    prompt.append("⚠️ 오직 현재 ").append(vitalType).append(" 값이 정상 범위 내에 있는지만 판단하세요.\n\n");

    prompt.append("### 환자 ID: ").append(patientId).append("\n\n");
    prompt.append("### 새로운 측정값\n");
    prompt.append("- 바이탈 타입: ").append(vitalType).append("\n");
    prompt.append("- 측정값: ").append(value).append("\n\n");

    if (!recentData.isEmpty()) {
      prompt.append("### 최근 측정 기록 (최신 10개)\n");
      DateTimeFormatter formatter = DateTimeFormatter.ofPattern("MM-dd HH:mm");
      for (Iot data : recentData) {
        prompt.append(String.format("- %s: %.2f (측정시간: %s)\n",
            data.getVitalType(),
            data.getValue(),
            data.getMeasuredAt().format(formatter)));
      }
      prompt.append("\n");
    }

    prompt.append("### 분석 요청\n");
    prompt.append("다음을 **반드시 JSON 형식**으로만 답변해주세요:\n");
    prompt.append("{\n");
    prompt.append("  \"isAbnormal\": true 또는 false,\n");
    prompt.append("  \"isEmergency\": true 또는 false,\n");
    prompt.append("  \"severity\": \"HIGH\" 또는 \"MEDIUM\" 또는 \"LOW\",\n");
    prompt.append("  \"reason\": \"판단 근거 설명\",\n");
    prompt.append("  \"recommendation\": \"의료진 권장사항\"\n");
    prompt.append("}\n\n");

    prompt.append("### 판단 기준\n");
    prompt.append("- 심박수(HEART_RATE): 60-100 bpm 정상\n");
    prompt.append("- 체온(TEMPERATURE): 36.0-37.5°C 정상\n");
    prompt.append("- 혈당(BLOOD_SUGAR): 70-140 mg/dL 정상\n");
    prompt.append("- 수축기혈압(BP_SYSTOLIC): 90-140 mmHg 정상\n");
    prompt.append("- 이완기혈압(BP_DIASTOLIC): 60-90 mmHg 정상\n");
    prompt.append("- 최근 추세가 급격히 악화되면 응급 상황으로 판단\n");

    return prompt.toString();
  }

  private AiAnalysis parseAiResponse(String aiResponse) {
    try {
      String json = extractJson(aiResponse);
      JsonNode node = objectMapper.readTree(json);

      return new AiAnalysis(
          node.get("isAbnormal").asBoolean(),
          node.get("isEmergency").asBoolean(),
          node.get("severity").asText(),
          node.get("reason").asText(),
          node.get("recommendation").asText()
      );

    } catch (Exception e) {
      log.error("Failed to parse AI response", e);
      return new AiAnalysis(true, false, "MEDIUM", "AI 분석 실패", "수동 확인 필요");
    }
  }

  private String extractJson(String text) {
    int start = text.indexOf("{");
    int end = text.lastIndexOf("}") + 1;
    if (start >= 0 && end > start) {
      return text.substring(start, end);
    }
    return text;
  }

  private record AiAnalysis(
      boolean isAbnormal,
      boolean isEmergency,
      String severity,
      String reason,
      String recommendation
  ) {}
}
