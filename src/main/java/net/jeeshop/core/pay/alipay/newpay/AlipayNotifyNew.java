package net.jeeshop.core.pay.alipay.newpay;

import java.util.Map;

import com.alipay.api.AlipayApiException;
import com.alipay.api.internal.util.AlipaySignature;

/* *
 *类名：AlipayNotify
 *功能：支付宝通知处理类
 *详细：处理支付宝各接口通知返回
 *版本：3.3
 *日期：2012-08-17
 *说明：
 *以下代码只是为了方便商户测试而提供的样例代码，商户可以根据自己网站的需要，按照技术文档编写,并非一定要使用该代码。
 *该代码仅供学习和研究支付宝接口使用，只是提供一个参考

 *************************注意*************************
 *调试通知返回时，可查看或改写log日志的写入TXT里的数据，来检查通知返回是否正常
 */
public class AlipayNotifyNew {
	
	/**
     * 验证消息是否是支付宝发出的合法消息
     * @param params 通知返回来的参数数组
     * @return 验证结果
     */
    public static boolean verify(Map<String, String> params) {
    	boolean signVerified=false;
		try {
			//调用SDK验证签名
			signVerified = AlipaySignature.rsaCheckV1(params, 
					AlipaynewConfig.ALIPAY_PUBLIC_KEY, AlipaynewConfig.CHARSET, AlipaynewConfig.SIGN_TYPE);
		} catch (AlipayApiException e) {
			e.printStackTrace();
		} 
		return signVerified;
    }
}
