package edu.pitt.sis.ceipts;
import android.app.Activity;
import android.graphics.Typeface;
import android.os.Bundle;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

import java.util.List;
import java.util.Map;
import java.util.TreeSet;
/**
 * 2016-04-25 Leon Lai
 */
public class activity_spending_log extends Activity {
  private final String PACKAGE = this.getClass().getPackage().getName();
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_spending_log);
    final TableLayout root = (TableLayout) findViewById(R.id.view);
    final Map<String, ?> p =
      getSharedPreferences("receipts", MODE_PRIVATE).getAll();
    for(final String receiptID : new TreeSet<String>(p.keySet())) {
      /**
       * Get receipt.
       */
      final Receipt receipt;
      {
        Receipt receiptTemp = null;
        try {
          receiptTemp = new Receipt(p.get(receiptID).toString());
        }
        catch(Throwable t) {
          t.printStackTrace();
        }
        receipt = receiptTemp;
      }
      if(receipt == null) {
        continue;
      }
      /**
       * Create when GUI.
       */
      final String when = receipt.when();
      final TextView whenGUI = new TextView(this);
      whenGUI.setTypeface(Typeface.SERIF, Typeface.BOLD_ITALIC);
      whenGUI.setText(when);
      root.addView(whenGUI);
      /**
       * Create items GUI.
       */
      final List<Item> items = receipt.items();
      for(Item item : items) {
        final TextView itemDescriptionGUI = new TextView(this);
        final TextView itemPriceGUI = new TextView(this);
        final TableRow spendingLogEntryGUI = new TableRow(this);
        itemDescriptionGUI.setText(item.itemDescription());
        itemPriceGUI.setText(item.itemPrice());
        spendingLogEntryGUI.addView(itemDescriptionGUI);
        spendingLogEntryGUI.addView(itemPriceGUI);
        root.addView(spendingLogEntryGUI);
      }
    }
  }
}

