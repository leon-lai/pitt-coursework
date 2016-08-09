package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
/**
 * @author leon
 */
public class AnsweredQuestion implements Serializable {
  public final String text;
  public final String type;
  public final Object answer;
  public AnsweredQuestion(
    final String text, final String type, final Object answer
  ) {
    this.text = text;
    this.type = type;
    this.answer = answer;
  }
  public JSONObject toJSON() {
    try {
      return new JSONObject().put("text", text)
        .put("type", type)
        .put("answer", answer);
    }
    catch(JSONException t) {
      return null;
    }
  }
  public String toString() {
    return toJSON().toString();
  }
  public AnsweredQuestion(JSONObject json) {
    this(json.optString("text"), json.optString("type"), json.opt("answer"));
  }
}
