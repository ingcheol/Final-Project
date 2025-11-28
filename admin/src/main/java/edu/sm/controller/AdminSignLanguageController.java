package edu.sm.controller;

import edu.sm.app.dto.SignLanguageMessage;
import lombok.extern.slf4j.Slf4j;
import org.springframework.http.MediaType;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.servlet.mvc.method.annotation.SseEmitter;

import java.io.IOException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Controller
@RequestMapping("/admin/signlanguage")
@Slf4j
public class AdminSignLanguageController {

  private final Map<String, SseEmitter> adminEmitters = new ConcurrentHashMap<>();

  @GetMapping("")
  public String adminPage(Model model) {
    model.addAttribute("center", "signlanguage");
    return "index";
  }

  @GetMapping(value = "/subscribe", produces = MediaType.TEXT_EVENT_STREAM_VALUE)
  @ResponseBody
  public SseEmitter subscribe(@RequestParam String adminId) {
    SseEmitter emitter = new SseEmitter(Long.MAX_VALUE);
    adminEmitters.put(adminId, emitter);

    log.info("Admin SSE 연결: {}", adminId);

    emitter.onCompletion(() -> adminEmitters.remove(adminId));
    emitter.onError(ex -> adminEmitters.remove(adminId));
    emitter.onTimeout(() -> adminEmitters.remove(adminId));

    try {
      emitter.send(SseEmitter.event().name("connect").data("연결 성공"));
    } catch (IOException e) {
      log.error("초기 메시지 전송 실패", e);
    }

    return emitter;
  }

  @PostMapping("/receive")
  @ResponseBody
  public String receiveTranslation(@RequestBody SignLanguageMessage message) {
    log.info("번역 결과 수신: {} - {}", message.getPatientName(), message.getTranslatedText());

    if (message.getTranslatedText() == null ||
        message.getTranslatedText().trim().isEmpty() ||
        "인식 불가".equals(message.getTranslatedText().trim())) {
      log.info("유효하지 않은 번역이므로 Admin 화면에 전송하지 않음: {}", message.getTranslatedText());
      return "SKIPPED";
    }

    adminEmitters.values().forEach(emitter -> {
      try {
        emitter.send(SseEmitter.event()
            .name("translation")
            .data(message));
      } catch (IOException e) {
        log.error("Admin에게 메시지 전송 실패", e);
      }
    });

    return "OK";
  }
}
