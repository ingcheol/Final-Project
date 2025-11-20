package edu.sm.controller;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/monitor")
public class IotAlertController {

  @GetMapping("/iotalert")
  public String iotAlert() {
    return "iotalert";
  }
}
