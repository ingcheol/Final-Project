package edu.sm.controller;

import com.google.gson.Gson;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.net.URI;
import java.net.URLEncoder;
import java.util.HashMap;
import java.util.Map;

@RestController
@RequestMapping("/map")
public class MapChatController {

    @Autowired
    private ChatClient chatClient;

    // 공공데이터 포털 인증키 (Decoding Key)
    private static final String SERVICE_KEY = "PPVzwqp/YiiOp0ShY6gY4Vkm0b/PaPg1bEJgcEVMBYbMYAQ2lVC/BRbGmi4/XTeID5pJBs9ShXOQ+P1Ve/FTbw==";

    /**
     * AI 챗봇 기능: 사용자의 증상/질문을 분석하여 검색 키워드와 행동(Action)을 JSON으로 반환
     */
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

        // 3. 프롬프트
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
            """.formatted(languageInstruction);

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
            errorResponse.put("answer", "Sorry, I encountered an error. (오류가 발생했습니다)");
            errorResponse.put("action", "NONE");
            return errorResponse;
        }
    }

    /**
     * 실시간 응급실 병상 정보 조회 (공공데이터 포털 API 프록시)
     */
    @GetMapping(value = "/api/er-realtime-info", produces = "application/json; charset=UTF-8")
    @ResponseBody
    public String getErRealtimeInfo(@RequestParam("stage1") String stage1,
                                    @RequestParam(value = "stage2", required = false) String stage2) { // 👈 required = false 추가
        System.out.println("🚑 응급실 데이터 요청: " + stage1 + " " + (stage2 != null ? stage2 : "전체"));
        try {
            // 1. API URL 설정
            StringBuilder urlBuilder = new StringBuilder("http://apis.data.go.kr/B552657/ErmctInfoInqireService/getEmrrmRltmUsefulSckbdInfoInqire");

            // 2. 파라미터 추가
            urlBuilder.append("?" + URLEncoder.encode("serviceKey", "UTF-8") + "=" + URLEncoder.encode(SERVICE_KEY, "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("STAGE1", "UTF-8") + "=" + URLEncoder.encode(stage1, "UTF-8"));

            // 👈 stage2가 있을 때만 파라미터 추가
            if (stage2 != null && !stage2.trim().isEmpty()) {
                urlBuilder.append("&" + URLEncoder.encode("STAGE2", "UTF-8") + "=" + URLEncoder.encode(stage2, "UTF-8"));
            }

            urlBuilder.append("&" + URLEncoder.encode("pageNo", "UTF-8") + "=" + URLEncoder.encode("1", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("numOfRows", "UTF-8") + "=" + URLEncoder.encode("100", "UTF-8"));
            urlBuilder.append("&" + URLEncoder.encode("_type", "UTF-8") + "=" + URLEncoder.encode("json", "UTF-8"));

            // 3. API 호출
            RestTemplate restTemplate = new RestTemplate();
            URI uri = new URI(urlBuilder.toString());

            String response = restTemplate.getForObject(uri, String.class);
            return response;

        } catch (Exception e) {
            e.printStackTrace();
            return "{\"error\":\"" + e.getMessage() + "\"}";
        }
    }

    /**
     * 🆕 지역 목록 조회 API (시도/시군구)
     */
    @GetMapping("/api/regions")
    @ResponseBody
    public Map<String, Object> getRegions() {
        Map<String, Object> result = new HashMap<>();

        // 시도 목록
        String[] stage1List = {
                "서울특별시", "부산광역시", "대구광역시", "인천광역시",
                "광주광역시", "대전광역시", "울산광역시", "세종특별자치시",
                "경기도", "강원특별자치도", "충청북도", "충청남도",
                "전북특별자치도", "전라남도", "경상북도", "경상남도", "제주특별자치도"
        };

        // 주요 시군구 (서울, 경기 중심)
        Map<String, String[]> stage2Map = new HashMap<>();
        stage2Map.put("서울특별시", new String[]{
                "강남구", "강동구", "강북구", "강서구", "관악구", "광진구",
                "구로구", "금천구", "노원구", "도봉구", "동대문구", "동작구",
                "마포구", "서대문구", "서초구", "성동구", "성북구", "송파구",
                "양천구", "영등포구", "용산구", "은평구", "종로구", "중구", "중랑구"
        });
        stage2Map.put("경기도", new String[]{
                "수원시", "성남시", "고양시", "용인시", "부천시", "안산시",
                "안양시", "남양주시", "화성시", "평택시", "의정부시", "시흥시",
                "파주시", "김포시", "광명시", "광주시", "군포시", "오산시",
                "이천시", "양주시", "안성시", "구리시", "포천시", "의왕시", "하남시"
        });

        result.put("stage1", stage1List);
        result.put("stage2", stage2Map);

        return result;
    }
}