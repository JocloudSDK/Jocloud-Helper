package com.jocloud.rays;

import android.content.Context;
import android.os.Build;
import android.widget.TextView;

import androidx.annotation.RequiresApi;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.jocloud.rays.bean.AdvanceSceneInfo;

import org.jetbrains.annotations.NotNull;

/**
 * Created by zhouwen on 2020/5/18.
 */
public class MainListAdapter extends RVBaseAdapter<AdvanceSceneInfo> {

    private OnRecycleItemViewListener mOnRecycleItemViewListener;

    public MainListAdapter(@NotNull Context context) {
        super(context, R.layout.item_view);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    protected void bindItemView(@NotNull RVViewHolder<AdvanceSceneInfo> holder, AdvanceSceneInfo item,
                                final int position) {
        TextView tvTitle = holder.getChildView(R.id.tv_title);
        if (item.enable) {
            tvTitle.setTextColor(mContext.getResources().getColor(R.color.color_1C1C1C));
        } else {
            tvTitle.setTextColor(mContext.getResources().getColor(R.color.color_50black));
        }

        tvTitle.setText(mContext.getString(item.itemTitle));
        holder.setText(R.id.tv_sub_title, mContext.getString(item.itemSubTitle));
        holder.setImageView(R.id.iv_icon, item.icon);
        holder.itemView.setOnClickListener(v -> {
            if (mOnRecycleItemViewListener != null) {
                mOnRecycleItemViewListener.onItemView(position);
            }
        });
    }

    public void setRecycleViewListener(OnRecycleItemViewListener recycleViewListener) {
        mOnRecycleItemViewListener = recycleViewListener;
    }

    interface OnRecycleItemViewListener {
        void onItemView(int position);
    }

}
