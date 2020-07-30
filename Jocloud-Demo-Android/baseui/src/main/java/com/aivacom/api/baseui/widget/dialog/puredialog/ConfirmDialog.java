package com.aivacom.api.baseui.widget.dialog.puredialog;

import android.content.Context;
import android.os.Handler;
import android.text.TextUtils;
import android.view.Gravity;
import android.view.View;
import android.widget.TextView;

import com.aivacom.api.baseui.BaseDialog;
import com.aivacom.api.baseui.R;
import com.aivacom.api.utils.Constant;

public class ConfirmDialog extends BaseDialog {

    private final TextView tvTitle;
    private final TextView tvCancel;
    private final TextView tvOk;
    private final TextView tvDesc;
    private final View vLine;
    // private final View vHorLine;
    private long leftTime = 0;
    private Handler mHandler = null;
    private String cancelstr = "";

    public interface OnConfirmCallback {
        void onSure();

        void onCancel();
    }

    public ConfirmDialog(Context context, final OnConfirmCallback listener) {
        super(context);
        tvTitle = view.findViewById(R.id.tv_title);
        tvCancel = view.findViewById(R.id.tv_cancel);
        tvOk = view.findViewById(R.id.tv_ok);
        tvDesc = view.findViewById(R.id.tv_desc);
        vLine = view.findViewById(R.id.v_confirm_line);
        // vHorLine = view.findViewById(R.id.v_confirm_hline);

        tvCancel.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) {
                    listener.onCancel();
                }
                dismiss();
            }
        });
        tvOk.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                if (listener != null) {
                    listener.onSure();
                }
                dismiss();
            }
        });
    }

    public void setTitle(CharSequence title) {
        this.tvTitle.setText(title);
    }

    public void setTitleTextSize(float dp) {
        this.tvTitle.setTextSize(dp);
    }

    public ConfirmDialog setDesc(CharSequence desc) {
        if (!TextUtils.isEmpty(desc)) {
            this.tvDesc.setVisibility(View.VISIBLE);
            this.tvDesc.setText(desc);
        } else {
            this.tvDesc.setVisibility(View.GONE);
        }
        return this;
    }

    public ConfirmDialog setDescTextColor(int color) {
        this.tvDesc.setTextColor(color);
        return this;
    }

    public void setDescTextSize(float dp) {
        this.tvDesc.setTextSize(dp);
    }

    public void setButton(CharSequence cancelCs, CharSequence okCs) {
        this.cancelstr = cancelCs.toString();
        tvCancel.setText(cancelCs);
        tvOk.setText(okCs);
    }

    public void setButton(CharSequence okCs) {
        tvCancel.setVisibility(View.GONE);
        vLine.setVisibility(View.GONE);
        // vHorLine.setVisibility(View.VISIBLE);
        tvOk.setText(okCs);
    }

    public void setTitleGrivate() {
        tvTitle.setGravity(Gravity.LEFT);
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
                tvCancel.setText(cancelstr + "(" + formatLongToTimeStr + ")");
                //每一秒执行一次
                if (mHandler != null) {
                    mHandler.postDelayed(this, 1000);
                }
            } else {
                if (mHandler != null) {
                    mHandler.sendEmptyMessage(Constant.CROSS_AGREE_TIME_OUT);
                }
            }
        }
    };

    @Override
    protected int getLayout() {
        return R.layout.dialog_confirm;
    }
}
