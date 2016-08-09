package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
/**
 * @author leon
 */
public class Index extends ActionBarActivity {
  private final String PACKAGE = this.getClass().getPackage().getName();
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_index);
  }
  @Override
  public boolean onCreateOptionsMenu(final Menu menu) {
    // Inflate the menu; this adds items to the action bar if it is present.
    getMenuInflater().inflate(R.menu.menu_index, menu);
    return true;
  }
  @Override
  public boolean onOptionsItemSelected(final MenuItem item) {
    // Handle action bar item clicks here. The action bar will
    // automatically handle clicks on the Home/Up button, so long
    // as you specify a parent activity in AndroidManifest.xml.
    int id = item.getItemId();
    if(id == R.id.action_settings) {
      return true;
    }
    return super.onOptionsItemSelected(item);
  }
  public void make(final View view) {
    startActivity(new Intent(this, IndexMake.class));
  }
  public void take(final View view) {
    startActivity(new Intent(this, IndexTake.class));
  }
}
