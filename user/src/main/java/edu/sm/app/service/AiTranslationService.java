package edu.sm.app.service;

import org.springframework.ai.chat.client.ChatClient;
import org.springframework.ai.chat.prompt.Prompt;
import org.springframework.ai.chat.prompt.PromptTemplate;
import org.springframework.stereotype.Service;
import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.util.List;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@Service
public class AiTranslationService {

    private final ChatClient chatClient;
    private final ObjectMapper objectMapper;

    // 서버 메모리 캐시
    private final Map<String, List<String>> responseCache = new ConcurrentHashMap<>();

    public AiTranslationService(ChatClient.Builder chatClientBuilder, ObjectMapper objectMapper) {
        this.chatClient = chatClientBuilder.build();
        this.objectMapper = objectMapper;
    }

    public List<String> translateBatch(List<String> texts, String targetLang) {
        // 1. 캐시 키 생성
        String cacheKey = targetLang + "::" + texts.hashCode();

        // 2. 캐시 확인 (있으면 즉시 반환)
        if (responseCache.containsKey(cacheKey)) {
            return responseCache.get(cacheKey);
        }

        // 3. 프롬프트 강화 (JSON 형식 강제 및 이스케이프 처리 강조)
        String message = """
                You are a professional translator.
                Translate the provided JSON array of strings into {targetLang}.
                
                CRITICAL RULES:
                1. Return ONLY a valid JSON array of strings. NO Markdown (```json), NO explanations.
                2. Maintain the exact length and order of the array.
                3. Properly escape all double quotes within the strings.
                4. If a term shouldn't be translated (like brand names), keep it as is.
                
                Input: {jsonTexts}
                """;

        try {
            String jsonTexts = objectMapper.writeValueAsString(texts);
            PromptTemplate template = new PromptTemplate(message);

            // 옵션 없이 기본 설정 사용
            Prompt prompt = template.create(Map.of("targetLang", targetLang, "jsonTexts", jsonTexts));

            // 4. AI 호출
            String responseContent = chatClient.prompt(prompt).call().content();

            // 5. [핵심] 응답 정리 (앞뒤 군더더기 완벽 제거 로직)
            String cleanJson = extractJsonArray(responseContent);

            // 6. JSON 파싱
            List<String> translated = objectMapper.readValue(cleanJson, new TypeReference<List<String>>() {});

            // 7. [검증] 입력 개수와 출력 개수가 다르면 오류로 간주 (화면 밀림 방지)
            if (translated.size() != texts.size()) {
                System.err.println("⚠️ 번역 개수 불일치! (요청: " + texts.size() + " vs 응답: " + translated.size() + ")");
                return texts; // 원본 반환
            }

            // 8. 캐시 저장
            responseCache.put(cacheKey, translated);

            return translated;

        } catch (Exception e) {
            e.printStackTrace(); // 로그 확인용
            System.err.println("❌ 번역 실패 (" + targetLang + "): 원본 텍스트 반환");
            return texts; // 에러 시 원본 반환
        }
    }

    /**
     * AI 응답에서 순수 JSON Array 부분만 발라내는 함수
     * "Here is the translation: ```json [ ... ] ```" 같은 형태에서 [ ... ] 만 추출
     */
    private String extractJsonArray(String content) {
        if (content == null || content.isBlank()) return "[]";

        int startIndex = content.indexOf("[");
        int endIndex = content.lastIndexOf("]");

        if (startIndex == -1 || endIndex == -1 || startIndex > endIndex) {
            // 대괄호를 못 찾았거나 순서가 꼬인 경우 (매우 드묾)
            // 최대한 정제 시도
            return content.replace("```json", "").replace("```", "").trim();
        }

        return content.substring(startIndex, endIndex + 1);
    }
}