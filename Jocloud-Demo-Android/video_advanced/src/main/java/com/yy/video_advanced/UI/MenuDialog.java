package com.yy.video_advanced.UI;

import android.content.Context;
import android.graphics.drawable.ColorDrawable;
import android.os.Bundle;
import android.view.View;
import android.view.ViewGroup;
import android.widget.TextView;

import com.google.android.material.bottomsheet.BottomSheetBehavior;
import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.yy.video_advanced.R;
import com.yy.video_advanced.adapter.BaseAdapter;
import com.yy.video_advanced.adapter.MenuAdapter;

import java.util.List;

import androidx.annotation.NonNull;
import androidx.core.content.ContextCompat;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.DividerItemDecoration;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

/**
 *
 * Menu Dialog
 *
 * ZH：
 * 菜单dailog
 *
 * @author Aslan chenhengfei@yy.com
 * @date 2019/12/31
 */
public class MenuDialog extends BottomSheetDialog {

  private RecyclerView recyclerView;
  private TextView btCancel;
  private List<String> list;
  private OnItemSelectedListener listener;

  public MenuDialog(@NonNull Context context, List<String> list, OnItemSelectedListener listener) {
    super(context);
    this.list = list;
    this.listener = listener;
  }

  @Override
  protected void onStart() {
    super.onStart();
    BottomSheetBehavior behavior = getBehavior();
    behavior.setState(BottomSheetBehavior.STATE_EXPANDED);
  }

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    setContentView(R.layout.layout_menu);
    getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT, ViewGroup.LayoutParams.MATCH_PARENT);

    recyclerView = findViewById(R.id.rvList);
    recyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
    DividerItemDecoration itemDecoration = new DividerItemDecoration(getContext(),
            DividerItemDecoration.VERTICAL);
    itemDecoration.setDrawable(
            new ColorDrawable(ContextCompat.getColor(getContext(), R.color.bg_grey)));
    recyclerView.addItemDecoration(itemDecoration);
    recyclerView.setItemAnimator(new DefaultItemAnimator());
    MenuAdapter adapter = new MenuAdapter(list);
    adapter.setOnItemClickListener(new BaseAdapter.OnItemClickListener() {
      @Override
      public void onItemClick(View view, int position) {
        listener.onItemSelected(position);
        dismiss();
      }
    });
    recyclerView.setAdapter(adapter);

    btCancel = findViewById(R.id.btCancel);
    btCancel.setOnClickListener(new View.OnClickListener() {
      @Override
      public void onClick(View v) {
        dismiss();
      }
    });
  }

  public interface OnItemSelectedListener {

    void onItemSelected(int index);
  }
}
