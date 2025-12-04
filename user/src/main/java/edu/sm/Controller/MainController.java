package edu.sm.Controller;

import edu.sm.app.dto.DiseaseStatsRequest;
import edu.sm.app.dto.DiseaseSimpleStatsItem;
import edu.sm.app.dto.NewsDto;
import edu.sm.app.service.DiseaseSimpleStatsService;
import edu.sm.app.service.NaverSearchService;
import edu.sm.app.springai.service.AiService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequiredArgsConstructor
@Slf4j
public class MainController {


    private final NaverSearchService naverSearchService;
    private final AiService aiService;
    private final DiseaseSimpleStatsService diseaseSimpleStatsService;

    @Value("${app.url.websocketurl}")
    String webSocketUrl;

    @RequestMapping("/")

    public String main(Model model) {
        return "index";

    }

    @RequestMapping("/consul")
    public String consul(Model model) {
        model.addAttribute("websocketurl", webSocketUrl);
        model.addAttribute("center", "consul");
        return "index";
    }


    @GetMapping("/statview")
    public String getStatview(DiseaseStatsRequest request, Model model) {

        // 1. 초기화 및 center 설정
        model.addAttribute("center", "statview");

        // 2. 필수 요청 파라미터 유효성 검사
        if (request.getYear() == null || request.getSickCd() == null) {
            return "index";
        }

        try {
            // 3. 통계 데이터 처리
            List<DiseaseSimpleStatsItem> items = diseaseSimpleStatsService.getSimpleStats(request);

            model.addAttribute("statsList", items);
            model.addAttribute("year", request.getYear());
            model.addAttribute("sickCd", request.getSickCd());
            model.addAttribute("sickType", request.getSickType());
            model.addAttribute("medTp", request.getMedTp());

            // 4. AI 뉴스 큐레이션 로직 (수정됨)
            // 상병코드(E11) 대신 한글 병명(2형 당뇨병)을 써야 뉴스가 잘 나옵니다.
            if (request.getSickCd() != null && !request.getSickCd().isEmpty()) {
                try {
                    // (1) 검색 키워드 결정 (우선순위: 통계 결과의 한글명 > 입력된 상병코드)
                    String diseaseName = request.getSickCd(); // 기본값: 코드 (예: E11)

                    if (items != null && !items.isEmpty()) {
                        // 통계 데이터 첫 번째 항목에서 한글 병명을 가져옴 (예: "2형 당뇨병")
                        String statsSickNm = items.get(0).getSickNm();
                        if (statsSickNm != null && !statsSickNm.isEmpty()) {
                            diseaseName = statsSickNm;
                        }
                    }

                    String searchKeyword = diseaseName + " 최신 치료 관리 예방";
                    log.info("🔍 네이버 검색 시작: 키워드={}", searchKeyword);

                    // (2) 네이버 검색
                    String rawNewsJson = naverSearchService.searchNews(searchKeyword);

                    // (3) AI 큐레이션 (AI에게도 한글 병명을 알려줘야 정확도가 올라감)
                    List<NewsDto> curatedNews = aiService.curateNews(rawNewsJson, diseaseName);

                    log.info("🤖 AI 요약 결과 개수: {}건", curatedNews != null ? curatedNews.size() : 0);

                    if (curatedNews != null && !curatedNews.isEmpty()) {
                        model.addAttribute("newsList", curatedNews);
                    }

                } catch (Exception e) {
                    log.error("🚨 AI 뉴스 로딩 에러: {}", e.getMessage());
                    // 화면에 에러 메시지 표시
                    String errorMsg = "AI 서비스 연결 지연";
                    if (e.getMessage().contains("Quota")) errorMsg = "AI 사용량 초과";
                    model.addAttribute("aiErrorMessage", errorMsg);
                }
            }

            return "index";

        } catch (RuntimeException e) {
            String errorMessage = "통계 정보 조회 실패: " + e.getMessage();
            log.error("질병 통계 조회 중 오류 발생: {}", errorMessage, e);
            model.addAttribute("errorMessage", errorMessage);
            return "index";
        }
    }

    @GetMapping("/monitor")
    public String monitor(@RequestParam("patientId") Long patientId, Model model) {
        model.addAttribute("patientId", patientId);

        // [수정] 다른 페이지와 마찬가지로 index 레이아웃 안에 monitor를 끼워넣는 방식이어야 합니다.
        model.addAttribute("center", "iot/monitor");

        return "index";
    }
}