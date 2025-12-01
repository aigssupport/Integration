<%! private static final String cvsId = "$Id: ws_admin_createuser.jsp,v 1.1 2012-02-17 02:26:51 steve Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.hof.util.*, java.util.*, java.text.*" %> 
<%@ page import="com.hof.web.form.*" %>
<%@ page import="com.hof.mi.web.service.*" %>
<%
String adminName = "admin@yellowfin.com.au";
String adminPass = "test";

String userFirst = request.getParameter("firstName");
String userLast = request.getParameter("lastName");
String userEmail = request.getParameter("emailAddress");
String userPass = request.getParameter("password");
String userRole = "YFADMIN";


String scheme = request.getScheme();
String host = request.getServerName();
int port = request.getServerPort();
boolean secure = "https".equalsIgnoreCase(scheme);
String protocol = secure ? "https" : "http";
String portPart = (port == 80 || port == 443) ? "" : ":" + port;     //checks if the port is standard(80/443), if it is not standard, it append :port
String baseUrl = protocol + "://" + host + portPart;
String adminWsdl = "/services/AdministrationService";

AdministrationServiceResponse rs = null;
AdministrationServiceRequest rsr = null;
AdministrationServiceService ts = new AdministrationServiceServiceLocator(host, port, adminWsdl, secure);
AdministrationServiceSoapBindingStub rssbs = (AdministrationServiceSoapBindingStub) ts.getAdministrationService();

// Service authentication attributes
rsr = new AdministrationServiceRequest();
AdministrationPerson ap = new AdministrationPerson();
AdministrationClientOrg client = new AdministrationClientOrg();
client.setDefaultOrg(true);
rsr.setClient(client);
rsr.setLoginId(adminName);
rsr.setPassword(adminPass);
rsr.setOrgId(new Integer(1));
rsr.setFunction("LISTUSERSATCLIENT");

// Call webservice
rs = rssbs.remoteAdministrationCall(rsr);
out.write("List users at Client : <br>");
if ("SUCCESS".equals(rs.getStatusCode())) {
	for (int y=0; y < rs.getPeople().length; y++) {
		AdministrationPerson p = rs.getPeople()[y];
		out.write(" " + p.getFirstName() + " " + p.getLastName() + " - " + p.getEmailAddress() + "<br>");
	}
} else {
	out.write("LISTUSERSATCLIENT Failed...<br>");
	out.write("Error Code: " + rs.getErrorCode()+"<br>");
}
out.write("<hr>");

// Service authentication attributes
rsr = new AdministrationServiceRequest();
rsr.setLoginId(adminName);
rsr.setPassword(adminPass);
rsr.setOrgId(new Integer(1));
rsr.setFunction("ADDUSER");

// New User Details
ap = new AdministrationPerson();
ap.setUserId(userEmail);
ap.setFirstName(userFirst);
ap.setLastName(userLast);
ap.setRoleCode(userRole);
ap.setPassword(userPass);
ap.setEmailAddress(userEmail);
ap.setLanguageCode("EN");
rsr.setPerson(ap);

// Call webservice
rs = rssbs.remoteAdministrationCall(rsr);
out.write("Creating new user : <br>");
if ("SUCCESS".equals(rs.getStatusCode()) ) {
	out.write("Successfully Created User: <br>" + userFirst + " " + userLast + " - " + userEmail + "<br>");
} else {
	out.write("ADDUSER Failed...<br>");
	out.write("Error Code: " + rs.getErrorCode()+"<br>");
}
out.write("<hr>");

// Service authentication attributes
rsr.setClient(client);
rsr.setLoginId(adminName);
rsr.setPassword(adminPass);
rsr.setOrgId(new Integer(1));
rsr.setFunction("LISTUSERSATCLIENT");

// Call webservice
rs = rssbs.remoteAdministrationCall(rsr);
out.write("List users at Client : <br>");
if ("SUCCESS".equals(rs.getStatusCode())) {
	for (int y=0; y < rs.getPeople().length; y++) {
		AdministrationPerson p = rs.getPeople()[y];
		out.write(" " + p.getFirstName() + " " + p.getLastName() + " - " + p.getEmailAddress() + "<br>");
	}
} else {
	out.write("LISTUSERSATCLIENT Failed...<br>");
	out.write("Error Code: " + rs.getErrorCode()+"<br>");
}
%>
<br>