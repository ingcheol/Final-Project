package edu.sm.Controller;

import edu.sm.entity.MedicalDocument;
import edu.sm.service.MedicalDocumentService;
import edu.sm.service.PdfRagService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import jakarta.servlet.http.HttpSession;
import java.util.List;
import java.util.ArrayList;


@Controller
@RequestMapping("/dia")
public class DiagnosisController {

    @Autowired
    private MedicalDocumentService medicalDocumentService;

    @Autowired
    private PdfRagService pdfRagService;

    @GetMapping("/test")
    public String test(Model model) {
        List<MedicalDocument> documents = medicalDocumentService.getAllDocuments();
        model.addAttribute("documents", documents);

        System.out.println("=== 의료 문서 목록 ===");
        for(MedicalDocument doc : documents) {
            System.out.println(doc.getDocTitle());
        }

        return "dia/test";
    }

    // 1단계: 증상 입력 페이지
    @GetMapping("/dia1")
    public String dia1(Model model) {
        return "dia/dia1";
    }

    // 2단계: 설문조사 페이지 (POST - 증상 데이터 받기)
    @PostMapping("/dia2")
    public String dia2Post(@RequestParam String symptomText,
                           @RequestParam(required = false) MultipartFile[] symptomImages,
                           HttpSession session,
                           Model model) {

        System.out.println("=== 증상 입력 데이터 ===");
        System.out.println("증상: " + symptomText);

        session.setAttribute("symptomText", symptomText);

        if (symptomImages != null && symptomImages.length > 0) {
            System.out.println("업로드된 이미지 수: " + symptomImages.length);
        }

        model.addAttribute("symptomText", symptomText);

        return "dia/dia2";
    }

    @GetMapping("/dia2")
    public String dia2Get(HttpSession session, Model model) {
        String symptomText = (String) session.getAttribute("symptomText");

        if (symptomText == null || symptomText.isEmpty()) {
            return "redirect:/dia/dia1";
        }

        model.addAttribute("symptomText", symptomText);
        return "dia/dia2";
    }

    // 3단계: AI 분석 페이지 (POST - 설문 응답 받기)
    @PostMapping("/dia3")
    public String dia3Post(@RequestParam String answer0,
                           @RequestParam String answer1,
                           @RequestParam String answer2,
                           @RequestParam String answer3,
                           @RequestParam String answer4,
                           HttpSession session,
                           Model model) {

        System.out.println("=== 설문 응답 데이터 ===");
        System.out.println("답변 1: " + answer0);
        System.out.println("답변 2: " + answer1);
        System.out.println("답변 3: " + answer2);
        System.out.println("답변 4: " + answer3);
        System.out.println("답변 5: " + answer4);

        String[] surveyAnswers = {answer0, answer1, answer2, answer3, answer4};
        session.setAttribute("surveyAnswers", surveyAnswers);

        String symptomText = (String) session.getAttribute("symptomText");
        model.addAttribute("symptomText", symptomText);
        model.addAttribute("surveyAnswers", surveyAnswers);

        return "dia/dia3";
    }

    @GetMapping("/dia3")
    public String dia3Get(HttpSession session, Model model) {
        String symptomText = (String) session.getAttribute("symptomText");

        if (symptomText == null || symptomText.isEmpty()) {
            return "redirect:/dia/dia1";
        }

        String[] surveyAnswers = (String[]) session.getAttribute("surveyAnswers");

        model.addAttribute("symptomText", symptomText);
        model.addAttribute("surveyAnswers", surveyAnswers);
        return "dia/dia3";
    }

    // 4단계: 진단 결과 페이지 (POST - AI 분석 실행!)
    @PostMapping("/dia4")
    public String dia4Post(@RequestParam(required = false) Double latitude,
                           @RequestParam(required = false) Double longitude,
                           HttpSession session,
                           Model model) {

        System.out.println("=== AI 분석 시작 ===");
        if (latitude != null && longitude != null) {
            System.out.println("📍 현재 위치: " + latitude + ", " + longitude);
        }

        String symptomText = (String) session.getAttribute("symptomText");
        String[] surveyAnswers = (String[]) session.getAttribute("surveyAnswers");

        if (symptomText == null || symptomText.isEmpty()) {
            return "redirect:/dia/dia1";
        }

        try {
            // AI 분석
            String aiDiagnosis = pdfRagService.analyzeSymptoms(symptomText);
            String recommendedDepartment = extractDepartment(aiDiagnosis, symptomText);
            String urgency = extractUrgency(aiDiagnosis, symptomText);

            model.addAttribute("symptomText", symptomText);
            model.addAttribute("surveyAnswers", surveyAnswers);
            model.addAttribute("aiDiagnosis", aiDiagnosis);
            model.addAttribute("recommendedDepartment", recommendedDepartment);
            model.addAttribute("urgency", urgency);
            model.addAttribute("userLatitude", latitude);
            model.addAttribute("userLongitude", longitude);

        } catch (Exception e) {
            System.err.println("❌ AI 분석 실패: " + e.getMessage());
            e.printStackTrace();

            model.addAttribute("symptomText", symptomText);
            model.addAttribute("aiDiagnosis", "현재 AI 분석 서비스에 일시적인 문제가 발생했습니다.");
            model.addAttribute("recommendedDepartment", "내과");
            model.addAttribute("urgency", "가능한 빨리");
        }

        return "dia/dia4";
    }

    @GetMapping("/dia4")
    public String dia4Get(HttpSession session, Model model) {
        String symptomText = (String) session.getAttribute("symptomText");

        if (symptomText == null || symptomText.isEmpty()) {
            return "redirect:/dia/dia1";
        }

        String[] surveyAnswers = (String[]) session.getAttribute("surveyAnswers");

        model.addAttribute("symptomText", symptomText);
        model.addAttribute("surveyAnswers", surveyAnswers);
        return "dia/dia4";
    }

    @GetMapping("/reset")
    public String reset(HttpSession session) {
        session.removeAttribute("symptomText");
        session.removeAttribute("surveyAnswers");
        return "redirect:/dia/dia1";
    }

    // ========== 헬퍼 메서드 ==========

    /**
     * AI 분석 결과에서 추천 진료과 추출
     */
    private String extractDepartment(String aiDiagnosis, String symptomText) {
        String combined = (aiDiagnosis + " " + symptomText).toLowerCase();

        if (combined.contains("호흡기") || combined.contains("폐렴") || combined.contains("기침") || combined.contains("천식")) {
            return "호흡기내과";
        } else if (combined.contains("피부") || combined.contains("발진") || combined.contains("가려움")) {
            return "피부과";
        } else if (combined.contains("복통") || combined.contains("설사") || combined.contains("소화")) {
            return "소화기내과";
        } else if (combined.contains("감염") || combined.contains("발열") || combined.contains("열")) {
            return "감염내과";
        } else if (combined.contains("두통") || combined.contains("어지러움") || combined.contains("신경")) {
            return "신경과";
        } else if (combined.contains("관절") || combined.contains("근육통")) {
            return "정형외과";
        } else {
            return "일반내과";
        }
    }

    /**
     * AI 분석 결과에서 시급성 판단
     */
    private String extractUrgency(String aiDiagnosis, String symptomText) {
        String combined = (aiDiagnosis + " " + symptomText).toLowerCase();

        if (combined.contains("응급") || combined.contains("즉시") || combined.contains("위험") || combined.contains("심각")) {
            return "즉시 응급실 방문 권장";
        } else if (combined.contains("빠른") || combined.contains("조속") || combined.contains("가능한 빨리")) {
            return "24-48시간 내 방문 권장";
        } else if (combined.contains("경미") || combined.contains("가벼운") || combined.contains("일시적")) {
            return "증상 지속 시 1주일 내 방문";
        } else {
            return "2-3일 내 방문 권장";
        }
    }
}