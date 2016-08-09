<%@page
  contentType="application/json"
  pageEncoding="UTF-8"
  import="org.json.JSONObject,org.json.JSONArray,edu.pitt.sis.INFSCI_2730.Assignment_3.Leon_Lai.DataManipulator.Item"
%><%
  if(request.getAttribute("status") == null) {
    final JSONObject outJSON = new JSONObject();
    if(request.getAttribute("could_not_remove") != null) {
      final JSONArray ret = new JSONArray();
      for(long item : (Iterable<Long>) request.getAttribute("could_not_remove")) {
        ret.put(item);
      }
      outJSON.put("could_not_remove", ret);
    }
    if(request.getAttribute("could_not_move") != null) {
      final JSONArray ret = new JSONArray();
      for(long item : (Iterable<Long>) request.getAttribute("could_not_move")) {
        ret.put(item);
      }
      outJSON.put("could_not_move", ret);
    }
    if(request.getAttribute("available_items") != null) {
      final JSONArray availableItemsJSON = new JSONArray();
      for(Item item : (Iterable<Item>) request.getAttribute("available_items")) {
        availableItemsJSON.put(
          new JSONObject()
          .put("item", item.item)
          .put("name", item.name)
          .put("weight", item.weight)
          .put("unit", item.unit)
          .put("price_usd", item.price_usd)
          .put("exp_date", item.exp_date)
        );
      }
      outJSON.put("available_items", availableItemsJSON);
    }
    else {
      return;
    }
    if(request.getAttribute("cart_items") != null) {
      final JSONArray cartItemsJSON = new JSONArray();
      for(Item item : (Iterable<Item>) request.getAttribute("cart_items")) {
        cartItemsJSON.put(
          new JSONObject()
          .put("item", item.item)
          .put("name", item.name)
          .put("weight", item.weight)
          .put("unit", item.unit)
          .put("price_usd", item.price_usd)
          .put("exp_date", item.exp_date)
        );
      }
      outJSON.put("cart_items", cartItemsJSON);
    }
    else {
      return;
    }
    if(request.getAttribute("cart_total_price_usd") != null) {
      final double cartTotalPriceUSD = (Double) request.getAttribute("cart_total_price_usd");
      outJSON.put("cart_total_price_usd", cartTotalPriceUSD);
    }
    else {
      return;
    }
    out.println(outJSON.toString(2));
  }
  else {
    final String status = (String) request.getAttribute("status");
    out.println(status);
  }
  out.flush();
  %>