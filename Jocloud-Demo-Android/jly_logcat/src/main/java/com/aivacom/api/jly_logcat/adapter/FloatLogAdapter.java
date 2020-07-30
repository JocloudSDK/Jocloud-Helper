package com.aivacom.api.jly_logcat.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.view.View;
import android.widget.TextView;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.aivacom.api.jly_logcat.ILog;
import com.aivacom.api.jly_logcat.R;
import com.aivacom.api.jly_logcat.bean.LogData;
import com.aivacom.api.utils.AppContextUtil;
import com.aivacom.api.utils.DataFormatUtil;

import java.util.logging.Logger;

/**
 * Created by zhouwen on 2020/5/19.
 */
public class FloatLogAdapter extends RVBaseAdapter<LogData> {

    private static Logger sLogger = Logger.getLogger("FloatLogAdapter");
    private OnRecycleItemViewListener mItemViewListener;

    public FloatLogAdapter(Context context, int layoutRes) {
        super(context, layoutRes);
    }

    @Override
    protected void bindItemView(final RVViewHolder<LogData> holder, final LogData item, final int position) {
        holder.itemView.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (mItemViewListener != null) {
                    mItemViewListener.onItemView(position);
                }
            }
        });

        TextView textView = holder.getChildView(R.id.tv_tag);
        String time = DataFormatUtil.formatTimeWithRim(item.time);

        if (TextUtils.equals(item.logTag, ILog.LogTag.INFO)) {
            textView.setTextColor(AppContextUtil.getAppContext().getResources().getColor(R.color.color_666));
        } else if (TextUtils.equals(item.logTag, ILog.LogTag.WARN)) {
            textView.setTextColor(AppContextUtil.getAppContext().getResources().getColor(R.color.color_y));
        } else if (TextUtils.equals(item.logTag, ILog.LogTag.ERROR)) {
            textView.setTextColor(AppContextUtil.getAppContext().getResources().getColor(R.color.color_333));
        }

        String logMsgStr = String.format("%s %s", time, item.logStr);
        textView.setText(logMsgStr);
    }

    public void setRecycleViewListener(OnRecycleItemViewListener recycleViewListener) {
        mItemViewListener = recycleViewListener;
    }

    public interface OnRecycleItemViewListener {
        void onItemView(int position);
    }
}
