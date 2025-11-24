package edu.sm.Controller;

import com.google.gson.Gson;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/map")
public class MapChatController {

    @Autowired
    private ChatClient chatClient;

    @PostMapping("/chat")
    public Map<String, Object> chat(@RequestBody Map<String, String> payload) {
        String userMessage = payload.get("message");

        // 1. 프론트엔드에서 보낸 언어 코드 확인 (없으면 ko)
        String langCode = payload.getOrDefault("language", "ko");

        // 2. 언어별 강력한 지시사항 생성
        String languageInstruction = switch (langCode) {
            case "en" -> "You MUST write the 'answer' value in ENGLISH.";
            case "jp" -> "You MUST write the 'answer' value in JAPANESE.";
            case "cn" -> "You MUST write the 'answer' value in CHINESE (Simplified).";
            default -> "You MUST write the 'answer' value in KOREAN.";
        };

        // 3. 프롬프트 (언어 규칙과 검색어 규칙 분리)
        String systemPrompt = """
            You are an AI Medical Map Assistant.
            Analyze the user's input and return a JSON object.
            
            [CRITICAL LANGUAGE RULES]
            1. %s (This is the most important rule for the 'answer' field).
            2. HOWEVER, the 'keyword' field MUST ALWAYS be in KOREAN for the Map API.
               (e.g., Even if the user asks in English, return '내과', '응급실' in the keyword field).
            
            [JSON Format]
            {
                "answer": "Response to the user (in the target language defined above)",
                "keyword": "Search keyword for Korean Map (e.g., '내과', '정형외과', '서울아산병원')",
                "action": "SEARCH" or "EMERGENCY" or "NONE"
            }

            [Search Logic]
            - "Headache" / "Cold" -> keyword: "내과"
            - "Bone" / "Joint" -> keyword: "정형외과"
            - "Emergency" -> keyword: "응급실", action: "EMERGENCY"
            - Just greeting -> action: "NONE"
            
            Output ONLY JSON. Do not include markdown.
            """.formatted(languageInstruction); // %s 자리에 위에서 정한 언어 규칙이 들어갑니다.

        try {
            String aiResponse = chatClient.prompt()
                    .system(systemPrompt)
                    .user(userMessage)
                    .call()
                    .content();

            System.out.println("🤖 AI 응답 (" + langCode + "): " + aiResponse);

            String cleanJson = aiResponse.replace("```json", "").replace("```", "").trim();
            return new Gson().fromJson(cleanJson, Map.class);

        } catch (Exception e) {
            e.printStackTrace();
            Map<String, Object> errorResponse = new HashMap<>();
            // 에러 메시지는 어쩔 수 없이 고정 (또는 여기서도 switch문 가능)
            errorResponse.put("answer", "Sorry, I encountered an error. (오류가 발생했습니다)");
            errorResponse.put("action", "NONE");
            return errorResponse;
        }
    }
}