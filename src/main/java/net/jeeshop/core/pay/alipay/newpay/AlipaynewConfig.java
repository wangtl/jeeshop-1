package net.jeeshop.core.pay.alipay.newpay;

public class AlipaynewConfig {
	
	//↓↓↓↓↓↓↓↓↓↓请在这里配置您的基本信息↓↓↓↓↓↓↓↓↓↓↓↓↓↓↓
	public static String GATEWAY = null;
	// PPID 即创建应用后生成的字符串
	public static String APPID = null;
	// 开发者私钥
	public static String APP_PRIVATE_KEY = null;
	//支付宝公钥
	public static String ALIPAY_PUBLIC_KEY = null;

	//↑↑↑↑↑↑↑↑↑↑请在这里配置您的基本信息↑↑↑↑↑↑↑↑↑↑↑↑↑↑↑
	

	public static String FORMAT = "json";

	// 字符编码格式 目前支持 gbk 或 utf-8
	public static String CHARSET = "utf-8";
	
	// 商户生成签名字符串所使用的签名算法类型
	public static String SIGN_TYPE = "RSA2";

}
