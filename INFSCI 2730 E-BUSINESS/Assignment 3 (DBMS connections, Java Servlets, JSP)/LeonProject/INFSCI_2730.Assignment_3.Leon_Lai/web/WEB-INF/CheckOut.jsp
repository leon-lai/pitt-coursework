<%@include file="[.jspf"%><% //
  final String status = (String) request.getAttribute("status");
  final String err;
  if(status == null) {
    err = "";
  }
  else {
    switch(status) {
      case ("due_date_not_unix_time"): {
        err = "Error processing request";
        break;
      }
      case ("null_address"): {
        err = "Blank address";
        break;
      }
      case ("empty_cart"): {
        err = "Empty cart";
        break;
      }
      case ("error_processing_request"): {
        err = "Error processing request";
        break;
      }
      default: {
        err = status;
      }
    }
  }
%>
<form id="form" class="column-container c" method="get" action="/Shop">
  <%="".equals(err) ? "" : "<div><div id=\"err\"><span>" + err + "</span></div></div>"%>
  <div>
    <input type="submit" value="Back to Shopping" />
  </div>
</form>
<%@include file="].jspf"%>