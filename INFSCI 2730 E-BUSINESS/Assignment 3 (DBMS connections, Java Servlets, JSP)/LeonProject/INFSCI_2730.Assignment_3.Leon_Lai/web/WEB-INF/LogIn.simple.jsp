<%@page 
  contentType="application/json" 
  pageEncoding="UTF-8"
  import="org.json.JSONObject,org.json.JSONArray"
%><%
  if(request.getAttribute("status") == null) {
  }
  else {
    final String status = (String) request.getAttribute("status");
    out.print(status);
  }
  out.flush();
%>