<%! private static final String cvsId = "$Id: ws_admin_singlesignon.jsp,v 1.1 2012-02-17 02:26:51 steve Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.hof.util.*, java.util.*, java.text.*" %> 
<%@ page import="com.hof.web.form.*" %>
<%@ page import="com.hof.mi.web.service.*" %>
<%
String adminName = "admin@yellowfin.com.au";
String adminPass = "test";

String userName = request.getParameter("userName");
String userPass = request.getParameter("userPass");
String redirect = request.getParameter("redirect");

String scheme = request.getScheme();
String host = request.getServerName();
Integer port =request.getServerPort();
Boolean secure = (scheme == "https") ? true : false;
String adminWsdl = "/services/AdministrationService";

AdministrationServiceResponse rs = null;
AdministrationServiceRequest rsr = new AdministrationServiceRequest();

AdministrationServiceService ts = new AdministrationServiceServiceLocator(host, port, adminWsdl, secure);
AdministrationServiceSoapBindingStub rssbs = (AdministrationServiceSoapBindingStub) ts.getAdministrationService();

// Service authentication attributes    
rsr.setLoginId(adminName);
rsr.setPassword(adminPass);
rsr.setOrgId(new Integer(1));
rsr.setFunction("LOGINUSER");
rsr.setOrgRef(request.getParameter("userComp"));

// User specific attributes
AdministrationPerson ap = new AdministrationPerson();
ap.setUserId(userName);
ap.setPassword(userPass);
rsr.setPerson(ap);

// Call webservice
rs = rssbs.remoteAdministrationCall(rsr);
if ("SUCCESS".equals(rs.getStatusCode()) ) {
	
	String url = scheme + "://" + host + ":" + port + "/logon.i4?LoginWebserviceId=" + rs.getLoginSessionId();
	
	if (request.getParameter("redirect")!=null) {
		response.sendRedirect(url);
	} else {
		out.write("Successfully Logged in User: <br>URL: <a href='" + url + "'>"+ url + "</a><br>");
	}
} else {
	out.write("LOGINUSER Failed...<br>");
	out.write("Error Code: " + rs.getErrorCode()+"<br>");
}
%>
