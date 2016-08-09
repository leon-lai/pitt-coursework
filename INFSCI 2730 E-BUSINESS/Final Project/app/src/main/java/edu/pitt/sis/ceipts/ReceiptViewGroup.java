package edu.pitt.sis.ceipts;
import android.app.AlertDialog;
import android.content.Context;
import android.graphics.Typeface;
import android.text.InputType;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.EditText;
import android.widget.LinearLayout;
import android.widget.TableLayout;
import android.widget.TableRow;
import android.widget.TextView;

import java.math.BigDecimal;
import java.text.ParseException;
import java.util.Date;
import java.util.LinkedList;
/**
 * 2016-04-25 Leon Lai
 */
public class ReceiptViewGroup extends LinearLayout {
  private final boolean edit;
  public ReceiptViewGroup(final Context c) {
    this(c, false, null);
  }
  public ReceiptViewGroup(
    final Context c, final boolean edit, Receipt receipt
  ) {
    super(c);
    this.edit = edit;
    receipt = receipt == null ? new Receipt() : receipt;
    setOrientation(LinearLayout.VERTICAL);
    setLayoutParams(
      new LinearLayout.LayoutParams(
        LinearLayout.LayoutParams.MATCH_PARENT,
        LinearLayout.LayoutParams.WRAP_CONTENT
      )
    );
    /**
     * Receipt → when
     */
    final TextView whenGUIHeader = new TextView(c);
    final TextView whenGUI;
    if(edit) {
      whenGUI = new EditText(c);
      whenGUI.setHint(Receipt.S.toPattern());
    }
    else {
      whenGUI = new TextView(c);
    }
    whenGUIHeader.setTypeface(Typeface.MONOSPACE, Typeface.BOLD);
    whenGUIHeader.setText(R.string.whenGUIHeader);
    whenGUI.setInputType(InputType.TYPE_CLASS_DATETIME);
    whenGUI.setText(receipt.when());
    whenGUI.setOnFocusChangeListener(
      new OnFocusChangeListener() {
        private final String message =
          "Unrecognizeable datetime: format must be \"" +
            Receipt.S.toPattern() + "\". Make blank to reset.";
        @Override
        public void onFocusChange(final View v, final boolean hasFocus) {
          if(!hasFocus) {
            try {
              if(whenGUI.getText().length() == 0) {
                whenGUI.setText(
                  Receipt.S.format(new Date())
                );
              }
              else {
                whenGUI.setText(
                  Receipt.S.format(
                    Receipt.S.parse(
                      ((TextView) v).getText().toString()
                    )
                  )
                );
              }
            }
            catch(ParseException t) {
              new AlertDialog.Builder(c).setMessage(message)
                .setPositiveButton("OK", null)
                .show();
            }
          }
        }
      }
    );
    addView(whenGUIHeader);
    addView(whenGUI);
    /**
     * Receipt → items
     */
    BigDecimal total = BigDecimal.ZERO;
    final TableLayout itemsGUI = new TableLayout(c);
    itemsGUI.setLayoutParams(
      new TableLayout.LayoutParams(
        TableLayout.LayoutParams.MATCH_PARENT,
        TableLayout.LayoutParams.WRAP_CONTENT
      )
    );
    for(Item item : receipt.items()) {
      total =
        total.add(item.itemPrice == null ? BigDecimal.ZERO : item.itemPrice);
      itemsGUI.addView(
        buildItemGUI(item.itemDescription(), item.itemPrice())
      );
    }
    final TableRow itemsGUIHeader = new TableRow(c);
    final TextView itemDescriptionGUIHeader = new TextView(c);
    final TextView itemPriceGUIHeader = new TextView(c);
    itemDescriptionGUIHeader.setLayoutParams(
      new TableRow.LayoutParams(
        TableRow.LayoutParams.WRAP_CONTENT,
        TableRow.LayoutParams.WRAP_CONTENT,
        4f
      )
    );
    itemPriceGUIHeader.setLayoutParams(
      new TableRow.LayoutParams(
        TableRow.LayoutParams.WRAP_CONTENT,
        TableRow.LayoutParams.WRAP_CONTENT,
        2f
      )
    );
    itemDescriptionGUIHeader.setTypeface(Typeface.MONOSPACE, Typeface.BOLD);
    itemPriceGUIHeader.setTypeface(Typeface.MONOSPACE, Typeface.BOLD);
    itemDescriptionGUIHeader.setText(R.string.itemDescriptionGUIHeader);
    itemPriceGUIHeader.setText(R.string.itemPriceGUIHeader);
    itemsGUIHeader.addView(itemDescriptionGUIHeader);
    itemsGUIHeader.addView(itemPriceGUIHeader);
    if(edit) {
      final TextView dummy = new TextView(c);
      dummy.setLayoutParams(
        new TableRow.LayoutParams(
          TableRow.LayoutParams.WRAP_CONTENT,
          TableRow.LayoutParams.WRAP_CONTENT,
          1f
        )
      );
      dummy.setTypeface(Typeface.MONOSPACE, Typeface.BOLD);
      itemsGUIHeader.addView(dummy);
    }
    itemsGUI.addView(itemsGUIHeader, 0);
    /**
     * Control for adding item
     */
    if(edit) {
      final Button addItemGUI = new Button(c);
      addItemGUI.setText(R.string.add);
      addItemGUI.setOnClickListener(
        new OnClickListener() {
          @Override
          public void onClick(final View v) {
            itemsGUI.addView(
              buildItemGUI(null, null), itemsGUI.indexOfChild(addItemGUI)
            );
          }
        }
      );
      itemsGUI.addView(addItemGUI);
    }
    else {
      final TableRow footerGUI = new TableRow(c);
      final TextView totalGUIHeader = new TextView(c);
      final TextView totalGUI = new TextView(c);
      totalGUIHeader.setLayoutParams(
        new TableRow.LayoutParams(
          TableRow.LayoutParams.MATCH_PARENT,
          TableRow.LayoutParams.WRAP_CONTENT,
          4f
        )
      );
      totalGUI.setLayoutParams(
        new TableRow.LayoutParams(
          TableRow.LayoutParams.MATCH_PARENT,
          TableRow.LayoutParams.WRAP_CONTENT,
          2f
        )
      );
      totalGUIHeader.setTypeface(Typeface.SERIF, Typeface.BOLD_ITALIC);
      totalGUI.setTypeface(Typeface.SERIF, Typeface.BOLD_ITALIC);
      totalGUIHeader.setText("Total:");
      totalGUI.setText(String.format("%.2f", total));
      footerGUI.addView(totalGUIHeader);
      footerGUI.addView(totalGUI);
      itemsGUI.addView(footerGUI);
    }
    addView(itemsGUI);
  }
  private TableRow buildItemGUI(
    final String itemDescription, final String itemPrice
  ) {
    final Context c = getContext();
    final TableRow itemGUI = new TableRow(c);
    itemGUI.setLayoutParams(
      new TableRow.LayoutParams(
        TableRow.LayoutParams.MATCH_PARENT, TableRow.LayoutParams.WRAP_CONTENT
      )
    );
    /**
     * Item → itemDescription, itemPrice
     */
    final TextView itemDescriptionGUI, itemPriceGUI;
    if(edit) {
      itemDescriptionGUI = new EditText(c);
      itemPriceGUI = new EditText(c);
      itemDescriptionGUI.setHint(R.string.itemDescriptionGUIHeader);
      itemPriceGUI.setHint(R.string.itemPriceGUIHeader);
    }
    else {
      itemDescriptionGUI = new TextView(c);
      itemPriceGUI = new TextView(c);
    }
    itemDescriptionGUI.setLayoutParams(
      new TableRow.LayoutParams(
        TableRow.LayoutParams.WRAP_CONTENT,
        TableRow.LayoutParams.WRAP_CONTENT,
        4f
      )
    );
    itemPriceGUI.setLayoutParams(
      new TableRow.LayoutParams(
        TableRow.LayoutParams.WRAP_CONTENT,
        TableRow.LayoutParams.WRAP_CONTENT,
        2f
      )
    );
    itemPriceGUI.setInputType(
      InputType.TYPE_CLASS_NUMBER | InputType.TYPE_NUMBER_FLAG_DECIMAL
    );
    itemDescriptionGUI.setText(itemDescription);
    itemPriceGUI.setText(itemPrice);
    itemGUI.addView(itemDescriptionGUI);
    itemGUI.addView(itemPriceGUI);
    /**
     * Control for removing item
     */
    if(edit) {
      final Button removeItemGUI = new Button(c);
      removeItemGUI.setLayoutParams(
        new TableRow.LayoutParams(
          TableRow.LayoutParams.WRAP_CONTENT,
          TableRow.LayoutParams.WRAP_CONTENT,
          1f
        )
      );
      removeItemGUI.setText(R.string.remove);
      removeItemGUI.setOnClickListener(
        new OnClickListener() {
          @Override
          public void onClick(final View v) {
            ((ViewGroup) itemGUI.getParent()).removeView(itemGUI);
          }
        }
      );
      itemGUI.addView(removeItemGUI);
    }
    return itemGUI;
  }
  public Receipt receipt() {
    final TextView whenGUI = (TextView) getChildAt(1);
    final ViewGroup itemsGUI = (ViewGroup) getChildAt(2);
    final LinkedList<Item> items = new LinkedList<Item>();
    final int lastIndex = itemsGUI.getChildCount() - 1;
    for(int index = 1; index <= lastIndex - 1; ++index) {
      final ViewGroup itemGUI = (ViewGroup) itemsGUI.getChildAt(index);
      final TextView itemDescriptionGUI = (TextView) itemGUI.getChildAt(0);
      final TextView itemPriceGUI = (TextView) itemGUI.getChildAt(1);
      items.add(
        new Item(
          itemDescriptionGUI.getText().toString(),
          itemPriceGUI.getText().toString()
        )
      );
    }
    if(!(itemsGUI.getChildAt(lastIndex) instanceof Button)) {
      final ViewGroup itemGUI = (ViewGroup) itemsGUI.getChildAt(lastIndex);
      final TextView itemDescriptionGUI = (TextView) itemGUI.getChildAt(0);
      final TextView itemPriceGUI = (TextView) itemGUI.getChildAt(1);
      items.add(
        new Item(
          itemDescriptionGUI.getText().toString(),
          itemPriceGUI.getText().toString()
        )
      );
    }
    try {
      return new Receipt(whenGUI.getText().toString(), items);
    }
    catch(NumberFormatException t) {
      t.printStackTrace();
      return null;
    }
    catch(ParseException t) {
      t.printStackTrace();
      return null;
    }
  }
}
