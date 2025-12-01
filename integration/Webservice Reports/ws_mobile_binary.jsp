<%@ page language="java"
%><%@ page import="java.util.*, com.hof.util.*, com.hof.mi.web.service.*"
%><%

response.setHeader("Cache-Control", "no-cache");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);

String id = (String)request.getParameter("id");
i4Report rpt = (i4Report)session.getAttribute("YFREPORT");
ReportBinaryObject rbo = (ReportBinaryObject)rpt.getBlobs().get(id);
if (rbo.getContentType() != null) {
   response.setContentType(rbo.getContentType());
}
java.io.BufferedOutputStream o = new java.io.BufferedOutputStream(response.getOutputStream(), 8000);
if (rbo.getData() != null) {
   o.write(rbo.getData());
   o.flush();
}

%>