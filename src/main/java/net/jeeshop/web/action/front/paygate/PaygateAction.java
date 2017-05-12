package net.jeeshop.web.action.front.paygate;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import net.jeeshop.core.front.SystemManager;
import net.jeeshop.core.pay.alipay.alipayescow.config.AlipayConfig;
import net.jeeshop.core.pay.alipay.newpay.AlipaynewConfig;
import net.jeeshop.services.common.Orderpay;
import net.jeeshop.services.front.order.OrderService;
import net.jeeshop.services.front.order.bean.Order;
import net.jeeshop.services.front.orderpay.OrderpayService;
import net.jeeshop.services.front.ordership.OrdershipService;
import net.jeeshop.services.front.ordership.bean.Ordership;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.ModelMap;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.ResponseBody;

import com.alipay.api.AlipayApiException;
import com.alipay.api.AlipayClient;
import com.alipay.api.DefaultAlipayClient;
import com.alipay.api.request.AlipayTradePagePayRequest;

/**
 * @author dylan
 * @date 16/2/18 22:58
 * Email: dinguangx@163.com
 */
@Controller("frontPaygateAction")
@RequestMapping("paygate")
public class PaygateAction {
    private Logger logger = LoggerFactory.getLogger(getClass());
    @Autowired
    SystemManager systemManager;
    @Autowired
    private OrderService orderService;
    @Autowired
    private OrdershipService ordershipService;
    @Autowired
    private OrderpayService orderpayService;
    
    private static AlipayClient alipayClient = null;
    static{
    	alipayClient = new DefaultAlipayClient(AlipaynewConfig.GATEWAY, 
		AlipaynewConfig.APPID, AlipaynewConfig.APP_PRIVATE_KEY,
		AlipaynewConfig.FORMAT, AlipaynewConfig.CHARSET, 
		AlipaynewConfig.ALIPAY_PUBLIC_KEY, AlipaynewConfig.SIGN_TYPE); //获得初始化的AlipayClient
    }
    
    @RequestMapping("pay")
    public String pay(HttpServletRequest request,HttpServletResponse response,
    		String orderId, String orderPayId,  ModelMap modelMap) throws Exception{
        Order order = orderService.selectById(orderId);

        if(order == null) {
            throw new NullPointerException("根据订单号查询不到订单信息！");
        }

        Ordership ordership = ordershipService.selectOne(new Ordership(orderId));
        if(ordership==null){
            throw new NullPointerException("根据订单号查询不到配送信息！");
        }
        Orderpay orderpay = orderpayService.selectById(orderPayId);
        if(orderpay==null){
            throw new NullPointerException("根据订单号查询不到配送信息！");
        }
        order.setOrderpayID(orderPayId);
        PayInfo payInfo = createPayInfo(order,ordership);
//        RequestHolder.getRequest().setAttribute("payInfo", payInfo);
        modelMap.addAttribute("payInfo", payInfo);

        ///使用的网关
        String paygateType = systemManager.getProperty("paygate.type");
        if("dummy".equalsIgnoreCase(paygateType)) {
            return "paygate/dummy/pay";
        }
        //调转到阿里支付
        alipay(request, response, payInfo);
        return null;
    }
    
    
    private void alipay(HttpServletRequest request,HttpServletResponse response,PayInfo payInfo)
    	throws Exception{
    	
        AlipayTradePagePayRequest alipayRequest = new AlipayTradePagePayRequest();//创建API对应的request
        StringBuilder baseurl=new StringBuilder();
        baseurl.append(request.getScheme()+"://");
        baseurl.append(request.getServerName());
        baseurl.append(":"+request.getServerPort());
        baseurl.append(request.getContextPath());
        
        alipayRequest.setReturnUrl(baseurl.toString()
        		+systemManager.getProperty("pay.return.url"));
        alipayRequest.setNotifyUrl(baseurl.toString()
        		+systemManager.getProperty("pay.notify.url"));//在公共参数中设置回跳和通知地址
        alipayRequest.setBizContent("{" +
            "    \"out_trade_no\":\"" +payInfo.getWIDout_trade_no()+"\","+
            "    \"product_code\":\"FAST_INSTANT_TRADE_PAY\","+
            "    \"total_amount\":" +payInfo.getAmount()+","+
            "    \"subject\":\"" +payInfo.getWIDsubject()+"\","+
            "    \"body\":\"" +payInfo.getWIDbody()+"\","+
            "    \"passback_params\":\"merchantBizType%3d3C%26merchantBizNo%3d2016010101111\"," +
            "    \"extend_params\":{" +
            "    \"sys_service_provider_id\":\"" +AlipayConfig.partner+"\""+
            "    }"+
            "  }");//填充业务参数
        String form="";
        try {
            form = alipayClient.pageExecute(alipayRequest).getBody(); //调用SDK生成表单
        } catch (AlipayApiException e) {
            e.printStackTrace();
            response.setContentType("text/html;charset=" + "UTF-8");
            response.getWriter().write("支付发送错误！！！");//直接将完整的表单html输出到页面
            response.getWriter().flush();
            response.getWriter().close();
            return;
        }
        response.setContentType("text/html;charset=" + "UTF-8");
        response.getWriter().write(form);//直接将完整的表单html输出到页面
        response.getWriter().flush();
        response.getWriter().close();
    }
    /**
     * 创建支付宝的付款信息对象
     * @param order
     */
    private PayInfo createPayInfo(Order order,Ordership ordership) {
        if(order==null || ordership==null){
            throw new NullPointerException("参数不能为空！请求非法！");
        }

        PayInfo payInfo = new PayInfo();
        payInfo.setWIDseller_email(ordership.getPhone());
        String www = SystemManager.getInstance().getSystemSetting().getWww();

        /**
         * 解决由于本地和线上正式环境提交相同的商户订单号导致支付宝出现TRADE_DATA_MATCH_ERROR错误的问题。
         * 本地提交的商户订单号前缀是test开头，正式环境提交的就是纯粹的支付订单号
         */
        if(www.startsWith("http://127.0.0.1") || www.startsWith("http://localhost")){
            payInfo.setWIDout_trade_no("test"+order.getOrderpayID());
        }else{
            payInfo.setWIDout_trade_no(order.getOrderpayID());
        }
        payInfo.setWIDsubject(order.getProductName());

        payInfo.setWIDprice(Double.valueOf(order.getPtotal()));
        payInfo.setWIDbody(order.getRemark());
//		payInfo.setShow_url(SystemManager.systemSetting.getWww()+"/product/"+payInfo.getWIDout_trade_no()+".html");
        payInfo.setShow_url(SystemManager.getInstance().getSystemSetting().getWww()+"/order/orderInfo.html?id="+order.getId());
        payInfo.setWIDreceive_name(ordership.getShipname());
        payInfo.setWIDreceive_address(ordership.getShipaddress());
        payInfo.setWIDreceive_zip(ordership.getZip());
        payInfo.setWIDreceive_phone(ordership.getTel());
        payInfo.setWIDreceive_mobile(ordership.getPhone());
        payInfo.setWIDsubject(order.getRemark());

        payInfo.setLogistics_fee(Double.valueOf(order.getFee()));
        payInfo.setLogistics_type(order.getExpressCode());
        payInfo.setAmount(Double.valueOf(order.getAmount()));
        payInfo.setProductCode(String.valueOf(order.getProductID()));
        logger.debug(payInfo.toString());
        return payInfo;
    }

    @RequestMapping("dummyPay")
    @ResponseBody
    public String dummyPay(String orderId){
        orderService.alipayNotify("WAIT_SELLER_SEND_GOODS",null,orderId,String.valueOf(System.nanoTime()));
        return "{\"success\":1}";
    }
}
