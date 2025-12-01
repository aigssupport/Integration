<%@ page language="java"
%><%@ page import="java.util.*, com.hof.util.*, com.hof.mi.web.service.*"
%><%

response.setHeader("Cache-Control", "no-cache");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

String id = (String)request.getParameter("id");
i4Report rpt = (i4Report)session.getAttribute("YFREPORT");
ReportChart rc = (ReportChart)rpt.getCharts().get(id);
if (rc.getContentType() != null) {
   response.setContentType(rc.getContentType());
}
java.io.BufferedOutputStream o = new java.io.BufferedOutputStream(response.getOutputStream(), 8000);
byte[] decoded = com.hof.util.Base64.decode(rc.getData().toString());
if (decoded != null) {
   o.write(decoded);
   o.flush();
}

%>