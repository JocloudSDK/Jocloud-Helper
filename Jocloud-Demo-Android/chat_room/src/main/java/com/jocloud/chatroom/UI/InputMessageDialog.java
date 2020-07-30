package com.jocloud.chatroom.UI;

import android.content.Context;
import android.os.Bundle;
import android.os.Handler;
import android.view.View;
import android.view.ViewGroup;
import android.view.inputmethod.EditorInfo;
import android.view.inputmethod.InputMethodManager;
import android.widget.EditText;

import androidx.annotation.NonNull;

import com.google.android.material.bottomsheet.BottomSheetDialog;
import com.jocloud.chatroom.R;

public class InputMessageDialog extends BottomSheetDialog {

    private EditText mEtInput;

    private ISendMessageCallback iSendMessageCallback;
    private Context mContext;

    public InputMessageDialog(@NonNull Context context) {
        super(context);
        init(context);
    }

    private void init(Context context) {
        mContext = context;
    }

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        setContentView(R.layout.layout_input_message);
        getWindow().getAttributes().dimAmount = 0f;
        getWindow().setLayout(ViewGroup.LayoutParams.MATCH_PARENT,
                ViewGroup.LayoutParams.MATCH_PARENT);

        mEtInput = findViewById(R.id.etInput);

        findViewById(R.id.tv_send).setOnClickListener(v -> sendMessage());
    }

    private void sendMessage() {
        String msg = mEtInput.getText().toString().trim();
        mEtInput.setText("");
        this.iSendMessageCallback.onSendMessage(msg);
        this.dismiss();
    }

    private Handler handler = new Handler();
    private Runnable delayShowInput = new Runnable() {
        @Override
        public void run() {
            mEtInput.requestFocus();
            InputMethodManager imm =
                    (InputMethodManager) mContext.getSystemService(Context.INPUT_METHOD_SERVICE);
            if (imm != null) {
                imm.showSoftInput(mEtInput, 0);
            }
        }
    };

    @Override
    public void dismiss() {
        InputMethodManager imm =
                (InputMethodManager) mContext.getSystemService(Context.INPUT_METHOD_SERVICE);
        if (imm != null) {
            imm.hideSoftInputFromWindow(mEtInput.getWindowToken(), 0);
        }
        mEtInput.setText("");
        handler.removeCallbacks(delayShowInput);
        super.dismiss();
    }

    public void show(ISendMessageCallback iSendMessageCallback) {
        super.show();
        this.iSendMessageCallback = iSendMessageCallback;
        handler.postDelayed(delayShowInput, 250L);
    }

    public interface ISendMessageCallback {
        void onSendMessage(String msg);
    }
}
