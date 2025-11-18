package edu.sm.controller;

import edu.sm.app.dto.Emr;
import edu.sm.app.dto.Patient;
import edu.sm.app.service.EmrService;
import edu.sm.app.springai.service.ETLService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.util.HashMap;
import java.util.Map;

@Controller
@RequestMapping("/emr")
@RequiredArgsConstructor
@Slf4j
public class EmrController {

  private final EmrService emrService;
  private final ETLService etlService;

  /**
   * EMR 통합 페이지
   */
  @GetMapping
  public String emrPage(Model model, HttpSession session) {
    Patient loginUser = (Patient) session.getAttribute("loginuser");
    if (loginUser == null) {
      return "redirect:/login";
    }

    model.addAttribute("center", "emr");
    return "index";
  }

  /**
   * 음성 파일 업로드 → STT + EMR 자동 생성 (DB 저장 안 함)
   */
  @PostMapping("/generate")
  @ResponseBody
  public Map<String, Object> generateEmr(
      @RequestParam("audioFile") MultipartFile audioFile,
      @RequestParam(value = "consultationId", required = false) Long consultationId,
      @RequestParam(value = "testResults", required = false) String testResults,
      @RequestParam(value = "prescription", required = false) String prescription,
      HttpSession session) {

    Map<String, Object> response = new HashMap<>();

    try {
      Patient loginUser = (Patient) session.getAttribute("loginuser");
      if (loginUser == null) {
        response.put("success", false);
        response.put("message", "로그인이 필요합니다.");
        return response;
      }

      Long patientId = loginUser.getPatientId();

      // ✅ EMR 생성 (DB 저장 안 함)
      Emr emr = emrService.generateEmrFromAudio(
          consultationId, patientId, audioFile, testResults, prescription);

      // ✅ 세션에 임시 저장 (최종 저장 시 사용)
      session.setAttribute("tempEmr", emr);

      response.put("success", true);
      response.put("sttText", emr.getPatientStatement());
      response.put("aiDraft", emr.getFinalRecord());
      response.put("testResults", emr.getTestResults());
      response.put("prescription", emr.getPrescriptionDetails());

    } catch (Exception e) {
      log.error("EMR 생성 오류", e);
      response.put("success", false);
      response.put("message", "EMR 생성 중 오류가 발생했습니다: " + e.getMessage());
    }

    return response;
  }

  /**
   * EMR 최종 저장 (수정된 내용 포함, DB insert)
   */
  @PostMapping("/save")
  @ResponseBody
  public Map<String, Object> saveEmr(
      @RequestParam("finalRecord") String finalRecord,
      HttpSession session) {
    Map<String, Object> response = new HashMap<>();
    try {
      Patient loginUser = (Patient) session.getAttribute("loginuser");
      if (loginUser == null) {
        response.put("success", false);
        response.put("message", "로그인이 필요합니다.");
        return response;
      }

      // 세션에서 임시 EMR 가져오기 (consultationId를 위해)
      Emr tempEmr = (Emr) session.getAttribute("tempEmr");
      Long consultationId = (tempEmr != null) ? tempEmr.getConsultationId() : null;

      // 🟢 AI로 텍스트 분배 후 저장
      emrService.saveEmrWithAIAutoParsing(consultationId, loginUser.getPatientId(), finalRecord);

      session.removeAttribute("tempEmr");
      response.put("success", true);
      response.put("message", "EMR이 분배 저장되었습니다.");
    } catch (Exception e) {
      response.put("success", false);
      response.put("message", "저장 중 오류: " + e.getMessage());
    }
    return response;
  }


  /**
   * Vector DB에 EMR 템플릿/규칙 업로드
   */
  @PostMapping("/upload-template")
  @ResponseBody
  public Map<String, Object> uploadEmrTemplate(
      @RequestParam("templateFile") MultipartFile templateFile,
      HttpSession session) {

    Map<String, Object> response = new HashMap<>();

    try {
      Patient loginUser = (Patient) session.getAttribute("loginuser");
      if (loginUser == null) {
        response.put("success", false);
        response.put("message", "로그인이 필요합니다.");
        return response;
      }

      String result = etlService.etlFromFile("emr_template", templateFile);

      response.put("success", true);
      response.put("message", result);

    } catch (Exception e) {
      log.error("템플릿 업로드 오류", e);
      response.put("success", false);
      response.put("message", "업로드 중 오류가 발생했습니다: " + e.getMessage());
    }

    return response;
  }
}
