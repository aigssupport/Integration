<%! private static final String cvsId = "$Id: ws_mobile_login.jsp,v 1.1 2012/02/17 02:26:51 steve Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.hof.util.*" %>
<%@ page import="com.hof.mi.web.service.*" %>
<%@ page import="java.util.*"%>
<%

String adminName = "admin@yellowfin.com.au";
String adminPass = "test";

String scheme = request.getScheme();
String host = request.getServerName();
int port = request.getServerPort();
boolean secure = "https".equalsIgnoreCase(scheme);
String protocol = secure ? "https" : "http";
String portPart = (port == 80 || port == 443) ? "" : ":" + port;     //checks if the port is standard(80/443), if it is not standard, it append :port
String baseUrl = protocol + "://" + host + portPart;
String adminWsdl = "/services/AdministrationService";
String reportWsdl =  "/services/ReportService";
String versionWsdl =  "/services/VersionService";

%>
<%!

private void validateUser(HttpServletRequest request, HttpServletResponse response, AdministrationServiceClient asc, String userId, String password, String client) throws WebserviceException {

   asc.setClientReferenceId(client);

   // validate user
   boolean result = asc.validateUser(userId, password);
   if (!result) throw new WebserviceException(asc.getErrorCode().intValue());

   // ok.. set session attributes and log in
   request.getSession().setAttribute("YFUSERID", userId);
   request.getSession().setAttribute("YFPASSWORD", password);
   request.getSession().setAttribute("YFCLIENTREF", client);

   String baseuri = request.getRequestURI();
   int index = baseuri.lastIndexOf('/');
   if (index >= 0) baseuri = baseuri.substring(0, index);
   String url = baseuri + "/ws_mobile_home.jsp";
   if (request.getSession().getId() != null) {
      url += ";jsessionid=" + request.getSession().getId();
   }
   try {
      response.sendRedirect(url);
   } catch (Exception e) {
   }

}

%>
<%

response.setHeader("Cache-Control", "no-cache");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);


System.out.println("DEBUG :: scheme       = " + scheme);
System.out.println("DEBUG :: host         = " + host);
System.out.println("DEBUG :: port         = " + port);
System.out.println("DEBUG :: secure       = " + secure);
System.out.println("DEBUG :: protocol     = " + protocol);
System.out.println("DEBUG :: portPart     = " + portPart);
System.out.println("DEBUG :: baseUrl      = " + baseUrl);
System.out.println("DEBUG :: adminWsdl    = " + adminWsdl);

// What URL Yellowfin will actually call:
String fullWsdlUrl = protocol + "://" + host + portPart + adminWsdl;
System.out.println("DEBUG :: full WSDL URL = " + fullWsdlUrl);


AdministrationServiceClient asc = new AdministrationServiceClient(host, port, adminName, adminPass, secure);


String cmd = request.getParameter("cmd");
int error = WebserviceException.NO_ERROR;
if ("login".equals(cmd)) {
   String userid = request.getParameter("userid");
   String password = request.getParameter("password");
   String client = request.getParameter("client");
   try {
      validateUser(request, response, asc, userid, password, client);
   } catch (WebserviceException e) {
      error = e.getErrorCode();
   }
}
%>
<html>
<head>
<title>Yellowfin login</title>
<link rel="stylesheet" type="text/css" href="css/ie.css" />
</head>
<body>
<h1>Yellowfin Login</h1>
<%
if (error != WebserviceException.NO_ERROR) { %>
<p>Error: <%=WebserviceException.getErrorString(error)%></p>
<%
} %>
<%
String formAction = "ws_mobile_login.jsp";
if (request.getSession().getId() != null) {
   formAction += ";jsessionid=" + request.getSession().getId();
} %>
<form method="post" action="<%=formAction%>">
<input type="hidden" name="cmd" value="login" />
<input type="hidden" name="client" value="" />
User Id:<br />
<input type="text" name="userid" /><br />
Password:<br />
<input type="password" name="password" /><br />
<input type="submit" value="Login" /><br />
</form>
<hr />
Web Service client library version: 
<%=AdministrationServiceClient.getClientRelease()%> build <%=AdministrationServiceClient.getClientBuild()%><br />
<% try {
      VersionServiceClient vsc = new VersionServiceClient(host, port, versionWsdl);
      VersionServiceResponse vsr = vsc.getDetails(); %>
Server version:
<%=vsr.getVersionNumber()%> build <%=vsr.getBuildNumber()%><br />
<% } catch (Throwable t) {} %>
</body>
</html>
