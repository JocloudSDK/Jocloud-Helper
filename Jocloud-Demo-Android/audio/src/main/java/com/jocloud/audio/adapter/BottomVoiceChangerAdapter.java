package com.jocloud.audio.adapter;

import android.content.Context;
import android.widget.TextView;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.jocloud.audio.R;
import com.jocloud.audio.bean.VoiceChanger;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;

/**
 * Menu Adapter
 * 菜单适配器
 */
public class BottomVoiceChangerAdapter extends RVBaseAdapter<VoiceChanger> {

    private boolean mEnable;
    private int mEnableItem;

    public BottomVoiceChangerAdapter(ArrayList<VoiceChanger> dataList, boolean enable, int mode,
                                     Context context) {
        super(context, R.layout.layout_voice_changer_item);
        mEnable = enable;
        mEnableItem = mode;
        setDataList(dataList);
    }

    @Override
    protected void bindItemView(@NotNull RVViewHolder<VoiceChanger> holder, VoiceChanger item, int position) {

        holder.getRootView().setOnClickListener(v -> {
            mEnableItem = item.mode;
            if (getMOnClickListener() != null) {
                getMOnClickListener().onItemClick(v, position);
            }
            notifyDataSetChanged();
        });

        TextView textView = holder.getChildView(R.id.tv_text);
        if (mEnable) {
            if (mEnableItem == item.mode) {
                holder.getRootView().setBackgroundResource(R.drawable.voice_changer_item_select_shape);
                textView.setTextColor(mContext.getResources().getColor(R.color.color_0041FF));
            } else {
                holder.getRootView().setBackgroundResource(R.drawable.voice_changer_item_shape);
                textView.setTextColor(mContext.getResources().getColor(R.color.color_7A7A7A));
            }

            holder.getRootView().setEnabled(true);

        } else {
            holder.getRootView().setEnabled(false);
            holder.getRootView().setBackgroundResource(R.drawable.voice_changer_item_disable_shape);
            textView.setTextColor(mContext.getResources().getColor(R.color.color_307A7A7A));


        }
        holder.setText(R.id.tv_text, item.text);
    }

    public void setEnable(boolean enable) {
        this.mEnable = enable;
        notifyDataSetChanged();
    }

}
