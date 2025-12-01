<%! private static final String cvsId = "$Id: ws_admin_singlesignon.jsp,v 1.1 2012-02-17 02:26:51 steve Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.hof.util.*, java.util.*, java.text.*" %> 
<%@ page import="com.hof.web.form.*" %>
<%@ page import="com.hof.mi.web.service.*" %>
<%

String adminName = "admin@yellowfin.com.au";
String adminPass = "test";

String userName = "admin@yellowfin.com.au";
String userPass = "test";

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

// User specific attributes
AdministrationPerson ap = new AdministrationPerson();
ap.setUserId(userName);
ap.setPassword(userPass);
rsr.setPerson(ap);

// Call webservice
rs = rssbs.remoteAdministrationCall(rsr);
String token = "";
if ("SUCCESS".equals(rs.getStatusCode()) ) {
	token = rs.getLoginSessionId();
} else {
	out.write("LOGINUSER Failed...<br>");
	out.write("Error Code: " + rs.getErrorCode()+"<br>");
	return;
}
%>
<html>
<head>
	<title>Interesting Blog or Intranet Page</title>
	<style>
		.pagefont { font:normal 13px Arial; };
		#sidebar {
			float: left;   
		}
		#sidebar ul { font-size:16px; }
		#sidebar2 {
			padding-left: 40;
			padding-top: 0;
			width:80%;
		}
		#headerline
		{
			background-image:url('HeaderLine.png');
			background-repeat:repeat-y;
		}
		ul {list-style-type:none; margin:0; padding:0; overflow:hidden;}
		ul li a {display:block; text-decoration:none; text-align:center; font-weight:bold; padding:9px 20px 9px 20px; font-family:Arial; font-size:13pt; color:#95FA3B!important; text-transform:uppercase; url(bg.gif) repeat-x; text-transform:uppercase; letter-spacing:.08em}
		ul li a:hover,
		body#home .nav-home,
		body#Leads .nav-Leads,
		body#Contacts .nav-Contacts
		body#Reports .nav-Reports
		{color:#FFFFFF; border-top:1px solid #424242; border-right:1px solid #424242; border-left:1px solid #424242; url(bg2.gif) repeat-x}
		ul li a.first {border-left:0}
		ul li a.last {border-right:0}
	</style>
</head>
<body class="pagefont">
	<div id="navbar" style="background-color:#FFFFFF; margin:0px; padding:13;  height:103px;">
		<a style="float:left;" href="../demo.html"> <img src="./images/Robot.png"> </a>
	</div>
	<div style="background-color:#00a6E4; height:8; width:100%; padding:0;"> </div>
	<div style="position: center;">
		<div id="sidebar" style="width:60%; padding-left: 0px;">
			<h2 style="color:#009eec; padding-left:12;"> Performance Dashboard </h2>
			<ul>
				<li style="float: left;">
					''I think it's turned out better than most expected, because of, ironically, the way it has unfolded, and it's probably got a far greater profile even though didn't end up winning it, in fact possibly because of it, because this thing has gripped the over the last few days.''
					High profile publications such as the New York Times and the Wall Street Journal had run extensive stories covering involvement.
				</li>
				<br><br><br>
			</ul>
		</div>
		<div id="sidebar2">
		</div>
	</div>
	<br>
	<table border="1" style="border-collapse:collapse; border-color:#FFFFFF; border-style:none">
		<tr>
			<td><script style="float: left;" type="text/javascript" src="<%= scheme %>://<%= host %>:<%= port %>/JsAPI?dashUUID=f19e63f5-7175-4c57-897d-ed865aba8972&&token=<%= token %>"></script></td>
			<td style="padding-left:120;"><img src="./images/Feed.png"></td>
		</tr>
	</table>
</body>
</html>