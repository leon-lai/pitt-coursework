package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
/**
 * @author leon
 */
public class Questionnaire implements Serializable {
  public final String title;
  public final Question[] questions;
  public Questionnaire(
    final String title, final Question[] questions
  ) {
    this.title = title;
    this.questions = questions;
  }
  public JSONObject toJSON() {
    try {
      return new JSONObject().put("title", title)
        .put("questions", questionsToJSON(questions));
    }
    catch(JSONException t) {
      return null;
    }
  }
  private static JSONArray questionsToJSON(Question[] ff) {
    if(ff == null) {
      return null;
    }
    JSONArray to = new JSONArray();
    for(Question f : ff) {
      to.put(f.toJSON());
    }
    return to;
  }
  public String toString() {
    return toJSON().toString();
  }
  public Questionnaire(JSONObject json) {
    this(
      json.optString("title"),
      questionsFromJSON(json.optJSONArray("questions"))
    );
  }
  private static Question[] questionsFromJSON(JSONArray json) {
    if(json == null) {
      return null;
    }
    Question[] to = new Question[json.length()];
    for(int index = 0, count = to.length; index < count; ++index) {
      to[index] = new Question(json.optJSONObject(index));
    }
    return to;
  }
  public Questionnaire(String json) throws JSONException {
    this(new JSONObject(json));
  }
}
