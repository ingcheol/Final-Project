package edu.sm.app.security;

import edu.sm.app.dto.Patient;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import lombok.extern.slf4j.Slf4j;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.SimpleUrlAuthenticationSuccessHandler;
import org.springframework.stereotype.Component;

import java.io.IOException;

@Slf4j
@Component
public class OAuth2SuccessHandler extends SimpleUrlAuthenticationSuccessHandler {

  @Override
  public void onAuthenticationSuccess(HttpServletRequest request, HttpServletResponse response,
                                      Authentication authentication) throws IOException, ServletException {

    PrincipalDetails principalDetails = (PrincipalDetails) authentication.getPrincipal();
    Patient patient = principalDetails.getPatient();;

    // 세션에 사용자 정보 저장
    HttpSession session = request.getSession();
    session.setAttribute("loginuser", patient);
    session.setAttribute("patientId", patient.getPatientId());
    session.setAttribute("loginid", patient.getPatientEmail());
    session.setAttribute("loginname", patient.getPatientName());

    // redirect
    String redirectUrl = (String) session.getAttribute("redirectUrl");

    if (redirectUrl != null && !redirectUrl.isEmpty()) {
      // 세션에서 URL 제거
      session.removeAttribute("redirectUrl");
      response.sendRedirect(redirectUrl);
    } else {
      // 저장된 URL이 없으면 홈으로
      response.sendRedirect("/");
    }
  }
}
