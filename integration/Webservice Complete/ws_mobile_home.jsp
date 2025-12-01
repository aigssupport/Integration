<%! private static final String cvsId = "$Id: ws_mobile_home.jsp,v 1.3 2012/10/02 23:41:40 jacob Exp $"; %>
<%@ page language="java" contentType="text/html; charset=UTF-8" %>
<%@ page import="com.hof.util.*" %>
<%@ page import="com.hof.mi.web.service.*" %>
<%@ page import="java.math.BigDecimal" %>
<%@ page import="java.net.*" %>
<%@ page import="java.util.*" %>
<%

String adminName = "admin@yellowfin.com.au";
String adminPass = "test";

String scheme = request.getScheme();
String host = request.getServerName();
int port = request.getServerPort();
boolean secure = "https".equalsIgnoreCase(scheme);
String adminWsdl = "/services/AdministrationService";
String reportWsdl = "/services/ReportService";

System.out.println(request.getScheme());
System.out.println(request.getServerName());
System.out.println(request.getServerPort());
System.out.println(secure);
%>
<%!

private String checkLogin(HttpServletRequest request, HttpServletResponse response, AdministrationServiceClient asc) {

   HttpSession session = request.getSession();
   String userId = (String)session.getAttribute("YFUSERID");

   if (userId != null) {
      // check user id is valid
      AdministrationPerson ap = asc.getUser(userId);
      if (ap == null) userId = null;
   }

   if (userId == null) {
      // invalid or missing userid
      String baseuri = request.getRequestURI();
      int index = baseuri.lastIndexOf('/');
      if (index >= 0) baseuri = baseuri.substring(0, index);
      String url = baseuri + "/ws_mobile_login.jsp";
      if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) {
         url += ";jsessionid=" + request.getSession().getId();
      }
      try {
         response.sendRedirect(url);
      } catch (Exception e) {
      }
      return null;
   }

   return userId;

}

%>
<%

response.setHeader("Cache-Control", "no-cache");
response.setHeader("Pragma", "no-cache");
response.setDateHeader("Expires", 0);



AdministrationServiceClient asc = new AdministrationServiceClient(host, port, adminName, adminPass, secure);
ReportServiceClient rsc = new ReportServiceClient(host, port,  adminName, adminPass, secure);

String userId = checkLogin(request, response, asc);
if (userId == null) return;

%>
<html>
<head>
<title>Yellowfin Homepage</title>


<% /* For active charts to work, we need to include requirejs.js and ws.js.
    * We should also define yfBaseURL as a global variable that points to
    * the location of the Yellowfin installation.
    */
%>
<script type="text/javascript">
var yfBaseURL = '<%=scheme%>://<%=host%>:<%=port%>/';
console.log("Yellowfin Base URL:", yfBaseURL);
</script>
<script src="<%=scheme%>://<%=host%>:<%=port%>/js/libs/requirejs/requirejs.js"></script>
<script src="<%=scheme%>://<%=host%>:<%=port%>/js/ws.js"></script>


<script type="text/javascript">
function runReportCommand(cmd) {

   var url = 'ws_mobile_home.jsp';
<% if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) { %>
   url += ';jsessionid=<%=request.getSession().getId()%>';
<% } %>
   url += '?cmd=cmd&sub=' + encodeURIComponent(cmd);
   window.location = url;

}
</script>
</head>
<body>
<ul class="nav">
<%
String url = "ws_mobile_home.jsp";
if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
%> 
<li><a href="<%=url%>">Home</a></li>
<%
url = "ws_mobile_logoff.jsp";
if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
%> 
<li><a href="<%=url%>">Logoff</a></li>
</ul>
<%

String cmd = request.getParameter("cmd");
if ("run".equals(cmd) || "cmd".equals(cmd) || "setfilters".equals(cmd)) {
   try {
      
      i4Report rpt = null;
      if ("run".equals(cmd)) {

         Integer id = Integer.valueOf(request.getParameter("id"));
         userId = (String)request.getSession().getAttribute("YFUSERID");
         String password = (String)request.getSession().getAttribute("YFPASSWORD");
         rpt = rsc.loadReportForUser(id, userId, password, null);
         if (rpt == null) throw new WebserviceException(rsc.getErrorCode().intValue());
         request.getSession().setAttribute("YFREPORT", rpt);

         url = "javascript:runReportCommand('##');";
         rpt.setLinkURL(url);

         url = "ws_mobile_image.jsp";
         if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) {
            url += ";jsessionid=" + request.getSession().getId();
         }
         url += "?id=";
         rpt.setImageURL(url);
         rpt.setImageType(getSupportedImageType(request));

         url = "ws_mobile_binary.jsp";
         if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) {
            url += ";jsessionid=" + request.getSession().getId();
         }
         url += "?id=";
         rpt.setBinaryURL(url);

         rpt.setSinglePage(true);
         
         rpt.setActiveCharts(true);

      } else {

         rpt = (i4Report)request.getSession().getAttribute("YFREPORT");
         if (rpt == null) {
            String baseuri = request.getRequestURI();
            int index = baseuri.lastIndexOf('/');
            if (index >= 0) baseuri = baseuri.substring(0, index);
            url = baseuri + "/ws_mobile_home.jsp";
            if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) {
               url += ";jsessionid=" + request.getSession().getId();
            }
            try {
               response.sendRedirect(url);
            } catch (Exception e) {
            }
         }

      }

      //String[] filters = rpt.getFilterColumns();
      ReportSchema[] filters = rpt.getFilterSchema();
      if ("setfilters".equals(cmd)) {
         Map<String, String> filterMap = new HashMap<String, String>();
         if (filters != null) {
            String key = null;
            String val = null;
            for (int i = 0; i < filters.length; i++) {
               for (int j = 1; j <= 3; j++) {
                  key = "filter-" + filters[i].getFilterId() + "-val" + j;
                  //val = request.getParameter(key);
                  val = convertArrayToValue(request.getParameterValues(key));
                  filterMap.put(key, val);
               }
            }
            request.getSession().setAttribute("YFFILTERS", filterMap);
         }
      }

      // make sure filters are set in the i4Report object
      // this must be done before runnning a command
      if (filters != null && filters.length > 0) {
         Map<String, String> filterMap = (Map)request.getSession().getAttribute("YFFILTERS");
         if (filterMap == null) filterMap = new HashMap<String, String>();
         String v1 = null;
         String v2 = null;
         String v3 = null;
         String str = null;
         for (int i = 0; i < filters.length; i++) {
            v1 = filterMap.get("filter-" + filters[i].getFilterId() + "-val1");
            v2 = filterMap.get("filter-" + filters[i].getFilterId() + "-val2");
            v3 = filterMap.get("filter-" + filters[i].getFilterId() + "-val3");
            if ("INLIST".equals(filters[i].getFilterType()) || "NOTINLIST".equals(filters[i].getFilterType())) {
               str = "";
               if (v1 != null && v1.trim().length() > 0) {
                  str += v1;
               }
               if (v2 != null && v2.trim().length() > 0) {
                  if (str.length() > 0) str += "|";
                  str += v2;
               }
               if (v3 != null && v3.trim().length() > 0) {
                  if (str.length() > 0) str += "|";
                  str += v3;
               }
               rpt.setFilterById(filters[i].getFilterId(), str);
            } else if ("BETWEEN".equals(filters[i].getFilterType()) || "NOTBETWEEN".equals(filters[i].getFilterType())) {
               str = "";
               if (v1 != null) str += v1.trim();
               str += "\\|";
               if (v2 != null) str += v2.trim();
               rpt.setFilterById(filters[i].getFilterId(), str);
            } else {
               rpt.setFilterById(filters[i].getFilterId(), v1);
            }
         }
      }

      if ("cmd".equals(cmd)) {
         String sub = request.getParameter("sub");
         rpt.runCommand(sub);
      }

      // are there required filters?
      if (filters != null && filters.length > 0) {
         Map<String, String> filterMap = (Map)request.getSession().getAttribute("YFFILTERS");
         if (filterMap == null) filterMap = new HashMap<String, String>(); %>

<p><b><%=rpt.getReportName()%></b></p>
<p>Filters:</p>
<%
String formAction = "ws_mobile_home.jsp";
if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) {
   formAction += ";jsessionid=" + request.getSession().getId();
} %>
<form name="filterForm" action="<%=formAction%>" method="post">
<input type="hidden" name="cmd" value="setfilters" />
<input type="hidden" name="id" value="<%=rpt.getReportId()%>" />
<table>
<%       String v1 = null;
         String v2 = null;
         String v3 = null;
         ArrayList values = null;
         ArrayList currValues = null;
         String[] option = null;
         String onchange = null;
         boolean list, bw, sel;
         for (int i = 0; i < filters.length; i++) {
            v1 = filterMap.get("filter-" + filters[i].getFilterId() + "-val1");
            v2 = filterMap.get("filter-" + filters[i].getFilterId() + "-val2");
            v3 = filterMap.get("filter-" + filters[i].getFilterId() + "-val3");
         %>
  <tr>
    <td>
      <%=filters[i].getDisplayName()%>
<%          if ("EQUAL".equals(filters[i].getFilterType())) { %>
      equal to
<%          } else if ("NOTEQUAL".equals(filters[i].getFilterType())) { %>
      not equal to
<%          } else if ("GREATER".equals(filters[i].getFilterType())) { %>
      greater than
<%          } else if ("GREATEREQUAL".equals(filters[i].getFilterType())) { %>
      greater than or equal to
<%          } else if ("LESS".equals(filters[i].getFilterType())) { %>
      less than
<%          } else if ("LESSEQUAL".equals(filters[i].getFilterType())) { %>
      less than or equal to
<%          } else if ("BETWEEN".equals(filters[i].getFilterType())) { %>
      between
<%          } else if ("NOTBETWEEN".equals(filters[i].getFilterType())) { %>
      not between
<%          } else if ("INLIST".equals(filters[i].getFilterType())) { %>
      in list
<%          } else if ("NOTINLIST".equals(filters[i].getFilterType())) { %>
      not in list
<%          } else if ("CONTAINS".equals(filters[i].getFilterType())) { %>
      contains
<%          } else if ("NOTCONTAINS".equals(filters[i].getFilterType())) { %>
      does not contain
<%          } else if ("STARTSWITH".equals(filters[i].getFilterType())) { %>
      starts with
<%          } else if ("NOTSTARTSWITH".equals(filters[i].getFilterType())) { %>
      does not start with
<%          } else if ("ENDSWITH".equals(filters[i].getFilterType())) { %>
      ends with
<%          } else if ("NOTENDSWITH".equals(filters[i].getFilterType())) { %>
      does not end with
<%          }
            if (v1 == null) v1 = "";
            if (v2 == null) v2 = "";
            if (v3 == null) v3 = ""; %>
    </td>
    <td>
<%          list = "INLIST".equals(filters[i].getFilterType()) || "NOTINLIST".equals(filters[i].getFilterType());
            bw = "BETWEEN".equals(filters[i].getFilterType()) || "NOTBETWEEN".equals(filters[i].getFilterType());
            
            onchange = "";
            if (rpt.filterHasDependantChildren(filters[i].getFilterId())) {
               onchange = "onchange=\"document.filterForm.submit();\"";
            }
            
            if ("DROPDOWN".equals(filters[i].getFilterDisplayType()) || "PREDEFDATE".equals(filters[i].getFilterDisplayType())) { %>
      <select name="filter-<%=filters[i].getFilterId()%>-val1" <%=list ? "multiple=\"multiple\"" : ""%> <%=onchange%>>
<%             // get filter options
               values = rpt.retrieveFilterPromptValues(filters[i].getFilterId());
               currValues = convertValueToList(v1);
               for (int j = 0; j < values.size(); j++) {
                  option = (String[])values.get(j);
                  sel = currValues.contains(option[0]); %>
        <option value="<%=UtilString.xmlEscape(option[0], true)%>" <%=sel ? "selected=\"selected\"" : ""%>><%=UtilString.xmlEscape(option[1], false)%></option>
<%             } %>
      </select>
<%             if (bw) { %>
      and
      <select name="filter-<%=filters[i].getFilterId()%>-val2" <%=onchange%>>
<%                for (int j = 0; j < values.size(); j++) {
                     option = (String[])values.get(j);
                     sel = currValues.contains(option[0]); %>
        <option value="<%=UtilString.xmlEscape(option[0], true)%>" <%=sel ? "selected=\"selected\"" : ""%>><%=UtilString.xmlEscape(option[1], false)%></option>
<%                } %>
      </select>
<%             }
            } else { %>
      <input type="text" name="filter-<%=filters[i].getFilterId()%>-val1" value="<%=v1%>" />
<%             if (bw) { %>
      and
      <input type="text" name="filter-<%=filters[i].getFilterId()%>-val2" value="<%=v2%>" />
<%             } else if (list) { %>
      <br />
      <input type="text" name="filter-<%=filters[i].getFilterId()%>-val2" value="<%=v2%>" />
      <br />
      <input type="text" name="filter-<%=filters[i].getFilterId()%>-val3" value="<%=v3%>" />
<%             } %>
<%          } %>
    </td>


  </tr>
<%       } %>
  <tr>
    <td></td>
    <td><input type="submit" /></td>
  </tr>
</table>
</form>
<br />
<hr />

<%    }

      rpt.run(null, "HTML"); 
      %>

      <style type="text/css">
		<% if (rpt.getReportStyle() != null) { %>
		<%=rpt.getReportStyle()%>
		<% } %>
	  </style>
	  
      <%=rpt.render()%>

<% } catch (WebserviceException e) { %>
<p>Error: <%=e.getErrorString()%></p>
<% }


} else {

   // get report list
   asc.setClientReferenceId((String)session.getAttribute("YFCLIENTREF"));
   AdministrationPerson ap = asc.getUser(userId);
   AdministrationReport[] reports = asc.listAllReportsForUser(ap);
   
   Comparator<AdministrationReport> rptCmp = new Comparator<AdministrationReport>() {
      public int compare(AdministrationReport rpt1, AdministrationReport rpt2) {
         return rpt1.getReportName().compareToIgnoreCase(rpt2.getReportName());
      }
   };
   Arrays.sort(reports, rptCmp);

   %>
<h1>Report List</h1>
<%
   if (reports == null || reports.length == 0) { %>
<p>None Found</p>
<% } else { %>
<ul>
<%    for (int i = 0; i < reports.length; i++) {
         url = "ws_mobile_home.jsp";
         if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
         url += "?cmd=run&id=" + reports[i].getReportId(); %>
<li><a href="<%=url%>"><%=reports[i].getReportName()%></a></li>
<%    } %>
</ul>
<% }

   // get dashboard tabs

   asc.setClientReferenceId((String)session.getAttribute("YFCLIENTREF"));
   AdministrationReportGroup[] tabs = asc.listAllTabsForUser(ap, true); %>
<h1>User Tabs</h1>
<% if (tabs == null || tabs.length == 0) { %>
<p>None Found</p>
<% } else { %>
<ul>
<%    for (int i = 0; i < tabs.length; i++) { %>
<li><%=UtilString.escapeText(tabs[i].getReportGroupName(), "xml")%><ul>
<%       Arrays.sort(tabs[i].getGroupReports(), rptCmp);
         for (int j = 0; j < tabs[i].getGroupReports().length; j++) {
            url = "ws_mobile_home.jsp";
            if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
            url += "?cmd=run&id=" + tabs[i].getGroupReports()[j].getReportId(); %>
          <li><a href="<%=url%>"><%=UtilString.escapeText(tabs[i].getGroupReports()[j].getReportName(), "xml")%></a></li>
<%       } %>
</ul></li>
<%    } %>
</ul>
<% }

   //get favourites
   asc.setClientReferenceId((String)session.getAttribute("YFCLIENTREF"));
   AdministrationReport[] favourites = asc.listUserFavourites(ap); %>
<h1>Favourite Reports</h1>
<% if (favourites == null || favourites.length == 0) { %>
<p>None Found</p>
<% } else { %>
<ul>
<%    Arrays.sort(favourites, rptCmp);
      for (int i = 0; i < favourites.length; i++) {
         url = "ws_mobile_home.jsp";
         if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
         url += "?cmd=run&id=" + favourites[i].getReportId(); %>
<li><a href="<%=url%>"><%=favourites[i].getReportName()%></a></li>
<%    } %>
</ul>
<% }

   // get inbox
   asc.setClientReferenceId((String)session.getAttribute("YFCLIENTREF"));
   AdministrationReport[] inbox = asc.listUserInbox(ap); %>
<h1>Inbox Reports</h1>
<% if (inbox == null || inbox.length == 0) { %>
<p>None Found</p>
<% } else { %>
<ul>
<%    Arrays.sort(inbox, rptCmp);
      for (int i = 0; i < inbox.length; i++) {
         url = "ws_mobile_home.jsp";
         if (!request.isRequestedSessionIdFromCookie() && request.getSession().getId() != null) url += ";jsessionid=" + request.getSession().getId();
         url += "?cmd=run&id=" + inbox[i].getReportId(); %>
<li><a href="<%=url%>"><%=inbox[i].getReportName()%></a></li>
<%    } %>
</ul>
<% }




}

%>
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

private String convertArrayToValue(String[] list) {

   if (list == null) return null;

   StringBuffer buf = new StringBuffer();
   String s = null;
   for (int i = 0; i < list.length; i++) {
      if (i > 0) buf.append("|");
      s = list[i];
      // escape any slashes
      s = s.replaceAll("\\\\", "\\\\\\\\");
      // now escape any pipes
      s = s.replaceAll("\\|", "\\\\|");
      buf.append(s);
   }
   return buf.toString();

}

private ArrayList convertValueToList(String value) {

   // unescape values
   int start = 0;
   String s = null;
   ArrayList al = new ArrayList();
   if (value != null) {
      for (int i = 0; i < value.length(); i++) {
         if (value.charAt(i) == '|') {
            s = value.substring(start, i);
            s = s.replaceAll("\\\\(.)", "$1"); // unescape
            start = i + 1;
            al.add(s);
         } else if (value.charAt(i) == '\\') {
            i++; // skip next char
         }
      }
      if (value.length() >= start) {
         s = value.substring(start);
         s = s.replaceAll("\\\\(.)", "$1");
         al.add(s);
      }
   }
   return al;

}

%>
</body>
</html>
