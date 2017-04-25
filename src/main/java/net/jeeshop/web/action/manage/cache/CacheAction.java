package net.jeeshop.web.action.manage.cache;

import net.jeeshop.core.oscache.FrontCache;
import net.jeeshop.core.oscache.ManageCache;
import org.apache.commons.lang.StringUtils;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestMethod;
import org.springframework.web.bind.annotation.ResponseBody;
import org.springframework.web.context.WebApplicationContext;
import org.springframework.web.context.support.WebApplicationContextUtils;

import javax.servlet.http.HttpServletRequest;

/**
 * Created by Administrator on 2017/2/22.
 */
@Controller
@RequestMapping("/manage/cache/")
public class CacheAction {
    private static final Logger logger = LoggerFactory.getLogger(CacheAction.class);
    private static final String page_toIndex = "/manage/cache/cacheIndex";


    @RequestMapping(value="show",method = RequestMethod.GET)
    public String toIndex() throws Exception {
        return page_toIndex;
    }

    @RequestMapping(value = "loadAllCache", method = RequestMethod.GET)
    @ResponseBody
    public String loadAllCache(HttpServletRequest request) throws Exception{
        WebApplicationContext app = WebApplicationContextUtils.getWebApplicationContext(request.getSession().getServletContext());
        ManageCache manageCache = (ManageCache) app.getBean("manageCache");
        manageCache.loadAllCache();
        logger.info("后台缓存更新成功");
        return "success";
    }

    @RequestMapping(value = "frontCache", method = RequestMethod.GET)
    @ResponseBody
    public String frontCache(HttpServletRequest request){
        WebApplicationContext app = WebApplicationContextUtils.getWebApplicationContext(request.getSession().getServletContext());
        FrontCache frontCache = (FrontCache) app.getBean("frontCache");

        String method = request.getParameter("method");
        try{
            if(StringUtils.isBlank(method)){
                frontCache.loadAllCache();
            }else if(method.equals("activity")){
                frontCache.loadActivityMap();
                frontCache.loadActivityProductList();
                frontCache.loadActivityScoreProductList();
                frontCache.loadActivityTuanProductList();
            }else if(method.equals("loadIndexImgs")){
                frontCache.loadIndexImgs();
            }else if(method.equals("loadAdvertList")){
                frontCache.loadAdvertList();
            }else if(method.equals("loadNotifyTemplate")){
                frontCache.loadNotifyTemplate();
            }else if(method.equals("loadProductStock")){
                frontCache.loadProductStock();
            }else if(method.equals("hotquery")){
                frontCache.loadHotquery();
            }
        }catch(Exception e){
            e.printStackTrace();
        }
        return "success";
    }

}
