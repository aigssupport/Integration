<%! private static final String cvsId = "$Id: ws_mobile_logoff.jsp,v 1.1 2012/02/17 02:26:51 steve Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.hof.util.*" %>
<%@ page import="com.hof.mi.web.service.*" %>
<%@ page import="java.util.*" %>
<%

response.setHeader("Cache-Control", "no-cache");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

// remove session attribute
request.getSession().removeAttribute("YFUSERID");
request.getSession().removeAttribute("YFPASSWORD");
request.getSession().removeAttribute("YFCLIENTREF");

// redirect to login page
String baseuri = request.getRequestURI();
int index = baseuri.lastIndexOf('/');
if (index >= 0) baseuri = baseuri.substring(0, index);
String url = baseuri + "/ws_mobile_login.jsp";
if (request.getSession().getId() != null) {
   url += ";jsessionid=" + request.getSession().getId();
}
try {
   response.sendRedirect(url);
} catch (Exception e) {
}

%>