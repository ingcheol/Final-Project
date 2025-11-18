package edu.sm.controller;

import edu.sm.app.service.HealthMgrService;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/healthmgr")
@RequiredArgsConstructor
@Slf4j
public class HealthMgrController {

  private final HealthMgrService healthMgrService;

  @GetMapping
  public String healthPage(HttpSession session, Model model, HttpServletRequest request) {
    Long patientId = (Long) session.getAttribute("patientId");

    if (patientId == null) {
      // 현재 URL을 세션에 저장 (OAuth2용)
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

    // 세션에서 대화 내역 가져오기 (없으면 새로 생성)
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

    // 세션 업데이트
    session.setAttribute("chatHistory", chatHistory);
    log.info("현재 대화 내역 수: {}", chatHistory.size());

    // 응답
    Map<String, Object> response = new HashMap<>();
    response.put("message", aiResponse);
    response.put("success", true);
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
