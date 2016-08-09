package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import android.app.AlertDialog;
import android.content.Intent;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.util.LongSparseArray;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
/**
 * @author leon
 */
public class IndexTake extends ActionBarActivity {
  private final String PACKAGE = this.getClass().getPackage().getName();
  private ArrayAdapter<String> adapter;
  private LongSparseArray<String> publicQuestionnaireTitles;
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_index_take);
    final ListView listView = (ListView) findViewById(R.id.listView);
    final Button button = (Button) findViewById(R.id.button);
    adapter =
      new ArrayAdapter<String>(this, android.R.layout.simple_list_item_1);
    listView.setAdapter(adapter);
    listView.setOnItemClickListener(
      new OnItemClickListener() {
        @Override
        public void onItemClick(
          AdapterView<?> adapterView, View view, int i, long l
        ) {
          proceed(publicQuestionnaireTitles.keyAt(i));
        }
      }
    );
    button.setOnClickListener(
      new OnClickListener() {
        @Override
        public void onClick(View view) {
          refresh();
        }
      }
    );
    refresh();
  }
  private void refresh() {
    new AsyncTask<Object, Object, Object>() {
      @Override
      protected Object doInBackground(Object... o) {
        try {
          return Database.getPublicQuestionnaireTitles();
        }
        catch(Database.DatabaseException t) {
          return t.messageId;
        }
      }
      @Override
      protected void onPostExecute(Object result) {
        if(result instanceof LongSparseArray) {
          publicQuestionnaireTitles = (LongSparseArray<String>) result;
          adapter.clear();
          for(
            int index = 0, count = publicQuestionnaireTitles.size();
            index < count;
            ++index
            ) {
            adapter.add(publicQuestionnaireTitles.valueAt(index));
          }
        }
        else {
          final int m = (Integer) result;
          new AlertDialog.Builder(IndexTake.this).setMessage(m).show();
        }
      }
    }.execute("");
  }
  private void proceed(final long id) {
    final Intent intent = new Intent(this, Take.class);
    intent.putExtra(PACKAGE + ".id", id);
    startActivity(intent);
  }
}
