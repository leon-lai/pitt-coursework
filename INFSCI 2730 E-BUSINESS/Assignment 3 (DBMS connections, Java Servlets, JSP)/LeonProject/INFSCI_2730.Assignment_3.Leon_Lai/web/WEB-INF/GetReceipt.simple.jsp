<%@page
  contentType="application/json"
  pageEncoding="UTF-8"
  import="org.json.JSONObject,org.json.JSONArray,edu.pitt.sis.INFSCI_2730.Assignment_3.Leon_Lai.DataManipulator.Receipt"
%><%
  if(request.getAttribute("status") == null) {
    final JSONObject receiptJSON;
    if(request.getAttribute("getReceipt") != null) {
      final Receipt receipt = (Receipt) request.getAttribute("getReceipt");
      final JSONArray itemsJSON = new JSONArray();
      if(receipt.items != null) {
        for(Receipt.Item item : (Iterable<Receipt.Item>) receipt.items) {
          itemsJSON.put(
            new JSONObject()
            .put("item", item.item)
            .put("name", item.name)
            .put("weight", item.weight)
            .put("unit", item.unit)
            .put("price_usd", item.price_usd)
          );
        }
      }
      receiptJSON = new JSONObject()
        .put("reservn", receipt.reservn)
        .put("cue_date", receipt.cue_date)
        .put("due_date", receipt.due_date)
        .put("address", receipt.address)
        .put("items", itemsJSON)
        .put("total_price_usd", receipt.total_price_usd);
    }
    else {
      return;
    }
    out.println(receiptJSON.toString(2));
  }
  else {
    final String status = (String) request.getAttribute("status");
    out.println(status);
  }
  out.flush();
  %>