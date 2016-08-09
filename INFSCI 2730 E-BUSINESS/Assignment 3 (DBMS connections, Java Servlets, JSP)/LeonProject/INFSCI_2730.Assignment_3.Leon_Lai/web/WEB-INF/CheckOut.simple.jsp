<%@page
  contentType="application/json"
  pageEncoding="UTF-8"
%><%
  if(request.getAttribute("status") == null) {
    final long reservn;
    if(request.getAttribute("finalizeCart") != null) {
      reservn = (long) request.getAttribute("finalizeCart");
    }
    else {
      return;
    }
    out.println(reservn);
  }
  else {
    final String status = (String) request.getAttribute("status");
    out.println(status);
  }
  out.flush();
  %>