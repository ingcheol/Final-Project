package edu.sm.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpSession;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    @GetMapping("/")
    public String home() {
        return "index";
    }

    @GetMapping("/login")
    public String loginForm(HttpServletRequest request, Model model) {
        // 로그아웃 처리
        String action = request.getParameter("action");
        if ("logout".equals(action)) {
            HttpSession session = request.getSession(false);
            if (session != null) {
                session.invalidate();
            }
            return "redirect:/login"; // 로그인 페이지로 리다이렉트
        }

        // 로그인 페이지 뷰 이름(login.jsp) 반환
        return "login";
    }

    @PostMapping("/login")
    public String loginProcess(
            @RequestParam("email") String email,
            @RequestParam("password") String password,
            @RequestParam(value = "rememberMe", required = false) String rememberMe,
            HttpSession session,
            Model model) {

        // 임시 로그인 검증 (테스트용)
        if (isValidUser(email, password)) {
            // 세션에 사용자 정보 저장
            session.setAttribute("userEmail", email);
            session.setAttribute("isLoggedIn", true);

            // 로그인 상태 유지 체크 시 세션 유지 시간 연장
            if (rememberMe != null) {
                session.setMaxInactiveInterval(60 * 60 * 24 * 7); // 7일
            } else {
                session.setMaxInactiveInterval(60 * 30); // 30분
            }

            // 메인 페이지로 리다이렉트
            return "redirect:/";

        } else {
            // 로그인 실패
            model.addAttribute("error", "이메일 또는 비밀번호가 올바지 않습니다.");
            return "login"; // 다시 login.jsp 페이지를 보여줌
        }
    }

    // 임시 검증 메서드
    private boolean isValidUser(String email, String password) {
        return email != null && email.equals("admin@test.com")
                && password != null && password.equals("1234");
    }
}