package edu.sm.controller;

import edu.sm.app.dto.Emr;
import edu.sm.app.dto.Patient;
import edu.sm.app.service.EmrService;
import edu.sm.app.springai.service.ETLService;
import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;
import org.springframework.messaging.handler.annotation.DestinationVariable;
import org.springframework.messaging.handler.annotation.MessageMapping;
import org.springframework.messaging.handler.annotation.Payload;
import org.springframework.messaging.simp.SimpMessagingTemplate;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@Slf4j
@Controller
public class ConsulController {

  private final SimpMessagingTemplate messagingTemplate;
  private final EmrService emrService;
  private final ETLService etlService;


  public ConsulController(SimpMessagingTemplate messagingTemplate, EmrService emrService, ETLService etlService) {
    this.messagingTemplate = messagingTemplate;
    this.emrService = emrService;
    this.etlService = etlService;
  }

  /**
   * 방(Room) 전체 채팅
   * Patient와 Adviser 모두 이 경로로 메시지를 보냄
   */
  @MessageMapping("/chat/to/{roomId}")
  public void sendToRoom(@Payload Map<String, String> message, @DestinationVariable String roomId) {
    String sendId = message.get("sendid");
    String content = message.get("content1");

    log.info("Room chat - From: {}, Room: {}, Content: {}", sendId, roomId, content);

//        // Patient용 브로드캐스트 (모든 patient가 구독)
//        messagingTemplate.convertAndSend("/send/chat/" + roomId, message);

    // Adviser용 브로드캐스트 (모든 adviser가 구독)
    messagingTemplate.convertAndSend("/advisersend/chat/" + roomId, message);
  }

  /**
   * Patient -> Adviser 개인 메시지
   */
//    @MessageMapping("/patient/send/to/{receiverId}")
//    public void patientSendToAdviser(@Payload Map<String, String> message, @DestinationVariable String receiverId) {
//        String sendId = message.get("sendid");
//        String content = message.get("content1");
//
//        log.info("Patient to Adviser - From: {} To: {}, Content: {}", sendId, receiverId, content);
//
//        // Adviser가 구독하는 경로로 전송
//        messagingTemplate.convertAndSend("/advisersend/to/" + receiverId, message);
//    }

  /**
   * Adviser -> Patient 개인 메시지
   */
  @MessageMapping("/adviser/send/to/{receiverId}")
  public void adviserSendToPatient(@Payload Map<String, String> message, @DestinationVariable String receiverId) {
    String sendId = message.get("sendid");
    String content = message.get("content1");

    log.info("Adviser to Patient - From: {} To: {}, Content: {}", sendId, receiverId, content);

    // Patient가 구독하는 경로로 전송
    messagingTemplate.convertAndSend("/send/to/" + receiverId, message);
  }

  /**
   * 음성 파일 업로드 → STT + EMR 자동 생성 (DB 저장 안 함)
   */
  @PostMapping("/generate")
  @ResponseBody
  public Map<String, Object> generateEmr(
      @RequestParam("audioFile") MultipartFile audioFile,
      @RequestParam(value = "consultationId", required = false) Long consultationId,
      @RequestParam(value = "testResults", required = false) String testResults,
      @RequestParam(value = "prescription", required = false) String prescription,
      @RequestParam(value = "language", defaultValue = "ko") String language,
      @RequestParam("patientId") Long patientId,
      HttpSession session) {

    Map<String, Object> response = new HashMap<>();

    try {
//      Object adviser = session.getAttribute("adviser");
//      if (adviser == null) {
//        response.put("success", false);
//        response.put("message", "상담사 로그인이 필요합니다.");
//        return response;
//      }

      // EMR 생성 (DB 저장 안 함)
      Emr emr = emrService.generateEmrFromAudio(
          consultationId, patientId, audioFile, testResults, prescription, language);

      session.setAttribute("tempEmr", emr);

      response.put("success", true);
      response.put("sttText", emr.getPatientStatement());
      response.put("aiDraft", emr.getFinalRecord());
      response.put("testResults", emr.getTestResults());
      response.put("prescription", emr.getPrescriptionDetails());

    } catch (Exception e) {
      log.error("EMR 생성 오류", e);
      response.put("success", false);
      response.put("message", "EMR 생성 중 오류가 발생했습니다: " + e.getMessage());
    }

    return response;
  }

  /**
   * EMR 최종 저장 (수정된 내용 포함, DB insert)
   */
  @PostMapping("/save")
  @ResponseBody
  public Map<String, Object> saveEmr(
      @RequestParam("finalRecord") String finalRecord,
      HttpSession session) {
    Map<String, Object> response = new HashMap<>();
    try {
//      Object adviser = session.getAttribute("adviser");
//      if (adviser == null) {
//        response.put("success", false);
//        response.put("message", "상담사 로그인이 필요합니다.");
//        return response;
//      }

      // 세션에서 임시 EMR 가져오기
      Emr tempEmr = (Emr) session.getAttribute("tempEmr");
      Long consultationId = (tempEmr != null) ? tempEmr.getConsultationId() : null;
      Long patientId = tempEmr.getPatientId();

      // AI로 텍스트 분배 후 저장
      emrService.saveEmrWithAIAutoParsing(consultationId, patientId, finalRecord);

      session.removeAttribute("tempEmr");
      response.put("success", true);
      response.put("message", "EMR이 분배 저장되었습니다.");
    } catch (Exception e) {
      response.put("success", false);
      response.put("message", "저장 중 오류: " + e.getMessage());
    }
    return response;
  }

  /**
   * Vector DB에 EMR 템플릿/규칙 업로드
   */
  @PostMapping("/upload-template")
  @ResponseBody
  public Map<String, Object> uploadEmrTemplate(
      @RequestParam("templateFile") MultipartFile templateFile,
      HttpSession session) {

    Map<String, Object> response = new HashMap<>();

    try {
//      Object adviser = session.getAttribute("adviser");
//      if (adviser == null) {
//        response.put("success", false);
//        response.put("message", "상담사 로그인이 필요합니다.");
//        return response;
//      }

      String result = etlService.etlFromFile("emr_template", templateFile);

      response.put("success", true);
      response.put("message", result);

    } catch (Exception e) {
      log.error("템플릿 업로드 오류", e);
      response.put("success", false);
      response.put("message", "업로드 중 오류가 발생했습니다: " + e.getMessage());
    }

    return response;
  }

}