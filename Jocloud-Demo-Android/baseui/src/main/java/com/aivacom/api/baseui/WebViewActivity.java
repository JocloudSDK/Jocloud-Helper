package com.aivacom.api.baseui;


import android.text.TextUtils;
import android.view.View;
import android.webkit.WebView;

import com.aivacom.api.baseui.base.BaseActivity;

public class WebViewActivity extends BaseActivity {

    public static final String URL = "web_view_url";
    private WebView mWebView;

    @Override
    protected int getLayoutResId() {
        return R.layout.web_view_activity;
    }

    @Override
    protected void initView() {
        mWebView = findViewById(R.id.web_view);
    }

    @Override
    protected void initData() {
        String url = getIntent().getStringExtra(URL);
        if (!TextUtils.isEmpty(url)) {
            mWebView.loadUrl(url);
        }
    }

    @Override
    protected int getTitleResId() {
        return R.string.title_api;
    }

    @Override
    public void onClick(View v) {

    }
}
