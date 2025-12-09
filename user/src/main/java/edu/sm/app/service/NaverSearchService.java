package edu.sm.app.service;

import org.json.JSONArray;
import org.json.JSONObject;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.http.*;
import org.springframework.stereotype.Service;
import org.springframework.web.client.RestTemplate;

@Service
public class NaverSearchService {

    @Value("${naver.client.id}")
    private String clientId;

    @Value("${naver.client.secret}")
    private String clientSecret;

    @Value("${naver.url.search}")
    private String searchUrl;

    public String searchNews(String query) {
        RestTemplate restTemplate = new RestTemplate();

        // 1. 헤더 설정
        HttpHeaders headers = new HttpHeaders();
        headers.set("X-Naver-Client-Id", clientId);
        headers.set("X-Naver-Client-Secret", clientSecret);
        HttpEntity<String> entity = new HttpEntity<>(headers);

        // 2. 요청 URL 생성 (검색어 인코딩 필요할 수 있으나 RestTemplate이 처리)
        // display=15: AI가 거를 수 있도록 넉넉하게 15개 가져옴
        String url = searchUrl + "?query=" + query + "&display=15&sort=sim";

        try {
            // 3. API 호출
            ResponseEntity<String> response = restTemplate.exchange(
                    url, HttpMethod.GET, entity, String.class
            );

            // 4. 결과에서 'items' 배열만 추출해서 리턴 (불필요한 메타데이터 제거)
            JSONObject jsonResponse = new JSONObject(response.getBody());
            JSONArray items = jsonResponse.getJSONArray("items");
            return items.toString();

        } catch (Exception e) {
            e.printStackTrace();
            return "[]"; // 에러 시 빈 배열 반환
        }
    }
}