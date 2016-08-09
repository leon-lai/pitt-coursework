package edu.pitt.sis.ceipts;
import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.io.PrintWriter;
import java.util.ArrayList;
import java.util.Date;
import java.util.regex.Matcher;
import java.util.regex.Pattern;

import android.app.Activity;
import android.content.Intent;
import android.graphics.Bitmap;
import android.graphics.BitmapFactory;
import android.graphics.Matrix;
import android.media.ExifInterface;
import android.net.Uri;
import android.os.Bundle;
import android.os.Environment;
import android.provider.MediaStore;

import com.googlecode.tesseract.android.TessBaseAPI;
/**
 * 0000-00-00 http://labs.makemachine.net/2010/03/simple-android-photo-capture
 * 0000-00-00 www.Gaut.am
 * 2016-04-13 Turki Alenezi
 * 2016-04-19 Leon Lai
 * 2016-04-25 Leon Lai
 */
public class activity_take_picture extends Activity {
  private final static String PACKAGE =
    activity_take_picture.class.getPackage().getName();
  private final static String PATH =
    Environment.getExternalStorageDirectory().getPath() + File.separator +
      "Ceipts";
  private final static String PATH_ENGTRAINEDDATA =
    PATH + File.separator + "tessdata" + File.separator + "eng.traineddata";
  private final static String PATH_PICTURE_ORIGINAL =
    PATH + File.separator + "picture.original.jpg";
  private final static String PATH_PICTURE_PREPROCESSED =
    PATH + File.separator + "picture.preprocessed.png";
  private final static String PATH_TRANSCRIPTION =
    PATH + File.separator + "transcription.txt";
  private final static String PATH_PARSE =
    PATH + File.separator + "parse.txt";
  private boolean photoTaken;
  private Bitmap picture;
  private String transcription;
  private Receipt parse;
  @Override
  public void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_take_picture);
    /*
     * Unpack eng.traineddata asset to external storage.
     */
    File engtraineddata = new File(PATH_ENGTRAINEDDATA);
    if(!engtraineddata.exists()) {
      /*
       * Create target folder if necessary.
       */
      final File parent = engtraineddata.getParentFile();
      if(parent.exists() && !parent.isDirectory()) {
        parent.delete();
      }
      if(!parent.exists()) {
        parent.mkdirs();
      }
      /*
       * Copy asset to file.
       */
      try {
        final InputStream in = getAssets().open("eng.traineddata");
        final OutputStream out = new FileOutputStream(engtraineddata);
        final byte[] buf = new byte[1024];
        int len;
        while((len = in.read(buf)) > 0) {
          out.write(buf, 0, len);
        }
        out.flush();
        in.close();
        out.close();
      }
      catch(IOException e) {
        e.printStackTrace();
      }
    }
    dispatchTakePictureIntent();
  }
  private void dispatchTakePictureIntent() {
    final Intent intent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
    intent.putExtra(
      MediaStore.EXTRA_OUTPUT, Uri.fromFile(new File(PATH_PICTURE_ORIGINAL))
    );
    photoTaken = true;
    startActivityForResult(intent, 0);
  }
  @Override
  protected void onActivityResult(
    final int requestCode, final int resultCode, final Intent data
  ) {
    if(resultCode == RESULT_OK) {
      preprocessPicture();
      transcribePicture();
      parseTranscription();
      dispatchMain2Intent();
    }
    finish();
  }
  private void preprocessPicture() {
    /**
     * Downsample picture to speed up OCR.
     */
    final BitmapFactory.Options options = new BitmapFactory.Options();
    options.inSampleSize = 3;
    picture = BitmapFactory.decodeFile(PATH_PICTURE_ORIGINAL, options);
    /**
     * Make picture upright if metadata states it is not.
     */
    try {
      final ExifInterface exif = new ExifInterface(PATH_PICTURE_ORIGINAL);
      final int orientation = exif.getAttributeInt(
        ExifInterface.TAG_ORIENTATION, ExifInterface.ORIENTATION_NORMAL
      );
      final int rotation;
      switch(orientation) {
        default: {
          rotation = 0;
          break;
        }
        case (ExifInterface.ORIENTATION_ROTATE_90): {
          rotation = 90;
          break;
        }
        case (ExifInterface.ORIENTATION_ROTATE_180): {
          rotation = 180;
          break;
        }
        case (ExifInterface.ORIENTATION_ROTATE_270): {
          rotation = 270;
          break;
        }
      }
      if(rotation != 0) {
        final Matrix matrix = new Matrix();
        matrix.preRotate(rotation);
        picture = Bitmap.createBitmap(
          picture,
          0,
          0,
          picture.getWidth(),
          picture.getHeight(),
          matrix,
          false
        );
      }
    }
    catch(IOException e) {
      e.printStackTrace();
    }
    /**
     * Store each pixel on 4 bytes as required by tess-two.
     */
    picture = picture.copy(Bitmap.Config.ARGB_8888, true);
    /**
     * Save preprocessed picture for later viewing.
     */
    try {
      FileOutputStream out = new FileOutputStream(PATH_PICTURE_PREPROCESSED);
      picture.compress(Bitmap.CompressFormat.PNG, 100, out);
      out.close();
    }
    catch(Throwable t) {
      t.printStackTrace();
    }
  }
  private void transcribePicture() {
    final TessBaseAPI baseApi = new TessBaseAPI();
    baseApi.setDebug(true);
    baseApi.init(PATH, "eng");
    baseApi.setImage(picture);
    transcription = baseApi.getUTF8Text();
    baseApi.end();
    /**
     * Save transcription for later viewing.
     */
    try {
      PrintWriter out = new PrintWriter(PATH_TRANSCRIPTION);
      out.write(transcription);
      out.close();
    }
    catch(Throwable t) {
      t.printStackTrace();
    }
  }
  private void parseTranscription() {
    final String[] transcriptionLines = transcription.split("\\r?\\n");
    final ArrayList<Item> items = new ArrayList<Item>();
    final Pattern pricePattern =
      Pattern.compile("\\s\\d{1,3}\\.\\d{2}(\\s|$)");
    for(int i = 0; i < transcriptionLines.length; i++) {
      final Matcher m = pricePattern.matcher(transcriptionLines[i]);
      if(m.find()) {
        items.add(
          new Item(
            transcriptionLines[i].substring(0, m.start()).trim(),
            m.group().trim()
          )
        );
      }
    }
    parse = new Receipt(new Date(), items);
  }
  private void dispatchMain2Intent() {
    final Intent intent = new Intent(this, activity_picture_to_receipt.class);
    intent.putExtra(
      PACKAGE + ".path.picture.original", PATH_PICTURE_ORIGINAL
    );
    intent.putExtra(
      PACKAGE + ".path.picture.preprocessed", PATH_PICTURE_PREPROCESSED
    );
    intent.putExtra(PACKAGE + ".path.transcription", PATH_TRANSCRIPTION);
    intent.putExtra(PACKAGE + ".parse", parse);
    startActivity(intent);
  }
}
