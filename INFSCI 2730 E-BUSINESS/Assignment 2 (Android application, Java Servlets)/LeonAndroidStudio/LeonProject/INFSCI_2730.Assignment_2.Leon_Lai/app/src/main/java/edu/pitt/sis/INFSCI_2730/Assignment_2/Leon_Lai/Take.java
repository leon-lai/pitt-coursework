package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnDismissListener;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.v7.app.ActionBarActivity;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.ViewGroup;
/**
 * @author leon
 */
public class Take extends ActionBarActivity {
  private final String PACKAGE = this.getClass().getPackage().getName();
  private ViewGroup questionnaireVG;
  private long id;
  @Override
  protected void onCreate(final Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.activity_take);
    id = getIntent().getLongExtra(PACKAGE + ".id", -1);
    get();
  }
  private void get() {
    new AsyncTask<Object, Object, Object>() {
      @Override
      protected Object doInBackground(Object... o) {
        try {
          return Database.getPublicQuestionnaire(id);
        }
        catch(Database.DatabaseException t) {
          return t.messageId;
        }
      }
      @Override
      protected void onPostExecute(Object result) {
        if(result instanceof Questionnaire) {
          final Questionnaire questionnaire = (Questionnaire) result;
          questionnaireVG = (questionnaire == null) ?
            null :
            QuestionnaireFrontend.questionnaireToViewGroup(
              Take.this, questionnaire, true
            );
          ((ViewGroup) findViewById(R.id.q)).addView(questionnaireVG);
          findViewById(R.id.button).setOnClickListener(
            new OnClickListener() {
              @Override
              public void onClick(View view) {
                send();
              }
            }
          );
        }
        else {
          final int m = (Integer) result;
          new AlertDialog.Builder(Take.this).setMessage(m).show();
          Take.this.finish();
        }
      }
    }.execute("");
  }
  private void send() {
    final AnsweredQuestionnaire answeredQuestionnaire =
      QuestionnaireFrontend.answeredQuestionnaireFromViewGroup(
        questionnaireVG
      );
    new AsyncTask<Object, Object, Object>() {
      @Override
      protected Object doInBackground(Object... o) {
        try {
          return Database.sendAnsweredQuestionnaire(answeredQuestionnaire);
        }
        catch(Database.DatabaseException t) {
          return t.messageId;
        }
      }
      @Override
      protected void onPostExecute(Object result) {
        if(result instanceof Long) {
          new AlertDialog.Builder(Take.this).setMessage(
            R.string.message_sendAnsweredQuestionnaire_success
          ).setOnDismissListener(
            new OnDismissListener() {
              @Override
              public void onDismiss(DialogInterface dialogInterface) {
                Take.this.finish();
              }
            }
          ).show();
        }
        else {
          final int m = (Integer) result;
          new AlertDialog.Builder(Take.this).setMessage(
            m
          ).setOnDismissListener(
            new OnDismissListener() {
              @Override
              public void onDismiss(DialogInterface dialogInterface) {
                if(m !=
                  R.string.message_sendAnsweredQuestionnaire_error_write_request) {
                  Take.this.finish();
                }
              }
            }
          ).show();
        }
      }
    }.execute("");
  }
}
