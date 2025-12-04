//package edu.sm.controller;
//
//import org.springframework.stereotype.Controller;
//import org.springframework.ui.Model;
//import org.springframework.web.bind.annotation.GetMapping;
//import org.springframework.web.bind.annotation.RequestMapping;
//import org.springframework.web.bind.annotation.RequestParam;
//
//@Controller
//@RequestMapping("/iot")
//public class IotviewController {
//
//  @GetMapping("/monitor")
//  public String monitor(@RequestParam("patientId") Long patientId, Model model) {
//    model.addAttribute("patientId", patientId);
//    return "iot/monitor";  // JSP 경로 (iot 폴더 안의 monitor.jsp)
//  }
//}
