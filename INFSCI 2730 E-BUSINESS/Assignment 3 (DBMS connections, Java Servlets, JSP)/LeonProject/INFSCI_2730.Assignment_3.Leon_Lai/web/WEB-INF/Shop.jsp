<%@include file="[.jspf"%><% //
  final String status = (String) request.getAttribute("status");
  final String err;
  final LinkedList<Item> availableItems, cartItems;
  final double cartTotalPriceUSD;
  if(status == null) {
    err = "";
    availableItems = (LinkedList<Item>) request.getAttribute("available_items");
    cartItems = (LinkedList<Item>) request.getAttribute("cart_items");
    cartTotalPriceUSD = (Double) request.getAttribute("cart_total_price_usd");
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
    availableItems = null;
    cartItems = null;
    cartTotalPriceUSD = 0;
  }
%>
<div id="container" class="column-container">
  <%="".equals(err) ? "" : "<div><div id=\"err\"><span>" + err + "</span></div></div>"%>
  <form id="availableItemsForm" method="post" action="/Shop">
    <label id="availableItemsLabel" for="availableItems">Items on Shelf:</label>
    <div id="availableItemsContainerContainer" class="c">
      <div id="availableItemsContainer">
        <select
          id="availableItems"
          name="move"
          size="15"
          multiple="multiple"
          accesskey="m"><% //
            if(availableItems != null)
              for(Item item : availableItems) {%>
          <option value="<%=item.item%>"><%=item.name + ", " + item.weight + " " + item.unit + ", " + String.format("$%.2f", item.price_usd) + ", " + "expires on " + item.exp_date%></option><%}%>
        </select>
      </div>
      <div>
        <input
          type="submit"
          id="availableItemsSubmit"
          value="Move to Cart" />
      </div>
    </div>
  </form>
  <form id="cartItemsForm" method="post" action="/Shop">
    <label id="cartItemsLabel" for="cartItems">Items in Cart: (<span id="cartTotalPriceUSD"><%=String.format("$%.2f", cartTotalPriceUSD)%></span>)</label>
    <div id="cartItemsContainerContainer" class="c">
      <div id="cartItemsContainer">
        <select
          id="cartItems"
          name="remove"
          size="15"
          multiple="multiple"
          accesskey="r"><% //
            if(cartItems != null)
              for(Item item : cartItems) {%>
          <option value="<%=item.item%>"><%=item.name + ", " + item.weight + " " + item.unit + ", " + String.format("$%.2f", item.price_usd) + ", " + "expires on " + item.exp_date%></option><%}%>
        </select>
      </div>
      <div>
        <input
          type="submit"
          id="cartItemsSubmit"
          value="Remove from Cart" />
      </div>
    </div>
  </form>
  <form id="checkOutForm" method="post" action="/CheckOut">
    <div id="checkOutLabel" class="label">Check Out Options</div>
    <div id="checkOutContainerContainer" class="c">
      <div id="checkOutContainer">
        <label for="isDelivery" class="compact">This is for Delivery:</label>
        <input
          type="checkbox"
          id="isDelivery"
          name="isDelivery"
          value="true"
          accesskey="t" />
        <div id="addressContainer">
          <label for="address" class="compact">Deliver to Address:</label>
          <input
            type="text"
            id="address"
            name="address"
            accesskey="a" />
        </div>
        <div>
          <label
            id="dueDateLabel"
            for="dueDate"
            class="compact">Pickup/Delivery Date &amp; Time (UNIX time):</label>
          <input
            type="text"
            id="dueDate"
            name="due_date"
            accesskey="d" />
        </div>
      </div>
      <div>
        <input
          type="submit"
          id="checkOutSubmit"
          value="Check Out" />
      </div>
    </div>
  </form>
</div>
<%@include file="].jspf"%>