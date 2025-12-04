package edu.sm.Controller;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.Map;

@Slf4j
@Controller
@RequestMapping("/consul") // 1. 접속 주소 앞부분 설정
public class ConsultationController {

    /**
     * 상담 신청 페이지 이동
     * URL: /consul/consul2
     */
    @GetMapping("/consul2")
    public String consul2Page() {
        log.info("상담 신청 페이지 진입");
        // application.yml의 view prefix/suffix에 따라 /views/consul/consul2.jsp 로 이동
        return "consul/consul2";
    }

    /**
     * 상담 신청 데이터 처리 (JSP 폼 전송 시)
     * URL: /consul/consul2 (POST 방식)
     */
    @PostMapping("/consul2")
    public String consul2Process(@RequestParam Map<String, String> params) {
        log.info("=== 상담 신청 데이터 수신 ===");
        log.info("내용: {}", params.get("consultContent"));
        log.info("날짜: {}", params.get("consultDate"));
        log.info("시간: {}", params.get("consultTime"));
        log.info("연락처: {}", params.get("phone"));

        // TODO: 여기에 Service를 호출해서 DB에 저장하는 코드를 넣으세요.
        // consultationService.register(params);

        // 처리가 끝나면 메인화면으로 리다이렉트 (또는 완료 페이지로 이동)
        return "redirect:/";
    }
}