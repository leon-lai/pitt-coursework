package edu.pitt.sis.ceipts;
import android.app.Activity;
import android.app.Fragment;
import android.content.Context;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
/**
 * 2016-04-25 Leon Lai
 */
public class activity_existing_receipt extends Activity {
  private String receiptID;
  private final String PACKAGE = this.getClass().getPackage().getName();
  private ReceiptViewGroup receiptGUI;
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_existing_receipt);
    /**
     * Get passed arguments.
     */
    final Intent intent = getIntent();
    receiptID = intent.getStringExtra(PACKAGE + ".receiptID");
    /**
     * Get receipt.
     */
    final Receipt receipt;
    {
      Receipt receiptTemp = null;
      try {
        receiptTemp = new Receipt(
          getSharedPreferences("receipts", Context.MODE_PRIVATE).getString(
            receiptID, null
          )
        );
      }
      catch(Throwable t) {
        t.printStackTrace();
      }
      receipt = receiptTemp;
    }
    /**
     * Create receipt GUI.
     */
    receiptGUI = new ReceiptViewGroup(this, false, receipt);
    ((ViewGroup) this.findViewById(R.id.view)).addView(receiptGUI, 0);
  }
  public void deleteReceipt(final View view) {
    final SharedPreferences.Editor p =
      getSharedPreferences("receipts", Context.MODE_PRIVATE).edit();
    System.err.println("DELETING: " + receiptID);
    p.remove(receiptID);
    p.apply();
    System.err.println("DELETED");
    finish();
  }
}
