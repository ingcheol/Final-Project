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
                          HttpSession session) throws Exception {

    Patient patient = patientService.getByEmail(email);

    if (patient != null && bCryptPasswordEncoder.matches(pwd, patient.getPatientPwd())) {
      session.setAttribute("loginuser", patient);
      session.setAttribute("patientId", patient.getPatientId());
      log.info(patient.getPatientId() + "," + patient.getPatientEmail() + "," + patient.getPatientName());
      return "redirect:/";
    }

    model.addAttribute("center", "login");
    model.addAttribute("loginstate", "fail");
    return "index";
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

//    @RequestMapping("/info")
//    public String info(Model model, @RequestParam("id") String id, HttpSession session) throws Exception {
//        User user = null;
//        user = userService.get(id);
//        user.setUserAddr(standardPBEStringEncryptor.decrypt(user.getUserAddr()));
//
//        model.addAttribute("user",user);
//        model.addAttribute("center","info");
//        return "index";
//    }
//
//    @RequestMapping("/updateimpl")
//    public String updateimpl(User user) throws Exception {
//        user.setUserPwd(bCryptPasswordEncoder.encode(user.getUserPwd()));
//        user.setUserAddr(standardPBEStringEncryptor.encrypt(user.getUserAddr()));
//        userService.modify(user);
//        return "redirect:/info?id=" + user.getUserId();
//    }
//
//    @RequestMapping("/updateinfo")
//    public String updateimpl(User user, @RequestParam("currentPwd") String currentPwd, HttpSession session, Model model) throws Exception {
//        User loginUser = (User) session.getAttribute("loginuser");
//        if (loginUser == null) return "redirect:/login";
//
//        User dbUser = userService.get(loginUser.getUserId());
//
//        if (bCryptPasswordEncoder.matches(currentPwd, dbUser.getUserPwd())) {
//            dbUser.setUserName(user.getUserName());
//            dbUser.setUserAddr(standardPBEStringEncryptor.encrypt(user.getUserAddr()));
//            userService.modify(dbUser);
//            return "redirect:/info?id="+user.getUserId();
//        } else {
//            user.setUserAddr(standardPBEStringEncryptor.decrypt(dbUser.getUserAddr()));
//            model.addAttribute("user", user);
//            model.addAttribute("center", "info");
//            model.addAttribute("error", "기존 비밀번호가 일치하지 않습니다.");
//            return "index";
//        }
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
