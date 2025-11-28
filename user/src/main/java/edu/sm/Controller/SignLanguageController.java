package edu.sm.controller;

import edu.sm.app.dto.SignLanguageMessage;
import edu.sm.app.service.SignLanguageService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/signlanguage")
@RequiredArgsConstructor
@Slf4j
public class SignLanguageController {

  private final SignLanguageService signLanguageService;
  private final RestTemplate restTemplate;

  @Value("${app.url.adminserver:https://127.0.0.1:8443}")
  private String adminServerUrl;

  @GetMapping("")
  public String patientPage(Model model, HttpSession session) {
    model.addAttribute("center", "signlanguage");
    return "index";
  }

  @PostMapping("/translate")
  @ResponseBody
  public Map<String, Object> translateSign(
      @RequestParam("videoFrame") MultipartFile frame,
      @RequestParam("signLanguage") String signLanguage,
      @RequestParam(value = "landmarksJson", required = false) String landmarksJson) {

    Map<String, Object> response = new HashMap<>();

    try {
      SignLanguageMessage message = signLanguageService.translateSignLanguage(
          frame, landmarksJson, signLanguage);

      // 필요하면 Admin 서버로 전송
      sendToAdminServer(message);

      response.put("status", "success");
      response.put("text", message.getTranslatedText());
      response.put("confidence", message.getConfidence());
      response.put("timestamp", message.getTimestamp());

    } catch (Exception e) {
      log.error("수어 번역 실패", e);
      response.put("status", "error");
      response.put("message", "번역 중 오류가 발생했습니다.");
    }

    return response;
  }

  private void sendToAdminServer(SignLanguageMessage message) {
    try {
      String url = adminServerUrl + "/admin/signlanguage/receive";

      HttpHeaders headers = new HttpHeaders();
      headers.setContentType(MediaType.APPLICATION_JSON);

      HttpEntity<SignLanguageMessage> request = new HttpEntity<>(message, headers);

      ResponseEntity<String> response =
          restTemplate.postForEntity(url, request, String.class);

      if (response.getStatusCode() == HttpStatus.OK) {
        log.info("Admin 서버로 번역 결과 전송 성공");
      }
    } catch (Exception e) {
      log.error("Admin 서버 전송 실패", e);
    }
  }
}
