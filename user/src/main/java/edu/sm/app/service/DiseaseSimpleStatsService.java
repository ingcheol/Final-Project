package edu.sm.app.service;

import edu.sm.app.dto.DiseaseStatsRequest;
import edu.sm.app.dto.DiseaseSimpleStatsItem;

import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Service;
import org.springframework.web.reactive.function.client.WebClient;
import org.springframework.web.util.UriComponentsBuilder;

import javax.xml.parsers.DocumentBuilder;
import javax.xml.parsers.DocumentBuilderFactory;
import org.w3c.dom.Document;
import org.w3c.dom.Element;
import org.w3c.dom.NodeList;
import org.xml.sax.InputSource;

import java.io.StringReader;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.Collections;
import java.util.List;
import java.util.Optional;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

@Service
public class DiseaseSimpleStatsService {

    private static final Logger log = LoggerFactory.getLogger(DiseaseSimpleStatsService.class);

    private final WebClient webClient;
    private final String diseaseApiKey;
    private final String diseaseInfoEndpoint;

    public DiseaseSimpleStatsService(
            WebClient.Builder webClientBuilder,
            @Value("${app.key.disease-api-key}") String diseaseApiKey,
            @Value("${app.url.disease-info-endpoint}") String diseaseInfoEndpoint) {

        this.diseaseApiKey = diseaseApiKey;
        this.diseaseInfoEndpoint = diseaseInfoEndpoint;
        this.webClient = webClientBuilder.build(); // baseUrl 제거

        log.info("초기화 완료 - Endpoint: {}", diseaseInfoEndpoint);
    }

    public List<DiseaseSimpleStatsItem> getSimpleStats(DiseaseStatsRequest request) {

        // 1. API Key URL 인코딩 (브라우저와 동일하게)
        String encodedServiceKey;
        try {
            encodedServiceKey = URLEncoder.encode(this.diseaseApiKey, StandardCharsets.UTF_8.toString());
        } catch (Exception e) {
            throw new RuntimeException("Service Key 인코딩 실패", e);
        }

        // 2. 전체 URL을 수동으로 조합 (WebClient의 자동 인코딩 방지)
        StringBuilder uriBuilder = new StringBuilder(diseaseInfoEndpoint);
        uriBuilder.append("?serviceKey=").append(encodedServiceKey);
        uriBuilder.append("&year=").append(request.getYear());
        uriBuilder.append("&sickCd=").append(request.getSickCd());
        uriBuilder.append("&numOfRows=").append(Optional.ofNullable(request.getNumOfRows()).orElse(10));
        uriBuilder.append("&pageNo=").append(Optional.ofNullable(request.getPageNo()).orElse(1));
        uriBuilder.append("&sickType=").append(Optional.ofNullable(request.getSickType()).orElse("1"));
        uriBuilder.append("&medTp=").append(Optional.ofNullable(request.getMedTp()).orElse("1"));

        String uri = uriBuilder.toString();

        log.info("API 요청 URL: {}", uri.replaceAll("serviceKey=[^&]*", "serviceKey=***")); // Key 마스킹

        // 3. WebClient 호출 - URI.create()로 인코딩된 URL 그대로 사용
        String xmlString;
        try {
            xmlString = webClient.get()
                    .uri(java.net.URI.create(uri)) // 중요: URI.create() 사용
                    .retrieve()
                    .onStatus(
                            status -> status.is4xxClientError() || status.is5xxServerError(),
                            response -> response.bodyToMono(String.class)
                                    .map(body -> new RuntimeException("API 오류: " + response.statusCode() + " - " + body))
                    )
                    .bodyToMono(String.class)
                    .block();
        } catch (Exception e) {
            log.error("API 호출 실패", e);
            throw new RuntimeException("API 호출 실패: " + e.getMessage(), e);
        }

        if (xmlString == null || xmlString.isEmpty()) {
            log.warn("API 응답이 비어있습니다");
            return Collections.emptyList();
        }

        log.debug("API 응답 (첫 200자): {}", xmlString.substring(0, Math.min(200, xmlString.length())));

        // 4. XML 파싱
        return parseXmlResponse(xmlString);
    }

    private List<DiseaseSimpleStatsItem> parseXmlResponse(String xmlString) {
        List<DiseaseSimpleStatsItem> itemList = new ArrayList<>();

        try {
            DocumentBuilderFactory factory = DocumentBuilderFactory.newInstance();
            DocumentBuilder builder = factory.newDocumentBuilder();

            InputSource is = new InputSource(new StringReader(xmlString));
            Document doc = builder.parse(is);
            doc.getDocumentElement().normalize();

            // 결과 코드 확인
            String resultCode = getTextContent(doc, "resultCode", "99");

            if (!"00".equals(resultCode)) {
                String resultMsg = getTextContent(doc, "resultMsg", "알 수 없는 API 오류");
                log.error("API 오류 - 코드: {}, 메시지: {}", resultCode, resultMsg);
                throw new RuntimeException("API 호출 실패. 코드: " + resultCode + ", 메시지: " + resultMsg);
            }

            // item 노드 추출
            NodeList itemNodes = doc.getElementsByTagName("item");
            log.info("파싱된 item 개수: {}", itemNodes.getLength());

            for (int i = 0; i < itemNodes.getLength(); i++) {
                Element itemElement = (Element) itemNodes.item(i);

                String sickCd = getElementText(itemElement, "sickCd");
                String sickNm = getElementText(itemElement, "sickNm");
                String sex = getElementText(itemElement, "sex");
                String age = getElementText(itemElement, "age");
                String ptntCntStr = getElementText(itemElement, "ptntCnt");

                Integer patientCount = parseInteger(ptntCntStr, 0);

                DiseaseSimpleStatsItem item = new DiseaseSimpleStatsItem(
                        sickCd, sickNm, sex, age, patientCount
                );
                itemList.add(item);
            }

            return itemList;

        } catch (RuntimeException e) {
            throw e;
        } catch (Exception e) {
            log.error("XML 파싱 오류", e);
            throw new RuntimeException("XML 데이터 파싱 중 오류 발생: " + e.getMessage(), e);
        }
    }

    // Helper 메서드들
    private String getTextContent(Document doc, String tagName, String defaultValue) {
        NodeList nodeList = doc.getElementsByTagName(tagName);
        if (nodeList.getLength() > 0) {
            return nodeList.item(0).getTextContent();
        }
        return defaultValue;
    }

    private String getElementText(Element element, String tagName) {
        NodeList nodes = element.getElementsByTagName(tagName);
        if (nodes.getLength() > 0 && nodes.item(0).getFirstChild() != null) {
            return nodes.item(0).getTextContent();
        }
        return "";
    }

    private Integer parseInteger(String value, Integer defaultValue) {
        try {
            return Integer.parseInt(value);
        } catch (NumberFormatException e) {
            return defaultValue;
        }
    }
}