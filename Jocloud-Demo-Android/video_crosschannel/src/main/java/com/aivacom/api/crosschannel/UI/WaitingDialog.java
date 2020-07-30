package com.aivacom.api.crosschannel.UI;

import android.content.Context;
import android.os.Handler;
import android.widget.TextView;

import com.aivacom.api.baseui.BaseDialog;
import com.aivacom.api.crosschannel.R;
import com.aivacom.api.utils.Constant;

public class WaitingDialog extends BaseDialog {

    private final TextView tvContent;
    private long leftTime = 0;
    private Handler mHandler = null;
    private Context mContext;

    public WaitingDialog(Context context) {
        super(context);
        mContext = context;
        tvContent = view.findViewById(R.id.tv_cross_waitting_remote);
        tvContent.setText(
                mContext.getResources().getString(R.string.cross_waitting_remote) + "15s");
    }

    public void setCountdown(final long timeLong, final Handler handler) {
        leftTime = timeLong;
        mHandler = handler;
        handler.postDelayed(runnable, 1000);
    }

    private String formatLongToTimeStr(long leftTime) {
        return String.valueOf(leftTime / 1000);
    }

    @Override
    public void dismiss() {
        super.dismiss();
        if (mHandler != null) {
            mHandler.removeCallbacks(runnable);
        }
    }

    Runnable runnable = new Runnable() {
        @Override
        public void run() {
            if (leftTime > 0) {
                leftTime = leftTime - 1000;
                //倒计时效果展示
                String formatLongToTimeStr = formatLongToTimeStr(leftTime);
                tvContent.setText(mContext.getResources().getString(R.string.cross_waitting_remote)
                        + formatLongToTimeStr + "s");
                //每一秒执行一次
                if (mHandler != null) {
                    mHandler.postDelayed(this, 1000);
                }
            } else {
                if (mHandler != null) {
                    mHandler.sendEmptyMessage(Constant.CROSS_AGREE_NO_RESPOSE);
                }
            }
        }
    };

    @Override
    protected int getLayout() {
        return R.layout.dialog_waitting;
    }
}
