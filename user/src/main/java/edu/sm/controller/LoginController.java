package edu.sm.controller;

import edu.sm.app.dto.Patient;
import edu.sm.app.service.PatientService;
import jakarta.servlet.http.HttpSession;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.jasypt.encryption.pbe.StandardPBEStringEncryptor;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.bind.annotation.ResponseBody;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@Slf4j
@RequiredArgsConstructor
public class LoginController {
  final PatientService patientService;
  final BCryptPasswordEncoder bCryptPasswordEncoder;
  final StandardPBEStringEncryptor standardPBEStringEncryptor;

  @RequestMapping("/login")
  public String login(Model model) {
    model.addAttribute("center", "login");
    return "index";
  }

  @RequestMapping("/logout")
  public String logout(Model model, HttpSession session) {
    if (session != null) {
      session.invalidate();
    }
    return "redirect:/";
  }

  @RequestMapping("/loginimpl")
  public String loginimpl(Model model,
                          @RequestParam("email") String email,
                          @RequestParam("pwd") String pwd,
                          @RequestParam(value = "redirect", required = false) String redirectParam,
                          HttpSession session) throws Exception {

    Patient patient = patientService.getByEmail(email);

    if (patient != null && bCryptPasswordEncoder.matches(pwd, patient.getPatientPwd())) {
      session.setAttribute("loginuser", patient);
      session.setAttribute("patientId", patient.getPatientId());
      log.info(patient.getPatientId() + "," + patient.getPatientEmail() + "," + patient.getPatientName());

      // 로그인 폼에서 전달
      if (redirectParam != null && !redirectParam.isEmpty()) {
        return "redirect:" + redirectParam;
      }

      // 세션의 redirectUrl 확인 (컨트롤러에서 저장)
      String redirectUrl = (String) session.getAttribute("redirectUrl");
      if (redirectUrl != null && !redirectUrl.isEmpty()) {
        session.removeAttribute("redirectUrl");
        return "redirect:" + redirectUrl;
      }

      return "redirect:/";
    }

    model.addAttribute("center", "login");
    model.addAttribute("loginstate", "fail");
    return "index";
  }

  @RequestMapping("/checkemail")
  @ResponseBody
  public Map<String, Boolean> checkEmail(@RequestParam("email") String email) throws Exception {
    Map<String, Boolean> result = new HashMap<>();

    // 이메일로 환자 검색
    List<Patient> patients = patientService.get();
    boolean isAvailable = patients.stream()
        .noneMatch(p -> p.getPatientEmail().equals(email));

    result.put("available", isAvailable);
    return result;
  }

  @RequestMapping("/register")
  public String register(Model model) {
    model.addAttribute("center", "register");
    return "index";
  }

  @RequestMapping("/registerimpl")
  public String registerimpl(Model model, Patient patient) throws Exception {
    patient.setPatientPwd(bCryptPasswordEncoder.encode(patient.getPatientPwd()));
    patient.setPatientAddr(standardPBEStringEncryptor.encrypt(patient.getPatientAddr()));
    patientService.register(patient);
    return "redirect:/login";
  }

  @RequestMapping("/deleteimpl")
  public String deleteimpl(@RequestParam("currentPwd") String currentPwd,
                           HttpSession session, Model model) throws Exception {

    Patient loginPatient = (Patient) session.getAttribute("loginuser");
    if (loginPatient == null) return "redirect:/login";

    Patient dbPatient = patientService.getByEmail(loginPatient.getPatientEmail());

    if (bCryptPasswordEncoder.matches(currentPwd, dbPatient.getPatientPwd())) {
      patientService.removeByEmail(loginPatient.getPatientEmail());
      session.invalidate();
      return "redirect:/";
    } else {
      Patient patient = patientService.getByEmail(loginPatient.getPatientEmail());
      patient.setPatientAddr(standardPBEStringEncryptor.decrypt(patient.getPatientAddr()));
      model.addAttribute("patient", patient);
      model.addAttribute("center", "info");
      model.addAttribute("error", "회원 탈퇴를 위해 정확한 비밀번호를 입력해야 합니다.");
      return "index";
    }
  }

  @RequestMapping("/info")
  public String info(Model model, @RequestParam("patientId") Long patientId, HttpSession session) throws Exception {
    Patient loginPatient = (Patient) session.getAttribute("loginuser");

    // 로그인 체크
    if (loginPatient == null) {
      return "redirect:/login";
    }

    // 본인 확인
    if (!loginPatient.getPatientId().equals(patientId)) {
      return "redirect:/";
    }

    Patient patient = patientService.get(patientId);

    // 주소 복호화
    if (patient.getPatientAddr() != null && !patient.getPatientAddr().isEmpty()) {
      patient.setPatientAddr(standardPBEStringEncryptor.decrypt(patient.getPatientAddr()));
    }

    model.addAttribute("patient", patient);
    model.addAttribute("center", "info");
    return "index";
  }

  @RequestMapping("/updateinfo")
  public String updateinfo(Patient patient, HttpSession session, Model model) throws Exception {
    Patient loginPatient = (Patient) session.getAttribute("loginuser");

    if (loginPatient == null) {
      return "redirect:/login";
    }

    // 본인 확인
    if (!loginPatient.getPatientId().equals(patient.getPatientId())) {
      return "redirect:/";
    }

    // 기존 환자 정보 가져오기
    Patient dbPatient = patientService.get(patient.getPatientId());

    // 수정 가능한 필드만 업데이트
    dbPatient.setPatientName(patient.getPatientName());
    dbPatient.setPatientPhone(patient.getPatientPhone());

    // 주소 암호화
    if (patient.getPatientAddr() != null && !patient.getPatientAddr().isEmpty()) {
      dbPatient.setPatientAddr(standardPBEStringEncryptor.encrypt(patient.getPatientAddr()));
    } else {
      dbPatient.setPatientAddr(null);
    }

    // 의료 정보 업데이트
    dbPatient.setPatientMedicalHistory(patient.getPatientMedicalHistory());
    dbPatient.setPatientLifestyleHabits(patient.getPatientLifestyleHabits());
    dbPatient.setLanguagePreference(patient.getLanguagePreference());

    patientService.modify(dbPatient);

    // 세션 업데이트
    session.setAttribute("loginuser", dbPatient);

    return "redirect:/info?patientId=" + patient.getPatientId() + "&update=success";
  }

//    @RequestMapping("/updateimpl")
//    public String updateimpl(User user) throws Exception {
//        user.setUserPwd(bCryptPasswordEncoder.encode(user.getUserPwd()));
//        user.setUserAddr(standardPBEStringEncryptor.encrypt(user.getUserAddr()));
//        userService.modify(user);
//        return "redirect:/info?id=" + user.getUserId();
//    }
//
//    @RequestMapping("updatepwd")
//    public String updatepwd(Model model, HttpSession session) {
//        if (session.getAttribute("loginuser") == null) {
//            return "redirect:/login";
//        }
//        model.addAttribute("center", "updatepwd");
//        return "index";
//    }
//
//    @RequestMapping("updatepwdimpl")
//    public String updatepwdimpl(@RequestParam("currentPwd") String currentPwd, @RequestParam("newPwd") String newPwd, Model model, HttpSession session) throws Exception {
//        User loginUser = (User) session.getAttribute("loginuser");
//        if (loginUser == null) return "redirect:/login";
//
//        User dbUser = userService.get(loginUser.getUserId());
//
//        if (bCryptPasswordEncoder.matches(currentPwd, dbUser.getUserPwd())) {
//            dbUser.setUserPwd(bCryptPasswordEncoder.encode(newPwd));
//            userService.modify(dbUser);
//            session.invalidate();
//            return "redirect:/login?update_pwd=success";
//        } else {
//            model.addAttribute("center", "updatepwd");
//            model.addAttribute("error", "기존 비밀번호가 일치하지 않습니다.");
//            return "index";
//        }
//    }
//
//    @RequestMapping("updatepwd_0909")
//    public String updatepwd_0909(Model model, HttpSession session) {
//        if (session.getAttribute("loginuser") == null) {
//            return "redirect:/login";
//        }
//        model.addAttribute("center", "updatepwd_0909");
//        return "index";
//    }
//
//    @RequestMapping("/updateimpl_0909")
//    public String updateimpl_0909(Model model,
//                            @RequestParam("pwd") String pwd,
//                            @RequestParam("new_pwd") String new_pwd,
//                            HttpSession session) throws Exception {
//        User sessionUser = (User) session.getAttribute("user");
//        boolean result = bCryptPasswordEncoder.matches(pwd, sessionUser.getUserPwd());
//        if(result != true){
//            model.addAttribute("msg","비밀번호가 틀렸습니다.");
//        }else{
//            sessionUser.setUserPwd(bCryptPasswordEncoder.encode(new_pwd));
//            userService.modify(sessionUser);
//            model.addAttribute("msg","비밀번호 변경완료.");
//        }
//        model.addAttribute("center","updatepwd_0909");
//
//        return "index";
//    }
}
