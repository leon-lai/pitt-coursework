package edu.pitt.sis.INFSCI_2730.Assignment_3.Leon_Lai;
import static edu.pitt.sis.INFSCI_2730.Assignment_3.Leon_Lai.DataManipulator.*;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.BufferedReader;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.http.HttpSession;
import javax.servlet.http.Cookie;
import java.util.Base64;
import java.security.MessageDigest;
import java.security.NoSuchAlgorithmException;
import java.io.UnsupportedEncodingException;
import java.util.LinkedList;
import java.util.Date;
import java.math.BigInteger;
/**
 * @author leon
 * @version 2016-03-18
 */
public class Servlets {
  private static String getCookieByName(
    final Cookie[] cookies, final String name
  ) {
    if(cookies != null && name != null) {
      for(Cookie cookie : cookies) {
        if(name.equals(cookie.getName())) {
          return cookie.getValue();
        }
      }
    }
    return null;
  }
  private static long[] stringArrayToLongArray(
    final String[] stringArray
  ) throws NumberFormatException {
    if(stringArray != null) {
      final long[] longArray = new long[stringArray.length];
      for(int index = 0, count = longArray.length; index < count; ++index) {
        longArray[index] = Long.valueOf(stringArray[index]);
      }
      return longArray;
    }
    return null;
  }
  private static String coalesceBlankToNull(final String string) {
    return (string == null || string.length() == 0) ? null : string;
  }
  private static String[] coalesceBlankToNull(final String[] strings) {
    return (strings == null || strings.length == 0) ? null : strings;
  }
  @WebServlet(name = "HashPassword", urlPatterns = {"/HashPassword"})
  public static class HashPassword extends HttpServlet {
    private static final Base64.Encoder BASE64_ENCODER = Base64.getUrlEncoder(); // "Safe for use by multiple concurrent threads" -- https://docs.oracle.com/javase/8/docs/api/java/util/Base64.Encoder.html
    @Override
    protected void doPost(
      final HttpServletRequest X, final HttpServletResponse Y
    ) throws ServletException, IOException {
      Y.setContentType("text/plain;charset=UTF-8");
      try(
        final PrintWriter out = Y.getWriter();
        final BufferedReader in = X.getReader()) {
        final StringBuilder inStringBuilder = new StringBuilder();
        String inLine;
        if((inLine = in.readLine()) != null) {
          inStringBuilder.append(inLine);
        }
        while((inLine = in.readLine()) != null) {
          inStringBuilder.append('\n');
          inStringBuilder.append(inLine);
        }
        try {
          out.print(new BigInteger(1, MessageDigest.getInstance("SHA-512").digest(inStringBuilder.toString().getBytes("UTF-8"))).toString(16));
          /* 88 characters: SHA-512 → 512 bits = 85 + (1/3) 3-bit groups → Base64 86 → meaningful characters + 2 padding characters */
        }
        catch(final NoSuchAlgorithmException | UnsupportedEncodingException t) {
        }
        out.flush();
      }
    }
  }
  @WebServlet(name = "LogIn", urlPatterns = {"/LogIn"})
  public static class LogIn extends HttpServlet {
    private void alreadyLoggedIn(
      final HttpServletRequest X, final HttpServletResponse Y, final boolean simplemode
    ) throws ServletException, IOException {
      X.setAttribute("status", "already_logged_in");
      if(simplemode) {
        getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
      }
      else {
        Y.sendRedirect("/Shop");
      }
    }
    @Override
    protected void doGet(
      final HttpServletRequest X, final HttpServletResponse Y
    ) throws ServletException, IOException {
      final HttpSession S = X.getSession(false);
      final String sessionAccount = (S == null) ? null : (String) S.getAttribute("account");
      final boolean simplemode = X.getAttribute("s") != null && X.getAttribute("s") instanceof Boolean && (boolean) X.getAttribute("s") || X.getParameter("s") != null;
      if(sessionAccount == null) {
        if(simplemode) {
          getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
        }
        else {
          getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
        }
      }
      else {
        alreadyLoggedIn(X, Y, simplemode);
      }
    }
    @Override
    protected void doPost(
      final HttpServletRequest X, final HttpServletResponse Y
    ) throws ServletException, IOException {
      final HttpSession S = X.getSession(false);
      final String sessionAccount = (S == null) ? null : (String) S.getAttribute("account");
      final boolean simplemode = X.getAttribute("s") != null && X.getAttribute("s") instanceof Boolean && (boolean) X.getAttribute("s") || X.getParameter("s") != null;
      if(sessionAccount == null) {
        final String account = coalesceBlankToNull(X.getParameter("account"));
        final String password_hash = coalesceBlankToNull(X.getParameter("password_hash"));
        if(account != null && password_hash != null) {
          final boolean doSignupInstead = coalesceBlankToNull(X.getParameter("doSignupInstead")) != null;
          final Boolean ret = doSignupInstead ? createAccount(account, password_hash) : isAccount(account, password_hash);
          if(ret != null && ret) {
            X.getSession().setAttribute("account", account);
            if(simplemode) {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
            }
            else {
              Y.sendRedirect("/Shop");
            }
          }
          else if(ret != null) {
            X.setAttribute("status", doSignupInstead ? "account_already_taken" : "incorrect");
            if(simplemode) {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
            }
            else {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
            }
          }
          else {
            X.setAttribute("status", "error_processing_request");
            if(simplemode) {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
            }
            else {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
            }
          }
        }
        else if(account != null && password_hash == null) {
          X.setAttribute("status", "null_password_hash");
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
        else if(account == null && password_hash != null) {
          X.setAttribute("status", "null_account");
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
        else {
          X.setAttribute("status", "null_account_password_hash");
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
      }
      else {
        alreadyLoggedIn(X, Y, simplemode);
      }
    }
  }
  @WebServlet(name = "Shop", urlPatterns = {"/Shop"})
  public static class Shop extends HttpServlet {
    @Override
    protected void doGet(
      final HttpServletRequest X, final HttpServletResponse Y
    ) throws ServletException, IOException {
      final HttpSession S = X.getSession(false);
      final String account = (S == null) ? null : (String) S.getAttribute("account");
      final boolean simplemode = X.getAttribute("s") != null && X.getAttribute("s") instanceof Boolean && (boolean) X.getAttribute("s") || X.getParameter("s") != null;
      if(account != null) {
        final LinkedList<Item> availableItems = getAvailableItems();
        final LinkedList<Item> cartItems = getCartItems(account);
        final Double cartTotalPriceUSD = getCartTotalPriceUSD(account);
        if(availableItems != null && cartItems != null && cartTotalPriceUSD != null) {
          X.setAttribute("available_items", availableItems);
          X.setAttribute("cart_items", cartItems);
          X.setAttribute("cart_total_price_usd", cartTotalPriceUSD);
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
        else {
          X.setAttribute("status", "error_processing_request");
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
      }
      else {
        X.setAttribute("status", "not_logged_in");
        if(simplemode) {
        }
        else {
          Y.sendRedirect("/LogIn");
        }
      }
    }
    @Override
    protected void doPost(
      final HttpServletRequest X, final HttpServletResponse Y
    ) throws ServletException, IOException {
      final HttpSession S = X.getSession(false);
      final String account = (S == null) ? null : (String) S.getAttribute("account");
      final boolean simplemode = X.getAttribute("s") != null && X.getAttribute("s") instanceof Boolean && (boolean) X.getAttribute("s") || X.getParameter("s") != null;
      X.setAttribute("s", simplemode);
      if(account != null) {
        final String[] move = coalesceBlankToNull(X.getParameterValues("move"));
        final String[] remove = coalesceBlankToNull(X.getParameterValues("remove"));
        if(move == null || remove == null) {
          if(move != null || remove != null) {
            final boolean toShelf = remove != null;
            final long[] items;
            try {
              items = stringArrayToLongArray(toShelf ? remove : move);
            }
            catch(NumberFormatException t) {
              X.setAttribute("status", "move_or_remove_param_not_csv");
              if(simplemode) {
                getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
              }
              else {
                getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
              }
              return;
            }
            final LinkedList<Long> ret = toShelf ? removeFromCart(account, items) : moveToCart(account, items);
            X.setAttribute(toShelf ? "could_not_remove" : "could_not_move", ret);
          }
          doGet(X, Y);
        }
        else {
          X.setAttribute("status", "move_and_remove_params_both_present");
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
      }
      else {
        X.setAttribute("status", "not_logged_in");
        if(simplemode) {
        }
        else {
          Y.sendRedirect("/LogIn");
        }
      }
    }
  }
  @WebServlet(name = "CheckOut", urlPatterns = {"/CheckOut"})
  public static class CheckOut extends HttpServlet {
    @Override
    protected void doGet(
      final HttpServletRequest X, final HttpServletResponse Y
    ) throws ServletException, IOException {
      final boolean simplemode = X.getAttribute("s") != null && X.getAttribute("s") instanceof Boolean && (boolean) X.getAttribute("s") || X.getParameter("s") != null;
      if(simplemode) {
      }
      else {
        Y.sendRedirect("/Shop");
      }
    }
    @Override
    protected void doPost(
      final HttpServletRequest X, final HttpServletResponse Y
    ) throws ServletException, IOException {
      final HttpSession S = X.getSession(false);
      final String account = (S == null) ? null : (String) S.getAttribute("account");
      final boolean simplemode = X.getAttribute("s") != null && X.getAttribute("s") instanceof Boolean && (boolean) X.getAttribute("s") || X.getParameter("s") != null;
      if(account != null) {
        final LinkedList<Item> cartItems = getCartItems(account);
        if(cartItems != null && cartItems.size() > 0) {
          final String due_dateParam = coalesceBlankToNull(X.getParameter("due_date"));
          final Date due_date;
          try {
            due_date = due_dateParam != null ? new Date(Long.valueOf(due_dateParam)) : null;
          }
          catch(NumberFormatException t) {
            X.setAttribute("status", "due_date_not_unix_time");
            if(simplemode) {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
            }
            else {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
            }
            return;
          }
          final boolean isDelivery = coalesceBlankToNull(X.getParameter("isDelivery")) != null;
          final String address = coalesceBlankToNull(X.getParameter("address"));
          if(!isDelivery || isDelivery&&address!=null){
          final Long ret = finalizeCart(account, due_date, address);
          if(ret != null) {
            X.setAttribute("finalizeCart", ret);
            if(simplemode) {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
            }
            else {
              Y.sendRedirect("/GetReceipt?reservn=" + ret);
            }
          }
          else {
            X.setAttribute("status", "error_processing_request");
            if(simplemode) {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
            }
            else {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
            }
          }
          }
          else{
            X.setAttribute("status", "null_address");
            if(simplemode) {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
            }
            else {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
            }
          }
        }
        else if(cartItems != null) {
          X.setAttribute("status", "empty_cart");
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
        else {
          X.setAttribute("status", "error_processing_request");
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
      }
      else {
        X.setAttribute("status", "not_logged_in");
        if(simplemode) {
        }
        else {
          Y.sendRedirect("/LogIn");
        }
      }
    }
  }
  @WebServlet(name = "GetReceipt", urlPatterns = {"/GetReceipt"})
  public static class GetReceipt extends HttpServlet {
    @Override
    protected void doGet(
      final HttpServletRequest X, final HttpServletResponse Y
    ) throws ServletException, IOException {
      final HttpSession S = X.getSession(false);
      final String account = (S == null) ? null : (String) S.getAttribute("account");
      final boolean simplemode = X.getAttribute("s") != null && X.getAttribute("s") instanceof Boolean && (boolean) X.getAttribute("s") || X.getParameter("s") != null;
      if(account != null) {
        final String reservnParam = coalesceBlankToNull(X.getParameter("reservn"));
        final long reservn;
        if(reservnParam != null) {
          try {
            reservn = Long.valueOf(reservnParam);
          }
          catch(NumberFormatException t) {
            X.setAttribute("status", "reservn_not_number");
            if(simplemode) {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
            }
            else {
              getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
            }
            return;
          }
        }
        else {
          return;
        }
        final Receipt ret = getReceipt(account, reservn);
        if(ret != null) {
          X.setAttribute("getReceipt", ret);
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
        else {
          X.setAttribute("status", "error_processing_request");
          if(simplemode) {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".simple.jsp").forward(X, Y);
          }
          else {
            getServletContext().getRequestDispatcher("/WEB-INF/" + this.getClass().getSimpleName() + ".jsp").forward(X, Y);
          }
        }
      }
      else {
        X.setAttribute("status", "not_logged_in");
        if(simplemode) {
        }
        else {
          Y.sendRedirect("/LogIn");
        }
      }
    }
  }
}
