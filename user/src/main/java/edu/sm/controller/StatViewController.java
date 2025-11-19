//package edu.sm.controller;
//
//import edu.sm.app.dto.DiseaseStatsRequest;
//import edu.sm.app.dto.DiseaseSimpleStatsItem;
//import edu.sm.app.service.DiseaseSimpleStatsService;
//
//import org.springframework.beans.factory.annotation.Autowired;
//import org.springframework.stereotype.Controller;
//import org.springframework.ui.Model;
//import org.springframework.web.bind.annotation.GetMapping;
//import org.springframework.web.bind.annotation.RequestMapping;
//
//import java.util.Collections;
//import java.util.List;
//import org.slf4j.Logger;
//import org.slf4j.LoggerFactory;
//
//@Controller
//@RequestMapping("/") // 루트 경로에서 /statview를 처리
//public class StatViewController {
//
//    private static final Logger log = LoggerFactory.getLogger(StatViewController.class);
//    private final DiseaseSimpleStatsService diseaseSimpleStatsService;
//
//    @Autowired
//    public StatViewController(DiseaseSimpleStatsService diseaseSimpleStatsService) {
//        this.diseaseSimpleStatsService = diseaseSimpleStatsService;
//    }
//
//    /**
//     * URL: /statview
//     * View 반환: index (레이아웃 구조 사용)
//     */
//    @GetMapping("/statview")
//    public String getStatview(DiseaseStatsRequest request, Model model) {
//
//        // 1. 초기화 및 center 설정
//        model.addAttribute("center", "statview"); // index.jsp가 statview.jsp를 로드하게 함
//
//        // 2. 필수 요청 파라미터 유효성 검사
//        if (request.getYear() == null || request.getSickCd() == null) {
//            log.warn("필수 파라미터 누락: year 또는 sickCd");
//            model.addAttribute("errorMessage", "조회에 필요한 년도와 상병코드를 입력하세요.");
//            return "index";
//        }
//
//        try {
//            // 3. Service 호출 및 데이터 처리 (XML 파싱)
//            List<DiseaseSimpleStatsItem> items = diseaseSimpleStatsService.getSimpleStats(request);
//
//            // 4. 데이터를 Model에 담아 JSP로 전달
//            model.addAttribute("statsList", items);
//            model.addAttribute("year", request.getYear());
//            model.addAttribute("sickCd", request.getSickCd());
//            model.addAttribute("sickType", request.getSickType());
//            model.addAttribute("medTp", request.getMedTp());
//
//            return "index";
//
//        } catch (RuntimeException e) {
//            String errorMessage = "통계 정보 조회 실패: " + e.getMessage();
//            log.error("질병 통계 조회 중 오류 발생: {}", errorMessage, e);
//
//            model.addAttribute("errorMessage", errorMessage);
//
//            return "index";
//        }
//    }
//}