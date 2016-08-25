package edu.pitt.sis.ceipts;
import android.app.ListActivity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ArrayAdapter;
import android.widget.ListView;
import android.widget.TextView;

import java.util.TreeSet;
/**
 * 2016-04-25 Leon Lai
 */
public class activity_receipts_list extends ListActivity {
  private final String PACKAGE = this.getClass().getPackage().getName();
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setListAdapter(
      new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1)
    );
  }
  @Override
  protected void onResume() {
    super.onResume();
    final TreeSet<String> keys = new TreeSet<String>(
      getSharedPreferences("receipts", MODE_PRIVATE).getAll().keySet()
    );
    final String[] headers = keys.toArray(new String[keys.size()]);
    final ArrayAdapter<String> adapter =
      (ArrayAdapter<String>) getListAdapter(); // Unchecked cast
    adapter.clear();
    adapter.addAll(headers);
  }
  @Override
  protected void onListItemClick(
    final ListView l, final View v, final int position, final long id
  ) {
    Intent intent = new Intent(
      activity_receipts_list.this, activity_existing_receipt.class
    );
    intent.putExtra(
      PACKAGE + ".receiptID", ((TextView) v).getText().toString()
    );
    startActivity(intent);
  }
}
