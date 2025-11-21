package edu.sm.Controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.RequestMapping;

@Controller
@RequestMapping("/map")
public class MapController {

    @RequestMapping("/map1")
    public String map1(Model model) {
        return "map/map1";
    }

}