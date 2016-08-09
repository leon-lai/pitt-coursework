<%@include file="[.jspf"%><% //
  final String status = (String) request.getAttribute("status");
  final String err;
  if(status == null) {
    err = "";
  }
  else {
    switch(status) {
      case ("account_already_taken"): {
        err = "Username already taken";
        break;
      }
      case ("incorrect"): {
        err = "Incorrect username or password";
        break;
      }
      case ("error_processing_request"): {
        err = "Error processing request";
        break;
      }
      case ("null_password_hash"): {
        err = "Blank password";
        break;
      }
      case ("null_account"): {
        err = "Blank username";
        break;
      }
      case ("null_account_password_hash"): {
        err = "";
        break;
      }
      default: {
        err = status;
      }
    }
  }
%>
<form id="form" class="column-container c" method="post" action="/LogIn">
  <div id="accountContainer">
    <input
      type="text"
      id="account"
      name="account"
      accesskey="u"
      placeholder="Username" />
  </div>
  <div id="passwordContainer">
    <input
      type="password"
      id="password"
      accesskey="p"
      placeholder="Password" />
  </div>
  <div id="doSignupInsteadContainer">
    <input
      type="submit"
      id="doSignupInstead"
      name="doSignupInstead"
      accesskey="s"
      value="Sign Up" />
  </div>
  <div id="logInContainer">
    <input
      type="submit"
      id="logIn"
      name="logIn"
      accesskey="l"
      value="Log In" />
  </div>
  <%="".equals(err) ? "" : "<div><div id=\"err\"><span>" + err + "</span></div></div>"%>
</form>
<%@include file="].jspf"%>