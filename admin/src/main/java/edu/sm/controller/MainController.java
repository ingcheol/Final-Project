package edu.sm.controller;

//import edu.sm.app.dto.Chat;
//import edu.sm.app.dto.Product;
//import edu.sm.app.service.ChatService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.multipart.MultipartFile;

import java.util.List;
import java.util.Random;

@Controller
@Slf4j
@RequiredArgsConstructor
public class MainController {

//    private final ChatService chatService;

    @Value("${app.url.sse}")
    String sseUrl;
    @Value("${app.url.mainsse}")
    String mainsseUrl;
    @Value("${app.url.websocketurl}")
    String websocketurl;

    @RequestMapping("/")
    public String main(Model model) {
        model.addAttribute("sseUrl", sseUrl);
        model.addAttribute("center", "dashboard");
        return "index";
    }

//    @RequestMapping("/chart")
//    public String chart(Model model) {
//        model.addAttribute("mainsseUrl",mainsseUrl);
//        model.addAttribute("center","chart");
//        return "index";
//    }
//
//    @RequestMapping("/chat")
//    public String chat(Model model) {
//        model.addAttribute("websocketurl",websocketurl);
//        model.addAttribute("center","chat");
//        return "index";
//    }

    /**
     * 상담 페이지 요청을 처리하고, views/consultation.jsp로 이동합니다.
     * (기존 /websocket 요청을 대체합니다.)
     */
    @RequestMapping("/consultation")
    public String consultation(Model model) {
        // WebSocket URL은 상담 페이지에서도 사용될 수 있으므로 그대로 전달합니다.
        model.addAttribute("websocketurl",websocketurl);
        // views/consultation.jsp로 이동하기 위해 center 속성을 "consultation"으로 설정합니다.
        model.addAttribute("center","consultation");
        return "index";
    }
}