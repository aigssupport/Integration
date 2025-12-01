<%! private static final String cvsId = "$Id: ws_admin_singlesignon.jsp,v 1.1 2012-02-17 02:26:51 steve Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.hof.util.*, java.util.*, java.text.*" %> 
<%@ page import="com.hof.web.form.*" %>
<%@ page import="com.hof.mi.web.service.*" %>
<%

String action = request.getParameter("action");
String url = "";

if ("reports".equals(action)) {
	String adminName = "admin@yellowfin.com.au";
	String adminPass = "test";
	
	String userName = "admin@yellowfin.com.au";
	String userPass = "test";
	String userComp = "";
	
	String scheme = request.getScheme();
	String host = request.getServerName();
	Integer port = request.getServerPort();
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
	rsr.setOrgRef(userComp);
	rsr.setParameters(new String[] {"CONTENT_INCLUDE=TUTORIAL"});
	
	// Function specific attributes
	AdministrationPerson ap = new AdministrationPerson();
	ap.setUserId(userName);
	ap.setPassword(userPass);
	rsr.setPerson(ap);
	
	// Call webservice
	rs = rssbs.remoteAdministrationCall(rsr);
	if ("SUCCESS".equals(rs.getStatusCode()) ) {
		url = scheme + "://" + host + ":" + port + "/logon.i4?LoginWebserviceId=" + rs.getLoginSessionId()+"&yftoolbar=false&entry=BROWSE&hideheader=true&hidefooter=true&disablesidenav=true";
		//response.sendRedirect(url);
	} else {
		out.write("LOGINUSER Failed...<br>");
		out.write("Error Code: " + rs.getErrorCode()+"<br>");
	}
}
%>
<html>
<head>
	<title>My ERP System</title>
	<style>
		.pagefont { font:normal 13px Arial; }
		div > img {padding: 13; width: 95%}
		div > object { height: 1024px; width: 100%}
	</style>
</head>
<body class="pagefont" style="margin:0; padding:0; background-color:#DDDDDD;" leftmargin="0" topmargin="0" marginwidth="0" marginheight="0" >
	<jsp:include page="tight_header.jsp" />
	<div  style="background-color:#FFFFFF; margin:0;">
		<% if (action==null || "home".equals(action)) { %>
			<img src="./images/CRMHome.png">
		<% } else if ("messages".equals(action)) { %>
		<img src="./images/CRMLeads.png">
		<% } else if ("settings".equals(action)) { %>
			<img src="./images/CRMContacts.png">
		<% } else if ("reports".equals(action)) { %>
			<object id="container" type="text/html" data="<%= url%>" ></object>
		<% } %>
	</div>

</body>
</html>