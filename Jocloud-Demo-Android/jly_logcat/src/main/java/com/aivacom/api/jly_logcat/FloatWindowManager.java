package com.aivacom.api.jly_logcat;

import android.app.Activity;
import android.content.Context;
import android.graphics.PixelFormat;
import android.os.Build;
import android.util.DisplayMetrics;
import android.view.Gravity;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.WindowManager;

import java.lang.reflect.Field;
import java.util.logging.Logger;

/**
 * Created by zhouwen on 2020/5/18.
 */
public class FloatWindowManager implements View.OnTouchListener {

    private Logger mLogger = Logger.getLogger("FloatWindowManager");
    private Context mContext;
    private WindowManager.LayoutParams mWindowParams;
    private WindowManager mWindowManager;

    private View mFloatLayout;
    private float mInViewX;
    private float mInViewY;
    private float mDownInScreenX;
    private float mDownInScreenY;
    private float mInScreenX;
    private float mInScreenY;

    private FloatViewListener mFloatViewListener;

    public FloatWindowManager(Activity context) {
        this.mContext = context;
        initFloatWindow();
    }

    private void initFloatWindow() {
        LayoutInflater inflater = LayoutInflater.from(mContext);
        if (inflater == null) {
            return;
        }
        mFloatLayout = inflater.inflate(R.layout.float_log_icon, null);
        mFloatLayout.setOnTouchListener(this);

        mWindowParams = new WindowManager.LayoutParams();
        mWindowManager = (WindowManager) mContext.getSystemService(Context.WINDOW_SERVICE);
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) { //8.0新特性
            mWindowParams.type = WindowManager.LayoutParams.TYPE_APPLICATION_OVERLAY;
        } else {
            mWindowParams.type = WindowManager.LayoutParams.TYPE_SYSTEM_ALERT;
        }
        mWindowParams.format = PixelFormat.RGBA_8888;
        mWindowParams.flags = WindowManager.LayoutParams.FLAG_NOT_FOCUSABLE;
        mWindowParams.gravity = Gravity.START | Gravity.TOP;
        mWindowParams.width = WindowManager.LayoutParams.WRAP_CONTENT;
        mWindowParams.height = WindowManager.LayoutParams.WRAP_CONTENT;

        mFloatLayout.setOnClickListener(new View.OnClickListener() {
            @Override
            public void onClick(View v) {
                mLogger.info("setOnClickListener#onClick");
            }
        });
    }

    @Override
    public boolean onTouch(View view, MotionEvent motionEvent) {
        return floatLayoutTouch(motionEvent);
    }

    private boolean floatLayoutTouch(MotionEvent motionEvent) {

        switch (motionEvent.getAction()) {
            case MotionEvent.ACTION_DOWN:
                mInViewX = motionEvent.getX();
                mInViewY = motionEvent.getY();
                mDownInScreenX = motionEvent.getRawX();
                mDownInScreenY = motionEvent.getRawY() - getSysBarHeight(mContext);
                mInScreenX = motionEvent.getRawX();
                mInScreenY = motionEvent.getRawY() - getSysBarHeight(mContext);
                break;
            case MotionEvent.ACTION_MOVE:
                mInScreenX = motionEvent.getRawX();
                mInScreenY = motionEvent.getRawY() - getSysBarHeight(mContext);
                mWindowParams.x = (int) (mInScreenX - mInViewX);
                mWindowParams.y = (int) (mInScreenY - mInViewY);
                mWindowManager.updateViewLayout(mFloatLayout, mWindowParams);
                break;
            case MotionEvent.ACTION_UP:
                if (mDownInScreenX == mInScreenX && mDownInScreenY == mInScreenY) {
                    if (mFloatViewListener != null) {
                        mFloatViewListener.onFloatView();
                    }
                }
                break;
            default:
        }
        return false;
    }

    public void showFloatWindow() {
        if (mFloatLayout.getParent() == null) {
            DisplayMetrics metrics = new DisplayMetrics();
            mWindowManager.getDefaultDisplay().getMetrics(metrics);
            mWindowParams.x = metrics.widthPixels;
            mWindowParams.y = metrics.heightPixels / 2 - getSysBarHeight(mContext);
            mWindowManager.addView(mFloatLayout, mWindowParams);
        }
    }

    public void hideFloatWindow() {
        if (mFloatLayout.getParent() != null) {
            mWindowManager.removeView(mFloatLayout);
        }
    }

    public void setFloatLayoutAlpha(boolean alpha) {
        if (alpha) {
            mFloatLayout.setAlpha((float) 0.5);
        } else {
            mFloatLayout.setAlpha(1);
        }
    }

    private static int getSysBarHeight(Context contex) {
        Class<?> c;
        Object obj;
        Field field;
        int x;
        int sbar = 0;
        try {
            c = Class.forName("com.android.internal.R$dimen");
            obj = c.newInstance();
            field = c.getField("status_bar_height");
            x = Integer.parseInt(field.get(obj).toString());
            sbar = contex.getResources().getDimensionPixelSize(x);
        } catch (Exception e1) {
            e1.printStackTrace();
        }
        return sbar;
    }

    public void setFloatViewListener(FloatViewListener floatViewListener) {
        mFloatViewListener = floatViewListener;
    }


    public interface FloatViewListener {
        void onFloatView();
    }
}
