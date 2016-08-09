package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import android.content.Intent;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.util.LongSparseArray;
import android.view.View;
import android.view.View.OnClickListener;
import android.widget.AdapterView;
import android.widget.AdapterView.OnItemClickListener;
import android.widget.AdapterView.OnItemLongClickListener;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.ListView;
/**
 * @author leon
 */
public class IndexMake extends ActionBarActivity {
  private final String PACKAGE = this.getClass().getPackage().getName();
  private ArrayAdapter<String> adapter;
  private LongSparseArray<String> unpublishedQuestionnaireTitles;
  private long idForNewQuestionnaire;
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_index_make);
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
          proceed(unpublishedQuestionnaireTitles.keyAt(i));
        }
      }
    );
    listView.setOnItemLongClickListener(
      new OnItemLongClickListener() {
        @Override
        public boolean onItemLongClick(
          AdapterView<?> adapterView, View view, int i, long l
        ) {
          remove(unpublishedQuestionnaireTitles.keyAt(i));
          return true;
        }
      }
    );
    button.setOnClickListener(
      new OnClickListener() {
        @Override
        public void onClick(View view) {
          proceed(idForNewQuestionnaire);
        }
      }
    );
  }
  @Override
  protected void onResume() {
    super.onResume();
    refresh();
  }
  private void refresh() {
    unpublishedQuestionnaireTitles =
      Database.getUnpublishedQuestionnaireTitles(this);
    adapter.clear();
    for(
      int index = 0, count = unpublishedQuestionnaireTitles.size();
      index < count;
      ++index
      ) {
      adapter.add(unpublishedQuestionnaireTitles.valueAt(index));
    }
    idForNewQuestionnaire = 0;
    while(true) {
      if(unpublishedQuestionnaireTitles.get(idForNewQuestionnaire) == null) {
        break;
      }
      ++idForNewQuestionnaire;
    }
  }
  private void remove(final long id) {
    Database.removeUnpublishedQuestionnaire(this, id);
    refresh();
  }
  private void proceed(final long id) {
    final Intent intent = new Intent(this, Make.class);
    intent.putExtra(PACKAGE + ".id", id);
    startActivity(intent);
  }
}
