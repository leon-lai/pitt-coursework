package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
/**
 * @author leon
 */
public class Make extends ActionBarActivity {
  private final String PACKAGE = this.getClass().getPackage().getName();
  private ViewGroup questionnaireVG;
  private long id;
  private boolean hasPublished = false;
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_make);
    id = getIntent().getLongExtra(PACKAGE + ".id", -1);
    get();
  }
  @Override
  protected void onPause() {
    super.onPause();
    save();
  }
  @Override
  public void onCreateContextMenu(
    ContextMenu menu, View v, ContextMenuInfo menuInfo
  ) {
    super.onCreateContextMenu(menu, v, menuInfo);
    targetView = v;
    QuestionnaireFrontend.onCreateContextMenu(
      this, menu, targetView, menuInfo
    );
  }
  private View targetView;
  @Override
  public boolean onContextItemSelected(MenuItem item) {
    QuestionnaireFrontend.onContextItemSelected(
      this, item, targetView, false
    );
    return super.onContextItemSelected(item);
  }
  private void get() {
    final Questionnaire questionnaire =
      Database.getUnpublishedQuestionnaire(this, id);
    questionnaireVG = (questionnaire == null) ?
      QuestionnaireFrontend.defaultQuestionnaireToViewGroup(this) :
      QuestionnaireFrontend.questionnaireToViewGroup(
        this, questionnaire, false
      );
    ((ViewGroup) findViewById(R.id.q)).addView(questionnaireVG);
    findViewById(R.id.button).setOnClickListener(
      new OnClickListener() {
        @Override
        public void onClick(View view) {
          publish();
        }
      }
    );
  }
  private void save() {
    if(hasPublished) {
      Database.removeUnpublishedQuestionnaire(this, id);
    }
    else {
      final Questionnaire questionnaire =
        QuestionnaireFrontend.questionnaireFromViewGroup(
          questionnaireVG, false
        );
      Database.saveUnpublishedQuestionnaire(this, id, questionnaire);
    }
  }
  private void publish() {
    final Questionnaire questionnaire =
      QuestionnaireFrontend.questionnaireFromViewGroup(
        questionnaireVG, false
      );
    new AsyncTask<Object, Object, Object>() {
      @Override
      protected Object doInBackground(Object... o) {
        try {
          return Database.publishQuestionnaire(questionnaire);
        }
        catch(Database.DatabaseException t) {
          return t.messageId;
        }
      }
      @Override
      protected void onPostExecute(Object result) {
        if(result instanceof Long) {
          hasPublished = true;
          new AlertDialog.Builder(Make.this).setMessage(
            R.string.message_publishQuestionnaire_success
          ).setOnDismissListener(
            new OnDismissListener() {
              @Override
              public void onDismiss(DialogInterface dialogInterface) {
                Make.this.finish();
              }
            }
          ).show();
        }
        else {
          final int m = (Integer) result;
          new AlertDialog.Builder(Make.this).setMessage(
            m
          ).setOnDismissListener(
            new OnDismissListener() {
              @Override
              public void onDismiss(DialogInterface dialogInterface) {
                if(m !=
                  R.string.message_publishQuestionnaire_error_write_request) {
                  Make.this.finish();
                }
              }
            }
          ).show();
        }
      }
    }.execute("");
  }
}
