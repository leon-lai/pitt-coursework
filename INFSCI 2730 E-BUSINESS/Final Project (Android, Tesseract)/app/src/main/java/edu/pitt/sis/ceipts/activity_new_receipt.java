package edu.pitt.sis.ceipts;
import android.app.Activity;
import android.content.Intent;
import android.content.SharedPreferences;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
/**
 * 2016-04-13 Turki Alenezi
 * 2016-04-19 Leon Lai
 * 2016-04-25 Leon Lai
 */
public class activity_new_receipt extends Activity {
  private final String PACKAGE = this.getClass().getPackage().getName();
  private ReceiptViewGroup receiptGUI;
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_new_receipt);
    /**
     * Get passed arguments.
     */
    final Intent intent = getIntent();
    final Receipt receipt = intent.getParcelableExtra(PACKAGE + ".parse");
    /**
     * Create receipt GUI.
     */
    receiptGUI = new ReceiptViewGroup(this, true, receipt);
    ((ViewGroup) this.findViewById(R.id.view)).addView(receiptGUI, 0);
  }
  public void saveReceipt(final View view) {
    final Receipt receipt = receiptGUI.receipt();
    final SharedPreferences.Editor p =
      getSharedPreferences("receipts", MODE_PRIVATE).edit();
    System.err.println("SAVING: " + receipt);
    p.putString(receipt.when(), receipt.toString());
    p.apply();
    System.err.println("SAVED");
    finish();
  }
  public void discardReceipt(final View view) {
    finish();
  }
}
