package com.jocloud.audio.UI;

import android.Manifest;
import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Build;
import android.text.Editable;
import android.text.InputFilter;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.text.method.ScrollingMovementMethod;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.annotation.RequiresApi;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aivacom.api.baseui.WebViewActivity;
import com.aivacom.api.baseui.base.BaseActivity;
import com.aivacom.api.baseui.widget.dialog.puredialog.BottomMenuDialog;
import com.aivacom.api.feedback.view.FeedBackActivity;
import com.aivacom.api.jly_logcat.FloatLogActivity;
import com.aivacom.api.rtc.FacadeRtcManager;
import com.aivacom.api.utils.Constant;
import com.aivacom.api.utils.DataFormatUtil;
import com.aivacom.api.utils.NetworkUtil;
import com.aivacom.api.utils.PermissionUtils;
import com.jocloud.audio.R;
import com.jocloud.audio.adapter.MemberAdapter;
import com.jocloud.audio.bean.AudioMember;
import com.jocloud.audio.bean.VoiceChanger;
import com.thunder.livesdk.ThunderEventHandler;
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.ThunderRtcConstant.VoiceChangerMode;

import java.util.ArrayList;
import java.util.Arrays;

public class AudioActivity extends BaseActivity {

    private EditText mEtUid;
    private EditText mEtRoomId;
    private TextView mTvStartLive;
    private RecyclerView mRvMember;
    private MemberAdapter mMemberAdapter;
    private TextView mTvLog;
    private ImageView mIvSpeaker;
    private ImageView mIvEarMonitor;
    private ImageView mIvVoiceChanger;
    private int mVoiceChangeMode;
    private boolean mVoiceChangeEnable = false;
    private TextView mTvSelect;
    private View mIvClearLocalUid;
    private View mIvClearLocalRid;

    private int mProfile = ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_SPEECH_STANDARD;
    private boolean mEnableInEarMonitor;

    private String[] permissions = new String[]{Manifest.permission.CAMERA,
            Manifest.permission.RECORD_AUDIO,
            Manifest.permission.WRITE_EXTERNAL_STORAGE,
            Manifest.permission.READ_EXTERNAL_STORAGE};

    private ThunderEventHandler myThunderEventHandler = new ThunderEventHandler() {
        @Override
        public void onJoinRoomSuccess(String room, String uid, int elapsed) {
            super.onJoinRoomSuccess(room, uid, elapsed);
            Log.i(TAG, "onJoinRoomSuccess: ");
            handleJoinRoomSuccess();
        }

        @Override
        public void onLeaveRoom(ThunderEventHandler.RoomStats status) {
            super.onLeaveRoom(status);
            Log.i(TAG, "onLeaveRoom: ");
            handleLeaveRoomUI();
        }

        @Override
        public void onRemoteAudioStopped(String uid, boolean stop) {
            Log.i(TAG, "onRemoteAudioStopped: uid " + uid + " stop " + stop);
            super.onRemoteAudioStopped(uid, stop);

            int index = mMemberAdapter.getMemberIndexByUid(uid);
            AudioMember audioMember;

            if (stop) {
                if (index != -1) {
                    mMemberAdapter.deleteItem(index);
                    addLog("UID=" + uid + " left");
                }
            } else {
                if (index == -1) {
                    audioMember = new AudioMember(uid, false);
                    mMemberAdapter.addItemData(audioMember);
                    addLog("UID=" + uid + " joined");
                    FacadeRtcManager.getInstance().stopRemoteAudioStream(uid, false);
                }
            }
        }

        @Override
        public void onCaptureVolumeIndication(int totalVolume, int cpt, int micVolume) {
            //Called when enabling/disabling volume capture
            //采集音量回调
            super.onCaptureVolumeIndication(totalVolume, cpt, micVolume);

            int index = mMemberAdapter.getMemberIndexByUid(Constant.mLocalUid);

            if (index != -1) {
                AudioMember audioMember = mMemberAdapter.getDataList().get(index);
                audioMember.micVolume = micVolume;
                mMemberAdapter.updateItemData(index, audioMember);
            }
        }

        @Override
        public void onPlayVolumeIndication(ThunderEventHandler.AudioVolumeInfo[] speakers, int totalVolume) {
            //Called when someone is speaking to report the speaker name and speaking volume
            //说话者音量回调
            super.onPlayVolumeIndication(speakers, totalVolume);

            for (ThunderEventHandler.AudioVolumeInfo speaker : speakers) {
                String uid = speaker.uid;
                int index = mMemberAdapter.getMemberIndexByUid(uid);
                AudioMember audioMember;
                if (index != -1) {
                    audioMember = mMemberAdapter.getDataList().get(index);
                    audioMember.micVolume = speaker.volume;
                    mMemberAdapter.updateItemData(index, audioMember);
                } else if (speaker.volume > 0) {
                    audioMember = new AudioMember(uid, false);
                    mMemberAdapter.addItemData(audioMember);
                    addLog("UID=" + uid + " joined");
                    FacadeRtcManager.getInstance().stopRemoteAudioStream(uid, false);
                }
            }
        }
    };

    @Override
    protected int getLayoutResId() {
        return R.layout.audio;
    }

    @SuppressLint("ClickableViewAccessibility")
    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    protected void initView() {

        mEtUid = findViewById(R.id.et_uid);
        mEtRoomId = findViewById(R.id.et_room_id);
        initEditTextUid();
        initEditTextRoomId();

        mTvStartLive = findViewById(R.id.tv_start_live);
        mTvStartLive.setOnClickListener(this);

        mRvMember = findViewById(R.id.rv_member);

        mTvLog = findViewById(R.id.tv_log);
        mTvLog.setMovementMethod(ScrollingMovementMethod.getInstance());
        mTvSelect = findViewById(R.id.tv_select);
        mTvSelect.setOnClickListener(this);
        String[] dataList = getResources().getStringArray(R.array.mode);
        mTvSelect.setText(dataList[0]);

        mIvSpeaker = findViewById(R.id.iv_speaker);
        mIvSpeaker.setOnClickListener(this);
        mIvEarMonitor = findViewById(R.id.iv_ear_monitor);
        mIvEarMonitor.setOnClickListener(this);
        mIvVoiceChanger = findViewById(R.id.iv_voice_changer);
        mIvVoiceChanger.setOnClickListener(this);
        mIvClearLocalUid = findViewById(R.id.iv_clear_local_uid);
        mIvClearLocalUid.setOnClickListener(this);
        mIvClearLocalRid = findViewById(R.id.iv_clear_local_rid);
        mIvClearLocalRid.setOnClickListener(this);

        findViewById(R.id.iv_log).setOnClickListener(this);
        findViewById(R.id.iv_api).setOnClickListener(this);
        findViewById(R.id.iv_feedback).setOnClickListener(this);
    }

    /**
     * init user id edit text
     */
    private void initEditTextUid() {
        mEtUid.setText(Constant.mLocalUid);
        mEtUid.setOnFocusChangeListener((v, hasFocus) -> setHideIvClearUid(hasFocus));
        mEtUid.setFilters(new InputFilter[]{new InputFilter.LengthFilter(6)});
        mEtUid.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!s.toString().equals("0")) {
                    Constant.mLocalUid = s.toString();
                    setJoinRoomBtnEnable();
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
    private void initEditTextRoomId() {
        mEtRoomId.setText(Constant.mLocalRoomId);
        mEtRoomId.setOnFocusChangeListener((v, hasFocus) -> setHideIvClearRoomId(hasFocus));
        mEtRoomId.setFilters(new InputFilter[]{new InputFilter.LengthFilter(8)});
        mEtRoomId.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!s.toString().equals("0")) {
                    Constant.mLocalRoomId = s.toString();
                    setJoinRoomBtnEnable();
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

    private void setJoinRoomBtnEnable() {
        if (TextUtils.isEmpty(Constant.mLocalUid) || TextUtils.isEmpty(Constant.mLocalRoomId)) {
            mTvStartLive.setEnabled(false);
        } else {
            mTvStartLive.setEnabled(true);
        }
    }

    @Override
    protected void initData() {
        PermissionUtils.checkAndRequestMorePermissions(this, permissions,
                PermissionUtils.REQUEST_CODE_PERMISSIONS,
                () -> {
                });

        mRvMember.setLayoutManager(new LinearLayoutManager(getContext()));
        mMemberAdapter = new MemberAdapter(this);
        mRvMember.setAdapter(mMemberAdapter);

        mEtUid.setText(Constant.mLocalUid);
        mEtRoomId.setText(Constant.mLocalRoomId);

        //initial
        //初始化
        FacadeRtcManager.getInstance().register(myThunderEventHandler);
        FacadeRtcManager.getInstance().setAudioVolumeIndication();
        FacadeRtcManager.getInstance().enableCaptureVolumeIndication();

        //Set SDK media mode
        //Pure voice mode (recommended for use without video scenes, for better audio performance)
        //设置sdk媒体模式
        //纯语音模式(无视频场景建议使用，获取更佳音频性能)
        FacadeRtcManager.getInstance().setMediaMode(ThunderRtcConstant.ThunderRtcProfile.THUNDER_PROFILE_ONLY_AUDIO);

        //Set room scene mode
        //设置房间场景模式
        FacadeRtcManager.getInstance().setRoomMode(ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_MULTIAUDIOROOM);

        //Set audio configuration
        //设置音频配置
        FacadeRtcManager.getInstance().setAudioConfig(mProfile, ThunderRtcConstant.CommutMode.THUNDER_COMMUT_MODE_HIGH,
                ThunderRtcConstant.ScenarioMode.THUNDER_SCENARIO_MODE_DEFAULT);

        initVoiceChangerData();
    }

    ArrayList<VoiceChanger> mVoiceChangerModeList;

    private void initVoiceChangerData() {
        mVoiceChangerModeList = new ArrayList<>();
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_ethereal),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_ETHEREAL));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_thriller),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_THRILLER));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_lu_ban),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_LUBAN));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_lorie),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_LORIE));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_uncle),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_UNCLE));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_die_fat),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_DIEFAT));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_bad_boy),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_BADBOY));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_war_craft),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_WRACRAFT));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_heavy_metal),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_HEAVYMETAL));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_cold),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_COLD));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_heavy_machinery),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_HEAVYMECHINERY));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_trapped_beast),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_TRAPPEDBEAST));
        mVoiceChangerModeList.add(new VoiceChanger(getString(R.string.voice_power_current),
                VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_POWERCURRENT));

        mVoiceChangeMode = mVoiceChangerModeList.get(0).mode;
    }

    @Override
    protected int getTitleResId() {
        return R.string.audio_title;
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

        if (v.getId() == R.id.tv_start_live) {
            if (isLiving()) {
                handleLeaveLive();
            } else {
                handleStartLive();
            }
        } else if (v.getId() == R.id.tv_select) {
            showModeDialog();
        } else if (v.getId() == R.id.iv_speaker) {
            switchEnableLoud();
        } else if (v.getId() == R.id.iv_ear_monitor) {
            switchEarMonitor();
        } else if (v.getId() == R.id.iv_voice_changer) {
            handleClickVoiceChanger();
        } else if (v.getId() == R.id.iv_api) {
            Intent intent = new Intent(this, WebViewActivity.class);
            intent.putExtra(WebViewActivity.URL, Constant.AUDIO_API_URL);
            startActivity(intent);
        } else if (v.getId() == R.id.iv_log) {
            startActivity(new Intent(this, FloatLogActivity.class));
        } else if (v.getId() == R.id.iv_feedback) {
            startActivity(new Intent(this, FeedBackActivity.class));
        } else if (v.getId() == R.id.iv_clear_local_uid) {
            mEtUid.setText("");
        } else if (v.getId() == R.id.iv_clear_local_rid) {
            mEtRoomId.setText("");
        }
    }


    /**
     * set ivClearLocalUid Visibility
     *
     * @param hasFocus user id editText has focus
     */
    private void setHideIvClearUid(boolean hasFocus) {
        int oldVisible = mIvClearLocalUid.getVisibility();
        int visible = getClearBtnVisible(oldVisible, hasFocus, TextUtils.isEmpty(Constant.mLocalUid));
        if (oldVisible != visible) {
            mIvClearLocalUid.setVisibility(visible);
        }
    }

    /**
     * set ivClearLocalRid Visibility
     *
     * @param hasFocus room id editText has focus
     */
    private void setHideIvClearRoomId(boolean hasFocus) {
        int oldVisible = mIvClearLocalRid.getVisibility();
        int visible = getClearBtnVisible(oldVisible, hasFocus, TextUtils.isEmpty(Constant.mLocalRoomId));
        if (oldVisible != visible) {
            mIvClearLocalRid.setVisibility(visible);
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

    private void handleStartLive() {
        setHideIvClearRoomId(false);
        setHideIvClearUid(false);
        if (NetworkUtil.isNetworkAvailable(this)) {
            showDialogProgress();
            int result = FacadeRtcManager.getInstance()
                    .joinRoom("token".getBytes(), Constant.mLocalRoomId, Constant.mLocalUid);

            if (result != 0) {
                dismissDialogProgress();
                showToast(getString(R.string.toast_live_failed));
            }
        } else {
            showToast(R.string.network_error);
        }
    }

    private void handleLeaveLive() {
        //Exit the room to reset, the ear return is not used by default
        //退出房间重置
        //默认不使用耳返
        FacadeRtcManager.getInstance().setEnableInEarMonitor(false);

        mEnableInEarMonitor = false;

        //Use speakers by default
        //默认使用扬声器
        FacadeRtcManager.getInstance().enableLoudspeaker(true);

        mVoiceChangeEnable = false;
        mVoiceChangeMode = mVoiceChangerModeList.get(0).mode;
        FacadeRtcManager.getInstance().setVoiceChanger(VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_NONE);
        //Stop local audio and video
        //停止本地开播
        FacadeRtcManager.getInstance().stopAudioAndVideo();

        //Exit the room
        //退出房间
        FacadeRtcManager.getInstance().leaveRoom();
    }

    private void handleJoinRoomSuccess() {
        showToast(R.string.toast_live_succeed);
        dismissDialogProgress();
        mTvStartLive.setText(R.string.text_leave_live);
        mEtUid.setEnabled(false);
        mEtRoomId.setEnabled(false);
        mTvSelect.setEnabled(false);

        mIvSpeaker.setEnabled(true);
        mIvEarMonitor.setEnabled(true);
        mIvVoiceChanger.setEnabled(true);
        mIvEarMonitor.setImageResource(R.mipmap.ear_monitor_close_icon);
        mIvSpeaker.setImageResource(R.mipmap.speaker_icon);
        mIvVoiceChanger.setImageResource(R.mipmap.voice_changer_icon);

        startPlay();
        addLog("UID=" + Constant.mLocalUid + " joined with audio config = " + getAudioConfigString());
    }

    private void handleLeaveRoomUI() {
        mMemberAdapter.clear();

        mTvStartLive.setText(R.string.text_start_live);
        mEtUid.setEnabled(true);
        mEtRoomId.setEnabled(true);
        mTvSelect.setEnabled(true);

        mIvSpeaker.setEnabled(false);
        mIvEarMonitor.setEnabled(false);
        mIvVoiceChanger.setEnabled(false);
        mIvEarMonitor.setImageResource(R.mipmap.ear_monitor_disable_icon);
        mIvSpeaker.setImageResource(R.mipmap.speaker_disable_icon);
        mIvVoiceChanger.setImageResource(R.mipmap.voice_changer_disable_icon);

    }

    /**
     * Start pushing
     * 开始推流
     */
    private void startPlay() {
        //By default, ear-back is not used
        //默认不使用耳返
        FacadeRtcManager.getInstance().setEnableInEarMonitor(false);
        mEnableInEarMonitor = false;

        //Use speakers by default
        //默认使用扬声器
        FacadeRtcManager.getInstance().enableLoudspeaker(true);

        int result = FacadeRtcManager.getInstance().startAudio();
        if (result != 0) {
            showToast(getString(R.string.error_start_play, result));
            return;
        }

        mMemberAdapter.addItemData(1, new AudioMember(Constant.mLocalUid, false));
    }

    /**
     * Menu for selecting mode
     * 模式菜单选择
     */
    private void showModeDialog() {
        String[] dataList = getResources().getStringArray(R.array.mode);
        BottomMenuView bottomMenuView = new BottomMenuView(this, Arrays.asList(dataList), index -> {
            mTvSelect.setText(dataList[index]);
            if (index == 0) {
                mProfile = ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_SPEECH_STANDARD;
            } else if (index == 1) {
                mProfile = ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_STANDARD_STEREO;
            } else if (index == 2) {
                mProfile = ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_STANDARD;
            } else if (index == 3) {
                mProfile = ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO;
            } else if (index == 4) {
                mProfile = ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO_192;
            }

            //Set audio mode
            //设置音频模式
            FacadeRtcManager.getInstance().setAudioConfig(mProfile,
                    ThunderRtcConstant.CommutMode.THUNDER_COMMUT_MODE_HIGH,
                    ThunderRtcConstant.ScenarioMode.THUNDER_SCENARIO_MODE_DEFAULT);
        });
        BottomMenuDialog bottomMenuDialog = new BottomMenuDialog(this, bottomMenuView.getContentView());
        bottomMenuView.setDialog(bottomMenuDialog);
        bottomMenuDialog.show();
    }

    private void handleClickVoiceChanger() {
        BottomVoiceChangeView bottomVoiceChangeView = new BottomVoiceChangeView(this, mVoiceChangerModeList,
                mVoiceChangeEnable,
                mVoiceChangeMode,
                index -> {
                    int mode;
                    if (index == -1) {
                        mVoiceChangeEnable = false;
                        addLog("UID=" + Constant.mLocalUid + " turned off voice changer");
                        mode = VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_NONE;
                    } else {
                        mVoiceChangeEnable = true;
                        mVoiceChangeMode = mVoiceChangerModeList.get(index).mode;
                        mode = mVoiceChangeMode;
                        addLog("UID=" + Constant.mLocalUid + " changed voice to " + getVoiceChangeString());
                    }
                    FacadeRtcManager.getInstance().setVoiceChanger(mode);
                });
        BottomMenuDialog bottomMenuDialog = new BottomMenuDialog(this, bottomVoiceChangeView.getContentView());
        bottomMenuDialog.show();
    }


    /**
     * Turn on / off loud speaker
     * 开/关外放
     */
    private void switchEnableLoud() {
        if (!NetworkUtil.isNetworkAvailable(this)) {
            showToast(R.string.network_error);
            return;
        }
        boolean enabled = FacadeRtcManager.getInstance().isLoudspeakerEnabled();
        FacadeRtcManager.getInstance().enableLoudspeaker(!enabled);
        if (FacadeRtcManager.getInstance().isLoudspeakerEnabled()) {
            mIvSpeaker.setImageResource(R.mipmap.speaker_icon);
            addLog("UID=" + Constant.mLocalUid + " switched to speaker");
        } else {
            mIvSpeaker.setImageResource(R.mipmap.earphone_icon);
            addLog("UID=" + Constant.mLocalUid + " switched to earphone");
        }
    }

    /**
     * Turn on / off ear monitor
     * 开/关耳返
     */
    private void switchEarMonitor() {
        if (!NetworkUtil.isNetworkAvailable(this)) {
            showToast(R.string.network_error);
            return;
        }
        if (FacadeRtcManager.getInstance().setEnableInEarMonitor(!mEnableInEarMonitor) == 0) {
            mEnableInEarMonitor = !mEnableInEarMonitor;
            addLog("Ear-in " + (mEnableInEarMonitor ? "On" : "Off"));
            int resource = mEnableInEarMonitor ? R.mipmap.ear_monitor_icon : R.mipmap.ear_monitor_close_icon;
            mIvEarMonitor.setImageResource(resource);
        }
    }


    public void addLog(String message) {
        String time = DataFormatUtil.formatTimeWithRim(System.currentTimeMillis());
        mTvLog.append(time + " " + message + "\n");

        int offset = (mTvLog.getLineCount() + 2) * mTvLog.getLineHeight();
        if (offset > mTvLog.getHeight()) {
            mTvLog.scrollTo(0, offset - mTvLog.getHeight());
        } else {
            mTvLog.scrollTo(0, 0);
        }
    }

    private String getAudioConfigString() {
        if (mProfile == ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_SPEECH_STANDARD) {
            return "Speech Mono 16 KHz 18 kbps";
        } else if (mProfile == ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_STANDARD_STEREO) {
            return "Music Stereo 44.1 KHz 24 kbps EAAC +";
        } else if (mProfile == ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_STANDARD) {
            return "Music Mono 48 KHz 40 kbps";
        } else if (mProfile == ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO) {
            return "Music Stereo 44.1 KHz 128 kbps AAC LC";
        } else if (mProfile == ThunderRtcConstant.AudioConfig.THUNDER_AUDIO_CONFIG_MUSIC_HIGH_QUALITY_STEREO_192) {
            return "Music Stereo 44.1 KHz 192 kbps AAC LC_192K";
        }
        return "";
    }

    private String getVoiceChangeString() {
        if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_NONE) {
            return "";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_ETHEREAL) {
            return "Ethereal";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_THRILLER) {
            return "Thriller";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_LUBAN) {
            return "Luban";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_LORIE) {
            return "Lorie";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_UNCLE) {
            return "Uncle";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_DIEFAT) {
            return "Diefat";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_BADBOY) {
            return "Badboy";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_WRACRAFT) {
            return "Wracraft";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_HEAVYMETAL) {
            return "Heavymetal";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_COLD) {
            return "Cold";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_HEAVYMECHINERY) {
            return "Heavymechinery";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_TRAPPEDBEAST) {
            return "Trappedbeast";
        } else if (mVoiceChangeMode == VoiceChangerMode.THUNDER_VOICE_CHANGER_MODE_POWERCURRENT) {
            return "Powercurrent";
        }
        return "";
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if (isLiving()) {
            handleLeaveLive();
        }
        FacadeRtcManager.getInstance().unRegister(myThunderEventHandler);
    }
}
