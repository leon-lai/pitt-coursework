package edu.pitt.sis.ceipts;
import android.app.Activity;
import android.content.Intent;
import android.os.Bundle;
import android.view.View;
public class activity_home extends Activity {
  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_home);
  }
  private void dispatchIntent(final Class c) {
    startActivity(new Intent(this, c));
  }
  public void takePicture(final View view) {
    dispatchIntent(activity_take_picture.class);
  }
  public void newReceipt(final View view) {
    dispatchIntent(activity_new_receipt.class);
  }
  public void receiptsList(final View view) {
    dispatchIntent(activity_receipts_list.class);
  }
  public void spendingLog(final View view) {
    dispatchIntent(activity_spending_log.class);
  }
}
