package edu.pitt.sis.ceipts;
import android.content.Intent;
import android.content.SharedPreferences;
import android.net.Uri;
import android.os.Bundle;
import android.app.Activity;
import android.view.View;
import android.view.ViewGroup;

import java.io.File;
/**
 * 2016-04-25 Leon Lai
 */
public class activity_picture_to_receipt extends Activity {
  private final String PACKAGE = this.getClass().getPackage().getName();
  private ReceiptViewGroup receiptGUI;
  String originalPicturePath, preprocessedPicturePath, transcriptionPath;
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_picture_to_receipt);
    /**
     * Get passed arguments.
     */
    final Intent intent = getIntent();
    final Receipt receipt = intent.getParcelableExtra(PACKAGE + ".parse");
    System.err.println("PARSE: " + receipt);
    originalPicturePath =
      intent.getStringExtra(PACKAGE + ".path.picture.original");
    preprocessedPicturePath =
      intent.getStringExtra(PACKAGE + ".path.picture.original");
    transcriptionPath =
      intent.getStringExtra(PACKAGE + ".path.transcription");
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
  private void show(final String path, final String mime) {
    Intent intent = new Intent();
    intent.setAction(Intent.ACTION_VIEW);
    intent.setDataAndType(Uri.fromFile(new File(path)), mime);
    startActivity(intent);
  }
  public void showOriginalPicture(final View view) {
    show(originalPicturePath, "image/jpeg");
  }
  public void showPreprocessedPicture(final View view) {
    show(preprocessedPicturePath, "image/png");
  }
  public void showTranscription(final View view) {
    show(transcriptionPath, "text/plain");
  }
}
