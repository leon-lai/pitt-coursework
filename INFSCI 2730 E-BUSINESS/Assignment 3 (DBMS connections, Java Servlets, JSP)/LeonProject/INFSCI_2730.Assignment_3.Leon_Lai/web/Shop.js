window.addEventListener("load", function() {
  /*
   * Containers
   */
  var availableItemsFormNode = document.getElementById("availableItemsForm");
  var cartItemsFormNode = document.getElementById("cartItemsForm");
  var checkOutFormNode = document.getElementById("checkOutForm");
  var addressContainerNode = document.getElementById("addressContainer");
  /*
   * Inputs
   */
  var availableItemsNode = document.getElementById("availableItems");
  var cartItemsNode = document.getElementById("cartItems");
  var isDeliveryNode = document.getElementById("isDelivery");
  var addressNode = document.getElementById("address");
  var dueDateNode = document.getElementById("dueDate");
  var availableItemsSubmitNode = document.getElementById("availableItemsSubmit");
  var cartItemsSubmitNode = document.getElementById("cartItemsSubmit");
  var checkOutSubmitNode = document.getElementById("checkOutSubmit");
  /*
   * Outputs (except err)
   */
  var dueDateLabelNode = document.getElementById("dueDateLabel");
  var cartTotalPriceUSDNode = document.getElementById("cartTotalPriceUSD");
  /*
   * Helper functions
   */
  var errUpdate = function(text) {
    alert(text);
  };
  var addressContainerNode_style_display = addressContainerNode.style.display;
  var isDelivery = function() {
    addressContainerNode.style.display =
      isDeliveryNode.checked ? addressContainerNode_style_display : "none";
    while(dueDateLabelNode.firstChild) {
      dueDateLabelNode.removeChild(dueDateLabelNode.firstChild);
    }
    dueDateLabelNode.appendChild(
      document.createTextNode(
        (isDeliveryNode.checked ? "Delivery" : "Pickup") + " Date & Time (YYYY-MM-DD HH:MM):"
        )
      );
  };
  var freeze = function() {
    availableItemsFormNode.disabled = true;
    cartItemsFormNode.disabled = true;
    checkOutFormNode.disabled = true;
  };
  var unfreeze = function() {
    availableItemsFormNode.disabled = false;
    cartItemsFormNode.disabled = false;
    checkOutFormNode.disabled = false;
  };
  var moveItem = function(select, item, toShelf) {
    var xhr = new XMLHttpRequest();
    xhr.onreadystatechange = function() {
      if(xhr.readyState === 4 && xhr.status === 200) {
        var reJSON;
        try {
          reJSON = JSON.parse(xhr.responseText);
        }
        catch(t) {
          errUpdate("Error processing request");
          unfreeze();
          return;
        }
        while(availableItemsNode.firstChild) {
          availableItemsNode.removeChild(availableItemsNode.firstChild);
        }
        while(cartItemsNode.firstChild) {
          cartItemsNode.removeChild(cartItemsNode.firstChild);
        }
        while(cartTotalPriceUSDNode.firstChild) {
          cartTotalPriceUSDNode.removeChild(cartTotalPriceUSDNode.firstChild);
        }
        reJSON.available_items.forEach(function(item, index, array) {
          var option = document.createElement("option");
          option.value = item.item;
          option.appendChild(document.createTextNode(item.name + ", " + item.weight + " " + item.unit + ", " + "$" + item.price_usd.toFixed(2) + ", " + "expires on " + item.exp_date));
          option.addEventListener("click", function() {
            moveItem(availableItemsNode, item.item, false);
          });
          availableItemsNode.appendChild(option);
        });
        reJSON.cart_items.forEach(function(item, index, array) {
          var option = document.createElement("option");
          option.value = item.item;
          option.appendChild(document.createTextNode(item.name + ", " + item.weight + " " + item.unit + ", " + "$" + item.price_usd.toFixed(2) + ", " + "expires on " + item.exp_date));
          option.addEventListener("click", function() {
            moveItem(cartItemsNode, item.item, true);
          });
          cartItemsNode.appendChild(option);
        });
        cartTotalPriceUSDNode.appendChild(
          document.createTextNode("$" + reJSON.cart_total_price_usd.toFixed(2))
          );
        unfreeze();
      }
    };
    freeze();
    xhr.open("post", "/Shop");
    xhr.setRequestHeader("Content-type", "application/x-www-form-urlencoded");
    xhr.send("s&" + (toShelf ? "re" : "") + "move=" + item);
  };
  var updateDueDate = function() {
    var V = dueDateNode.value;
    if(V !== "") {
      // https://stackoverflow.com/questions/11516332/
      var v = Date.parse(dueDateNode.value.split("-").join("/"));
      if(isNaN(v)) {
        errUpdate("Date must be YYYY-MM-DD HH:MM" + dueDateNode.value.split("-").join("/"));
        return false;
      }
      else {
        dueDateNewNode.value = v;
        return true;
      }
    }
  };
  /*
   * Event listeners
   */
  isDeliveryNode.addEventListener("change", function() {
    isDelivery();
  });
  dueDateNode.addEventListener("change", function() {
    updateDueDate();
  });
  availableItemsFormNode.addEventListener("submit", function(event) {
    event.preventDefault();
  });
  cartItemsFormNode.addEventListener("submit", function(event) {
    event.preventDefault();
  });
  checkOutFormNode.addEventListener("submit", function(event) {
    event.preventDefault();
    if(updateDueDate()) {
      checkOutFormNode.submit();
    }
  });
  /*
   * Synchronous logic
   */
  isDelivery();
  for(index = 0, count = availableItemsNode.children.length; index < count; ++index) {
    var thisChild = availableItemsNode.children[index];
    thisChild.addEventListener("click", function() {
      moveItem(availableItemsNode, thisChild.value, false);
    });
  }
  for(index = 0, count = cartItemsNode.children.length; index < count; ++index) {
    var thisChild = cartItemsNode.children[index];
    thisChild.addEventListener("click", function() {
      moveItem(cartItemsNode, thisChild.value, true);
    });
  }
  var availableItemsInstruction = document.createElement("div");
  var cartItemsInstruction = document.createElement("div");
  availableItemsInstruction.className = "instruction";
  cartItemsInstruction.className = "instruction";
  availableItemsInstruction.appendChild(document.createTextNode("Click on item to move it to cart"));
  cartItemsInstruction.appendChild(document.createTextNode("Click on item to remove it from cart"));
  availableItemsSubmitNode.parentNode.replaceChild(availableItemsInstruction, availableItemsSubmitNode);
  cartItemsSubmitNode.parentNode.replaceChild(cartItemsInstruction, cartItemsSubmitNode);
  dueDateNode.removeAttribute("name");
  var dueDateNewNode = document.createElement("input");
  dueDateNewNode.type = "hidden";
  dueDateNewNode.name = "due_date";
  checkOutFormNode.appendChild(dueDateNewNode);
});