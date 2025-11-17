package edu.sm.controller;

import edu.sm.app.springai.service.AiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@RestController
@RequestMapping("/api")
@RequiredArgsConstructor
@Slf4j
@CrossOrigin(origins = "*") // CORS 설정 추가
public class AiChatController {

    private final AiService aiService;

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
}