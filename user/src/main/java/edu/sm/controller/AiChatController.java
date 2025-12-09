package edu.sm.controller;

import edu.sm.app.springai.service.AiService;
import edu.sm.app.springai.service.AiSttService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.Map;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*") // CORS 설정 추가
public class AiChatController {

  private final AiService aiService;
  private final AiSttService sttService;

  @PostMapping("/chat")
  public Map<String, String> chat(@RequestBody Map<String, String> request) {
    String question = request.get("question");
    log.info("=== 챗봇 질문 수신 ===");
    log.info("질문: {}", question);

    try {
      String answer = aiService.generateText(question);
      log.info("=== 챗봇 응답 생성 완료 ===");
      log.info("응답: {}", answer);

      return Map.of(
          "answer", answer,
          "status", "success"
      );
    } catch (Exception e) {
      log.error("=== 챗봇 오류 발생 ===", e);
      log.error("오류 메시지: {}", e.getMessage());

      return Map.of(
          "answer", "죄송합니다. 일시적인 오류가 발생했습니다. 다시 시도해주세요.",
          "status", "error",
          "errorMessage", e.getMessage()
      );
    }
  }

  // 테스트용 GET 엔드포인트 추가
  @GetMapping("/chat/test")
  public Map<String, String> testChat() {
    log.info("=== 챗봇 테스트 호출 ===");
    return Map.of(
        "message", "챗봇 API가 정상 작동 중입니다.",
        "status", "success"
    );
  }

  // 번역 요청
  @PostMapping("/chat-support/translate")
  public Map<String, String> translateMessage(@RequestBody Map<String, String> payload) {
    String text = payload.get("text");
    String targetLang = payload.get("targetLang");

    log.info("번역 요청: {} -> {}", text, targetLang);

    // AiService에 translate 메서드가 추가되어 있어야 합니다!
    String translatedText = aiService.translate(text, targetLang);

    return Map.of("translatedText", translatedText);
  }

  // 읽어주기 (TTS)
  @PostMapping("/chat-support/tts")
  public Map<String, String> textToSpeech(@RequestBody Map<String, String> payload) {
    String text = payload.get("text");
    log.info("TTS 요청: {}", text);
    return sttService.tts2(text);
  }

  // 말하기 (STT)
  @PostMapping("/chat-support/stt")
  public Map<String, String> speechToText(@RequestParam("audio") MultipartFile audioFile) {
    log.info("STT 요청: 파일 크기 {}", audioFile.getSize());
    try {
      String text = sttService.stt(audioFile);
      return Map.of("text", text, "status", "success");
    } catch (Exception e) {
      log.error("STT 변환 실패", e);
      return Map.of("text", "", "status", "error");
    }
  }
}