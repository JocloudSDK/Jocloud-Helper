package com.yy.video_advanced;

import android.content.Intent;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.view.View;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;

import com.aivacom.api.baseui.base.BaseActivity;
import com.aivacom.api.utils.Constant;
import com.aivacom.api.utils.PermissionUtils;
import com.yy.video_advanced.UI.AnchorActivity;
import com.yy.video_advanced.UI.AudienceActivity;

import java.util.Random;

import tv.athena.util.common.ShellUtils;

public class VideoAdvancedActivity extends BaseActivity {

    private Button btnCreateRoom; //创建房间
    private Button btnJoinRoom; //加入房间
    private EditText mEditText;
    private ImageView ivClean;

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_video_advanced;
    }

    @Override
    protected void initView() {
        btnCreateRoom = findViewById(R.id.btnCreatRoom);
        btnJoinRoom = findViewById(R.id.btnJoinRoom);
        mEditText = findViewById(R.id.etRoomID);
        ivClean = findViewById(R.id.ivClean);

        btnCreateRoom.setOnClickListener(this);
        btnJoinRoom.setOnClickListener(this);
        ivClean.setOnClickListener(this);

        mEditText.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String inputtxt = s.toString();
                if (inputtxt.startsWith("0")) {
                    mEditText.setText("");
                    return;
                }

                if (!inputtxt.equals("")) {
                    ivClean.setVisibility(View.VISIBLE);
                    btnJoinRoom.setEnabled(true);
                } else {
                    ivClean.setVisibility(View.GONE);
                    btnJoinRoom.setEnabled(false);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

        PermissionUtils.checkAndRequestMorePermissions(mContext, PermissionUtils.permissions,
                PermissionUtils.REQUEST_CODE_PERMISSIONS,
                new PermissionUtils.PermissionRequestSuccessCallBack() {
                    @Override
                    public void onHasPermission() {
                    }
                });
    }

    @Override
    protected void initData() {

    }

    @Override
    protected int getTitleResId() {
        return R.string.advanced_main_title;
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btnCreatRoom) { //创建房间
            createRoom();
        } else if (id == R.id.btnJoinRoom) { //加入房间
            joinRoom();
        } else if (id == R.id.ivClean) {
            mEditText.setText("");
        }
    }

    /**
     * 创建房间
     */
    private void createRoom() {
        if (netIsAvailableByPing()) {
            String roomID = String.valueOf(new Random().nextInt(8999) + 1000);
            Intent intent = new Intent(this, AnchorActivity.class);
            intent.putExtra("roomID", roomID);
            startActivity(intent);
        } else {
            showToast(getResources().getString(R.string.text_toast_network_error));
        }
    }

    /**
     * 加入房间
     */
    private void joinRoom() {
        if (netIsAvailableByPing()) {
            Intent intent = new Intent(this, AudienceActivity.class);
            intent.putExtra("roomID", mEditText.getText().toString());
            startActivity(intent);
        } else {
            showToast(getResources().getString(R.string.text_toast_network_error));
        }
    }

    public static boolean netIsAvailableByPing() {
        ShellUtils.CommandResult result = ShellUtils.execCmd("ping -c 1 -w 1 223.5.5.5", false);
        return result.result == 0;
    }
}
