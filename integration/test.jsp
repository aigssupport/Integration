<%! private static final String cvsId = "$Id: ws_mobile_home.jsp,v 1.3 2012/10/02 23:41:40 jacob Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.hof.util.*" %>
<%@ page import="com.hof.mi.web.service.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.net.*" %>
<%@ page import="java.util.*" %>
<%

String adminName = "admin@yellowfin.com.au";
String adminPass = "test";

String scheme = request.getScheme();
String host = request.getServerName();
Integer port = request.getServerPort();
Boolean secure = (scheme == "https") ? true : false;
String adminWsdl = "/services/AdministrationService";
String reportWsdl = "/services/ReportService";

System.out.println(request.getScheme());
System.out.println(request.getServerName());
System.out.println(request.getServerPort());
System.out.println(secure);
%>
