<%@page import="net.jeeshop.core.oscache.FrontCache"%>
<%@page import="net.jeeshop.core.oscache.ManageCache"%>
<%@page import="org.springframework.web.context.support.WebApplicationContextUtils"%>
<%@page import="org.springframework.web.context.WebApplicationContext"%>
<%@page import="net.jeeshop.core.ManageContainer"%>
<%@ page contentType="text/html; charset=UTF-8"%>
<%
WebApplicationContext app = WebApplicationContextUtils.getWebApplicationContext(getServletContext());
ManageCache manageCache = (ManageCache) app.getBean("manageCache");
manageCache.loadAllCache();
out.println("加载数据成功！");
%>
