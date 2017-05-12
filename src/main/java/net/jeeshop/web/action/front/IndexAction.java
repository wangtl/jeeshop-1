package net.jeeshop.web.action.front;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;

/**
 * 前端首页
 */
@Controller
@RequestMapping("/")
public class IndexAction {
    @RequestMapping({"/","/index"})
    public String index(HttpServletRequest request) {
        return "index";
    }

}
