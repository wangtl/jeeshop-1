package net.jeeshop.core.oss;

import java.io.File;
import java.io.FileNotFoundException;
import java.util.List;

import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

import com.aliyun.oss.ClientConfiguration;
import com.aliyun.oss.ClientException;
import com.aliyun.oss.OSSClient;
import com.aliyun.oss.OSSException;
import com.aliyun.oss.model.CannedAccessControlList;
import com.aliyun.oss.model.GetObjectRequest;
import com.aliyun.oss.model.OSSObjectSummary;
import com.aliyun.oss.model.ObjectListing;
import com.aliyun.oss.model.ObjectMetadata;

import net.jeeshop.core.front.SystemManager;
import net.jeeshop.services.manage.oss.bean.AliyunOSS;

/**
 * 该示例代码展示了如果在OSS中创建和删除一个Bucket，以及如何上传和下载一个文件。
 * 
 * 该示例代码的执行过程是：
 * 1. 检查指定的Bucket是否存在，如果不存在则创建它；
 * 2. 上传一个文件到OSS；
 * 3. 下载这个文件到本地；
 * 4. 清理测试资源：删除Bucket及其中的所有Objects。
 * 
 * 尝试运行这段示例代码时需要注意：
 * 1. 为了展示在删除Bucket时除了需要删除其中的Objects,
 *    示例代码最后为删除掉指定的Bucket，因为不要使用您的已经有资源的Bucket进行测试！
 * 2. 请使用您的API授权密钥填充ACCESS_ID和ACCESS_KEY常量；
 * 3. 需要准确上传用的测试文件，并修改常量uploadFilePath为测试文件的路径；
 *    修改常量downloadFilePath为下载文件的路径。
 * 4. 该程序仅为示例代码，仅供参考，并不能保证足够健壮。
 *
 */
public class OSSObjectSample {
	private static final Logger logger = LoggerFactory.getLogger(OSSObjectSample.class);
    public static Object lock = new Object();
    
    /**
     * 上传本地文件到阿里云OSS
     * @param filePath 文件存储到阿里云OSS的路径
     * @param file	本地文件对象
     * @throws com.aliyun.oss.OSSException
     * @throws com.aliyun.oss.ClientException
     * @throws FileNotFoundException
     */
	public static void save(String filePath, File file) {
		try {
			save0(filePath, file);
		} catch (OSSException e) {
			e.printStackTrace();
		} catch (ClientException e) {
			e.printStackTrace();
		} catch (FileNotFoundException e) {
			e.printStackTrace();
		} catch (Exception e) {
			e.printStackTrace();
		}
	}

	private static void save0(String filePath, File file)
			throws FileNotFoundException {
        AliyunOSS aliyunOSS = SystemManager.getInstance().getAliyunOSS();
		if(aliyunOSS==null){
    		logger.error("阿里云存储未被启用");
    		return;
    	}
    	
    	logger.error("filePath="+filePath);
    	System.out.println("filePath="+filePath);
    	// 可以使用ClientConfiguration对象设置代理服务器、最大重试次数等参数。
        ClientConfiguration config = new ClientConfiguration();
        OSSClient client = new OSSClient(aliyunOSS.getOSS_ENDPOINT(), aliyunOSS.getACCESS_ID(), aliyunOSS.getACCESS_KEY(),config);

        ensureBucket(client, aliyunOSS.getBucketName());
        setBucketPublicReadable(client, aliyunOSS.getBucketName());
        // 获取Object，返回结果为OSSObject对象
        logger.error("bucketName=" + aliyunOSS.getBucketName());
       
        System.out.println("正在上传...");
//            fileName = System.currentTimeMillis() + "." +getExtensionName(fileName);
        String url = uploadFile(client, aliyunOSS.getBucketName(), filePath, file);
        System.out.println("上传成功！url="+url);
        client.shutdown();
	}
    
    /*
     * Java文件操作 获取文件扩展名
     *
     *  Created on: 2011-8-2
     *      Author: blueeagle
     */
    public static String getExtensionName(String filename) { 
        if ((filename != null) && (filename.length() > 0)) { 
            int dot = filename.lastIndexOf('.'); 
            if ((dot >-1) && (dot < (filename.length() - 1))) { 
                return filename.substring(dot + 1); 
            } 
        } 
        return filename; 
    } 


    // 如果Bucket不存在，则创建它。
    private static void ensureBucket(OSSClient client, String bucketName)
            throws OSSException, ClientException{

        if (client.doesBucketExist(bucketName)){
        	logger.error("isBucketExist true");
            return;
        }

        //创建bucket
        client.createBucket(bucketName);
    }

    // 删除一个Bucket和其中的Objects 
    private static void deleteBucket(OSSClient client, String bucketName)
            throws OSSException, ClientException {

        ObjectListing ObjectListing = client.listObjects(bucketName);
        List<OSSObjectSummary> listDeletes = ObjectListing
                .getObjectSummaries();
        for (int i = 0; i < listDeletes.size(); i++) {
            String objectName = listDeletes.get(i).getKey();
            // 如果不为空，先删除bucket下的文件
            client.deleteObject(bucketName, objectName);
        }
        client.deleteBucket(bucketName);
    }

    // 把Bucket设置为所有人可读
    private static void setBucketPublicReadable(OSSClient client, String bucketName)
            throws OSSException, ClientException {
        //创建bucket
        client.createBucket(bucketName);

        //设置bucket的访问权限，public-read-write权限
        client.setBucketAcl(bucketName, CannedAccessControlList.PublicRead);
    }

    // 上传文件
    private static String uploadFile(OSSClient client, String bucketName, String filePath, File file)
            throws OSSException, ClientException, FileNotFoundException {
        ObjectMetadata objectMeta = new ObjectMetadata();
        objectMeta.setContentLength(file.length());
        // 可以在metadata中标记文件类型
        objectMeta.setContentType("image/jpeg");

//        InputStream input = new FileInputStream(file);
//        SimpleDateFormat sdf = new SimpleDateFormat("yyyyMMdd");
//        String ymd = sdf.format(new Date());
//        String path = "attached/"+ymd+"/"+key;
        String key = filePath +file.getName();
        logger.info("oss-object:key="+key);
        client.putObject(bucketName, key, file,objectMeta);
        
        return "http://"+bucketName+".oss-cn-hangzhou.aliyuncs.com/"+filePath;
    }

    // 下载文件
    private static void downloadFile(OSSClient client, String bucketName, String key, String filename)
            throws OSSException, ClientException {
        client.getObject(new GetObjectRequest(bucketName, key),
                new File(filename));
    }
}
