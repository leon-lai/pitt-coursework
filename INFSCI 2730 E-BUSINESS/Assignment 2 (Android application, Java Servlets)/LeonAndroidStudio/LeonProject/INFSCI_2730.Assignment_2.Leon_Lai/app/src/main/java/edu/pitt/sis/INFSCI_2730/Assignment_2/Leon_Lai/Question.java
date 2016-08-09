package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.io.Serializable;
/**
 * @author leon
 */
public class Question implements Serializable {
  public final String text;
  public final String type;
  public final String[] choices;
  public Question(
    final String text, final String type, final String[] choices
  ) {
    this.text = text;
    this.type = type;
    this.choices = choices;
  }
  public JSONObject toJSON() {
    try {
      return new JSONObject().put("text", text)
        .put("type", type)
        .put("choices", choicesToJSON(choices));
    }
    catch(JSONException t) {
      return null;
    }
  }
  private static JSONArray choicesToJSON(String[] ff) {
    if(ff == null) {
      return null;
    }
    JSONArray to = new JSONArray();
    for(String f : ff) {
      to.put(f);
    }
    return to;
  }
  public String toString() {
    return toJSON().toString();
  }
  public Question(JSONObject json) {
    this(
      json.optString("text"),
      json.optString("type"),
      choicesFromJSON(json.optJSONArray("choices"))
    );
  }
  private static String[] choicesFromJSON(JSONArray json) {
    if(json == null) {
      return null;
    }
    String[] to = new String[json.length()];
    for(int index = 0, count = to.length; index < count; ++index) {
      to[index] = json.optString(index);
    }
    return to;
  }
  public Question(String json) throws JSONException {
    this(new JSONObject(json));
  }
}
