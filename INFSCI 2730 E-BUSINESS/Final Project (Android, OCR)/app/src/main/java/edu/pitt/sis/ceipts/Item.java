package edu.pitt.sis.ceipts;
import android.os.Parcel;
import android.os.Parcelable;

import org.json.JSONException;
import org.json.JSONObject;

import java.math.BigDecimal;
/**
 * 2016-04-25 Leon Lai
 */
public class Item implements Parcelable {
  private final String itemDescription;
  public final BigDecimal itemPrice;
  private final String itemPriceString;
  public String itemDescription() {
    return itemDescription;
  }
  public String itemPrice() {
    return itemPriceString;
  }
  public Item() {
    this(null, null);
  }
  public Item(
    final String itemDescription, final String itemPrice
  ) throws NumberFormatException {
    this.itemDescription = itemDescription == null ? "" : itemDescription;
    this.itemPrice = (itemPrice == null || "".equals(itemPrice)) ?
      null :
      new BigDecimal(itemPrice);
    this.itemPriceString =
      this.itemPrice == null ? "" : String.format("%.2f", this.itemPrice);
  }
  @Override
  public int describeContents() {
    return 0;
  }
  @Override
  public void writeToParcel(Parcel out, int flags) {
    out.writeString(itemDescription);
    out.writeString(itemPriceString);
  }
  public static final Parcelable.Creator<Item> CREATOR =
    new Parcelable.Creator<Item>() {
      public Item createFromParcel(Parcel in) {
        return new Item(in);
      }
      public Item[] newArray(int size) {
        return new Item[size];
      }
    };
  private Item(Parcel in) {
    this(in.readString(), in.readString());
  }
  public Item(String json) throws JSONException {
    this(new JSONObject(json));
  }
  public Item(final JSONObject json) {
    this(json.optString("itemDescription"), json.optString("itemPrice"));
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
      return new JSONObject().put("itemDescription", itemDescription)
        .put("itemPrice", itemPriceString);
    }
    catch(Throwable t) {
      t.printStackTrace();
      return null;
    }
  }
}
