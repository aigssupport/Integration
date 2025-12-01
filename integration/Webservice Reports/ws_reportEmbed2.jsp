<%! private static final String cvsId = "$Id: ws_admin_singlesignon.jsp,v 1.1 2012-02-17 02:26:51 steve Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %> 
<%@ page import="com.hof.web.form.*" %>
<%@ page import="com.hof.mi.web.service.*" %>
<%@ page import="com.hof.util.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="com.hof.util.*, java.util.*, java.text.*" %>
<%@ page import="java.net.*" %>
<%@ page import="java.util.*" %>
<%!

private String getSupportedImageType(HttpServletRequest request) {
	String[] arr = javax.imageio.ImageIO.getWriterMIMETypes();
	// map types
	Map types = new HashMap();
	for (int i = 0; i < arr.length; i++) {
		types.put(arr[i].toUpperCase(), arr[i]);
	}
	
	// get accepted types, and order by quality
	Enumeration en = request.getHeaders("accept");
	String s = null;
	String[] parts = null;
	TreeMap map = new TreeMap();
	ArrayList al = null;
	Object[] o = null;
	while (en.hasMoreElements()) {
		s = (String)en.nextElement();
		parts = s.split(",");
		for (int i = 0; i < parts.length; i++) {
			o = convert(parts[i].trim());
			if (!((String)o[0]).startsWith("image/")) continue; // only interested in image types
			al = (ArrayList)map.get(o[1]); // map by q
			if (al == null) {
				al = new ArrayList();
				map.put(o[1], al);
			}
			al.add(o);
			
			if (o.length > 0) {
				if ("image/png".equals(o[0])) {
					return((String)o[0]);
				} else if ("image/jpeg".equals(o[0]) || "image/jpg".equals(o[0])) {
					return((String)o[0]);
				}
			}
		}
	}
	
	Object[] keys = map.keySet().toArray();
	for (int i = keys.length - 1; i >= 0; i--) {
		al = (ArrayList)map.get(keys[i]);
		for (int j = 0; j < al.size(); j++) {
			o = (Object[])al.get(j);
			if (types.containsKey(((String)o[0]).toUpperCase())) {
				return (String)o[0];
			}
		}
	}
	return null;
}

private static final BigDecimal DEFAULTQ = new BigDecimal("1.0");

private Object[] convert(String accept) {
	BigDecimal q = null;
	int i = accept.indexOf(';');
	if (i >= 0) {
		if (accept.length() > i + 2) {
			if (accept.substring(i + 1, i + 3).equals("q=")) {
				String s = accept.substring(i + 3);
				int i2 = s.indexOf(';');
				if (i2 >= 0) {
					s = s.substring(0, i2);
				}
				try {
					q = new BigDecimal(s);
				} catch (Exception e) {}
			}
		}
		accept = accept.substring(0, i);
	}
	if (q == null) q = DEFAULTQ;
	return new Object[] { accept, q };
}
%>
<%
String adminName = "admin@yellowfin.com.au";
String adminPass = "test";

String userName = "admin@yellowfin.com.au";
String userPass = "test";

String scheme = request.getScheme();
String host = request.getServerName();
Integer port = request.getServerPort();
String adminPath = "/services/AdministrationService";
String reportPath = "/services/ReportService";

AdministrationServiceResponse rs = null;
AdministrationServiceRequest rsr = new AdministrationServiceRequest();
AdministrationServiceService ts = new AdministrationServiceServiceLocator(host, port, adminPath, true);
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

AdministrationServiceClient asc = new AdministrationServiceClient(host, port, adminName, adminPass, adminPath);
ReportServiceClient rsc = new ReportServiceClient(host, port,  adminName, adminPass, reportPath);

String cmd = request.getParameter("cmd");
i4Report rpt = null;
if ("run".equals(cmd)) {
	
	Integer id = Integer.valueOf(request.getParameter("id"));
	String userId = (String)request.getSession().getAttribute("YFUSERID");
	rpt = rsc.loadReportForUser(id, userName, userPass, null);
	if (rpt == null) throw new WebserviceException(rsc.getErrorCode().intValue());
	request.getSession().setAttribute("YFREPORT", rpt);
	
	String url = "../Single Sign-On/SS0.jsp";
	if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) {
		url += ";jsessionid=" + request.getSession().getId();
	}
	url += "?cmd=cmd&sub=";
	rpt.setLinkURL(url);
	
	url = "./ws_mobile_image.jsp";
	if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) {
		url += ";jsessionid=" + request.getSession().getId();
	}
	url += "?id=";
	rpt.setImageURL(url);
	rpt.setImageType(getSupportedImageType(request));
	
	url = "./ws_mobile_binary.jsp";
	if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) {
		url += ";jsessionid=" + request.getSession().getId();
	}
	url += "?id=";
	rpt.setBinaryURL(url);
	rpt.setSinglePage(true);
	rpt.setActiveCharts(true);
}
%>
<html>
<head>
	<style>
		nav ul ul {
			display: none;
		}
		nav ul li:hover > ul {
			display: block;
		}
		nav ul {
			background: linear-gradient(top, #efefef 0%, #bbbbbb 100%);  
			background: -moz-linear-gradient(top, #efefef 0%, #bbbbbb 100%); 
			box-shadow: 0px 0px 9px rgba(0,0,0,0.15);
			padding: 0 0px;
			border-radius: 10px;  
			list-style: none;
			position: relative;
			display: inline-table;
			z-index: 999;
		}
		nav ul:after {
			content: ""; clear: both; display: block;
		}
		nav ul li {
			float: left;
		}
		nav ul li:hover {
			background: #4b545f;
			background: linear-gradient(top, #4f5964 0%, #5f6975 40%);
			background: -moz-linear-gradient(top, #4f5964 0%, #5f6975 40%);
			background: -webkit-linear-gradient(top, #4f5964 0%,#5f6975 40%);
			
			
		}
		nav ul li:hover a {
			color: #fff;
			
		}
		nav ul li a {
			display: block; padding: 15px 35px;
			color: #757575; text-decoration: none;
		}
		nav ul ul {
			background: #5f6975; border-radius: 0px; padding: 0;
			position: absolute; top: 100%;
		}
		nav ul ul li {
			float: none; 
			border-top: 1px solid #6b727c;
			border-bottom: 1px solid #575f6a;
			position: relative;
		}
		nav ul ul li a {
			padding: 5px 10px;
			color: #fff;
		}
		nav ul ul li a:hover {
			background: #4b545f;
		}
	</style>
<head>
<body>
	<img src="../yf_header.gif" style="float:left; padding-left:5;">
	<nav style="height:80; margin:0; float:left; padding-left:25;">
		<ul>
			<li> <a href="./ws_reportEmbed.jsp"> Home </a> </li>
			<li> <a href="#"> Reports </a>
				<ul>
					<%	String url = "./ws_reportEmbed.jsp";
						if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
						url += "?cmd=run&id=" + "54035";
					%>
					<li><a href="<%=url%>">Profit Margin</a></li>
					<%	url = "./ws_reportEmbed.jsp";
						if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
						url += "?cmd=run&id=" + "53824"; %>
					<li><a href="<%=url%>">Athlete Spending</a></li>
					<%	url = "./ws_reportEmbed.jsp";
						if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
						url += "?cmd=run&id=" + "55367"; %>
					<li><a href="<%=url%>">Athlete GIS Map</a></li>
					<%	url = "./ws_reportEmbed.jsp";
						if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
						url += "?cmd=run&id=" + "53941"; %>
					<li><a href="<%=url%>">Cancelled Bookings</a></li>
					<%	url = "./ws_reportEmbed.jsp";
						if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
						url += "?cmd=run&id=" + "54044"; %>
					<li><a href="<%=url%>">Sales Forecast</a></li>
				</ul>
			</li>
			<li> <a href="./ws_reportEmbed.jsp"> News Feed </a> </li>
			<li> <a href="./ws_reportEmbed.jsp"> My Profile </a> </li>
			<li> <a href="./ws_reportEmbed.jsp"> Settings </a> </li>
			<li> <a href="../demo.html"> Log off </a> </li>
		</ul>
	</nav>
	<br><br><br><br><br>
	<div style="background-color:#FAFAFA; margin:-5;">
		<% if(rpt != null) { %>
		<%
			rpt.run(null, "HTMLCHARTONLY"); 
		%>
		<style type="text/css">
			<% if (rpt.getReportStyle() != null) { %>
			<%=rpt.getReportStyle()%>
			<% } %>
		</style>
		
		<%=rpt.render()%>
		<% } else { %>
		<img src="WSOverview.PNG">
		<%	}%>
	</div>
<body>
</html>