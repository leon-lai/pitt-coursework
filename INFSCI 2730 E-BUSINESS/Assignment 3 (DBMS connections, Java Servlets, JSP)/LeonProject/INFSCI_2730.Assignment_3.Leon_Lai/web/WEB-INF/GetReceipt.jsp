<%@include file="[.jspf"%><% //
  final String status = (String) request.getAttribute("status");
  final String err;
  final Receipt receipt;
  final double cartTotalPriceUSD;
  if(status == null) {
    err = "";
    receipt = (Receipt) request.getAttribute("getReceipt");
  }
  else {
    switch(status) {
      case ("error_processing_request"): {
        err = "Error processing request";
        break;
      }
      default: {
        err = status;
      }
    }
    receipt = null;
  }
  final SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd(EEE) HH:mm:ss z");
%>
<div>
  <div>
    <div id="receiptLabel" class="label">Receipt</div>
    <div class="c">
      <%="".equals(err) ? "" : "<div><div id=\"err\"><span>" + err + "</span></div></div>"%>
      <div id="receipt" class="column-container">
        <div class="left" id="reservn">Reservn #<%=receipt.reservn%></div>
        <div class="right" id="cue_date"><%=sdf.format(receipt.cue_date)%></div>
        <div class="left" id="isDelivery"><%=receipt.address == null ? "Pick up" : "Delivery"%></div>
        <div class="right" id="due_date"><%=sdf.format(receipt.due_date)%></div><% if(receipt.address != null) {%>
        <%="<div class=\"left\" id=\"address\">To: " + receipt.address + "</div>"%><%}%>
        <hr />
        <ul id="items"><%
          for(Receipt.Item item : receipt.items) {%>
          <li class="column-container">
            <div class="left"><%=item.name + ", " + item.weight + " " + item.unit%></div>
            <div class="right"><%=String.format("$%.2f", item.price_usd)%></div>
          </li><%}%>
        </ul>
        <hr />
        <div class="left">Total</div>
        <div class="right" id="total_price_usd"><%=String.format("$%.2f", receipt.total_price_usd)%></div>
      </div>
    </div>
  </div>
</div>
<%@include file="].jspf"%>