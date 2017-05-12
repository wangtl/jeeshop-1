<#macro htmlBase title="" jsFiles=[] cssFiles=[] staticJsFiles=[] staticCssFiles=[] checkLogin=true>
<!DOCTYPE html>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <#assign non_responsive2>y</#assign>
    <#assign responsive>${Session["responsive"]!""}</#assign>
    <#if responsive == "y">
        <#assign non_responsive2>n</#assign>
    <#elseif systemSetting().openResponsive == "n">
        <#assign non_responsive2>y</#assign>
    <#else >
        <#assign non_responsive2>n</#assign>
    </#if>
    <script>
        var basepath = "${basepath}";
        var staticpath = "${staticpath}";
        var imageRootPath = "${systemSetting().imageRootPath}";
        var non_responsive2 = "${non_responsive2}";
        var systemCode = "${systemSetting().systemCode}"
            <#if currentUser()??>
            var login = true;
            var currentUser = "${currentUser().username}";
            <#else >
            var login = false;
            var currentUser = "";
                <#if checkLogin>
                top.location = "${basepath}/manage/user/logout";
                </#if>
            </#if>
    </script>
    <#if non_responsive2 != "y">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
    </#if>
    <meta name="description" content="${systemSetting().description}"/>
    <meta name="keywords" content="${systemSetting().keywords}"/>
    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <title>${(title?? && title!="")?string("${systemSetting().systemCode} - "+ title , "${systemSetting().systemCode}")}</title>
    <link rel="shortcut icon" type="image/x-icon" href="${basepath}/favicon.ico">
    <link href="http://g.alicdn.com/bui/bui/1.1.21/css/bs3/dpl.css" rel="stylesheet">
    <link href="http://g.alicdn.com/bui/bui/1.1.21/css/bs3/bui.css" rel="stylesheet">
    <link rel="stylesheet" href="${staticpath}/bui-admin/index.css">


    <script type="text/javascript" src="${staticpath}/js/jquery-1.9.1.min.js"></script>
    <script src="http://g.tbcdn.cn/fi/bui/bui-min.js?t=201309041336"></script>


</head>
    <#nested />
</html>
</#macro>
