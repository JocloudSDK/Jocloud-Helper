package com.aivacom.api.jly_logcat;

import android.view.View;

import com.aivacom.api.baseui.base.BaseActivity;
import com.aivacom.api.jly_logcat.bean.LogData;

import java.util.ArrayList;

/**
 * Created by zhouwen on 2020/5/22.
 */
public class FloatLogActivity extends BaseActivity {

    private FloatLogView mFloatLogView;

    @Override
    protected int getLayoutResId() {
        return R.layout.float_layout;
    }

    @Override
    protected void initView() {
        mFloatLogView = findViewById(R.id.float_view);
    }

    @Override
    protected void initData() {
        ArrayList<LogData> logDataList = LogManager.getInstance().getLogList();
        mFloatLogView.addLogs(logDataList);

        LogManager.getInstance().setCallback(mFloatLogView);
    }

    @Override
    protected int getTitleResId() {
        return R.string.log_title;
    }

    @Override
    public void finish() {
        LogManager.getInstance().setCallback(null);
        super.finish();
    }

    @Override
    public void onClick(View v) {

    }
}
