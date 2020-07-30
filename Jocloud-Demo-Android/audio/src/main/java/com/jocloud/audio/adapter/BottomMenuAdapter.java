package com.jocloud.audio.adapter;

import android.content.Context;
import android.widget.TextView;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.jocloud.audio.R;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;

/**
 * Menu Adapter
 * 菜单适配器
 */
public class BottomMenuAdapter extends RVBaseAdapter<String> {

    public BottomMenuAdapter(ArrayList<String> dataList, Context context) {
        super(context, R.layout.layout_menu_item);
        setDataList(dataList);
    }

    @Override
    protected void bindItemView(@NotNull RVViewHolder<String> holder, String item, int position) {
        TextView textView = holder.getChildView(R.id.tv_text);
        if (position == getItemCount() - 1) {
            textView.setTextColor(mContext.getResources().getColor(R.color.color_7A7A7A));
        }
        textView.setText(item);
    }
}
