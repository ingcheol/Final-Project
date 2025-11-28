package edu.sm.controller;

import edu.sm.app.springai.service.AiServiceByChatClient;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*")
public class AiChatController {

    private final AiServiceByChatClient aiService;

    @PostMapping("/chat")
    public Map<String, Object> chat(@RequestBody Map<String, String> request) {
        String question = request.get("question");
        String language = request.getOrDefault("language", "ko");
        
        log.info("=== 챗봇 질문 수신 ===");
        log.info("질문: {}", question);
        log.info("언어: {}", language);

        try {
            String rawAnswer = aiService.generateText(question, language);
            log.info("=== 챗봇 응답 생성 완료 ===");
            log.info("응답: {}", rawAnswer);

            String answer = "";
            String page = null;
            
            String[] lines = rawAnswer.split("\n");
            for (String line : lines) {
                if (line.startsWith("ANSWER:")) {
                    answer = line.substring(7).trim();
                } else if (line.startsWith("PAGE:")) {
                    String pagePath = line.substring(5).trim();
                    if (!pagePath.equals("NONE")) {
                        page = pagePath;
                    }
                }
            }
            
            if (answer.isEmpty()) {
                answer = rawAnswer;
            }

            return Map.of(
                    "answer", answer,
                    "page", page != null ? page : "",
                    "status", "success"
            );
        } catch (Exception e) {
            log.error("=== 챗봇 오류 발생 ===", e);
            log.error("오류 메시지: {}", e.getMessage());

            return Map.of(
                    "answer", "죄송합니다. 일시적인 오류가 발생했습니다. 다시 시도해주세요.",
                    "page", "",
                    "status", "error",
                    "errorMessage", e.getMessage()
            );
        }
    }

    @GetMapping("/chat/test")
    public Map<String, String> testChat() {
        log.info("=== 챗봇 테스트 호출 ===");
        return Map.of(
                "message", "챗봇 API가 정상 작동 중입니다.",
                "status", "success"
        );
    }
}
