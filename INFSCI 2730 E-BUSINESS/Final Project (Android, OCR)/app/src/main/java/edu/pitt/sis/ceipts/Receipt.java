package edu.pitt.sis.ceipts;
import android.os.Parcel;
import android.os.Parcelable;

import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.text.ParseException;
import java.text.SimpleDateFormat;
import java.util.Arrays;
import java.util.Date;
import java.util.List;
/**
 * 2016-04-25 Leon Lai
 */
public class Receipt implements Parcelable {
  public static final SimpleDateFormat S =
    new SimpleDateFormat("yyyy-MM-dd(EE) HH:mm Z");
  private static final int NUM_MSEC_IN_MIN = 60000;
  public final long when;
  private final String whenString;
  private Item[] items;
  public String when() {
    return whenString;
  }
  public List<Item> items() {
    return Arrays.asList(items);
  }
  public Receipt() {
    this(new Date(), Arrays.asList(new Item()));
  }
  public Receipt(
    final String when, final List<Item> items
  ) throws ParseException {
    this(when == null ? null : S.parse(when), items);
  }
  public Receipt(final Date when, final List<Item> items) {
    this(
      when == null ? null : when.getTime() / NUM_MSEC_IN_MIN,
      items == null ? null : items.toArray(new Item[items.size()])
    );
  }
  public Receipt(final long when, final Item[] items) {
    this.when = when;
    this.whenString = S.format(new Date(when * NUM_MSEC_IN_MIN));
    this.items = items == null ? new Item[0] : items;
  }
  @Override
  public int describeContents() {
    return 0;
  }
  @Override
  public void writeToParcel(Parcel out, int flags) {
    out.writeLong(when);
    out.writeTypedArray(items, 0);
  }
  public static final Parcelable.Creator<Receipt> CREATOR =
    new Parcelable.Creator<Receipt>() {
      public Receipt createFromParcel(Parcel in) {
        return new Receipt(in);
      }
      public Receipt[] newArray(int size) {
        return new Receipt[size];
      }
    };
  private Receipt(Parcel in) {
    this(in.readLong(), in.createTypedArray(Item.CREATOR));
  }
  public Receipt(String json) throws JSONException {
    this(new JSONObject(json));
  }
  public Receipt(final JSONObject json) {
    this(json.optLong("when"), itemsFromJSON(json.optJSONArray("items")));
  }
  private static Item[] itemsFromJSON(final JSONArray from) {
    if(from == null) {
      return null;
    }
    Item[] to = new Item[from.length()];
    for(int index = 0, count = from.length(); index < count; ++index) {
      to[index] = new Item(from.optJSONObject(index));
    }
    return to;
  }
  public String toString() {
    return toJSON().toString();
  }
  public String toStringIndented() {
    try {
      return toJSON().toString(2);
    }
    catch(Throwable t) {
      t.printStackTrace();
      return null;
    }
  }
  public JSONObject toJSON() {
    try {
      return new JSONObject().put("when", when)
        .put("items", itemsToJSON(items));
    }
    catch(Throwable t) {
      t.printStackTrace();
      return null;
    }
  }
  private static JSONArray itemsToJSON(final Item[] from) {
    JSONArray to = new JSONArray();
    for(int index = 0, count = from.length; index < count; ++index) {
      to.put(from[index].toJSON());
    }
    return to;
  }
}
