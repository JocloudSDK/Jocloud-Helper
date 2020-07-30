package com.aivacom.api.crosschannel.UI;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.net.Uri;
import android.os.Handler;
import android.text.Editable;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;
import android.widget.Toast;

import androidx.annotation.NonNull;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aivacom.api.baseui.WebViewActivity;
import com.aivacom.api.baseui.base.BaseActivity;
import com.aivacom.api.baseui.widget.dialog.puredialog.ConfirmDialog;
import com.aivacom.api.crosschannel.R;
import com.aivacom.api.crosschannel.adapter.CrossLogAdapter;
import com.aivacom.api.crosschannel.model.CrossLogBean;
import com.aivacom.api.feedback.view.FeedBackActivity;
import com.aivacom.api.jly_logcat.FloatLogActivity;
import com.aivacom.api.rtc.FacadeRtcManager;
import com.aivacom.api.rts.FacadeRtsManager;
import com.aivacom.api.utils.Constant;
import com.aivacom.api.utils.DataFormatUtil;
import com.aivacom.api.utils.PermissionUtils;
import com.aivacom.api.utils.TimeUtil;
import com.hummer.Error;
import com.hummer.HMR;
import com.hummer.model.Message;
import com.hummer.model.RequestId;
import com.hummer.rts.PeerService;
import com.thunder.livesdk.LiveTranscoding;
import com.thunder.livesdk.ThunderEventHandler;
import com.thunder.livesdk.ThunderNotification;
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.video.ThunderPlayerView;
import com.thunder.livesdk.video.ThunderPreviewView;

import java.util.ArrayList;
import java.util.Date;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import static com.thunder.livesdk.ThunderRtcConstant.ThunderPublishCDNErrorCode.THUNDER_PUBLISH_CDN_ERR_SUCCESS;

/**
 * Cross-Room Video Call Activity
 * 跨房间连麦
 */
public class CrossChannelActivity extends BaseActivity {

    //video
    private ThunderPreviewView previewView; //local
    private ThunderPlayerView playerView; //remote
    private RelativeLayout defaultPreview;
    private RelativeLayout defaultPlayview;
    private ImageView ivSelfNet;
    private ImageView ivOtherNet;
    private LinearLayout llCrossDate;
    private TextView tvUpData;
    private TextView tvDownData;
    //local
    private EditText etLocalUid;
    private ImageView ivClearLocalUid;
    private EditText etLocalRid;
    private ImageView ivClearLocalRid;
    private TextView tvLocalPush; //开播
    //remote
    private EditText etRemoteUid;
    private ImageView ivClearRemoteUid;
    private EditText etRemoteRid;
    private ImageView ivClearRemoteRid;
    private TextView tvRemoteSubcribe;
    //stream
    private EditText etStreamUrl;
    private ImageView ivClearStreamUrl;
    private TextView tvPushStream;
    //log list
    private RecyclerView mRecyclerView;
    //bottom
    private ImageView ivSwitchCamera;
    private ImageView ivSwitchMic;
    private ImageView ivFeedback;
    private ImageView ivDoc;
    private ImageView ivApi;
    private ImageView ivLog;

    private boolean isStartLiving = false;
    private boolean isSubcribe = false;
    private boolean bFront = false;
    private boolean isStopMicrophone = false;

    private ConfirmDialog confirmDialog;
    private WaitingDialog waittingDialog;

    private List<CrossLogBean> logs = new ArrayList<>();
    private CrossLogAdapter logAdapter;

    @Override
    protected int getLayoutResId() {
        return R.layout.layout_cross_channel;
    }

    @Override
    protected void initView() {
        previewView = findViewById(R.id.preView);
        playerView = findViewById(R.id.playView);
        defaultPreview = findViewById(R.id.defaultPreviewView);
        defaultPlayview = findViewById(R.id.defaultPlayView);
        ivSelfNet = findViewById(R.id.iv_cross_self_net);
        ivOtherNet = findViewById(R.id.iv_cross_other_net);
        llCrossDate = findViewById(R.id.ll_cross_date);
        tvUpData = findViewById(R.id.tv_cross_up_data);
        tvDownData = findViewById(R.id.tv_cross_down_data);
        etLocalUid = findViewById(R.id.et_cross_local_uid);
        etLocalRid = findViewById(R.id.et_cross_local_rid);
        ivClearLocalUid = findViewById(R.id.iv_clear_local_uid);
        ivClearLocalRid = findViewById(R.id.iv_clear_local_rid);
        tvLocalPush = findViewById(R.id.tv_cross_local_push);
        etRemoteUid = findViewById(R.id.et_cross_remote_uid);
        ivClearRemoteUid = findViewById(R.id.iv_clear_remote_uid);
        etRemoteRid = findViewById(R.id.et_cross_remote_rid);
        ivClearRemoteRid = findViewById(R.id.iv_clear_remote_rid);
        tvRemoteSubcribe = findViewById(R.id.tv_cross_remote_subcribe);
        etStreamUrl = findViewById(R.id.et_cross_stream_url);
        ivClearStreamUrl = findViewById(R.id.iv_clear_stream_url);
        tvPushStream = findViewById(R.id.tv_cross_push_stream);
        ivSwitchCamera = findViewById(R.id.iv_switch_camera);
        ivSwitchMic = findViewById(R.id.iv_switch_mic);
        ivFeedback = findViewById(R.id.iv_feedback);
        ivDoc = findViewById(R.id.iv_doc);
        ivApi = findViewById(R.id.iv_api);
        ivLog = findViewById(R.id.iv_log);
        mRecyclerView = findViewById(R.id.rv_cross_log);

        mRecyclerView.setLayoutManager(new LinearLayoutManager(this, LinearLayoutManager.VERTICAL,
                false));

        logAdapter = new CrossLogAdapter(mContext);
        logAdapter.setDataList((ArrayList<CrossLogBean>) logs);
        mRecyclerView.setAdapter(logAdapter);

        initListener();

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
        etLocalRid.setText(Constant.mLocalRoomId);
        etLocalUid.setText(Constant.mLocalUid);
        etStreamUrl.setText(getPushMixUrl());
        String upformat = getResources().getString(R.string.cross_up_bitrate);
        String updateTxt = String.format(upformat, 0, 0, 0);
        tvUpData.setText(updateTxt);
        String downformat = getResources().getString(R.string.cross_down_bitrate);
        String downdateTxt = String.format(downformat, 0, 0, 0);
        tvDownData.setText(downdateTxt);
        FacadeRtcManager.getInstance().setObserver(observer);
    }

    @Override
    protected int getTitleResId() {
        return R.string.cross_channel;
    }

    /**
     * init listener
     */
    private void initListener() {
        ivClearLocalUid.setOnClickListener(this);
        ivClearLocalRid.setOnClickListener(this);
        tvLocalPush.setOnClickListener(this);
        ivClearRemoteUid.setOnClickListener(this);
        ivClearRemoteRid.setOnClickListener(this);
        tvRemoteSubcribe.setOnClickListener(this);
        ivClearStreamUrl.setOnClickListener(this);
        tvPushStream.setOnClickListener(this);
        ivSwitchCamera.setOnClickListener(this);
        ivSwitchMic.setOnClickListener(this);
        ivFeedback.setOnClickListener(this);
        ivDoc.setOnClickListener(this);
        ivApi.setOnClickListener(this);
        ivLog.setOnClickListener(this);

        FacadeRtsManager.getIns().addMsgListener(mEventListener);

        etLocalUid.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String inputtxt = s.toString();
                if (inputtxt.startsWith("0")) {
                    etLocalUid.setText("");
                    return;
                }
                Constant.mLocalUid = inputtxt;
                if (!inputtxt.equals("")) {
                    ivClearLocalUid.setVisibility(View.VISIBLE);
                } else {
                    ivClearLocalUid.setVisibility(View.GONE);
                }
                if (!isStartLiving) {
                    checkNotNull(Constant.mLocalUid, Constant.mLocalRoomId, tvLocalPush, true);
                    //processing status
                    changState();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        etLocalRid.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String inputtxt = s.toString();
                if (inputtxt.startsWith("0")) {
                    etLocalRid.setText("");
                    return;
                }
                Constant.mLocalRoomId = inputtxt;
                if (!inputtxt.equals("")) {
                    ivClearLocalRid.setVisibility(View.VISIBLE);
                } else {
                    ivClearLocalRid.setVisibility(View.GONE);
                }
                if (!isStartLiving) {
                    checkNotNull(Constant.mLocalUid, Constant.mLocalRoomId, tvLocalPush, true);
                    //processing status
                    changState();
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        etRemoteUid.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String inputtxt = s.toString();
                if (inputtxt.startsWith("0")) {
                    etRemoteUid.setText("");
                    return;
                }
                Constant.mRemoteUid = inputtxt;
                checkNotNull(Constant.mRemoteUid, Constant.mRemoteRoomId, tvRemoteSubcribe,
                        isStartLiving);
                if (!inputtxt.equals("")) {
                    ivClearRemoteUid.setVisibility(View.VISIBLE);
                } else {
                    ivClearRemoteUid.setVisibility(View.GONE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        etRemoteRid.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                String inputtxt = s.toString();
                if (inputtxt.startsWith("0")) {
                    etRemoteRid.setText("");
                    return;
                }
                Constant.mRemoteRoomId = inputtxt;
                checkNotNull(Constant.mRemoteUid, Constant.mRemoteRoomId, tvRemoteSubcribe,
                        isStartLiving);
                if (!inputtxt.equals("")) {
                    ivClearRemoteRid.setVisibility(View.VISIBLE);
                } else {
                    ivClearRemoteRid.setVisibility(View.GONE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });
        etStreamUrl.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {

            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                Constant.customPushUrl = s.toString();
                if (!s.toString().equals("")) {
                    ivClearStreamUrl.setVisibility(View.VISIBLE);
                    if (isStartLiving) {
                        tvPushStream.setEnabled(true);
                    } else {
                        tvPushStream.setEnabled(false);
                    }
                } else {
                    ivClearStreamUrl.setVisibility(View.GONE);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {

            }
        });

    }

    @Override
    protected void onClickBack() {
        if (isStartLiving) {
            showToast(getResources().getString(R.string.cross_toast_end_live));
            return;
        }
        showConfirmDialog();
    }

    public void onClick(View v) {
        int resId = v.getId();
        if (resId == R.id.iv_clear_local_uid) { //clear uid input fields
            etLocalUid.setText("");
        } else if (resId == R.id.iv_clear_local_rid) { //clear room id input fields
            etLocalRid.setText("");
        } else if (resId == R.id.tv_cross_local_push) { //go live
            switchLive();
        } else if (resId == R.id.iv_clear_remote_uid) { //clear uid input fields
            etRemoteUid.setText("");
        } else if (resId == R.id.iv_clear_remote_rid) { //clear room id input fields
            etRemoteRid.setText("");
        } else if (resId == R.id.tv_cross_remote_subcribe) { //connect
            switchSubcribe();
        } else if (resId == R.id.iv_clear_stream_url) { //clear url input fields
            etStreamUrl.setText("");
        } else if (resId == R.id.tv_cross_push_stream) { //push
            pushStream();
        } else if (resId == R.id.iv_switch_camera) { //switch camera
            switchCamera();
        } else if (resId == R.id.iv_switch_mic) { //switch microphone
            switchMicrophone();
        } else if (resId == R.id.iv_api) { //api
            go2Api();
        } else if (resId == R.id.iv_log) { //log
            goLogActivity();
        } else if (resId == R.id.iv_doc) { //doc

        } else if (resId == R.id.iv_feedback) { //feed back
            go2FeedBack();
        }
    }

    /**
     * start / stop live broadcast
     * 开/关直播
     */
    private void switchLive() {
        if (!isStartLiving) {
            if (isStopMicrophone) {
                switchMicrophone();
            }
            FacadeRtcManager.getInstance()
                    .setRoomConfig(ThunderRtcConstant.ThunderRtcProfile.THUNDER_PROFILE_DEFAULT,
                            ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_LIVE);
            int joinroomResult = FacadeRtcManager.getInstance()
                    .joinRoom(null, Constant.mLocalRoomId, Constant.mLocalUid);
            if (joinroomResult == 0) {
                FacadeRtsManager.getIns()
                        .login(Long.parseLong(Constant.mLocalUid), Constant.CROSS_REGION, null);
            } else {
                //joinroom faild
                slog("UID=" + Constant.mLocalUid + " failed to join roomID=" +
                        Constant.mLocalRoomId, true);
            }

        } else {

            if (isSubcribe) {
                showToast(getResources().getString(R.string.cross_toast_end_1v1call));
                return;
            }

            if (Constant.isPushMixStream) {
                showToast(getResources().getString(R.string.cross_toast_end_1v1call));
                return;
            }

            FacadeRtcManager.getInstance().stopPush();
            slog("Stream is stopped by UID=" + Constant.mLocalUid, false);
            leaveThunderRoom();
            FacadeRtsManager.getIns().logout();
            tvLocalPush.setText(getResources().getString(R.string.cross_local_start_push));
            isStartLiving = !isStartLiving;
            defaultPreview.setVisibility(View.VISIBLE);
            llCrossDate.setVisibility(View.GONE);
            ivSwitchCamera.setAlpha(0.5f);
            ivSwitchMic.setAlpha(0.5f);
            showToast(getResources().getString(R.string.cross_toast_end_live_succeed));
        }

        //processing status
        changState();
        enableInput();
    }

    /**
     * start / stop connect someone
     * 开关跨频道订阅
     */
    private void switchSubcribe() {
        //To cross a room means to have different rooms
        if (Constant.mLocalRoomId.equals(Constant.mRemoteRoomId)) {
            showToast(R.string.cross_toast_cant_same_room);
            return;
        }

        if (!isSubcribe) {
            showDialogProgress();
            //send video call invitation message
            sendInviteMsg();
        } else {
            //send cancel video call message
            sendCancelMsg();
            unSubscribeSomeone(Constant.mRemoteRoomId, Constant.mRemoteUid);
            slog("1v1 video call is ended by you", false);
            isSubcribe = false;
            Constant.isMixSubscribeRemote = false;
            tvRemoteSubcribe.setText(getResources().getString(R.string.cross_remote_subscribe));
            defaultPlayview.setVisibility(View.VISIBLE);
            enableInput();
        }
    }

    /**
     * connect
     * 订阅
     *
     * @param remoteRid 远端room id
     * @param remoteUid 远端uid
     */
    private void subscribeSomeone(String remoteRid, String remoteUid) {
        FacadeRtcManager.getInstance().prepareRemoteView(playerView, remoteUid);
        FacadeRtcManager.getInstance().addSubscribe(remoteRid, remoteUid);
    }

    /**
     * disconnect
     * 取消订阅
     *
     * @param remoteRid 远端room id
     * @param remoteUid 远端uid
     */
    private void unSubscribeSomeone(String remoteRid, String remoteUid) {
        FacadeRtcManager.getInstance().prepareRemoteView(null, remoteUid);
        FacadeRtcManager.getInstance().removeSubscribe(remoteRid, remoteUid);
    }

    /**
     * leave room
     * 离开房间
     */
    private void leaveThunderRoom() {
        if (isStopMicrophone) { //reset microphone status
            switchMicrophone();
        }
        if (!bFront && isStartLiving) { //reset camera status
            FacadeRtcManager.getInstance().switchFrontCamera(!bFront);
            bFront = !bFront;
        }
        //leave room
        FacadeRtcManager.getInstance().leaveRoom();
    }

    /**
     * switch microphone
     * 开关麦克风
     */
    private void switchMicrophone() {
        if (isStartLiving) {
            isStopMicrophone = !isStopMicrophone;
            ivSwitchMic.setImageDrawable(getResources().getDrawable(isStopMicrophone ?
                    R.mipmap.ic_cross_mic_mute : R.mipmap.ic_cross_mic_open));
            FacadeRtcManager.getInstance().stopLocalAudioStream(isStopMicrophone);
        }
    }

    /**
     * switch camera
     * 切换前后摄像头
     */
    private void switchCamera() {
        bFront = !bFront;
        FacadeRtcManager.getInstance().switchFrontCamera(bFront);
    }

    /**
     * push stream
     * 推流
     */
    private void pushStream() {
        Uri uri = Uri.parse(Constant.customPushUrl);
        if (uri == null || TextUtils.isEmpty(uri.getScheme()) || TextUtils.isEmpty(uri.getHost())) {
            dissMissDialogProgress();
            Toast.makeText(this, getResources().getString(R.string.cross_toast_invalid_url) +
                            Constant.customPushUrl,
                    Toast.LENGTH_SHORT)
                    .show();
            return;
        }

        if (Constant.isPushMixStream) {
            Constant.isPushMixStream = false;
            Constant.isUserStopPushMixStream = true;
            tvPushStream.setText(R.string.cross_push_stream);
            FacadeRtcManager.getInstance()
                    .removePublishTranscodingStreamUrl(Constant.TASK_ID, getPushMixUrl()); //停止推混画流
            showToast(getResources().getString(R.string.cross_push_stoped));
            enableInput();
            slog("RTMP stream is stopped", false);
        } else {
            Constant.isUserStopPushMixStream = false;
            mixAndPushStream();
            FacadeRtcManager.getInstance()
                    .addPublishTranscodingStreamUrl(Constant.TASK_ID, getPushMixUrl());
            showDialogProgress();
        }
    }

    /**
     * mixed flow configuration
     * 混流参数配置
     */
    private void mixAndPushStream() {
        int mixMode = ThunderRtcConstant.LiveTranscodingMode.TRANSCODING_MODE_640X480;
        int height = 480;
        int width = 640;

        LiveTranscoding transCoding = new LiveTranscoding();
        LiveTranscoding.TranscodingUser localUser = new LiveTranscoding.TranscodingUser();
        if (!TextUtils.isEmpty(Constant.mLocalRoomId) && !TextUtils.isEmpty(Constant.mLocalUid)) {
            localUser.roomId = Constant.mLocalRoomId;
            localUser.uid = Constant.mLocalUid;
            localUser.layoutW = Constant.isMixSubscribeRemote ? width / 2 : width;
            localUser.layoutH = height;
            localUser.layoutX = 0;
            localUser.layoutY = 0;
            localUser.zOrder = 1;
            localUser.bCrop = true;
            transCoding.addUser(localUser);
        }

        if (!TextUtils.isEmpty(Constant.mRemoteRoomId) && !TextUtils.isEmpty(Constant.mRemoteUid) &&
                Constant.isMixSubscribeRemote) {
            LiveTranscoding.TranscodingUser matchUser = new LiveTranscoding.TranscodingUser();
            matchUser.roomId = Constant.mRemoteRoomId;
            matchUser.uid = Constant.mRemoteUid;
            matchUser.layoutW = width / 2;
            matchUser.layoutH = height;
            matchUser.layoutX = localUser.layoutW;
            matchUser.layoutY = 0;
            matchUser.zOrder = 0;
            matchUser.bStandard = true;
            matchUser.bCrop = true;
            transCoding.addUser(matchUser);
        }
        if (transCoding.getUserCount() <= 0) {
            return;
        }
        transCoding.setTransCodingMode(mixMode);
        FacadeRtcManager.getInstance().setLiveTranscodingTask(Constant.TASK_ID, transCoding);
    }

    /**
     * get push url
     * 设置推流地址
     */
    private String getPushMixUrl() {
        //业务自己定义
        String pusUrl = Constant.PUSH_BASE_URL;
        if (!TextUtils.isEmpty(Constant.customPushUrl)) {
            pusUrl = Constant.customPushUrl;
        }
        return pusUrl;
    }

    /**
     * feed back
     */
    private void go2FeedBack() {
        Intent intent = new Intent(CrossChannelActivity.this, FeedBackActivity.class);
        startActivity(intent);
    }

    /**
     * log
     */
    private void goLogActivity() {
        Intent intent = new Intent(CrossChannelActivity.this, FloatLogActivity.class);
        startActivity(intent);
    }

    private void go2Doc() {

    }

    /**
     * api
     */
    private void go2Api() {
        Intent intent = new Intent(this, WebViewActivity.class);
        intent.putExtra(WebViewActivity.URL, Constant.CROSS_API_URL);
        startActivity(intent);
    }

    /**
     * send video call invitation message
     * 发送连麦邀请消息
     */
    private void sendInviteMsg() {
        Map<String, String> extra = new HashMap<>();
        extra.put(Constant.CROSS_SEND_MSG_TIMESTAMP, String.valueOf(new Date().getTime() / 1000));
        Message message = new Message(Constant.CROSS_INVITE_ONE2ONE_CALL,
                Constant.mLocalRoomId.getBytes(), extra);

        FacadeRtsManager.getIns().sendPeerMsg(Constant.mRemoteUid, message,
                new HMR.Completion() {
                    @Override
                    public void onSuccess(RequestId requestId) {
                        dissMissDialogProgress();
                        showWaitingDialog();
                        slog("Invitation to UID=" + Constant.mRemoteUid + ", roomID=" +
                                Constant.mRemoteRoomId + " is sent", false);
                    }

                    @Override
                    public void onFailed(RequestId requestId, Error err) {
                        dissMissDialogProgress();
                        showToast("onFailed" + err.code + " - " + err.desc);
                        slog(" Failed to send invitation to UID" + Constant.mRemoteUid +
                                ", roomID=" + Constant.mRemoteRoomId, true);
                    }
                });
    }

    /**
     * send video call busy message
     * 发送对方正在连麦中消息
     */
    private void sendBusyMsg(final String roomid, final String uid) {
        Message message = new Message(Constant.CROSS_BUSY_ONE2ONE_CALL,
                roomid.getBytes());
        FacadeRtsManager.getIns().sendPeerMsg(uid, message,
                new HMR.Completion() {
                    @Override
                    public void onSuccess(RequestId requestId) {
                        dissMissDialogProgress();
                        slog("Invitation from UID=" + uid + ", roomID=" +
                                roomid + " is rejected by system", false);
                    }

                    @Override
                    public void onFailed(RequestId requestId, Error err) {
                        dissMissDialogProgress();
                        showToast("onFailed" + err.code + " - " + err.desc);
                    }
                });
    }

    /**
     * send agree video call message
     * 发送同意连麦消息
     */
    private void sendAgreeMsg() {
        Message message = new Message(Constant.CROSS_AGREE_ONE2ONE_CALL,
                Constant.mLocalRoomId.getBytes());
        FacadeRtsManager.getIns().sendPeerMsg(Constant.mRemoteUid, message);
    }

    /**
     * send refuse video call message
     * 发送拒绝连麦消息
     */
    private void sendRefuseMsg(String roomid, String uid) {
        Message message = new Message(Constant.CROSS_REFUSE_ONE2ONE_CALL,
                roomid.getBytes());
        FacadeRtsManager.getIns().sendPeerMsg(uid, message);
    }

    /**
     * send cancel video call message
     * 发送取消连麦消息
     */
    private void sendCancelMsg() {
        Message message = new Message(Constant.CROSS_CANCEL_ONE2ONE_CALL,
                Constant.mLocalRoomId.getBytes());
        FacadeRtsManager.getIns().sendPeerMsg(Constant.mRemoteUid, message);
    }

    /**
     * write log
     * 日志打印
     */
    public void slog(String msg, boolean isDark) {
        Log.e(TAG, "slog: " + msg);
        String time = DataFormatUtil.formatTimeWithRim(System.currentTimeMillis());
        logs.add(new CrossLogBean(time, msg, isDark));
        logAdapter.notifyDataSetChanged();
        mRecyclerView.scrollToPosition(logs.size() - 1);
    }

    /**
     * invition dialog
     * 邀请对话框
     *
     * @param des describe
     * @param rid remote room id
     * @param uid remote user id
     */
    private void showInviteDialog(String des, final String rid, final String uid) {
        if (confirmDialog != null && confirmDialog.isShowing()) {
            return;
        }
        confirmDialog = new ConfirmDialog(this, new ConfirmDialog.OnConfirmCallback() {
            @Override
            public void onSure() {
                Constant.mRemoteRoomId = rid;
                Constant.mRemoteUid = uid;
                //send agree video call message
                sendAgreeMsg();
                isSubcribe = true; //change connect status
                tvRemoteSubcribe
                        .setText(getResources().getString(R.string.cross_remote_unsubscribe));
                //connect remote
                subscribeSomeone(rid, uid);
                defaultPlayview.setVisibility(View.GONE);
                enableInput();
                slog("Invitation is accepted by you", false);

                etRemoteRid.setText(rid);
                etRemoteUid.setText(uid);

                showToast(getResources().getString(R.string.cross_toast_subcribe_succeed));

                confirmDialog.dismiss();
            }

            @Override
            public void onCancel() {
                //send refuse video call message
                sendRefuseMsg(rid, uid);
                slog("Invitation is rejected by you", false);
                confirmDialog.dismiss();
            }
        });
        confirmDialog.setDesc(des);
        confirmDialog.setButton(getResources().getString(R.string.confirm_refuse_one2one_call),
                getResources().getString(R.string.confirm_agree_one2one_call));
        if (mHandler != null) {
            confirmDialog.setCountdown(Constant.CROSS_COUNTDOWN_TIME, mHandler);
        }
        confirmDialog.show();
    }

    private void showConfirmDialog() {
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

    /**
     * dialog of inviting someone
     * 邀请等待
     */
    private void showWaitingDialog() {
        if (waittingDialog != null && waittingDialog.isShowing()) {
            return;
        }
        waittingDialog = new WaitingDialog(mContext);
        if (mHandler != null) {
            waittingDialog.setCountdown(Constant.CROSS_COUNTDOWN_TIME, mHandler);
        }
        waittingDialog.show();
    }

    /**
     * handle btn state change
     * 处理按钮状态变化
     */
    private void changState() {

        if (TextUtils.isEmpty(Constant.mRemoteUid) ||
                TextUtils.isEmpty(Constant.mRemoteRoomId) || !isStartLiving) {
            tvRemoteSubcribe.setEnabled(false);
        } else {
            tvRemoteSubcribe.setEnabled(true);
        }

        if (TextUtils.isEmpty(Constant.customPushUrl) || !isStartLiving) {
            tvPushStream.setEnabled(false);
        } else {
            tvPushStream.setEnabled(true);
        }
    }

    /**
     * control editText  enable
     * 控制输入框是否可以输入
     */
    private void enableInput() {
        etLocalUid.setEnabled(!isStartLiving);
        etLocalRid.setEnabled(!isStartLiving);
        ivClearLocalUid.setEnabled(!isStartLiving);
        ivClearLocalRid.setEnabled(!isStartLiving);

        etLocalUid.setTextColor(isStartLiving ? getResources().getColor(R.color.color_ccc) :
                getResources().getColor(R.color.color_edit));
        etLocalRid.setTextColor(isStartLiving ? getResources().getColor(R.color.color_ccc) :
                getResources().getColor(R.color.color_edit));

        etRemoteUid.setEnabled(!isSubcribe);
        etRemoteRid.setEnabled(!isSubcribe);
        ivClearRemoteUid.setEnabled(!isSubcribe);
        ivClearRemoteRid.setEnabled(!isSubcribe);

        etRemoteUid.setTextColor(isSubcribe ? getResources().getColor(R.color.color_ccc) :
                getResources().getColor(R.color.color_edit));
        etRemoteRid.setTextColor(isSubcribe ? getResources().getColor(R.color.color_ccc) :
                getResources().getColor(R.color.color_edit));

        etStreamUrl.setEnabled(!Constant.isPushMixStream);
        ivClearStreamUrl.setEnabled(!Constant.isPushMixStream);

        etStreamUrl.setTextColor(Constant.isPushMixStream ?
                getResources().getColor(R.color.color_ccc) :
                getResources().getColor(R.color.color_edit));
    }

    @SuppressLint("ResourceAsColor")
    private static void checkNotNull(String mUid, String mRoomId, TextView tv,
                                     boolean isStartLiving) {
        if (TextUtils.isEmpty(mUid) || TextUtils.isEmpty(mRoomId) || !isStartLiving) {
            tv.setEnabled(false);
        } else {
            tv.setEnabled(true);
        }
    }

    FacadeRtcManager.Observer observer = new FacadeRtcManager.Observer() {

        @Override
        public void onJoinRoomSuccess(String room, String uid, int elapsed) {
            if (uid.equals(Constant.mLocalUid)) {
                dissMissDialogProgress();
                FacadeRtcManager.getInstance()
                        .startPush(previewView, etLocalUid.getText().toString(),
                                ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_NORMAL);
                tvLocalPush.setText(getResources().getString(R.string.cross_local_stop_push));
                isStartLiving = !isStartLiving;
                defaultPreview.setVisibility(View.GONE);
                llCrossDate.setVisibility(View.VISIBLE);
                ivSwitchCamera.setAlpha(1f);
                ivSwitchMic.setAlpha(1f);
                showToast(getResources().getString(R.string.cross_toast_live_succeed));
                //processing status
                changState();
                enableInput();
                slog("UID=" + uid + " joined roomID=" + room, false);
                slog("Stream is publishing by UID=" + uid, false);
            }
        }

        @Override
        public void onLeaveRoom(ThunderEventHandler.RoomStats status) {
            super.onLeaveRoom(status);
            dissMissDialogProgress();
            slog("UID=" + Constant.mLocalUid + " has left the room", false);
        }

        @Override
        public void onPublishStreamToCDNStatus(String url, int errorCode) {
            super.onPublishStreamToCDNStatus(url, errorCode);
            dissMissDialogProgress();
            if (errorCode == THUNDER_PUBLISH_CDN_ERR_SUCCESS) {
                Constant.isPushMixStream = true;
                tvPushStream.setText(R.string.cross_stop_push_stream);
                showToast(getResources().getString(R.string.cross_push_succeed));
                slog("Pushing " + Constant.customPushUrl, false);
            } else {
                //push faild and must to remove the task
                FacadeRtcManager.getInstance().removePublishTranscodingStreamUrl(Constant.TASK_ID,
                        getPushMixUrl());
                showToast(getResources().getString(R.string.cross_push_faild));
                slog("Failed to push " + Constant.customPushUrl, true);
            }
            enableInput();
        }

        @Override
        public void onRemoteVideoStopped(String uid, boolean muted) {
            if (Constant.mRemoteUid.equals(uid)) {
                Constant.isMixSubscribeRemote = !muted;
                mixAndPushStream();
            }

            //Disconnect the connection if there is no downstream video stream
            if (muted && isSubcribe) {
                slog("1v1 video call is ended due to no video/audio stream for a long time", true);
                switchSubcribe();
            }
        }

        @Override
        public void onRemoteAudioStopped(String uid, boolean muted) {

        }

        @Override
        public void onNetworkQuality(String uid, int txQuality, int rxQuality) {
            //the local uid is 0
            if (uid.equals("0")) {
                if (txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_UNKNOWN) {
                    ivSelfNet.setImageResource(R.mipmap.ic_cross_net0);
                } else if (txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_VBAD ||
                        txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_DOWN) {
                    ivSelfNet.setImageResource(R.mipmap.ic_cross_net1);
                } else if (txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_POOR ||
                        txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_BAD) {
                    ivSelfNet.setImageResource(R.mipmap.ic_cross_net2);
                } else if (
                        txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_EXCELLENT ||
                                txQuality ==
                                        ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_GOOD) {
                    ivSelfNet.setImageResource(R.mipmap.ic_cross_net3);
                }
            }

            //remote uid
            if (uid.equals(String.valueOf(Constant.mRemoteUid))) {
                if (txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_UNKNOWN) {
                    ivOtherNet.setImageResource(R.mipmap.ic_cross_net0);
                } else if (txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_VBAD ||
                        txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_DOWN) {
                    ivOtherNet.setImageResource(R.mipmap.ic_cross_net1);
                } else if (txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_POOR ||
                        txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_BAD) {
                    ivOtherNet.setImageResource(R.mipmap.ic_cross_net2);
                } else if (
                        txQuality == ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_EXCELLENT ||
                                txQuality ==
                                        ThunderRtcConstant.NetworkQuality.THUNDER_QUALITY_GOOD) {
                    ivOtherNet.setImageResource(R.mipmap.ic_cross_net3);
                }
            }

        }

        @Override
        public void onRoomStats(ThunderNotification.RoomStats stats) {
            super.onRoomStats(stats);
            String upformat = getResources().getString(R.string.cross_up_bitrate);
            String updateTxt = String.format(upformat, stats.txBitrate / 1000,
                    stats.txAudioBitrate / 1000, stats.txVideoBitrate / 1000);
            tvUpData.setText(updateTxt);
            String downformat = getResources().getString(R.string.cross_down_bitrate);
            String downdateTxt = String.format(downformat, stats.rxBitrate / 1000,
                    stats.rxAudioBitrate / 1000, stats.rxVideoBitrate / 1000);
            tvDownData.setText(downdateTxt);
        }
    };

    PeerService.EventListener mEventListener = new PeerService.EventListener() {

        @Override
        public void onPeerMessageReceived(long fromUserId, Message message) {
            //message received
            String type = message.getType();
            String remoteRoomId = new String(message.getContent());
            String remoteUid = String.valueOf(fromUserId);
            Map<String, String> extras = message.getExtras();

            //filter out self
            if (Constant.mLocalUid.equals(remoteUid) &&
                    Constant.mLocalRoomId.equals(remoteRoomId)) {
                return;
            }

            if (type.equals(Constant.CROSS_INVITE_ONE2ONE_CALL)) {
                slog("Invitation from UID=" + remoteUid + ", roomID=" +
                        remoteRoomId + " is received", false);

                if (!extras.isEmpty()) {
                    String timestamp = extras.get(Constant.CROSS_SEND_MSG_TIMESTAMP);
                    long sendTime = Long.valueOf(timestamp);
                    long currentTime = TimeUtil.getCurrentSecondTimestamp();
                    long disTime = (currentTime - sendTime) * 1000;
                    if (disTime > Constant.CROSS_COUNTDOWN_TIME) {
                        //if it is greater than 15S, the invitation dialog is not displayed
                        return;
                    }
                }

                if (isSubcribe || (confirmDialog != null && confirmDialog.isShowing())) {
                    //in connection and tell your partner you're busy.
                    sendBusyMsg(Constant.mLocalRoomId, remoteUid);
                } else {
                    //show the invitation dialog
                    String descRes = getResources().getString(R.string.confirm_invite_one2one_call);
                    String desc = String.format(descRes, fromUserId);
                    showInviteDialog(desc, remoteRoomId, remoteUid);
                }
            } else if (type.equals(Constant.CROSS_BUSY_ONE2ONE_CALL)) {
                //received a message of busy
                waittingDialog.dismiss();
                showToast(R.string.cross_toast_busy);
                slog("Invitation is rejected by system", false);
            } else if (type.equals(Constant.CROSS_CANCEL_ONE2ONE_CALL)) {
                //received a message of disconnect
                unSubscribeSomeone(Constant.mRemoteRoomId, Constant.mRemoteUid);
                isSubcribe = false; //change connect status
                tvRemoteSubcribe.setText(getResources().getString(R.string.cross_remote_subscribe));
                defaultPlayview.setVisibility(View.VISIBLE);
                showToast(getResources().getString(R.string.cross_call_end));
                enableInput();
                slog("1v1 video call is ended by UID=" + Constant.mRemoteUid, false);
            } else if (type.equals(Constant.CROSS_AGREE_ONE2ONE_CALL)) {
                //received a message of agree
                Constant.mRemoteRoomId = remoteRoomId;
                Constant.mRemoteUid = remoteUid;
                waittingDialog.dismiss();
                isSubcribe = true; //change connect status
                tvRemoteSubcribe
                        .setText(getResources().getString(R.string.cross_remote_unsubscribe));
                //connect
                subscribeSomeone(Constant.mRemoteRoomId, Constant.mRemoteUid);
                defaultPlayview.setVisibility(View.GONE);
                enableInput();
                showToast(getResources().getString(R.string.cross_toast_subcribe_succeed));
                slog("Invitation is accepted by UID=" + Constant.mRemoteUid, false);
            } else if (type.equals(Constant.CROSS_REFUSE_ONE2ONE_CALL)) {
                //received a message of rejected
                waittingDialog.dismiss();
                showToast(getResources().getString(R.string.cross_refuse));
                slog("Invitation is rejected by UID=" + remoteUid, false);
            }
        }
    };

    @SuppressLint("HandlerLeak")
    private Handler mHandler = new Handler() {
        @Override
        public void handleMessage(@NonNull android.os.Message msg) {
            super.handleMessage(msg);
            switch (msg.what) {
                case Constant.CROSS_AGREE_TIME_OUT://time out
                    if (confirmDialog != null) {
                        confirmDialog.dismiss();
                    }
                    slog("Invitation from UID=" + Constant.mRemoteUid
                            + ", roomID=" + Constant.mRemoteRoomId + " is expired", false);
                    break;
                case Constant.CROSS_AGREE_NO_RESPOSE://no response
                    tvRemoteSubcribe
                            .setText(getResources().getString(R.string.cross_remote_subscribe));
                    if (waittingDialog != null) {
                        waittingDialog.dismiss();
                    }
                    showToast(getResources().getString(R.string.cross_toast_subcribe_timeout));
                    slog("No response from UID=" + Constant.mRemoteUid
                            + ", roomID=" + Constant.mRemoteRoomId, false);
                    break;
                default:
                    break;
            }
        }
    };

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (confirmDialog != null) {
            confirmDialog.dismiss();
        }
        FacadeRtsManager.getIns().removeMsgListener(mEventListener);
    }
}
