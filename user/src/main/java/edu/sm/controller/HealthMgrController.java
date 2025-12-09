package edu.sm.controller;

import edu.sm.app.service.HealthMgrService;
import edu.sm.app.springai.service.ETLService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.core.io.Resource;
import org.springframework.core.io.UrlResource;
import org.springframework.http.HttpHeaders;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import javax.imageio.ImageIO;
import java.awt.image.BufferedImage;
import java.io.File;
import java.nio.file.Path;
import java.nio.file.Paths;
import java.util.*;

@Controller
@RequestMapping("/healthmgr")
@RequiredArgsConstructor
@Slf4j
public class HealthMgrController {

  private final HealthMgrService healthMgrService;
  private final ETLService etlService;

  @Value("${app.dir.uploadimgsdir}")
  private String uploadDir;

  @GetMapping
  public String healthPage(HttpSession session, Model model, HttpServletRequest request) {
    Long patientId = (Long) session.getAttribute("patientId");
    if (patientId == null) {
      String currentUrl = request.getRequestURI();
      String queryString = request.getQueryString();
      if (queryString != null) {
        currentUrl += "?" + queryString;
      }
      session.setAttribute("redirectUrl", currentUrl);
      return "redirect:/login";
    }
    return "healthmgr";
  }

  // 채팅 메시지 전송
  @PostMapping("/chat")
  @ResponseBody
  public Map<String, Object> chat(
      @RequestBody Map<String, String> request,
      HttpSession session) throws Exception {

    Long patientId = (Long) session.getAttribute("patientId");
    String userMessage = request.get("message");
    log.info("채팅 메시지 수신 - 환자 ID: {}, 메시지: {}", patientId, userMessage);

    @SuppressWarnings("unchecked")
    List<Map<String, String>> chatHistory =
        (List<Map<String, String>>) session.getAttribute("chatHistory");

    if (chatHistory == null) {
      chatHistory = new ArrayList<>();
      session.setAttribute("chatHistory", chatHistory);
    }

    // AI 응답 생성
    String aiResponse = healthMgrService.processChat(patientId, userMessage, chatHistory);

    // 대화 내역에 추가
    Map<String, String> userMsg = new HashMap<>();
    userMsg.put("role", "user");
    userMsg.put("content", userMessage);
    chatHistory.add(userMsg);

    Map<String, String> aiMsg = new HashMap<>();
    aiMsg.put("role", "assistant");
    aiMsg.put("content", aiResponse);
    chatHistory.add(aiMsg);

    session.setAttribute("chatHistory", chatHistory);

    Map<String, Object> response = new HashMap<>();
    response.put("message", aiResponse);
    response.put("success", true);
    return response;
  }

  // 진단서/처방전 업로드 (PDF, TXT, 이미지)
  @PostMapping("/upload-document")
  @ResponseBody
  public Map<String, Object> uploadDocument(
      @RequestParam("file") MultipartFile file,
      @RequestParam("documentType") String documentType,
      HttpSession session) {

    Map<String, Object> response = new HashMap<>();

    try {
      Long patientId = (Long) session.getAttribute("patientId");
      if (patientId == null) {
        response.put("success", false);
        response.put("message", "로그인이 필요합니다.");
        return response;
      }

      if (file.isEmpty()) {
        response.put("success", false);
        response.put("message", "파일이 비어있습니다.");
        return response;
      }

      String contentType = file.getContentType();
      String originalFilename = file.getOriginalFilename();

      log.info("문서 업로드 - 환자 ID: {}, 파일: {}, 타입: {}, ContentType: {}",
          patientId, originalFilename, documentType, contentType);

      // 파일 형식 검증
      if (contentType == null) {
        response.put("success", false);
        response.put("message", "파일 형식을 확인할 수 없습니다.");
        return response;
      }

      boolean isSupported = contentType.equals("application/pdf") ||
          contentType.equals("text/plain") ||
          contentType.contains("wordprocessingml") ||
          contentType.startsWith("image/");

      if (!isSupported) {
        response.put("success", false);
        response.put("message", "지원하지 않는 파일 형식입니다. PDF, TXT, DOCX, 이미지 파일만 업로드 가능합니다.");
        return response;
      }

      // 이미지 파일 처리
      if (contentType.startsWith("image/")) {
        // GIF 차단
        if (contentType.equals("image/gif")) {
          response.put("success", false);
          response.put("message", "GIF 파일은 지원하지 않습니다.");
          return response;
        }

        // 벡터 DB에 저장 (OCR 텍스트)
        String type = "patient_" + patientId + "_" + documentType;
        String result = etlService.etlFromFile(type, file);
        String savedFileName = saveImage(file, patientId, documentType);

        response.put("success", true);
        response.put("message", "이미지가 성공적으로 업로드되었습니다.");
        response.put("imageUrl", "/healthmgr/images/" + savedFileName);
        response.put("fileName", savedFileName);

        // 세션에 업로드된 이미지 목록 저장
        @SuppressWarnings("unchecked")
        List<Map<String, String>> uploadedImages =
            (List<Map<String, String>>) session.getAttribute("uploadedImages");

        if (uploadedImages == null) {
          uploadedImages = new ArrayList<>();
        }

        Map<String, String> imageInfo = new HashMap<>();
        imageInfo.put("fileName", savedFileName);
        imageInfo.put("documentType", documentType);
        imageInfo.put("url", "/healthmgr/images/" + savedFileName);
        uploadedImages.add(imageInfo);

        session.setAttribute("uploadedImages", uploadedImages);

        log.info("이미지 저장 완료 - 파일명: {}", savedFileName);

      } else {
        // PDF, TXT, DOCX 처리
        String type = "patient_" + patientId + "_" + documentType;
        String result = etlService.etlFromFile(type, file);

        response.put("success", true);
        response.put("message", "문서가 성공적으로 업로드되었습니다.");
        response.put("result", result);
      }

    } catch (Exception e) {
      log.error("문서 업로드 중 오류", e);
      response.put("success", false);
      response.put("message", "문서 업로드 중 오류가 발생했습니다: " + e.getMessage());
    }

    return response;
  }

  // 이미지 파일 저장
  private String saveImage(MultipartFile file, Long patientId, String documentType) throws Exception {
    // 저장 경로 확인 및 생성
    File uploadDirFile = new File(uploadDir);
    if (!uploadDirFile.exists()) {
      uploadDirFile.mkdirs();
    }

    // 고유 파일명 생성
    String originalFilename = file.getOriginalFilename();
    String extension = originalFilename.substring(originalFilename.lastIndexOf("."));
    String savedFileName = "patient_" + patientId + "_" + documentType + "_" +
        System.currentTimeMillis() + extension;

    // 파일 저장
    File destFile = new File(uploadDir + savedFileName);
    byte[] fileBytes = file.getBytes();

    // ByteArrayInputStream을 사용하여 이미지 검증
    java.io.ByteArrayInputStream bais = new java.io.ByteArrayInputStream(fileBytes);
    BufferedImage image = ImageIO.read(bais);

    if (image == null) {
      throw new Exception("유효하지 않은 이미지 파일입니다.");
    }

    // 파일 쓰기
    java.nio.file.Files.write(destFile.toPath(), fileBytes);

    return savedFileName;
  }

  // 이미지 조회
  @GetMapping("/images/{filename:.+}")
  @ResponseBody
  public ResponseEntity<Resource> getImage(@PathVariable String filename) {
    try {
      Path filePath = Paths.get(uploadDir).resolve(filename);
      Resource resource = new UrlResource(filePath.toUri());

      if (resource.exists() && resource.isReadable()) {
        return ResponseEntity.ok()
            .header(HttpHeaders.CONTENT_TYPE, "image/jpeg")
            .body(resource);
      } else {
        return ResponseEntity.notFound().build();
      }
    } catch (Exception e) {
      log.error("이미지 조회 오류", e);
      return ResponseEntity.notFound().build();
    }
  }

  // 업로드된 이미지 목록 조회
  @GetMapping("/uploaded-images")
  @ResponseBody
  public Map<String, Object> getUploadedImages(HttpSession session) {
    @SuppressWarnings("unchecked")
    List<Map<String, String>> uploadedImages =
        (List<Map<String, String>>) session.getAttribute("uploadedImages");

    if (uploadedImages == null) {
      uploadedImages = new ArrayList<>();
    }

    Map<String, Object> response = new HashMap<>();
    response.put("images", uploadedImages);
    response.put("success", true);
    return response;
  }

  // 질환 예측 요청
  @PostMapping("/predict-disease")
  @ResponseBody
  public Map<String, Object> predictDisease(HttpSession session) throws Exception {
    Map<String, Object> response = new HashMap<>();

    try {
      Long patientId = (Long) session.getAttribute("patientId");
      if (patientId == null) {
        response.put("success", false);
        response.put("message", "로그인이 필요합니다.");
        return response;
      }

      log.info("질환 예측 요청 - 환자 ID: {}", patientId);

      String prediction = healthMgrService.predictDiseaseRisk(patientId);

      response.put("success", true);
      response.put("prediction", prediction);

    } catch (Exception e) {
      log.error("질환 예측 중 오류", e);
      response.put("success", false);
      response.put("message", "질환 예측 중 오류가 발생했습니다: " + e.getMessage());
    }

    return response;
  }

  @PostMapping("/delete-document")
  @ResponseBody
  public Map<String, Object> deleteDocument(
      @RequestParam("fileName") String fileName,
      HttpSession session) {

    Map<String, Object> response = new HashMap<>();

    try {
      Long patientId = (Long) session.getAttribute("patientId");
      if (patientId == null) {
        response.put("success", false);
        response.put("message", "로그인이 필요합니다.");
        return response;
      }

      log.info("문서 삭제 요청 - 환자 ID: {}, 파일명: {}", patientId, fileName);

      // 파일 삭제
      File file = new File(uploadDir + fileName);
      if (file.exists()) {
        boolean deleted = file.delete();
        log.info("파일 삭제 결과: {}", deleted);
      } else {
        log.warn("파일이 존재하지 않음: {}", fileName);
      }

      // 세션에서 제거
      @SuppressWarnings("unchecked")
      List<Map<String, String>> uploadedImages =
          (List<Map<String, String>>) session.getAttribute("uploadedImages");

      if (uploadedImages != null) {
        uploadedImages.removeIf(img -> fileName.equals(img.get("fileName")));
        session.setAttribute("uploadedImages", uploadedImages);
        log.info("세션에서 문서 제거 완료");
      }

      response.put("success", true);
      response.put("message", "문서가 삭제되었습니다.");

    } catch (Exception e) {
      log.error("문서 삭제 중 오류", e);
      response.put("success", false);
      response.put("message", "삭제 중 오류가 발생했습니다: " + e.getMessage());
    }

    return response;
  }

  // 채팅 내역 초기화
  @PostMapping("/chat/clear")
  @ResponseBody
  public Map<String, Object> clearChat(HttpSession session) {
    session.removeAttribute("chatHistory");
    log.info("채팅 내역 초기화");

    Map<String, Object> response = new HashMap<>();
    response.put("success", true);
    response.put("message", "채팅 내역이 초기화되었습니다.");
    return response;
  }

  // 채팅 내역 조회
  @GetMapping("/chat/history")
  @ResponseBody
  public Map<String, Object> getChatHistory(HttpSession session) {
    @SuppressWarnings("unchecked")
    List<Map<String, String>> chatHistory =
        (List<Map<String, String>>) session.getAttribute("chatHistory");

    if (chatHistory == null) {
      chatHistory = new ArrayList<>();
    }

    Map<String, Object> response = new HashMap<>();
    response.put("history", chatHistory);
    response.put("success", true);
    return response;
  }
}
