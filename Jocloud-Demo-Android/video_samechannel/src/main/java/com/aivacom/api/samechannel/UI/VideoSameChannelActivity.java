package com.aivacom.api.samechannel.UI;

import android.Manifest;
import android.content.Intent;
import android.os.Bundle;
import android.text.Editable;
import android.text.InputFilter;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.ScrollingMovementMethod;
import android.view.View;
import android.view.WindowManager;
import android.widget.Button;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.Nullable;
import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.OrientationHelper;
import androidx.recyclerview.widget.RecyclerView;

import com.aivacom.api.baseui.WebViewActivity;
import com.aivacom.api.baseui.base.BaseActivity;
import com.aivacom.api.feedback.view.FeedBackActivity;
import com.aivacom.api.jly_logcat.FloatLogActivity;
import com.aivacom.api.rtc.FacadeRtcManager;
import com.aivacom.api.samechannel.OnRemoteListener;
import com.aivacom.api.samechannel.R;
import com.aivacom.api.samechannel.adapter.RoomAdapter;
import com.aivacom.api.samechannel.bean.UserInfo;
import com.aivacom.api.utils.Constant;
import com.aivacom.api.utils.DataFormatUtil;
import com.aivacom.api.utils.NetworkUtil;
import com.aivacom.api.utils.PermissionUtils;
import com.thunder.livesdk.ThunderEventHandler;
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.ThunderVideoEncoderConfiguration;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.CopyOnWriteArrayList;

public class VideoSameChannelActivity extends BaseActivity implements View.OnClickListener {

    private RecyclerView rvVideoView;
    private View line1;
    private View line2;
    private EditText etValueUid;
    private ImageView ivClearLocalUid;
    private EditText etValueRoomId;
    private ImageView ivClearLocalRid;
    private TextView tvStartLive;
    private TextView tvRoomStatus;
    private Button btSwitchCamera;
    private Button btCamera;
    private Button btMicrophone;
    private List<View> ivPreviewList = new ArrayList<>();

    private RoomAdapter roomAdapter;

    public UserInfo userInfo;

    private String[] permissions = new String[]{
            Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE};

    private volatile static boolean isFullScreen = false;

    private Map<String, UserInfo> localUserMap = new HashMap<>();

    public volatile static List<OnRemoteListener> mRemoteListeners = new CopyOnWriteArrayList<>();

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        getWindow().setSoftInputMode(WindowManager.LayoutParams.SOFT_INPUT_ADJUST_PAN);
        super.onCreate(savedInstanceState);
    }

    /**
     * thunder SDK event callback
     * see https://docs.aivacom.com/cloud/cn/product_category/rtc_service/rt_video_interaction/api/Android/v2.8
     * .0/notification.html
     */
    private ThunderEventHandler mMyThunderEventHandler = new ThunderEventHandler() {
        @Override
        public void onJoinRoomSuccess(String room, String uid, int elapsed) {
            super.onJoinRoomSuccess(room, uid, elapsed);
            dismissDialogProgress();
            addMessageToLogView("Stream is publishing by UID=" + uid);
            onJoinRoomStatus();
            startPlay();
        }

        @Override
        public void onLeaveRoom(ThunderEventHandler.RoomStats status) {
            super.onLeaveRoom(status);
            dismissDialogProgress();

            onUnJoinRoomStatus();
        }

        @Override
        public void onConnectionLost() {
            super.onConnectionLost();
            dismissDialogProgress();
            showToast(getString(R.string.network_error));
        }

        @Override
        public void onRemoteAudioStopped(String uid, boolean stop) {
            super.onRemoteAudioStopped(uid, stop);

            UserInfo userInfo = roomAdapter.getUserInfo(uid);
            addMessageToLogView("UID=" + uid + " turned " + (stop ? "off" : "on") + " microphone");

            if (userInfo != null) {
                userInfo.setAudioStreamStopped(stop);
                userInfo.setMuteAudio(stop);
                localUserMap.put(userInfo.getUid(), userInfo);
                if (stop && userInfo.isVideoStreamStopped()) {
                    onRemoteLeaveRoom(userInfo);
                    return;
                }
                int index = roomAdapter.getDataList().indexOf(userInfo);
                if (index != -1 && index < 4) {
                    rvVideoView.getChildAt(index).findViewById(R.id.ivMicrophone).
                            setBackgroundResource(stop ? R.drawable.player_btn_microphone_disable :
                                    R.drawable.player_btn_microphone);
                    roomAdapter.updateItemWithoutNotify(index, userInfo);
                }

            } else if (!stop) {
                userInfo = new UserInfo(uid);
                userInfo.setAudioStreamStopped(false);
                userInfo.setMuteAudio(false);
                onRemoteJoinRoom(userInfo, false);

                FacadeRtcManager.getInstance().stopRemoteVideoStream(uid, false);
                FacadeRtcManager.getInstance().stopRemoteAudioStream(uid, false);
            }
        }

        @Override
        public void onRemoteVideoStopped(String uid, boolean stop) {
            super.onRemoteVideoStopped(uid, stop);

            UserInfo userInfo = roomAdapter.getUserInfo(uid);
            addMessageToLogView("UID=" + uid + " turned " + (stop ? "off" : "on") + " camera");

            if (userInfo != null) {
                userInfo.setVideoStreamStopped(stop);
                userInfo.setMuteVideo(stop);

                localUserMap.put(userInfo.getUid(), userInfo);
                if (stop && userInfo.isAudioStreamStopped()) {
                    onRemoteLeaveRoom(userInfo);
                    return;
                }
                int index = roomAdapter.getDataList().indexOf(userInfo);
                if (index != -1 && index < 4) {
                    roomAdapter.updateItemData(index, userInfo);
                }
            } else if (!stop) {
                userInfo = new UserInfo(uid);
                userInfo.setVideoStreamStopped(false);
                userInfo.setMuteVideo(false);
                onRemoteJoinRoom(userInfo, true);

                FacadeRtcManager.getInstance().stopRemoteVideoStream(uid, false);
                FacadeRtcManager.getInstance().stopRemoteAudioStream(uid, false);
            }
        }
    };

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_video_same_channel;
    }

    @Override
    protected void initView() {
        etValueUid = findViewById(R.id.et_value_uid);
        etValueRoomId = findViewById(R.id.et_value_room_id);
        ivClearLocalUid = findViewById(R.id.iv_clear_local_uid);
        ivClearLocalRid = findViewById(R.id.iv_clear_local_rid);
        tvStartLive = findViewById(R.id.tv_start_live);
        btSwitchCamera = findViewById(R.id.bt_switch_camera);
        btCamera = findViewById(R.id.bt_camera);
        btMicrophone = findViewById(R.id.bt_microphone);
        rvVideoView = findViewById(R.id.rv_mutil_video);
        line1 = findViewById(R.id.line1);
        line2 = findViewById(R.id.line2);
        tvRoomStatus = findViewById(R.id.room_status);
        ivPreviewList.add(findViewById(R.id.iv_preview_default1));
        ivPreviewList.add(findViewById(R.id.iv_preview_default2));
        ivPreviewList.add(findViewById(R.id.iv_preview_default3));
        ivPreviewList.add(findViewById(R.id.iv_preview_default4));

        tvRoomStatus.setMovementMethod(ScrollingMovementMethod.getInstance());

        tvStartLive.setOnClickListener(this);
        btSwitchCamera.setOnClickListener(this);
        ivClearLocalUid.setOnClickListener(this);
        ivClearLocalRid.setOnClickListener(this);
        btCamera.setOnClickListener(this);
        btMicrophone.setOnClickListener(this);
        findViewById(R.id.bt_interface).setOnClickListener(this);
        findViewById(R.id.bt_document).setOnClickListener(this);
        findViewById(R.id.bt_feedback).setOnClickListener(this);
        findViewById(R.id.bt_log).setOnClickListener(this);
        findViewById(R.id.bt_setting).setOnClickListener(this);

        roomAdapter = new RoomAdapter(VideoSameChannelActivity.this);
        roomAdapter.setOnItemClickListener((view, position) -> {
            UserInfo userInfo = roomAdapter.getDataList().get(position);
            if (userInfo == null || TextUtils.isEmpty(userInfo.getUid())) {
                return;
            }

            VideoSameChannelActivity.this.userInfo = userInfo;
            handleFullScreen(userInfo, position);
        });

        rvVideoView.setLayoutManager(new WrapGridLayoutManager(this, 2));
        rvVideoView.setAdapter(roomAdapter);
        rvVideoView.setItemAnimator(new DefaultItemAnimator());

    }


    @Override
    protected void initData() {
        PermissionUtils.checkAndRequestMorePermissions(VideoSameChannelActivity.this, permissions,
                PermissionUtils.REQUEST_CODE_PERMISSIONS,
                () -> {
                });

        initEditTextUid();
        initEditTextRId();

        onUnJoinRoomStatus();

        monitorFrontCameraStatus();

        FacadeRtcManager.getInstance().register(mMyThunderEventHandler);

        //set thunder Video Encoder Config
        //设置开播视频的编码配置
        ThunderVideoEncoderConfiguration configuration = new ThunderVideoEncoderConfiguration();
        configuration.publishMode = ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_NORMAL;
        configuration.playType = ThunderRtcConstant.ThunderPublishPlayType.THUNDERPUBLISH_PLAY_INTERACT;
        FacadeRtcManager.getInstance().setVideoEncoderConfig(configuration);

        //set thunder media mode
        //设置媒体模式
        FacadeRtcManager.getInstance().setMediaMode(ThunderRtcConstant.ThunderRtcProfile.THUNDER_PROFILE_DEFAULT);

        //set thunder room mode
        //设置房间场景模式
        FacadeRtcManager.getInstance().setRoomMode(ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_LIVE);

    }

    /**
     * init user id edit text
     */
    private void initEditTextUid() {
        etValueUid.setText(Constant.mLocalUid);
        etValueUid.setFilters(new InputFilter[]{new InputFilter.LengthFilter(6)});
        etValueUid.setOnFocusChangeListener((v, hasFocus) -> setHideIvClearUid(hasFocus));
        etValueUid.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!s.toString().equals("0")) {
                    Constant.mLocalUid = s.toString();
                    setStartLiveEnable();
                    setHideIvClearUid(true);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.toString().equals("0")) {
                    s.clear();
                }
            }
        });
    }

    /**
     * init room id edit text
     */
    private void initEditTextRId() {
        etValueRoomId.setText(Constant.mLocalRoomId);
        etValueRoomId.setOnFocusChangeListener((v, hasFocus) -> setHideIvClearRoomId(hasFocus));
        etValueRoomId.setFilters(new InputFilter[]{new InputFilter.LengthFilter(8)});
        etValueRoomId.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!s.toString().equals("0")) {
                    Constant.mLocalRoomId = s.toString();
                    setStartLiveEnable();
                    setHideIvClearRoomId(true);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.toString().equals("0")) {
                    s.clear();
                }
            }
        });
    }

    /**
     * set tvStartLive is enable
     */
    private void setStartLiveEnable() {
        if (TextUtils.isEmpty(Constant.mLocalUid) || TextUtils.isEmpty(Constant.mLocalRoomId)) {
            tvStartLive.setEnabled(false);
        } else {
            tvStartLive.setEnabled(true);
        }
    }

    /**
     * set ivClearLocalUid Visibility
     *
     * @param hasFocus user id editText has focus
     */
    private void setHideIvClearUid(boolean hasFocus) {
        int oldVisible = ivClearLocalUid.getVisibility();
        int visible = getClearBtnVisible(oldVisible, hasFocus, TextUtils.isEmpty(Constant.mLocalUid));
        if (oldVisible != visible) {
            ivClearLocalUid.setVisibility(visible);
        }
    }

    /**
     * set ivClearLocalRid Visibility
     *
     * @param hasFocus room id editText has focus
     */
    private void setHideIvClearRoomId(boolean hasFocus) {
        int oldVisible = ivClearLocalRid.getVisibility();
        int visible = getClearBtnVisible(oldVisible, hasFocus, TextUtils.isEmpty(Constant.mLocalRoomId));
        if (oldVisible != visible) {
            ivClearLocalRid.setVisibility(visible);
        }
    }

    /**
     * get new ivClearLocalRid or setHideIvClearUid Visibility
     *
     * @param visible     current visibility
     * @param hasFocus    editText has focus
     * @param textIsEmpty editText is empty
     */
    private int getClearBtnVisible(int visible, boolean hasFocus, boolean textIsEmpty) {
        if (hasFocus) {
            if (textIsEmpty) {
                if (visible != View.GONE) {
                    visible = View.GONE;
                }
            } else {
                if (visible != View.VISIBLE) {
                    visible = View.VISIBLE;
                }
            }
        } else {
            if (visible != View.GONE) {
                visible = View.GONE;
            }
        }
        return visible;
    }

    @Override
    protected int getTitleResId() {
        return R.string.text_same_channel_mutil_video;
    }

    @Override
    protected void onClickBack() {
        if (isLiving()) {
            showQuitConfirmDialog();
        } else {
            super.onClickBack();
        }
    }

    @Override
    public void onClick(View v) {
        if (fastClick()) {
            return;
        }
        int id = v.getId();
        if (id == R.id.tv_start_live) {
            if (!isLiving()) {
                joinRoom();
            } else {
                leaveRoom(false);
            }
        } else if (id == R.id.iv_clear_local_uid) {
            etValueUid.setText("");
        } else if (id == R.id.iv_clear_local_rid) {
            etValueRoomId.setText("");
        } else if (id == R.id.bt_switch_camera) {
            switchFrontCamera();
        } else if (id == R.id.bt_camera) {
            handleClickBtnCamera();
        } else if (id == R.id.bt_microphone) {
            handleClickBtnMicrophone();
        } else if (id == R.id.bt_feedback) {
            startActivity(new Intent(VideoSameChannelActivity.this, FeedBackActivity.class));
        } else if (id == R.id.bt_interface) {
            Intent intent = new Intent(this, WebViewActivity.class);
            intent.putExtra(WebViewActivity.URL, Constant.SAME_API_URL);
            startActivity(intent);
        } else if (id == R.id.bt_log) {
            startActivity(new Intent(VideoSameChannelActivity.this, FloatLogActivity.class));
        }
//        else if (id == R.id.bt_document) {
//            website not ready
//        }else if (id == R.id.bt_setting) {
//            startActivity(new Intent(VideoSameChannelActivity.this, SettingActivity.class));
//        }
    }

    /**
     * is start living
     * 是否正在开播
     */
    private boolean isLiving() {
        if (FacadeRtcManager.getInstance().isJoinRoom.getValue() == null) {
            return false;
        }
        return FacadeRtcManager.getInstance().isJoinRoom.getValue();
    }

    /**
     * handle click enable or disable video streaming
     */
    private void handleClickBtnCamera() {
        UserInfo userInfo = roomAdapter.getDataList().get(0);
        if (userInfo == null) {
            return;
        }
        this.userInfo = userInfo;
        handleVideo(rvVideoView.getChildAt(0), userInfo);
    }

    /**
     * handle click enable or disable audio streaming
     */
    private void handleClickBtnMicrophone() {
        UserInfo userInfo = roomAdapter.getDataList().get(0);
        if (userInfo == null) {
            return;
        }
        this.userInfo = userInfo;
        handleAudio(rvVideoView.getChildAt(0), userInfo);
    }

    /**
     * Switch front and rear cameras
     * 切换前后置摄像头
     */
    private void switchFrontCamera() {
        int result = FacadeRtcManager.getInstance().switchFrontCamera();
        if (result != 0) {
            showToast(getString(R.string.error_switch_forn_camera, String.valueOf(result)));
        }
    }


    /**
     * Join the room
     * 加入房间
     */
    private void joinRoom() {
        setHideIvClearRoomId(false);
        setHideIvClearUid(false);
        if (NetworkUtil.isNetworkAvailable(this)) {
            showDialogProgress();
            int result = FacadeRtcManager.getInstance()
                    .joinRoom("token".getBytes(), Constant.mLocalRoomId, Constant.mLocalUid);

            if (result != 0) {
                dismissDialogProgress();
                showToast(getString(R.string.error_join_room, result));
            }
        } else {
            showToast(R.string.network_error);
        }
    }

    /**
     * Leave the room
     * 离开房间
     */
    private void leaveRoom(boolean quiet) {
        //还原操作
        localUserMap.clear();
        dismissDialogProgress();

        addMessageToLogView("Stream is stopped by UID=" + FacadeRtcManager.getInstance().getUid());
        exitFullScreen();

        //Stop local audio and video
        //停止本地开播
        FacadeRtcManager.getInstance().stopAudioAndVideo();

        //Exit the room
        //退出房间
        FacadeRtcManager.getInstance().leaveRoom();
        if (!quiet) {
            showToast(R.string.text_end_live_success);
        }
        showAllIvPreview();
    }

    /**
     * The status after joining the room
     * 加入房间后状态
     */
    private void onJoinRoomStatus() {
        tvStartLive.setText(R.string.text_stop_publish);
        etValueUid.setEnabled(false);
        etValueRoomId.setEnabled(false);

        btSwitchCamera.setEnabled(true);
        btSwitchCamera.setAlpha(1);
        btCamera.setEnabled(true);
        btCamera.setAlpha(1);
        btMicrophone.setEnabled(true);
        btMicrophone.setAlpha(1);
//        scLog.setVisibility(View.VISIBLE);
    }

    /**
     * The status of not joining the room
     * 未加入房间的状态
     */
    private void onUnJoinRoomStatus() {
        rvVideoView.setVisibility(View.VISIBLE);
        isFullScreen = false;
        VideoSameChannelActivity.this.userInfo = null;

        for (UserInfo userInfo : roomAdapter.getDataList()) {
            for (OnRemoteListener listener : mRemoteListeners) {
                String uid = userInfo.getUid();
                if (!TextUtils.isEmpty(uid)) {
                    listener.onLeaveRoom(uid);
                }
            }
        }
        mRemoteListeners.clear();
        roomAdapter.clear();
        tvStartLive.setText(R.string.text_start_publish);
        etValueUid.setEnabled(true);
        etValueRoomId.setEnabled(true);

        btSwitchCamera.setEnabled(false);
        btSwitchCamera.setAlpha(0.5f);
        btCamera.setEnabled(false);
        btCamera.setAlpha(0.5f);
        btCamera.setBackgroundResource(R.drawable.toolbar_btn_camera_enable);
        btMicrophone.setEnabled(false);
        btMicrophone.setAlpha(0.5f);
        btMicrophone.setBackgroundResource(R.drawable.toolbar_btn_microphone_enable);
    }

    /**
     * Monitor the status of front and rear cameras
     * 监控前后置摄像头状态
     */
    private void monitorFrontCameraStatus() {
        FacadeRtcManager.getInstance().mIsFrontCamera.observe(this, aBoolean -> {
            if (aBoolean == null) {
                btSwitchCamera.setEnabled(false);
            } else {
                btSwitchCamera.setEnabled(true);
            }
        });
    }

    /**
     * Start pushing
     * 开始推流
     */
    private void startPlay() {

        int result = FacadeRtcManager.getInstance().startAudioAndVideo();
        if (result != 0) {
            showToast(getString(R.string.error_start_play, result));
            return;
        }

        showToast(getString(R.string.text_start_publish_success));

        String uid = FacadeRtcManager.getInstance().getUid();
        UserInfo userInfo = new UserInfo(uid);
        userInfo.setAudioStreamStopped(false);
        userInfo.setVideoStreamStopped(false);
//        roomAdapter.updateItem(0, userInfo);
        roomAdapter.addItemData(userInfo);
        for (OnRemoteListener listener : mRemoteListeners) {
            listener.onJoinRoom(userInfo.getUid());
        }
    }

    @Override
    protected void onDestroy() {
        leaveRoom(true);
        FacadeRtcManager.getInstance().unRegister(mMyThunderEventHandler);
        super.onDestroy();
    }

    @Override
    public void onBackPressed() {
        moveTaskToBack(true);
    }

    /**
     * Exit Full Screen
     * 退出全屏
     */
    private void exitFullScreen() {
        if (!isFullScreen) {
            return;
        }

        rvVideoView.setLayoutManager(new WrapGridLayoutManager(this, 2));
        rvVideoView.scrollToPosition(0);

        line1.setVisibility(View.VISIBLE);
        line2.setVisibility(View.VISIBLE);

        showIvPreviewByItemCount();
        isFullScreen = false;
    }

    /**
     * Processing zoom logic
     * 处理放大缩小逻辑
     */
    private void handleFullScreen(UserInfo userInfo, int position) {
        if (isFullScreen) {
            exitFullScreen();

            //处理个别手机surfaceview会重合问题，所以恢复的时候就还原设置
            List<UserInfo> lists = roomAdapter.getDataList();
            for (UserInfo data : lists) {
                if (!TextUtils.isEmpty(data.getUid()) && !TextUtils.equals(data.getUid(),
                        userInfo.getUid()) && !data.isMuteVideo()) {
                    //打开其他视频流
                    FacadeRtcManager.getInstance()
                            .stopRemoteVideoStream(data.getUid(), false);
                }
            }
        } else {
            rvVideoView.setLayoutManager(new LinearLayoutManager(this, OrientationHelper.VERTICAL, false) {
                @Override
                public boolean canScrollVertically() {
                    return false;
                }
            });
            rvVideoView.scrollToPosition(position);

            line1.setVisibility(View.GONE);
            line2.setVisibility(View.GONE);
            hideAllIvPreview();
            isFullScreen = true;

            //处理个别手机surfaceview会重合问题，所以全屏的时候就关闭其他
            List<UserInfo> lists = roomAdapter.getDataList();
            for (UserInfo data : lists) {
                if (!TextUtils.isEmpty(data.getUid()) && !TextUtils.equals(data.getUid(), userInfo.getUid())) {
                    //关闭其他视频流
                    FacadeRtcManager.getInstance()
                            .stopRemoteVideoStream(data.getUid(), true);
                }
            }
        }
    }

    /**
     * Processing audio logic
     * 处理音频逻辑
     */
    public void handleAudio(View view, UserInfo userInfo) {
        String uid = FacadeRtcManager.getInstance().getUid();
        String targetUid = userInfo.getUid();
        boolean isLocal = TextUtils.equals(uid, targetUid);

        if (isLocal) {
            //Set Local
            //设置本地
            userInfo.setMuteAudio(false);
            if (userInfo.isAudioStreamStopped()) {
                btMicrophone.setBackgroundResource(R.drawable.toolbar_btn_microphone_enable);
                int result = FacadeRtcManager.getInstance().startAudio();
                if (result != 0) {
                    return;
                }
                userInfo.setAudioStreamStopped(false);
            } else {
                btMicrophone.setBackgroundResource(R.drawable.toolbar_btn_microphone_disable);
                int result = FacadeRtcManager.getInstance().stopAudio();
                if (result != 0) {
                    return;
                }
                userInfo.setAudioStreamStopped(true);
            }
        } else {
            if (userInfo.isMuteAudio()) {
                view.findViewById(R.id.ivMicrophone).setBackgroundResource(R.drawable.player_btn_microphone);
                int result = FacadeRtcManager.getInstance()
                        .stopRemoteAudioStream(targetUid, false);
                if (result != 0) {
                    return;
                }
                userInfo.setMuteAudio(false);
            } else {
                view.findViewById(R.id.ivMicrophone).setBackgroundResource(R.drawable.player_btn_microphone_disable);
                int result = FacadeRtcManager.getInstance()
                        .stopRemoteAudioStream(targetUid, true);
                if (result != 0) {
                    return;
                }
                userInfo.setMuteAudio(true);
            }
        }
    }

    /**
     * Processing video logic
     * 处理视频逻辑
     */
    public void handleVideo(View view, UserInfo userInfo) {
        String uid = FacadeRtcManager.getInstance().getUid();
        String targetUid = userInfo.getUid();
        boolean isLocal = TextUtils.equals(uid, targetUid);

        //Video control
        //视频控制
        if (isLocal) {

            //Set Local
            //设置本地
            userInfo.setMuteVideo(false);
            if (userInfo.isVideoStreamStopped()) {
                //open video
                //打开
                btCamera.setBackgroundResource(R.drawable.toolbar_btn_camera_enable);
                int result = FacadeRtcManager.getInstance().startVideo();
                if (result != 0) {
                    return;
                }

                userInfo.setVideoStreamStopped(false);

            } else {
                //close video
                //关闭
                btCamera.setBackgroundResource(R.drawable.toolbar_btn_camera_disable);
                int result = FacadeRtcManager.getInstance().stopVideo();
                if (result != 0) {
                    return;
                }

                LocalUserView thunderPreviewView = view.findViewById(R.id.myview);
                thunderPreviewView.resetView();
                userInfo.setVideoStreamStopped(true);
            }
        } else {
            if (userInfo.isMuteVideo()) {
                //open
                //打开
                view.findViewById(R.id.ivCamera).setBackgroundResource(R.drawable.player_btn_camera);
                int result = FacadeRtcManager.getInstance()
                        .stopRemoteVideoStream(targetUid, false);
                if (result != 0) {
                    return;
                }

                userInfo.setMuteVideo(false);
            } else {
                //close video
                //关闭
                view.findViewById(R.id.ivCamera).setBackgroundResource(R.drawable.player_btn_camera_disable);
                int result = FacadeRtcManager.getInstance()
                        .stopRemoteVideoStream(targetUid, true);
                if (result != 0) {
                    return;
                }

                userInfo.setMuteVideo(true);
            }
        }
    }

    /**
     * Remote user joins the room
     * 远程用户加入房间
     *
     * @param userInfo      userInfo
     * @param setCacheAudio set cache userInfo audio of video if exist
     */
    private void onRemoteJoinRoom(UserInfo userInfo, boolean setCacheAudio) {
        addMessageToLogView("UID=" + userInfo.getUid() + " joined");
        String uid = userInfo.getUid();
        UserInfo cache = localUserMap.get(uid);
        if (cache != null) {
            //This user has been to the room before
            //此用户之前来过房间
            if (setCacheAudio) {
                userInfo.setMuteAudio(cache.isMuteAudio());
            } else {
                userInfo.setMuteVideo(cache.isMuteVideo());
            }
        }
        localUserMap.put(uid, userInfo);

        if (roomAdapter.getItemCount() >= 4) {
            roomAdapter.addItemWithoutNotify(userInfo);
        } else {
            roomAdapter.addItemData(userInfo);
        }

        for (OnRemoteListener listener : mRemoteListeners) {
            listener.onJoinRoom(userInfo.getUid());
        }
    }

    /**
     * Remote user exits the room ,when audio and video both close,remote user has leave room
     * 远程用户退出房间，当远端用户关闭音频流和视频流之后，认为远端用户已经离开房间
     *
     * @param userInfo userInfo
     */
    private void onRemoteLeaveRoom(UserInfo userInfo) {
        //If you are in full screen, exit full screen mode
        //如果正在全屏，就退出全屏模式
        addMessageToLogView("UID=" + userInfo.getUid() + " has left the room");
        if (VideoSameChannelActivity.this.userInfo != null &&
                TextUtils.equals(VideoSameChannelActivity.this.userInfo.getUid(), userInfo.getUid())) {

            if (isFullScreen) {
                exitFullScreen();
            }
            VideoSameChannelActivity.this.userInfo = null;
        }

        for (OnRemoteListener listener : mRemoteListeners) {
            listener.onLeaveRoom(userInfo.getUid());
        }

        FacadeRtcManager.getInstance()
                .stopRemoteVideoStream(userInfo.getUid(), false);

        int index = roomAdapter.getDataList().indexOf(userInfo);
        if (index != -1) {
            if (index < 4) {
                roomAdapter.deleteItem(index);
                if (roomAdapter.getItemCount() >= 4) {
                    rvVideoView.setLayoutManager(new WrapGridLayoutManager(this, 2));
                }
            } else {
                roomAdapter.deleteItemWithoutNotify(userInfo);
            }
        }
        showIvPreviewByItemCount();
    }

    private void addMessageToLogView(String message) {
        String time = DataFormatUtil.formatTimeWithRim(System.currentTimeMillis());
        tvRoomStatus.append(time + " " + message + "\n");

        int offset = (tvRoomStatus.getLineCount() + 2) * tvRoomStatus.getLineHeight();
        if (offset > tvRoomStatus.getHeight()) {
            tvRoomStatus.scrollTo(0, offset - tvRoomStatus.getHeight());
        } else {
            tvRoomStatus.scrollTo(0, 0);
        }

    }

    private void hideAllIvPreview() {
        for (View v : ivPreviewList) {
            v.setVisibility(View.INVISIBLE);
        }
    }

    private void showAllIvPreview() {
        for (View v : ivPreviewList) {
            v.setVisibility(View.VISIBLE);
        }
    }

    private void showIvPreviewByItemCount() {
        for (int i = roomAdapter.getItemCount(); i < ivPreviewList.size(); i++) {
            ivPreviewList.get(i).setVisibility(View.VISIBLE);
        }
    }

    public void hideIvPreviewByPosition(int position) {
        if (position >= 0 && ivPreviewList.size() > position) {
            ivPreviewList.get(position).setVisibility(View.INVISIBLE);
        }
    }
}
