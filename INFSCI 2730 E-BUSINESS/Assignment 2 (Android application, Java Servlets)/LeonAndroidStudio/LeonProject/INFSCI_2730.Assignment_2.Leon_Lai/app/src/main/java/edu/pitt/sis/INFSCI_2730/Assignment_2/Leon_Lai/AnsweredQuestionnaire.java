package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
/**
 * @author leon
 */
public class AnsweredQuestionnaire implements Serializable {
  public final String title;
  public final AnsweredQuestion[] answeredQuestions;
  public AnsweredQuestionnaire(
    final String title, final AnsweredQuestion[] answeredQuestions
  ) {
    this.title = title;
    this.answeredQuestions = answeredQuestions;
  }
  public JSONObject toJSON() {
    try {
      return new JSONObject().put("title", title)
        .put("answeredQuestions", answeredQuestionsToJSON(answeredQuestions));
    }
    catch(JSONException t) {
      return null;
    }
  }
  private static JSONArray answeredQuestionsToJSON(AnsweredQuestion[] ff) {
    if(ff == null) {
      return null;
    }
    JSONArray to = new JSONArray();
    for(AnsweredQuestion f : ff) {
      to.put(f.toJSON());
    }
    return to;
  }
  public String toString() {
    return toJSON().toString();
  }
  public AnsweredQuestionnaire(JSONObject json) {
    this(
      json.optString("title"),
      answeredQuestionsFromJSON(json.optJSONArray("answeredQuestions"))
    );
  }
  private static AnsweredQuestion[] answeredQuestionsFromJSON(JSONArray json) {
    if(json == null) {
      return null;
    }
    AnsweredQuestion[] to = new AnsweredQuestion[json.length()];
    for(int index = 0, count = to.length; index < count; ++index) {
      to[index] = new AnsweredQuestion(json.optJSONObject(index));
    }
    return to;
  }
  public AnsweredQuestionnaire(String json) throws JSONException {
    this(new JSONObject(json));
  }
}
