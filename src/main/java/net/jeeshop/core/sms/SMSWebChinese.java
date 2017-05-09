package net.jeeshop.core.sms;

import java.io.IOException;
import java.io.UnsupportedEncodingException;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.apache.http.HttpException;
import org.apache.http.HttpResponse;
import org.apache.http.NameValuePair;
import org.apache.http.client.entity.UrlEncodedFormEntity;
import org.apache.http.client.methods.HttpPost;
import org.apache.http.impl.client.DefaultHttpClient;
import org.apache.http.message.BasicNameValuePair;
import org.apache.http.util.EntityUtils;

import net.jeeshop.core.util.CheckSumBuilder;
import net.jeeshop.services.manage.sms.bean.Sms;

/**
 * http://www.webchinese.com.cn   此公司的SMS短信平台
 * @author jqsl2012@163.com
 *
 */
public class SMSWebChinese {
	public static void main(String[] args) throws HttpException, IOException {
		sendSMS(null);
	}

	public static void sendSMS(Sms sms) throws IOException, HttpException,
			UnsupportedEncodingException {
		DefaultHttpClient httpClient = new DefaultHttpClient();
		String url = "https://api.netease.im/nimserver/user/create.action";
		HttpPost httpPost = new HttpPost(url);

		String appKey = "94kid09c9ig9k1loimjg012345123456";
		String appSecret = "123456789012";
		String nonce =  "12345";
		String curTime = String.valueOf((new Date()).getTime() / 1000L);
		String checkSum = CheckSumBuilder.getCheckSum(appSecret, nonce, curTime);//参考 计算CheckSum的java代码

		// 设置请求的header
		httpPost.addHeader("AppKey", appKey);
		httpPost.addHeader("Nonce", nonce);
		httpPost.addHeader("CurTime", curTime);
		httpPost.addHeader("CheckSum", checkSum);
		httpPost.addHeader("Content-Type", "application/x-www-form-urlencoded;charset=utf-8");

		// 设置请求的参数
		List<NameValuePair> nvps = new ArrayList<NameValuePair>();
		nvps.add(new BasicNameValuePair("accid", "helloworld"));
		httpPost.setEntity(new UrlEncodedFormEntity(nvps, "utf-8"));

		// 执行请求
		HttpResponse response = httpClient.execute(httpPost);

		// 打印执行结果
		System.out.println(EntityUtils.toString(response.getEntity(), "utf-8"));
	}
}
