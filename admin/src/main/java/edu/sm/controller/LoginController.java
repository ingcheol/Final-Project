package edu.sm.controller;

import edu.sm.app.dto.Admin;
import edu.sm.app.dto.Adviser; // Adviser DTO import
import edu.sm.app.service.AdminService;
import edu.sm.app.service.AdviserService; // AdviserService import
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@Slf4j
@RequiredArgsConstructor
public class LoginController {

    // 관리자 및 상담사 서비스 주입
    final AdminService adminService;
    final AdviserService adviserService; // AdviserService 추가
    final BCryptPasswordEncoder bCryptPasswordEncoder;

    /**
     * 로그인 처리 로직
     * 하나의 엔드포인트에서 관리자(Admin)와 상담사(Adviser) 모두를 처리합니다.
     * @param model Model 객체
     * @param inputId 사용자가 입력한 로그인 ID (adminId 또는 adviserId)
     * @param inputPwd 사용자가 입력한 비밀번호
     * @param httpSession 세션 객체
     * @return 로그인 성공 시 루트 페이지로 리다이렉트, 실패 시 index 페이지로 이동
     * @throws Exception 서비스 레이어 예외
     */
    @RequestMapping("/loginimpl")
    public String loginimpl(Model model,
                            @RequestParam("id") String inputId, // 변수명을 inputId로 통일
                            @RequestParam("pwd") String inputPwd, HttpSession httpSession) throws Exception {

        // 1. **관리자 (Admin) 로그인 시도**
        Admin dbAdmin = adminService.getByAdminId(inputId);

        if (dbAdmin != null && bCryptPasswordEncoder.matches(inputPwd, dbAdmin.getPassword())) {
            log.info("관리자 로그인 성공: {}", inputId);
            httpSession.setAttribute("admin", dbAdmin);
            httpSession.setAttribute("role", "ADMIN"); // 역할 정보 추가
            return "redirect:/";
        }

        // 2. **상담사 (Adviser) 로그인 시도**
        Adviser dbAdviser = adviserService.getByAdviserId(inputId);

        if (dbAdviser != null && bCryptPasswordEncoder.matches(inputPwd, dbAdviser.getPassword())) {
            log.info("상담사 로그인 성공: {}", inputId);
            httpSession.setAttribute("adviser", dbAdviser);
            httpSession.setAttribute("role", "ADVISER"); // 역할 정보 추가
            return "redirect:/";
        }

        // 3. **로그인 실패**
        model.addAttribute("loginfail", "fail");
        model.addAttribute("msg", "로그인 실패!!!");
        return "index";
    }

    /**
     * 로그아웃 처리 로직
     * @param model Model 객체 (사용되지 않음)
     * @param httpSession 세션 객체
     * @return 루트 페이지로 리다이렉트
     * @throws Exception 예외
     */
    @RequestMapping("/logoutimpl")
    public String logout(Model model, HttpSession httpSession) throws Exception {
        if(httpSession != null){
            httpSession.invalidate(); // 세션 무효화
        }
        return "redirect:/";
    }

}