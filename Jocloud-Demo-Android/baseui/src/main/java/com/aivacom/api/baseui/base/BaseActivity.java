package com.aivacom.api.baseui.base;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.os.Build;
import android.os.Bundle;
import android.os.IBinder;
import android.text.TextUtils;
import android.view.KeyEvent;
import android.view.LayoutInflater;
import android.view.MotionEvent;
import android.view.View;
import android.view.ViewGroup;
import android.view.Window;
import android.view.WindowManager;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.Nullable;
import androidx.annotation.StringRes;
import androidx.appcompat.app.AppCompatActivity;

import com.aivacom.api.baseui.R;
import com.aivacom.api.baseui.widget.dialog.puredialog.ConfirmDialog;
import com.aivacom.api.baseui.widget.dialog.puredialog.LoadingDialog;
import com.aivacom.api.utils.LangUtil;


/**
 * Base Activity
 */
public abstract class BaseActivity extends AppCompatActivity implements View.OnClickListener {

    protected final String TAG = getClass().getSimpleName();

    public Context mContext;

    private LoadingDialog dialog;

    private ConfirmDialog confirmDialog;

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);

        LangUtil.initLang(getContext());
        setStatusBar();
        setContentView(R.layout.base_layout);
        int titleResId = getTitleResId();
        String title = null;
        if (titleResId != 0) {
            title = getString(getTitleResId());
        }
        if (TextUtils.isEmpty(title)) {
            findViewById(R.id.ll_title).setVisibility(View.GONE);
        } else {
            ((TextView) findViewById(R.id.tv_title)).setText(title);
            findViewById(R.id.iv_back).setOnClickListener(new View.OnClickListener() {
                @Override
                public void onClick(View v) {
                    onClickBack();
                }
            });
        }

        View view = LayoutInflater.from(this).inflate(getLayoutResId(), null);
        RelativeLayout.LayoutParams params = new RelativeLayout.LayoutParams(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);
        params.addRule(RelativeLayout.BELOW, R.id.ll_title);
        ((ViewGroup) findViewById(R.id.ll_root)).addView(view, params);

        mContext = this;
        initView();
        initData();
    }

    protected void onClickBack() {
        finish();
    }

    protected abstract int getLayoutResId();

    protected abstract void initView();

    protected abstract void initData();

    /**
     * 标题resId，若传0或者其他导致找不到则会隐藏标题栏
     */
    protected abstract int getTitleResId();


    public Context getContext() {
        return this;
    }

    private void setStatusBar() {
        //状态栏透明化: 侵入式透明status bar
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.KITKAT) {
            Window window = getWindow();
            // Translucent status bar
            window.setFlags(WindowManager.LayoutParams.FLAG_TRANSLUCENT_STATUS, WindowManager
                    .LayoutParams.FLAG_TRANSLUCENT_STATUS);
        }
    }

    public void showDialogProgress() {
        if (dialog == null) {
            LoadingDialog.Builder builder = new LoadingDialog.Builder(this)
                    .setMessage(getResources().getString(R.string.loading_progress))
                    .setCancelable(false);
            dialog = builder.create();
            dialog.show();
        }
    }

    public void showDialogProgress(String message) {
        if (dialog == null) {
            LoadingDialog.Builder builder = new LoadingDialog.Builder(this)
                    .setMessage(message)
                    .setCancelable(false);
            dialog = builder.create();
            dialog.show();
        }
    }

    public void dismissDialogProgress() {
        if (dialog != null) {
            dialog.dismiss();
            dialog = null;
        }
    }

    //设置返回按钮：不应该退出程序---而是返回桌面
    //复写onKeyDown事件
    @Override
    public boolean onKeyDown(int keyCode, KeyEvent event) {

        if (keyCode == KeyEvent.KEYCODE_BACK) {
            Intent home = new Intent(Intent.ACTION_MAIN);
            home.setFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP);
            home.addCategory(Intent.CATEGORY_HOME);
            startActivity(home);
            return true;
        }
        return super.onKeyDown(keyCode, event);
    }

    @Override
    public boolean dispatchTouchEvent(MotionEvent ev) {
        switch (ev.getAction()) {
            case MotionEvent.ACTION_UP:
                View view = getCurrentFocus();
                hideKeyboard(ev, view, BaseActivity.this); //调用方法判断是否需要隐藏键盘
                break;
            default:
                break;
        }
        return super.dispatchTouchEvent(ev);
    }

    public void hideKeyboard(MotionEvent event, View view,
                             Activity activity) {
        try {
            if (view != null && view instanceof EditText) {
                int[] location = {0, 0};
                view.getLocationInWindow(location);
                int left = location[0], top = location[1], right = left
                        + view.getWidth(), bottom = top + view.getHeight();
                // 判断焦点位置坐标是否在空间内，如果位置在控件外，则隐藏键盘
//                if (event.getRawX() < left || event.getRawX() > right
//                        || event.getY() < top || event.getRawY() > bootom) {
                if (event.getY() < top || event.getRawY() > bottom) { //左右不隐藏键盘
                    // 隐藏键盘
                    IBinder token = view.getWindowToken();
                    InputMethodManager inputMethodManager = (InputMethodManager) activity
                            .getSystemService(Context.INPUT_METHOD_SERVICE);
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.CUPCAKE) {
                        inputMethodManager.hideSoftInputFromWindow(token,
                                InputMethodManager.HIDE_NOT_ALWAYS);
                    }
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    protected void showToast(CharSequence text) {
        Toast.makeText(this, text, Toast.LENGTH_SHORT).show();
    }

    protected void showToast(@StringRes int resId) {
        Toast.makeText(this, resId, Toast.LENGTH_SHORT).show();
    }

    /* 最后一次点击的时间 */
    private long lastClick = 0;

    /**
     * 可选函数，防止短时间内快速点击按钮而引发了多次事件响应
     */
    public boolean fastClick() {
        if (System.currentTimeMillis() - lastClick <= 1000) {
            return true;
        }
        lastClick = System.currentTimeMillis();
        return false;
    }

    public void showQuitConfirmDialog() {
        if (confirmDialog != null && confirmDialog.isShowing()) {
            return;
        }
        confirmDialog = new ConfirmDialog(this, new ConfirmDialog.OnConfirmCallback() {
            @Override
            public void onSure() {
                finish();
            }

            @Override
            public void onCancel() {
                confirmDialog.dismiss();
            }
        });
        confirmDialog.setDesc(getResources().getString(R.string.confirm_logout_scenario));
        confirmDialog.show();
    }

}

