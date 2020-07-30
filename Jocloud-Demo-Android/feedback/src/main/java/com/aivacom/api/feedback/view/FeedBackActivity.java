package com.aivacom.api.feedback.view;

import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import com.aivacom.api.baseui.base.BaseActivity;
import com.aivacom.api.feedback.FeedBackManager;
import com.aivacom.api.feedback.R;
import com.aivacom.api.utils.CustomVersionUtil;
import com.google.gson.JsonObject;

import org.jetbrains.annotations.NotNull;

import tv.athena.feedback.api.FeedbackData;


public class FeedBackActivity extends BaseActivity {
    //content
    private EditText etContent;
    //mobile
    private EditText etMobile;
    //button
    private TextView tvSubmit;

    @Override
    protected int getLayoutResId() {
        return R.layout.layout_feedback;
    }

    @Override
    protected void initView() {
        etContent = findViewById(R.id.et_feedback_content);
        etMobile = findViewById(R.id.et_feedback_mobile);
        tvSubmit = findViewById(R.id.tv_feedback_submit);

        TextView tvVersion = findViewById(R.id.tv_version);
        tvVersion.setText(CustomVersionUtil.getsVersionString());

        initListener();
    }

    @Override
    protected void initData() {
    }

    @Override
    protected int getTitleResId() {
        return R.string.text_feedback_title;
    }

    private void initListener() {
        tvSubmit.setOnClickListener(this);
    }

    @Override
    public void onClick(View v) {
        int resId = v.getId();
        if (resId == R.id.tv_feedback_submit) { //submit
            submitFeedback();
        }
    }

    private void submitFeedback() {
        String content = etContent.getText().toString();
        String mobile = etMobile.getText().toString();

        if (content.isEmpty()) {
            showToast(R.string.text_feedback_content_toast);
            return;
        }


        showDialogProgress(getString(R.string.text_feedback_submitting));

        JsonObject jsonObject = new JsonObject();
        jsonObject.addProperty("mobile", mobile);
        jsonObject.addProperty("content", content);
        FeedBackManager.getInstance()
                .feedBackLog(jsonObject.toString(), new FeedbackData.FeedbackStatusListener() {
                    @Override
                    public void onFailure(@NotNull FailReason failReason) {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                showToast(R.string.text_feedback_submit_faild);
                                dissMissDialogProgress();
                            }
                        });
                    }

                    @Override
                    public void onComplete() {
                        runOnUiThread(new Runnable() {
                            @Override
                            public void run() {
                                showToast(R.string.text_feedback_submit_succeed);
                                dissMissDialogProgress();
                                finish();
                            }
                        });
                    }

                    @Override
                    public void onProgressChange(int i) {

                    }
                });
    }

}
