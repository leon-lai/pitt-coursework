package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.LongSparseArray;

import org.json.JSONArray;
import org.json.JSONObject;

import java.io.InputStreamReader;
import java.io.PrintWriter;
import java.io.BufferedReader;
import java.net.HttpURLConnection;
import java.net.URL;
import java.util.Iterator;
import java.util.Map;
/**
 * @author leon
 */
public final class Database {
  /**
   * https://developer.android.com/tools/devices/emulator.html
   */
  private static final String PROTOCOL_HOST_PORT = "http://10.0.2.2:8080";
  public static class DatabaseException extends Exception {
    public final int messageId;
    public DatabaseException(final int messageId, final Throwable cause) {
      super(cause);
      this.messageId = messageId;
    }
  }
  static LongSparseArray<String> getUnpublishedQuestionnaireTitles(
    final Context c
  ) {
    final String loc = "unpublished_questionnaires";
    final Map<String, ?> p =
      c.getSharedPreferences(loc, Context.MODE_PRIVATE).getAll();
    final LongSparseArray<String> ret = new LongSparseArray<String>();
    for(final String idString : p.keySet()) {
      try {
        final int id = Integer.valueOf(idString);
        final String qString = (String) p.get(idString);
        ret.put(id, new Questionnaire(qString).title);
      }
      catch(Throwable t) {
        t.printStackTrace();
      }
    }
    return ret;
  }
  static Questionnaire getUnpublishedQuestionnaire(
    final Context c, final long id
  ) {
    final String loc = "unpublished_questionnaires";
    final SharedPreferences p = c.getSharedPreferences(
      loc, Context.MODE_PRIVATE
    );
    try {
      final String idString = String.valueOf(id);
      final String qString = p.getString(idString, null);
      return (qString == null) ? null : new Questionnaire(qString);
    }
    catch(Throwable t) {
      t.printStackTrace();
      return null;
    }
  }
  static void removeUnpublishedQuestionnaire(
    final Context c, final long id
  ) {
    final String loc = "unpublished_questionnaires";
    final SharedPreferences.Editor p =
      c.getSharedPreferences(loc, Context.MODE_PRIVATE).edit();
    try {
      final String idString = String.valueOf(id);
      p.remove(idString);
    }
    catch(Throwable t) {
      t.printStackTrace();
    }
    p.commit();
  }
  static void saveUnpublishedQuestionnaire(
    final Context c, final long id, final Questionnaire q
  ) {
    final String loc = "unpublished_questionnaires";
    final SharedPreferences.Editor p =
      c.getSharedPreferences(loc, Context.MODE_PRIVATE).edit();
    System.err.println("SAVING: " + q);
    try {
      final String idString = String.valueOf(id);
      final String qString = (q == null) ? null : q.toString();
      p.putString(idString, qString);
    }
    catch(Throwable t) {
      t.printStackTrace();
    }
    p.commit();
  }
  static long publishQuestionnaire(
    final Questionnaire questionnaire
  ) throws DatabaseException {
    final String loc = PROTOCOL_HOST_PORT + "/PublishQuestionnaire";
    final HttpURLConnection p;
    final String responseBody;
    System.err.println("PUBLISHING: " + questionnaire);
    try {
      p = (HttpURLConnection) new URL(loc).openConnection();
      p.setRequestMethod("POST");
      p.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
      p.setDoOutput(true);
      final PrintWriter out =
        new PrintWriter(p.getOutputStream(), true); // want autoflush
      out.println(questionnaire);  // don't care newline at end
      out.close();
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_publishQuestionnaire_error_write_request, t
      );
    }
    try {
      final BufferedReader in =
        new BufferedReader(new InputStreamReader(p.getInputStream()));
      final StringBuilder inStringBuilder = new StringBuilder();
      String inLine;
      if((inLine = in.readLine()) != null) {
        inStringBuilder.append(inLine);
      }
      while((inLine = in.readLine()) != null) {
        inStringBuilder.append('\n');
        inStringBuilder.append(inLine);
      }
      in.close();
      responseBody = inStringBuilder.toString();
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_publishQuestionnaire_error_read_response, t
      );
    }
    p.disconnect();
    System.err.println(responseBody);
    try {
      return Long.valueOf(responseBody);
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_publishQuestionnaire_error_parse_response, t
      );
    }
  }
  static LongSparseArray<String> getPublicQuestionnaireTitles(
  ) throws DatabaseException {
    final String loc = PROTOCOL_HOST_PORT + "/GetPublicQuestionnaireTitles";
    final HttpURLConnection p;
    final String responseBody;
    try {
      p = (HttpURLConnection) new URL(loc).openConnection();
      p.setRequestMethod("GET");
      final BufferedReader in =
        new BufferedReader(new InputStreamReader(p.getInputStream()));
      final StringBuilder inStringBuilder = new StringBuilder();
      String inLine;
      if((inLine = in.readLine()) != null) {
        inStringBuilder.append(inLine);
      }
      while((inLine = in.readLine()) != null) {
        inStringBuilder.append('\n');
        inStringBuilder.append(inLine);
      }
      in.close();
      responseBody = inStringBuilder.toString();
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_getPublicQuestionnaireTitles_error_read_response, t
      );
    }
    p.disconnect();
    System.err.println(responseBody);
    try {
      final LongSparseArray<String> ret = new LongSparseArray<String>();
      final JSONObject ttJ = new JSONObject(responseBody);
      final Iterator<String> ttJkeys = ttJ.keys();
      while(ttJkeys.hasNext()) {
        final String key = ttJkeys.next();
        final long id = Long.valueOf(key);
        final String title = ttJ.getString(key);
        ret.put(id, title);
      }
      return ret;
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_getPublicQuestionnaireTitles_error_parse_response, t
      );
    }
  }
  static Questionnaire getPublicQuestionnaire(
    final long id
  ) throws DatabaseException {
    final String loc = PROTOCOL_HOST_PORT + "/GetPublicQuestionnaire";
    final HttpURLConnection p;
    final String responseBody;
    try {
      p = (HttpURLConnection) new URL(loc + "?id=" + id).openConnection();
      p.setRequestMethod("GET");
      final BufferedReader in =
        new BufferedReader(new InputStreamReader(p.getInputStream()));
      final StringBuilder inStringBuilder = new StringBuilder();
      String inLine;
      if((inLine = in.readLine()) != null) {
        inStringBuilder.append(inLine);
      }
      while((inLine = in.readLine()) != null) {
        inStringBuilder.append('\n');
        inStringBuilder.append(inLine);
      }
      in.close();
      responseBody = inStringBuilder.toString();
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_getPublicQuestionnaire_error_read_response, t
      );
    }
    p.disconnect();
    System.err.println(responseBody);
    try {
      return new Questionnaire(responseBody);
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_getPublicQuestionnaire_error_parse_response, t
      );
    }
  }
  static long sendAnsweredQuestionnaire(
    final AnsweredQuestionnaire answeredQuestionnaire
  ) throws DatabaseException {
    final String loc = PROTOCOL_HOST_PORT + "/SendAnsweredQuestionnaire";
    final HttpURLConnection p;
    final String responseBody;
    System.err.println("SENDING: " + answeredQuestionnaire);
    try {
      p = (HttpURLConnection) new URL(loc).openConnection();
      p.setRequestMethod("POST");
      p.setRequestProperty("Content-Type", "application/json;charset=UTF-8");
      p.setDoOutput(true);
      final PrintWriter out =
        new PrintWriter(p.getOutputStream(), true); // want autoflush
      out.println(answeredQuestionnaire);  // don't care newline at end
      out.close();
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_sendAnsweredQuestionnaire_error_write_request, t
      );
    }
    try {
      final BufferedReader in =
        new BufferedReader(new InputStreamReader(p.getInputStream()));
      final StringBuilder inStringBuilder = new StringBuilder();
      String inLine;
      if((inLine = in.readLine()) != null) {
        inStringBuilder.append(inLine);
      }
      while((inLine = in.readLine()) != null) {
        inStringBuilder.append('\n');
        inStringBuilder.append(inLine);
      }
      in.close();
      responseBody = inStringBuilder.toString();
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_sendAnsweredQuestionnaire_error_read_response, t
      );
    }
    p.disconnect();
    System.err.println(responseBody);
    try {
      return Long.valueOf(responseBody);
    }
    catch(Throwable t) {
      t.printStackTrace();
      throw new DatabaseException(
        R.string.message_sendAnsweredQuestionnaire_error_parse_response, t
      );
    }
  }
  /* Servlet for this has not been implemented ! */
  static AnsweredQuestionnaire[] getAnsweredQuestionnaires(
    final int questionnaireId
  ) throws DatabaseException {
    final String loc = PROTOCOL_HOST_PORT + "/GetAnsweredQuestionnaires";
    final HttpURLConnection p;
    final String responseBody;
    return null;
  }
}
