package com.aivacom.api.crosschannel.adapter;

import android.content.Context;
import android.graphics.Color;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.aivacom.api.crosschannel.R;
import com.aivacom.api.crosschannel.model.CrossLogBean;

import org.jetbrains.annotations.NotNull;

/**
 * created by chenshibiao on 2020/6/9.
 */
public class CrossLogAdapter extends RVBaseAdapter<CrossLogBean> {
    public CrossLogAdapter(@NotNull Context context) {
        super(context, R.layout.item_cross_log);
    }

    @Override
    protected void bindItemView(@NotNull RVViewHolder<CrossLogBean> holder, CrossLogBean item, int position) {
        holder.setText(R.id.tv_cross_log, item.getTime() + " " + item.getMsg());

        holder.setTextColor(R.id.tv_cross_log, item.isDark() ?
                Color.parseColor("#333333") :
                Color.parseColor("#858585"));
    }
}
