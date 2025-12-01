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
//Integer port = request.getServerPort();
Integer port = 80;
String adminWsdl = "/services/AdministrationService";

AdministrationServiceResponse rs = null;
AdministrationServiceRequest rsr = new AdministrationServiceRequest();
AdministrationServiceService ts = new AdministrationServiceServiceLocator(host, port, adminWsdl, false);
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
			float: left;
			padding-left: 50;
			padding-top: 60;
			width:auto;
		}
	</style>
</head>
<body class="pagefont">
	<div id="navbar" style="background-color:#FFFFFF; margin:0px; padding:13; height:103px;">
		<a style="float:left;" href="../demo.html"> <img src="./images/Robot.png"></a>
	</div>
	<div style="background-color:#00a6E4; height:8; width:100%; padding:0;"> </div>
	
	<div style="position: center;">
		<div id="sidebar" style="width:30%; float:left; padding-left: 0px;">
			<h2 style="color:#009eec; padding-left:12;"> Tracking Revenue Performance </h2>
			<ul>
				'I think it's turned out better than most expected, because of, ironically, the way it has unfolded, the cup, and it's probably got a far greater profile even though  didn't end up winning it, in fact possibly because of it, because this thing has gripped the Americas over the last few days.''
				
				High profile publications had run extensive stories covering involvement.
				
				<br><br>
				
				''I would say it's certainly come off for us in terms of investment. It was risky at the time, particularly since the GFC [global financial crisis] turned up, but you'd have to say it's turned out well.''
				
				Had spoken only briefly to key members of the team, who were not in a position to think about a defence.
				
				''I said to them, if they did bring a proposal to us, the Government would look at that seriously, given the outcome and given the profile that 's received out of the campaign,'' he said.
				
				<br><br>
				''We've just got to wait, let the dust settle, let the emotions settle. It's pretty raw here at the moment, as you can imagine. Some of the people here have been working on it for 10 years and are not really in a position to start making massive commitments,'' he said, with no one in the team thinking about the issue of a new challenge.
				
				''The intention was to win the cup. Right up until the end it was plan A and they didn't have a plan B.''
				
				Meanwhile it was the right decision for the Government.
				<br><br>
				"We can all go and second-guess it and of course it would have been great for if we'd won, but if you want to win something sometimes you have to be prepared to accept that you'll lose.
				
				''On this occasion we lost, it feels pretty tough, But I for one don't have any regrets about that $36 million."
				<br><br>
				
				<a style="font-size:20; font-style:italic;" href="./java_DashEmbed%20-%20Dashboard.jsp"> Performance Dashboard </a>
				
			</ul>
		</div>
		<div id="sidebar2">
			<script type="text/javascript" src="<%= scheme %>://<%= host %>:<%= port %>/JsAPI?reportUUID=f087bc89-5f3d-4f77-bd0b-e2fbe8e47a39&token=<%= token %>"></script>
		</div>
	</div>
</body>
</html>