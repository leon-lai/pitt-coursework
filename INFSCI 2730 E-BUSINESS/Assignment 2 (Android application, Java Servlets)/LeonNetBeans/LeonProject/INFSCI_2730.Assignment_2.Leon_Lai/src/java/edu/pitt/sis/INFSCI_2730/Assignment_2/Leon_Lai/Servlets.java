package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;

import java.io.IOException;
import java.io.PrintWriter;
import java.io.BufferedReader;
import javax.servlet.ServletException;
import javax.servlet.annotation.WebServlet;
import javax.servlet.http.HttpServlet;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;
import java.sql.SQLException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import org.json.JSONObject;

/**
 * @author leon
 */
public class Servlets {

  private static final DataSource CONNECTION_POOL;

  static {
    try {
      Context ctx = new InitialContext();
      Context ctxJavaEE = (Context) ctx.lookup("java:comp/env");
      CONNECTION_POOL = (DataSource) ctxJavaEE.lookup("connection_pool");
    }
    catch(NamingException t) {
      throw new ExceptionInInitializerError(t);
    }
  }

  @WebServlet(
     name = "PublishQuestionnaire",
     urlPatterns = {"/PublishQuestionnaire"}
  )
  public static class PublishQuestionnaire extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest X, HttpServletResponse Y)
       throws ServletException, IOException {
      Y.setContentType("text/html;charset=UTF-8");
      try(PrintWriter out = Y.getWriter(); BufferedReader in = X.getReader()) {
        try {
          final Connection connection = CONNECTION_POOL.getConnection();
          final PreparedStatement ps = connection.prepareStatement(
             "INSERT INTO Questionnaires(title, json) VALUES(?, ?)",
             PreparedStatement.RETURN_GENERATED_KEYS
          );
          final StringBuilder inStringBuilder = new StringBuilder();
          String inLine;
          if((inLine = in.readLine()) != null) {
            inStringBuilder.append(inLine);
          }
          while((inLine = in.readLine()) != null) {
            inStringBuilder.append('\n');
            inStringBuilder.append(inLine);
          }
          final JSONObject json = new JSONObject(inStringBuilder.toString());
          final String title = json.getString("title");
          ps.setString(1, title);
          ps.setString(2, json.toString());
          ps.executeUpdate();
          final ResultSet rs = ps.getGeneratedKeys();
          if(rs.next()) {
            out.print(rs.getLong(1));
          }
          if(rs.next()) { // shouldn't happen...
            out.println();
            out.print(rs.getLong(1));
          }
        }
        catch(SQLException t) {
          out.print("ERROR: " + t);
        }
        out.flush();
      }
    }
  }

  @WebServlet(
     name = "GetPublicQuestionnaireTitles",
     urlPatterns = {"/GetPublicQuestionnaireTitles"}
  )
  public static class GetPublicQuestionnaireTitles extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest X, HttpServletResponse Y)
       throws ServletException, IOException {
      Y.setContentType("application/json;charset=UTF-8");
      try(PrintWriter out = Y.getWriter()) {
        try {
          final Connection connection = CONNECTION_POOL.getConnection();
          final PreparedStatement ps = connection.prepareStatement(
             "SELECT id, title FROM Questionnaires",
             PreparedStatement.RETURN_GENERATED_KEYS
          );
          final ResultSet rs = ps.executeQuery();
          final JSONObject id2title = new JSONObject();
          while(rs.next()) {
            id2title.put(String.valueOf(rs.getLong(1)), rs.getString(2));
          }
          out.print(id2title);
        }
        catch(SQLException t) {
          out.print("ERROR: " + t);
        }
        out.flush();
      }
    }
  }

  @WebServlet(
     name = "GetPublicQuestionnaire",
     urlPatterns = {"/GetPublicQuestionnaire"}
  )
  public static class GetPublicQuestionnaire extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest X, HttpServletResponse Y)
       throws ServletException, IOException {
      Y.setContentType("application/json;charset=UTF-8");
      try(PrintWriter out = Y.getWriter()) {
        try {
          final Connection connection = CONNECTION_POOL.getConnection();
          final PreparedStatement ps = connection.prepareStatement(
             "SELECT json FROM Questionnaires WHERE id = ?",
             PreparedStatement.RETURN_GENERATED_KEYS
          );
          ps.setLong(1, Long.valueOf(X.getParameter("id")));
          final ResultSet rs = ps.executeQuery();
          if(rs.next()) {
            out.print(rs.getString(1));
          }
          if(rs.next()) { // shouldn't happen...
            out.println();
            out.print(rs.getString(1));
          }
        }
        catch(SQLException t) {
          out.print("ERROR: " + t);
        }
        out.flush();
      }
    }
  }

  @WebServlet(
     name = "SendAnsweredQuestionnaire",
     urlPatterns = {"/SendAnsweredQuestionnaire"}
  )
  public static class SendAnsweredQuestionnaire extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest X, HttpServletResponse Y)
       throws ServletException, IOException {
      Y.setContentType("text/html;charset=UTF-8");
      try(PrintWriter out = Y.getWriter(); BufferedReader in = X.getReader()) {
        try {
          final Connection connection = CONNECTION_POOL.getConnection();
          final PreparedStatement ps = connection.prepareStatement(
             "INSERT INTO AnsweredQuestionnaires(title, json) VALUES(?, ?)",
             PreparedStatement.RETURN_GENERATED_KEYS
          );
          final StringBuilder inStringBuilder = new StringBuilder();
          String inLine;
          if((inLine = in.readLine()) != null) {
            inStringBuilder.append(inLine);
          }
          while((inLine = in.readLine()) != null) {
            inStringBuilder.append('\n');
            inStringBuilder.append(inLine);
          }
          final JSONObject json = new JSONObject(inStringBuilder.toString());
          final String title = json.getString("title");
          ps.setString(1, title);
          ps.setString(2, json.toString());
          ps.executeUpdate();
          final ResultSet rs = ps.getGeneratedKeys();
          if(rs.next()) {
            out.print(rs.getLong(1));
          }
          if(rs.next()) { // shouldn't happen...
            out.println();
            out.print(rs.getLong(1));
          }
        }
        catch(SQLException t) {
          out.print("ERROR: " + t);
        }
        out.flush();
      }
    }
  }
}
