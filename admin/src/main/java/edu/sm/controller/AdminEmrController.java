package edu.sm.controller;

import edu.sm.app.dto.Emr;
import edu.sm.app.service.EmrService;
import lombok.RequiredArgsConstructor;
import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.List;

@Controller
@RequestMapping("/admin/emr")
@RequiredArgsConstructor
@Slf4j
public class AdminEmrController {

    private final EmrService emrService;

    String dir = "emr/";

    // 1. EMR 전체 목록 페이지
    @RequestMapping("")
    public String list(Model model) {
        try {
            List<Emr> list = emrService.getEmrs();
            model.addAttribute("emrs", list);
            model.addAttribute("center", dir + "list");
        } catch (Exception e) {
            log.error("EMR 목록 조회 실패", e);
            throw new RuntimeException(e);
        }
        return "index"; // admin/index.jsp의 center 영역에 list.jsp를 끼워 넣는 구조 가정
    }

    // 2. EMR 상세 페이지
    @RequestMapping("/detail")
    public String detail(Model model, @RequestParam("id") Long emrId) {
        try {
            Emr emr = emrService.getEmr(emrId);
            model.addAttribute("emr", emr);
            model.addAttribute("center", dir + "detail");
        } catch (Exception e) {
            log.error("EMR 상세 조회 실패", e);
            throw new RuntimeException(e);
        }
        return "index";
    }
}