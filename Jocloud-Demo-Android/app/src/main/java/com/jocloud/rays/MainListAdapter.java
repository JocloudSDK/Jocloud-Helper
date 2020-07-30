package com.jocloud.rays;

import android.content.Context;
import android.os.Build;
import android.view.View;

import androidx.annotation.RequiresApi;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.aivacom.api.utils.AppContextUtil;
import com.jocloud.rays.bean.AdvanceSceneInfo;

import org.jetbrains.annotations.NotNull;

import java.util.logging.Logger;

/**
 * Created by zhouwen on 2020/5/18.
 */
public class MainListAdapter extends RVBaseAdapter<AdvanceSceneInfo> {

    private OnRecycleItemViewListener mOnRecycleItemViewListener;

    public MainListAdapter(@NotNull Context context, int layoutRes) {
        super(context, layoutRes);
    }

    @RequiresApi(api = Build.VERSION_CODES.LOLLIPOP)
    @Override
    protected void bindItemView(@NotNull RVViewHolder<AdvanceSceneInfo> holder, AdvanceSceneInfo item,
                                final int position) {
        Logger.getLogger("chowen#bindItemView position=" + position);
        holder.setText(R.id.tv_title, AppContextUtil.getAppContext().getString(item.itemTitle));
        holder.setText(R.id.tv_sub_title, AppContextUtil.getAppContext().getString(item.itemSubTitle));
        holder.setImageView(R.id.iv_icon, item.icon);
        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mOnRecycleItemViewListener != null) {
                    mOnRecycleItemViewListener.onItemView(position);
                }
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
