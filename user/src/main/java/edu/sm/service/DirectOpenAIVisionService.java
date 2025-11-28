package edu.sm.service;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.HttpEntity;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

import java.util.List;

@Service
public class DirectOpenAIVisionService {

    @Value("${spring.ai.openai.api-key}")
    private String apiKey;

    private static final String OPENAI_API_URL = "https://api.openai.com/v1/chat/completions";

    /**
     * 이미지 기반 증상 분석 (언어 파라미터 추가)
     */
    public String analyzeImages(String symptomText, List<String> base64Images, String language) {
        try {
            System.out.println("📤 OpenAI Vision API 호출 시작 (" + language + ")");

            // ... (기존 RestTemplate, Header 설정 코드 동일) ...
            RestTemplate restTemplate = new RestTemplate();
            HttpHeaders headers = new HttpHeaders();
            headers.setContentType(MediaType.APPLICATION_JSON);
            headers.setBearerAuth(apiKey);

            JSONObject requestBody = new JSONObject();
            requestBody.put("model", "gpt-4o");
            requestBody.put("max_tokens", 2000);
            requestBody.put("temperature", 0.1);

            JSONArray messages = new JSONArray();
            JSONObject userMessage = new JSONObject();
            userMessage.put("role", "user");

            JSONArray contentArray = new JSONArray();

            // 6-1. 텍스트 프롬프트 (언어 전달)
            JSONObject textContent = new JSONObject();
            textContent.put("type", "text");
            // buildPrompt에 language 전달
            textContent.put("text", buildPrompt(symptomText, base64Images.size(), language));
            contentArray.put(textContent);

            // ... (이미지 추가 루프 코드 동일) ...
            for (int i = 0; i < base64Images.size(); i++) {
                String base64Image = base64Images.get(i);
                String imageUrl = base64Image.startsWith("data:image") ? base64Image : "data:image/jpeg;base64," + base64Image;

                JSONObject imageContent = new JSONObject();
                imageContent.put("type", "image_url");
                JSONObject imageUrlObject = new JSONObject();
                imageUrlObject.put("url", imageUrl);
                imageContent.put("image_url", imageUrlObject);
                contentArray.put(imageContent);
            }

            userMessage.put("content", contentArray);
            messages.put(userMessage);
            requestBody.put("messages", messages);

            HttpEntity<String> entity = new HttpEntity<>(requestBody.toString(), headers);
            ResponseEntity<String> response = restTemplate.postForEntity(OPENAI_API_URL, entity, String.class);

            JSONObject responseBody = new JSONObject(response.getBody());
            return responseBody.getJSONArray("choices")
                    .getJSONObject(0)
                    .getJSONObject("message")
                    .getString("content");

        } catch (Exception e) {
            e.printStackTrace();
            throw new RuntimeException("이미지 분석 중 오류 발생", e);
        }
    }

    /**
     * 언어별 프롬프트 생성
     */
    private String buildPrompt(String symptomText, int imageCount, String language) {

        // 언어 설정
        String langInstruction = switch (language) {
            case "en" -> "Please write the response in English.";
            case "ja" -> "日本語で答えてください。";
            case "zh" -> "请用中文回答。";
            default -> "한국어로 답변해 주세요.";
        };

        // 포맷 용어 설정 (관찰된 외관 등)
        String formatInstruction = switch (language) {
            case "en" -> """
                    **Format:**
                    Observed Appearance: [Color, Texture, Size, Location]
                    Features: [Notable features]
                    Summary: [One sentence summary]
                    """;
            default -> """
                    **응답 형식:**
                    관찰된 외관: [색상, 질감, 크기, 위치를 구체적으로]
                    특징: [눈에 띄는 특징]
                    요약: [한 문장으로 간단히]
                    """;
        };

        return String.format("""
                당신은 객관적인 관찰 도우미입니다. %d장의 사진을 보고 시각적으로 관찰되는 내용만 설명해주세요.
                
                사용자 설명: %s
                
                **중요: %s**
                
                1. 색상 / 2. 크기와 위치 / 3. 형태
                
                %s
                
                객관적이고 사실적으로만 서술하세요. 의학적 진단이나 치료 조언은 하지 마세요.
                """, imageCount, symptomText, langInstruction, formatInstruction);
    }
}