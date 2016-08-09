package edu.pitt.sis.INFSCI_2730.Assignment_2.Leon_Lai;
import android.app.Activity;
import android.app.AlertDialog;
import android.content.DialogInterface;
import android.content.DialogInterface.OnCancelListener;
import android.content.DialogInterface.OnDismissListener;
import android.view.ContextMenu;
import android.view.ContextMenu.ContextMenuInfo;
import android.view.MenuItem;
import android.view.View;
import android.view.View.OnClickListener;
import android.view.View.OnFocusChangeListener;
import android.view.View.OnLongClickListener;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.CheckBox;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.RatingBar;
import android.widget.SeekBar;
import android.widget.Spinner;
import android.widget.SpinnerAdapter;
import android.widget.TextView;
import android.widget.TimePicker;

import java.util.ArrayList;
import java.util.Calendar;
/**
 * @author leon
 */
public class QuestionnaireFrontend {
  public static ViewGroup defaultQuestionnaireToViewGroup(final Activity c) {
    return questionnaireToViewGroup(
      c, new Questionnaire(
        null, new Question[] {new Question(null, null, null)}
      ), false
    );
  }
  public static ViewGroup questionnaireToViewGroup(
    final Activity c, final Questionnaire q, final boolean isPublished
  ) {
    final String title = q.title;
    final Question[] questions = q.questions;
    final LinearLayout questionnaireVG = new LinearLayout(c);
    final TextView titleV = isPublished ? new TextView(c) : new EditText(c);
    final LinearLayout questionsVG = new LinearLayout(c);
    questionnaireVG.setOrientation(LinearLayout.VERTICAL);
    if(!isPublished) {
      titleV.setHint(R.string.placeholder_title);
    }
    titleV.setText(title);
    questionsVG.setOrientation(LinearLayout.VERTICAL);
    for(Question question : questions) {
      questionsVG.addView(questionToViewGroup(c, question, isPublished));
    }
    questionnaireVG.addView(titleV);
    questionnaireVG.addView(questionsVG);
    if(!isPublished) {
      final Button addQuestionB = new Button(c);
      addQuestionB.setText(R.string.action_addquestion);
      addQuestionB.setOnClickListener(
        new OnClickListener() {
          @Override
          public void onClick(final View view) {
            questionsVG.addView(
              questionToViewGroup(
                c, new Question(null, null, null), isPublished
              )
            );
          }
        }
      );
      questionnaireVG.addView(addQuestionB);
    }
    return questionnaireVG;
  }
  private static ViewGroup questionToViewGroup(
    final Activity c, final Question question, final boolean isPublished
  ) {
    final String text = question.text;
    final String type = question.type;
    final LinearLayout questionVG = new LinearLayout(c);
    final LinearLayout questionTextVG = new LinearLayout(c);
    final TextView textV = isPublished ? new TextView(c) : new EditText(c);
    final View responseV;
    questionVG.setOrientation(LinearLayout.VERTICAL);
    c.registerForContextMenu(questionVG);
    if(!isPublished) {
      final Button delQuestionB = new Button(c);
      delQuestionB.setText("×");
      delQuestionB.setOnClickListener(
        new OnClickListener() {
          @Override
          public void onClick(final View view) {
            ((ViewGroup) questionVG.getParent()).removeView(questionVG);
          }
        }
      );
      questionTextVG.addView(delQuestionB);
      textV.setHint(R.string.placeholder_question);
    }
    textV.setText(text);
    textV.setLayoutParams(
      new LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.WRAP_CONTENT,
        LinearLayout.LayoutParams.WRAP_CONTENT,
        1f
      )
    );
    questionTextVG.addView(textV);
    if(type == null) {
      responseV = new EditText(c);
    }
    else if(type.equals("CheckBox")) {
      responseV = buildCheckBoxGroup(c, question.choices, isPublished);
    }
    else if(type.equals("SeekBar")) {
      responseV = new SeekBar(c);
    }
    else if(type.equals("RatingBar")) {
      responseV = new RatingBar(c);
    }
    else if(type.equals("Spinner")) {
      responseV = buildSpinner(c, question.choices, isPublished);
    }
    else if(type.equals("EditText")) {
      responseV = new EditText(c);
    }
    else if(type.equals("DatePicker")) {
      responseV = new DatePicker(c);
    }
    else if(type.equals("TimePicker")) {
      responseV = new TimePicker(c);
    }
    else {
      responseV = new EditText(c);
    }
    questionVG.addView(questionTextVG);
    questionVG.addView(responseV);
    return questionVG;
  }
  private static ViewGroup buildCheckBoxGroup(
    final Activity c, final String[] choices, final boolean isPublished
  ) {
    final LinearLayout checkBoxGroupVG = new LinearLayout(c);
    final LinearLayout choicesVG = new LinearLayout(c);
    checkBoxGroupVG.setOrientation(LinearLayout.VERTICAL);
    choicesVG.setOrientation(LinearLayout.VERTICAL);
    for(String choice : choices) {
      final View choiceV;
      if(isPublished) {
        final CheckBox choiceCB = new CheckBox(c);
        choiceCB.setText(choice);
        choiceV = choiceCB;
      }
      else {
        choiceV = buildCheckBoxForUnpublished(c, choice);
      }
      choicesVG.addView(choiceV);
    }
    checkBoxGroupVG.addView(choicesVG);
    if(!isPublished) {
      final Button addChoiceB = new Button(c);
      addChoiceB.setText("+");
      addChoiceB.setOnClickListener(
        new OnClickListener() {
          @Override
          public void onClick(final View view) {
            choicesVG.addView(
              buildCheckBoxForUnpublished(c, ""), choicesVG.getChildCount()
            );
          }
        }
      );
      checkBoxGroupVG.addView(addChoiceB);
    }
    return checkBoxGroupVG;
  }
  private static ViewGroup buildCheckBoxForUnpublished(
    final Activity c, final String choice
  ) {
    final LinearLayout choiceVG = new LinearLayout(c);
    final CheckBox choiceCB = new CheckBox(c);
    final EditText choiceText = new EditText(c);
    final Button delChoiceB = new Button(c);
    choiceText.setHint(R.string.placeholder_choice);
    choiceText.setText(choice);
    choiceText.setLayoutParams(
      new LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.WRAP_CONTENT,
        LinearLayout.LayoutParams.WRAP_CONTENT,
        1f
      )
    );
    delChoiceB.setText("×");
    delChoiceB.setOnClickListener(
      new OnClickListener() {
        @Override
        public void onClick(final View view) {
          ((ViewGroup) choiceVG.getParent()).removeView(choiceVG);
        }
      }
    );
    choiceVG.addView(choiceCB);
    choiceVG.addView(choiceText);
    choiceVG.addView(delChoiceB);
    return choiceVG;
  }
  private static Spinner buildSpinner(
    final Activity c, final String[] choices, final boolean isPublished
  ) {
    final Spinner choicesV = new Spinner(c);
    final ArrayAdapter<String> choicesA = new ArrayAdapter<String>(
      c, android.R.layout.simple_spinner_dropdown_item, choices
    );
    if(!isPublished) {
      choicesV.setOnLongClickListener(
        new OnLongClickListener() {
          @Override
          public boolean onLongClick(final View view) {
            final ViewGroup s =
              buildSpinnerEditor(c, (ArrayAdapter) choicesV.getAdapter());
            final AlertDialog choicesAD =
              new AlertDialog.Builder(c).setView(s).setOnCancelListener(
                new OnCancelListener() {
                  @Override
                  public void onCancel(final DialogInterface dialogInterface) {
                    final ViewGroup choicesVG = (ViewGroup) s.getChildAt(0);
                    final int count = choicesVG.getChildCount();
                    final String[] choices = new String[count];
                    final ArrayAdapter<String> choicesA;
                    for(int index = 0; index < count; ++index) {
                      final ViewGroup choiceVG =
                        (ViewGroup) choicesVG.getChildAt(index);
                      final EditText choiceText =
                        (EditText) choiceVG.getChildAt(0);
                      final String choice = choiceText.getText().toString();
                      choices[index] = choice;
                    }
                    choicesA = new ArrayAdapter<String>(
                      c,
                      android.R.layout.simple_spinner_dropdown_item,
                      choices
                    );
                    choicesV.setAdapter(choicesA);
                  }
                }
              ).setOnDismissListener(
                new OnDismissListener() {
                  @Override
                  public void onDismiss(final DialogInterface dialogInterface) {
                    final ViewGroup choicesVG = (ViewGroup) s.getChildAt(0);
                    final int count = choicesVG.getChildCount();
                    final String[] choices = new String[count];
                    final ArrayAdapter<String> choicesA;
                    for(int index = 0; index < count; ++index) {
                      final ViewGroup choiceVG =
                        (ViewGroup) choicesVG.getChildAt(index);
                      final EditText choiceText =
                        (EditText) choiceVG.getChildAt(0);
                      final String choice = choiceText.getText().toString();
                      choices[index] = choice;
                    }
                    choicesA = new ArrayAdapter<String>(
                      c,
                      android.R.layout.simple_spinner_dropdown_item,
                      choices
                    );
                    choicesV.setAdapter(choicesA);
                  }
                }
              ).show();
            return true;
          }
        }
      );
    }
    choicesV.setAdapter(choicesA);
    return choicesV;
  }
  private static ViewGroup buildSpinnerEditor(
    final Activity c, final ArrayAdapter<String> a
  ) {
    final LinearLayout spinnerEditorVG = new LinearLayout(c);
    final LinearLayout choicesVG = new LinearLayout(c);
    final Button addChoiceB = new Button(c);
    spinnerEditorVG.setOrientation(LinearLayout.VERTICAL);
    choicesVG.setOrientation(LinearLayout.VERTICAL);
    for(int index = 0, count = a.getCount(); index < count; ++index) {
      final String choice = a.getItem(index);
      final ViewGroup choiceVG = buildSpinnerEditorItem(c, choice);
      choicesVG.addView(choiceVG);
    }
    addChoiceB.setText("+");
    addChoiceB.setOnClickListener(
      new OnClickListener() {
        @Override
        public void onClick(final View view) {
          choicesVG.addView(
            buildSpinnerEditorItem(c, ""), choicesVG.getChildCount()
          );
        }
      }
    );
    spinnerEditorVG.addView(choicesVG);
    spinnerEditorVG.addView(addChoiceB);
    return spinnerEditorVG;
  }
  private static ViewGroup buildSpinnerEditorItem(
    final Activity c, final String choice
  ) {
    final LinearLayout choiceVG = new LinearLayout(c);
    final EditText choiceText = new EditText(c);
    final Button delChoiceB = new Button(c);
    choiceText.setHint(R.string.placeholder_choice);
    choiceText.setText(choice);
    choiceText.setLayoutParams(
      new LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.WRAP_CONTENT,
        LinearLayout.LayoutParams.WRAP_CONTENT,
        1f
      )
    );
    delChoiceB.setText("×");
    delChoiceB.setOnClickListener(
      new OnClickListener() {
        @Override
        public void onClick(final View view) {
          ((ViewGroup) choiceVG.getParent()).removeView(choiceVG);
        }
      }
    );
    choiceVG.addView(choiceText);
    choiceVG.addView(delChoiceB);
    return choiceVG;
  }
  public static void onCreateContextMenu(
    final Activity c, final ContextMenu menu, final View v, final ContextMenuInfo menuInfo
  ) {
    /**
     * Question must be of type CheckBox
     */
    c.getMenuInflater().inflate(R.menu.question_types, menu);
  }
  public static void onContextItemSelected(
    final Activity c, final MenuItem item, final View v, final boolean isPublished
  ) {
    /**
     * Question must be of type CheckBox
     */
    final ViewGroup questionVG = (ViewGroup) v;
    switch(item.getItemId()) {
      case (R.id.CheckBox): {
        changeQuestionType(c, questionVG, "CheckBox", isPublished);
        break;
      }
      case (R.id.SeekBar): {
        changeQuestionType(c, questionVG, "SeekBar", isPublished);
        break;
      }
      case (R.id.RatingBar): {
        changeQuestionType(c, questionVG, "RatingBar", isPublished);
        break;
      }
      case (R.id.Spinner): {
        changeQuestionType(c, questionVG, "Spinner", isPublished);
        break;
      }
      case (R.id.EditText): {
        changeQuestionType(c, questionVG, "EditText", isPublished);
        break;
      }
      case (R.id.DatePicker): {
        changeQuestionType(c, questionVG, "DatePicker", isPublished);
        break;
      }
      case (R.id.TimePicker): {
        changeQuestionType(c, questionVG, "TimePicker", isPublished);
        break;
      }
    }
  }
  private static void changeQuestionType(
    final Activity c, final ViewGroup questionVG, final String type, final boolean isPublished
  ) {
    final View responseV;
    questionVG.removeViews(1, questionVG.getChildCount() - 1);
    if(type == null) {
      responseV = new EditText(c);
    }
    else if(type.equals("CheckBox")) {
      responseV = buildCheckBoxGroup(c, new String[] {""}, isPublished);
    }
    else if(type.equals("SeekBar")) {
      responseV = new SeekBar(c);
    }
    else if(type.equals("RatingBar")) {
      responseV = new RatingBar(c);
    }
    else if(type.equals("Spinner")) {
      responseV = buildSpinner(c, new String[] {""}, isPublished);
    }
    else if(type.equals("EditText")) {
      responseV = new EditText(c);
    }
    else if(type.equals("DatePicker")) {
      responseV = new DatePicker(c);
    }
    else if(type.equals("TimePicker")) {
      responseV = new TimePicker(c);
    }
    else {
      responseV = new EditText(c);
    }
    questionVG.addView(responseV);
  }
  public static Questionnaire questionnaireFromViewGroup(
    final ViewGroup questionnaireVG, final boolean isPublished
  ) {
    return new Questionnaire(
      ((TextView) questionnaireVG.getChildAt(0)).getText().toString(),
      questionsFromViewGroup(
        (ViewGroup) questionnaireVG.getChildAt(1), isPublished
      )
    );
  }
  private static Question[] questionsFromViewGroup(
    final ViewGroup questionsVG, final boolean isPublished
  ) {
    final Question[] questions = new Question[questionsVG.getChildCount()];
    for(
      int index = 0, count = questions.length; index < count; ++index
      ) {
      questions[index] = questionFromViewGroup(
        (ViewGroup) questionsVG.getChildAt(index), isPublished
      );
    }
    return questions;
  }
  private static Question questionFromViewGroup(
    final ViewGroup questionVG, final boolean isPublished
  ) {
    final String text =
      ((TextView) ((ViewGroup) questionVG.getChildAt(0)).getChildAt(1)).getText()
        .toString();
    final View responseV = questionVG.getChildAt(1);
    final String type;
    final String[] choices;
    if(responseV instanceof DatePicker || responseV instanceof TimePicker) {
      type = responseV.getClass().getSimpleName();
      choices = null;
    }
    else if(responseV instanceof Spinner) {
      type = responseV.getClass().getSimpleName();
      final ArrayAdapter<String> choicesA =
        (ArrayAdapter<String>) ((Spinner) responseV).getAdapter();
      final int count = choicesA.getCount();
      choices = new String[count];
      for(int index = 0; index < count; ++index) {
        choices[index] = choicesA.getItem(index);
      }
    }
    else if(responseV instanceof ViewGroup) {
      /**
       * Question must be of type CheckBox
       */
      type = "CheckBox";
      final ViewGroup checkBoxGroupVG = (ViewGroup) responseV;
      final ViewGroup choicesVG = (ViewGroup) checkBoxGroupVG.getChildAt(0);
      choices = new String[choicesVG.getChildCount()];
      for(
        int choiceVIndex = 0, choiceVCount = choicesVG.getChildCount();
        choiceVIndex < choiceVCount;
        ++choiceVIndex
        ) {
        final View choiceV = choicesVG.getChildAt(choiceVIndex);
        final String choice;
        if(isPublished) {
          choice = ((CheckBox) choiceV).getText().toString();
        }
        else {
          final ViewGroup choiceVG = (ViewGroup) choiceV;
          final EditText choiceText = (EditText) choiceVG.getChildAt(1);
          choice = choiceText.getText().toString();
        }
        choices[choiceVIndex] = choice;
      }
    }
    else {
      type = responseV.getClass().getSimpleName();
      choices = null;
    }
    return new Question(text, type, choices);
  }
  public static AnsweredQuestionnaire answeredQuestionnaireFromViewGroup(
    final ViewGroup questionnaireVG
  ) {
    return new AnsweredQuestionnaire(
      ((TextView) questionnaireVG.getChildAt(0)).getText().toString(),
      answeredQuestionsFromViewGroup(
        (ViewGroup) questionnaireVG.getChildAt(1)
      )
    );
  }
  private static AnsweredQuestion[] answeredQuestionsFromViewGroup(final ViewGroup questionsVG) {
    final AnsweredQuestion[] answeredQuestions =
      new AnsweredQuestion[questionsVG.getChildCount()];
    for(
      int index = 0, count = answeredQuestions.length; index < count; ++index
      ) {
      answeredQuestions[index] = answeredQuestionFromViewGroup(
        (ViewGroup) questionsVG.getChildAt(index)
      );
    }
    return answeredQuestions;
  }
  private static AnsweredQuestion answeredQuestionFromViewGroup(final ViewGroup questionVG) {
    final String text =
      ((TextView) ((ViewGroup) questionVG.getChildAt(0)).getChildAt(0)).getText()
        .toString();
    final View responseV = questionVG.getChildAt(1);
    final String type;
    final Object answer;
    if(responseV instanceof SeekBar) {
      type = responseV.getClass().getSimpleName();
      answer = ((SeekBar) responseV).getProgress(); // int
    }
    else if(responseV instanceof RatingBar) {
      type = responseV.getClass().getSimpleName();
      answer = ((RatingBar) responseV).getRating(); // float
    }
    else if(responseV instanceof Spinner) {
      type = responseV.getClass().getSimpleName();
      answer = ((Spinner) responseV).getSelectedItem().toString();
    }
    else if(responseV instanceof EditText) {
      type = responseV.getClass().getSimpleName();
      answer = ((EditText) responseV).getText().toString();
    }
    else if(responseV instanceof DatePicker) {
      type = responseV.getClass().getSimpleName();
      final DatePicker responseDatePicker = (DatePicker) responseV;
      final Calendar calendar = Calendar.getInstance();
      calendar.set(
        responseDatePicker.getYear(),
        responseDatePicker.getMonth(),
        responseDatePicker.getDayOfMonth()
      );
      answer = calendar.getTime(); // java.util.Date
    }
    else if(responseV instanceof TimePicker) {
      type = responseV.getClass().getSimpleName();
      final TimePicker responseTimePicker = (TimePicker) responseV;
      answer = new TimePickerValue(
        responseTimePicker.getCurrentHour(),
        responseTimePicker.getCurrentMinute()
      );
    }
    else if(responseV instanceof ViewGroup) {
      /**
       * Questionnaire must be of type CheckBox
       */
      type = "CheckBox";
      final ViewGroup checkBoxGroupVG = (ViewGroup) responseV;
      final ViewGroup choicesVG = (ViewGroup) checkBoxGroupVG.getChildAt(0);
      ArrayList<Boolean> checkedList = new ArrayList<Boolean>();
      for(
        int choiceVIndex = 0, choiceVCount = choicesVG.getChildCount();
        choiceVIndex < choiceVCount;
        ++choiceVIndex
        ) {
        final View choiceV = choicesVG.getChildAt(choiceVIndex);
        checkedList.add(((CheckBox) choiceV).isChecked());
      }
      answer = checkedList;
    }
    else {
      type = responseV.getClass().getSimpleName();
      answer = null;
    }
    return new AnsweredQuestion(text, type, answer);
  }
}
