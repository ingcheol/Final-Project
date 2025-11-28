package edu.sm.Controller;

import edu.sm.service.DirectOpenAIVisionService;
import edu.sm.service.MedicalDocumentService;
import edu.sm.service.PdfRagService;
import jakarta.servlet.http.HttpSession;
import org.springframework.ai.chat.client.ChatClient;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.ArrayList;
import java.util.Base64;
import java.util.List;

@Controller
@RequestMapping("/dia")
public class DiagnosisController {

    @Autowired
    private MedicalDocumentService medicalDocumentService;

    @Autowired
    private PdfRagService pdfRagService;

    @Autowired
    private ChatClient chatClient;

    @Autowired
    private DirectOpenAIVisionService directVisionService;

    @GetMapping("/dia1")
    public String dia1(Model model) {
        return "dia/dia1";
    }

    // 2단계: 증상 입력 (세션에 언어 저장)
    @PostMapping("/dia2")
    public String dia2Post(@RequestParam String symptomText,
                           @RequestParam(required = false) MultipartFile[] symptomImages,
                           @RequestParam(value = "language", defaultValue = "ko") String language,
                           HttpSession session,
                           Model model) {

        System.out.println("=== [dia2] 언어 설정 확인: " + language + " ===");

        // 1. 세션에 언어 확실하게 저장 (이게 제일 중요)
        session.setAttribute("symptomText", symptomText);
        session.setAttribute("language", language);

        // 이미지 처리
        List<String> base64Images = null;
        if (symptomImages != null && symptomImages.length > 0) {
            base64Images = new ArrayList<>();
            for (MultipartFile image : symptomImages) {
                if (!image.isEmpty()) {
                    try {
                        String base64 = "data:" + image.getContentType() + ";base64," +
                                Base64.getEncoder().encodeToString(image.getBytes());
                        base64Images.add(base64);
                    } catch (Exception e) {
                        e.printStackTrace();
                    }
                }
            }
            session.setAttribute("symptomImages", base64Images);
        } else {
            session.removeAttribute("symptomImages");
        }

        // 설문 생성 (선택된 언어로)
        String customSurvey = generateCustomSurvey(symptomText, base64Images, language);
        session.setAttribute("customSurvey", customSurvey);

        model.addAttribute("symptomText", symptomText);
        model.addAttribute("customSurvey", customSurvey);
        model.addAttribute("language", language);
        return "dia/dia2";
    }

    private String generateCustomSurvey(String symptomText, List<String> base64Images, String language) {
        try {
            String imageContext = (base64Images != null && !base64Images.isEmpty()) ?
                    "\n\n[참고: 사용자가 " + base64Images.size() + "장의 증상 사진을 첨부했습니다]" : "";

            String langInstruction = switch (language) {
                case "en" -> "Create 5 follow-up questions in English. Ensure options are natural.";
                case "ja" -> "5つの追加質問を日本語で作成してください。";
                case "zh" -> "请用中文生成5个附加问题。";
                default -> "5가지 추가 질문을 한국어로 생성해주세요.";
            };

            String prompt = String.format("""
                    다음 증상에 대해 추가로 확인이 필요한 5가지 질문을 생성해주세요.
                    각 질문은 4개의 선택지를 포함해야 합니다.
                    
                    증상: %s%s
                    
                    **중요: %s**
                    
                    **응답 형식 (형식 준수):**
                    Q1: [질문]
                    A1: [옵션1]|[옵션2]|[옵션3]|[옵션4]
                    ...
                    """, symptomText, imageContext, langInstruction);

            return chatClient.prompt().user(prompt).call().content();
        } catch (Exception e) {
            return null;
        }
    }

    @PostMapping("/dia3")
    public String dia3Post(@RequestParam String answer0,
                           @RequestParam String answer1,
                           @RequestParam String answer2,
                           @RequestParam String answer3,
                           @RequestParam String answer4,
                           @RequestParam(value = "language", defaultValue = "ko") String language,
                           HttpSession session,
                           Model model) {
        String[] surveyAnswers = {answer0, answer1, answer2, answer3, answer4};
        session.setAttribute("surveyAnswers", surveyAnswers);

        // 세션 값 재확인 및 유지
        String sessionLang = (String) session.getAttribute("language");
        if (sessionLang != null) language = sessionLang;

        model.addAttribute("language", language);
        return "dia/dia3";
    }

    @GetMapping("/dia2") public String dia2Get() { return "dia/dia2"; }
    @GetMapping("/dia3") public String dia3Get() { return "dia/dia3"; }

    // 4단계: 최종 결과 (★ 수정됨: 세션 언어값 우선 확인 ★)
    @PostMapping("/dia4")
    public String dia4Post(@RequestParam(required = false) Double latitude,
                           @RequestParam(required = false) Double longitude,
                           // 파라미터로 안 넘어올 경우를 대비해 defaultValue="ko" 유지하지만, 로직에서 무시함
                           @RequestParam(value = "language", defaultValue = "ko") String paramLanguage,
                           HttpSession session,
                           Model model) {

        String symptomText = (String) session.getAttribute("symptomText");
        String[] surveyAnswers = (String[]) session.getAttribute("surveyAnswers");
        List<String> symptomImages = (List<String>) session.getAttribute("symptomImages");

        // [핵심 수정] 파라미터보다 '세션'에 저장된 언어 값을 진짜로 간주합니다.
        // dia3.jsp에서 hidden input이 누락되어도 세션값은 살아있기 때문입니다.
        String sessionLanguage = (String) session.getAttribute("language");
        String targetLanguage = (sessionLanguage != null) ? sessionLanguage : paramLanguage;

        System.out.println("=== [dia4] 최종 언어 확인: " + targetLanguage + " (세션값: " + sessionLanguage + ") ===");

        if (symptomText == null) return "redirect:/dia/dia1";

        try {
            String surveyContext = "";
            if (surveyAnswers != null && surveyAnswers.length > 0) {
                surveyContext = "\n\n[추가 설문 답변]: " + String.join(", ", surveyAnswers);
            }
            String enhancedSymptomText = symptomText + surveyContext;

            String aiDiagnosisKo;

            // 1. 분석은 무조건 한국어로 (정확도 위해)
            if (symptomImages != null && !symptomImages.isEmpty()) {
                aiDiagnosisKo = analyzeWithImages(enhancedSymptomText, symptomImages, "ko");
            } else {
                String prompt = String.format("""
                        환자 증상: %s
                        위 증상을 바탕으로 의료 문서를 분석하여 상세한 진단 결과를 작성해주세요.
                        (반드시 한국어로 작성)
                        """, enhancedSymptomText);
                aiDiagnosisKo = pdfRagService.analyzeSymptoms(prompt);
            }

            // 2. 진료과/시급성 추출 (한국어 텍스트 기반)
            String recommendedDepartmentKo = extractDepartment(aiDiagnosisKo, symptomText);
            String urgencyKo = extractUrgency(aiDiagnosisKo, symptomText);

            // 3. 최종 번역 (targetLanguage 기준)
            String aiDiagnosisFinal;
            String deptFinal;
            String urgencyFinal;

            if (!"ko".equals(targetLanguage)) {
                System.out.println("🌐 번역 실행 중... (" + targetLanguage + ")");
                aiDiagnosisFinal = translateText(aiDiagnosisKo, targetLanguage);
                deptFinal = translateText(recommendedDepartmentKo, targetLanguage);
                urgencyFinal = translateText(urgencyKo, targetLanguage);
            } else {
                aiDiagnosisFinal = aiDiagnosisKo;
                deptFinal = recommendedDepartmentKo;
                urgencyFinal = urgencyKo;
            }

            model.addAttribute("symptomText", symptomText);
            model.addAttribute("aiDiagnosis", aiDiagnosisFinal);
            model.addAttribute("symptomImages", symptomImages);
            model.addAttribute("recommendedDepartment", deptFinal);
            model.addAttribute("urgency", urgencyFinal);
            model.addAttribute("userLatitude", latitude);
            model.addAttribute("userLongitude", longitude);
            model.addAttribute("language", targetLanguage);

        } catch (Exception e) {
            e.printStackTrace();
            return "redirect:/dia/dia1";
        }

        return "dia/dia4";
    }

    @GetMapping("/dia4")
    public String dia4Get(HttpSession session, Model model) {
        String symptomText = (String) session.getAttribute("symptomText");
        String language = (String) session.getAttribute("language");
        if (symptomText == null) return "redirect:/dia/dia1";

        model.addAttribute("symptomText", symptomText);
        model.addAttribute("language", language != null ? language : "ko");
        return "dia/dia4";
    }

    @GetMapping("/reset")
    public String reset(HttpSession session) {
        session.invalidate();
        return "redirect:/dia/dia1";
    }

    private String analyzeWithImages(String symptomText, List<String> base64Images, String language) {
        try {
            String imageObservation = directVisionService.analyzeImages(symptomText, base64Images, language);
            String combinedSymptoms = String.format("""
                    환자 증상: %s
                    사진 관찰 내용: %s
                    위 내용을 바탕으로 종합 진단을 내려주세요.
                    """, symptomText, imageObservation);
            String ragDiagnosis = pdfRagService.analyzeSymptoms(combinedSymptoms);

            return String.format("""
                    ### 📸 사진 기반 관찰
                    %s
                    
                    ---
                    
                    ### 🏥 의료 문서 기반 종합 진단
                    %s
                    """, imageObservation, ragDiagnosis);
        } catch (Exception e) {
            return pdfRagService.analyzeSymptoms(symptomText);
        }
    }

    private String translateText(String text, String targetLang) {
        if (text == null || text.isEmpty()) return "";

        String targetLangName = switch (targetLang) {
            case "en" -> "English";
            case "ja" -> "Japanese";
            case "zh" -> "Chinese";
            default -> "Korean";
        };

        String prompt = String.format("""
                Translate the following medical text into %s.
                Maintain Markdown formatting (like ###, **, -).
                Only output the translated text.
                
                Text:
                %s
                """, targetLangName, text);

        return chatClient.prompt().user(prompt).call().content();
    }

    private String extractDepartment(String aiDiagnosis, String symptomText) {
        String combined = (aiDiagnosis + " " + symptomText).toLowerCase();
        if (aiDiagnosis.contains("추천 진료과:")) {
            String[] lines = aiDiagnosis.split("\n");
            for (String line : lines) {
                if (line.contains("추천 진료과:")) {
                    String dept = line.replace("**추천 진료과:**", "")
                            .replace("추천 진료과:", "").trim();
                    if (!dept.isEmpty() && dept.length() < 20) return dept;
                }
            }
        }
        if (combined.contains("골절") || combined.contains("뼈") || combined.contains("인대")) return "정형외과";
        if (combined.contains("화상") || combined.contains("상처") || combined.contains("열상") || combined.contains("찰과상") || combined.contains("자상")) return "외과";
        if (combined.contains("흉통") || combined.contains("심장")) return "순환기내과";
        if (combined.contains("피부") || combined.contains("발진")) return "피부과";
        if (combined.contains("기침") || combined.contains("호흡")) return "호흡기내과";
        if (combined.contains("복통") || combined.contains("소화")) return "소화기내과";
        if (combined.contains("허리") || combined.contains("관절")) return "정형외과";
        if (combined.contains("두통") || combined.contains("신경")) return "신경과";
        if (combined.contains("눈")) return "안과";
        if (combined.contains("귀") || combined.contains("코")) return "이비인후과";
        if (combined.contains("우울") || combined.contains("불안")) return "정신건강의학과";
        if (combined.contains("치아")) return "치과";
        return "내과";
    }

    private String extractUrgency(String aiDiagnosis, String symptomText) {
        String combined = (aiDiagnosis + " " + symptomText).toLowerCase();
        if (aiDiagnosis.contains("진료 시급성:")) {
            String[] lines = aiDiagnosis.split("\n");
            for (String line : lines) {
                if (line.contains("진료 시급성:")) {
                    String urgency = line.replace("**진료 시급성:**", "")
                            .replace("진료 시급성:", "").trim();
                    if (!urgency.isEmpty() && urgency.length() < 30) return urgency;
                }
            }
        }
        if (combined.contains("응급") || combined.contains("즉시") || combined.contains("119")) return "즉시 방문";
        if (combined.contains("빠른")) return "빠른 시일 내 방문";
        return "일반 진료";
    }
}