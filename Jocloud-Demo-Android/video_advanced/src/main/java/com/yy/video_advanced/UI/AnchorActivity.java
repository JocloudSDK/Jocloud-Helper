package com.yy.video_advanced.UI;

import android.app.Activity;
import android.content.Context;
import android.content.Intent;
import android.content.pm.ActivityInfo;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.graphics.Color;
import android.graphics.drawable.BitmapDrawable;
import android.os.Build;
import android.os.Bundle;
import android.util.DisplayMetrics;
import android.util.Log;
import android.view.Gravity;
import android.view.View;
import android.view.ViewGroup;
import android.widget.Button;
import android.widget.ImageView;
import android.widget.PopupWindow;
import android.widget.TextView;

import com.aivacom.api.baseui.WebViewActivity;
import com.aivacom.api.feedback.view.FeedBackActivity;
import com.aivacom.api.jly_logcat.FloatLogActivity;
import com.aivacom.api.rtc.FacadeRtcManager;
import com.aivacom.api.utils.Constant;
import com.aivacom.api.utils.DisplayUtils;
import com.aivacom.api.utils.LangUtil;
import com.gyf.immersionbar.ImmersionBar;
import com.thunder.livesdk.ThunderEventHandler;
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.video.ThunderPreviewView;
import com.yy.video_advanced.R;

import java.util.Locale;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import static com.thunder.livesdk.ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_BLUERAY_2M;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_NORMAL;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_SUPERQULITY;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoMirrorMode.THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoMirrorMode.THUNDER_VIDEO_MIRROR_MODE_PREVIEW_NO_MIRROR_PUBLISH_MIRROR;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoMirrorMode.THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoMirrorMode.THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_FILL;

/**
 * 主播 activity
 */
public class AnchorActivity extends Activity implements View.OnClickListener {

    private Context mContext;
    private Button btnOrientation;
    private Button btnFillModel;
    private Button btnCloseMic;
    private Button btnSwitchCamera;
    private Button btnOnOffCamera;
    private Button btnMir;
    private Button btnTranscodingMode;

    private TextView tvUID;
    private TextView tvRoomID;

    private ImageView ivBack;
    private ImageView ivFeedback;
    private ImageView ivApi;
    private ImageView ivLog;

    private ThunderPreviewView mPreviewView;

    //填充模式
    private PopupWindow mModelPopupWindow;
    private int modePopHeight = 0;
    private int fillMode = THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS;
    private TextView tvFillMode;
    private TextView tvClipMode;
    private TextView tvFitMode;

    //镜像模式
    private PopupWindow mirrorModePop;
    private int mirrorPopHeight = 0;
    private boolean previewMirror = true;
    private boolean pushMirror = true;
    private TextView tvPreviewMirror;
    private TextView tvPreviewNoMirror;
    private TextView tvPushMirror;
    private TextView tvPushNoMirror;

    //档位
    private PopupWindow transcodingModePop;
    private int transcodingModePopHeight = 0;
    private int transcodingMode = THUNDERPUBLISH_VIDEO_MODE_SUPERQULITY;
    private TextView tvFluencyMode;
    private TextView tvNormalMode;
    private TextView tvHighqulityMode;
    private TextView tvSuperqulityMode;

    private boolean isOnMicrophone = true;
    private boolean isOnCamera = true;
    private boolean bFront = true;

    private String roomID = "";

    private boolean isStartLive = false;

    private String currentLang = "zh";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        int orientation = getResources().getConfiguration().orientation;
        if (orientation == Configuration.ORIENTATION_LANDSCAPE) {
            setContentView( R.layout.activity_anchor_land);
        }else {
        setContentView( R.layout.activity_anchor_port);
        }
        initView();
        initData();
    }

    protected void initView() {
        initStatubar();
        btnOrientation = findViewById(R.id.btnVAD_orientation);
        btnFillModel = findViewById(R.id.btnVAD_fillModel);
        btnCloseMic = findViewById(R.id.btnVAD_closeMic);
        btnSwitchCamera = findViewById(R.id.btnVAD_switchCamera);
        btnOnOffCamera = findViewById(R.id.btnVAD_onOffCamera);
        btnMir = findViewById(R.id.btnVAD_Mir);
        btnTranscodingMode = findViewById(R.id.btnVAD_transcodingMode);
        mPreviewView = findViewById(R.id.vAD_preview);
        tvRoomID = findViewById(R.id.tv_roomid);
        tvUID = findViewById(R.id.tv_uid);
        ivBack = findViewById(R.id.iv_ad_back);
        ivFeedback = findViewById(R.id.iv_feedback);
        ivApi = findViewById(R.id.iv_api);
        ivLog = findViewById(R.id.iv_log);

        btnOrientation.setOnClickListener(this);
        btnFillModel.setOnClickListener(this);
        btnCloseMic.setOnClickListener(this);
        btnSwitchCamera.setOnClickListener(this);
        btnOnOffCamera.setOnClickListener(this);
        btnMir.setOnClickListener(this);
        btnTranscodingMode.setOnClickListener(this);

        ivBack.setOnClickListener(this);
        ivFeedback.setOnClickListener(this);
        ivApi.setOnClickListener(this);
        ivLog.setOnClickListener(this);
        initStatubar();
    }

    // @Override
    protected void initData() {
        initStatubar();
        String lang = LangUtil.getLang(this);
        if (lang != null) {
            currentLang = lang;
        }
        roomID = getIntent().getStringExtra("roomID");
        String roomformat = getResources().getString(R.string.advanced_room_id);
        String roomTxt = String.format(roomformat, roomID);
        tvRoomID.setText(roomTxt);

        String userformat = getResources().getString(R.string.advanced_user_id);
        String userTxt = String.format(userformat, Constant.mLocalUid);
        tvUID.setText(userTxt);

        if (!isStartLive) {
            FacadeRtcManager.getInstance().setObserver(observer);
            startLive();
            isStartLive = true;
        } else {
            btnOnOffCamera.setText(isOnCamera
                    ? getResources().getString(R.string.advanced_close_camera)
                    : getResources().getString(R.string.advanced_open_camera));
            btnSwitchCamera.setEnabled(isOnCamera);
            if (isOnCamera) {
                FacadeRtcManager.getInstance().startPreview(mPreviewView, Constant.mLocalUid);
            }else {
                FacadeRtcManager.getInstance().setPreview(mPreviewView, Constant.mLocalUid);
            }
        }
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btnVAD_orientation) {
            changeOrientation();
        } else if (id == R.id.btnVAD_fillModel) {
            showFillModePop();
        } else if (id == R.id.btnVAD_closeMic) {
            switchMic();
        } else if (id == R.id.btnVAD_switchCamera) {
            switchFrontCamera();
        } else if (id == R.id.btnVAD_onOffCamera) {
            onOffCamera();
        } else if (id == R.id.btnVAD_Mir) {
            showMirrorModePop();
        } else if (id == R.id.btnVAD_transcodingMode) {
            showTranscodingModePop();
        } else if (id == R.id.iv_ad_back) {
            finish();
        } else if (id == R.id.iv_feedback) {
            go2Feedback();
        } else if (id == R.id.iv_api) {
            go2Api();
        } else if (id == R.id.iv_log) {
            go2Log();
        } else if (id == R.id.tv_fillMode) {//填充模式-填充
            fillMode = THUNDERVIDEOVIEW_SCALE_MODE_FILL;
            selectFillMode();
            FacadeRtcManager.getInstance().setLocalCanvasScaleMode(fillMode);
        } else if (id == R.id.tv_clipMode) {//填充模式-裁剪
            fillMode = THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS;
            selectFillMode();
            FacadeRtcManager.getInstance().setLocalCanvasScaleMode(fillMode);
        } else if (id == R.id.tv_fitMode) {//填充模式-适应，留黑边
            fillMode = THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT;
            selectFillMode();
            FacadeRtcManager.getInstance().setLocalCanvasScaleMode(fillMode);
        } else if (id == R.id.tv_ModeFluency) {//流畅
            transcodingMode = THUNDERPUBLISH_VIDEO_MODE_NORMAL;
            selectTrancodingMode();
            FacadeRtcManager.getInstance().setVideoEncoderConfig(transcodingMode);
        } else if (id == R.id.tv_ModeNormal) {//标清
            transcodingMode = THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY;
            selectTrancodingMode();
            FacadeRtcManager.getInstance().setVideoEncoderConfig(transcodingMode);
        } else if (id == R.id.tv_ModeHighqulity) {//高清
            transcodingMode = THUNDERPUBLISH_VIDEO_MODE_SUPERQULITY;
            selectTrancodingMode();
            FacadeRtcManager.getInstance().setVideoEncoderConfig(transcodingMode);
        } else if (id == R.id.tv_ModeSuperqulity) {//超清
            transcodingMode = THUNDERPUBLISH_VIDEO_MODE_BLUERAY_2M;
            selectTrancodingMode();
            FacadeRtcManager.getInstance().setVideoEncoderConfig(transcodingMode);
        } else if (id == R.id.tvPreviewMirror) {//预览镜像
            previewMirror = true;
            selectMirrorMode();
        } else if (id == R.id.tvPreviewNoMirror) {//预览不镜像
            previewMirror = false;
            selectMirrorMode();
        } else if (id == R.id.tvPushMirror) {//推流镜像
            pushMirror = true;
            selectMirrorMode();
        } else if (id == R.id.tvPushNoMirror) {//推流不镜像
            pushMirror = false;
            selectMirrorMode();
        }
    }

    /**
     * 横竖屏切换
     */
    private void changeOrientation() {
        if (getRequestedOrientation() == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            //切换竖屏
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
        } else {
            //切换横屏
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
        }
    }

    private void startLive() {
        FacadeRtcManager.getInstance().setLocalVideoMirrorMode(
                THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR);
        FacadeRtcManager.getInstance()
                .setRoomConfig(ThunderRtcConstant.ThunderRtcProfile.THUNDER_PROFILE_DEFAULT,
                        ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_LIVE);
        FacadeRtcManager.getInstance()
                .joinRoom(null, roomID, Constant.mLocalUid);
    }

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        changeLang();
        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            setContentView(R.layout.activity_anchor_land);

            initView();
            initData();

            initStatubar();
            FacadeRtcManager.getInstance().setVideoCaptureOrientation(
                    ThunderRtcConstant.ThunderVideoCaptureOrientation.THUNDER_VIDEO_CAPTURE_ORIENTATION_LANDSCAPE);

        } else {
            setContentView(R.layout.activity_anchor_port);

            initView();
            initData();
            initStatubar();
            FacadeRtcManager.getInstance().setVideoCaptureOrientation(
                    ThunderRtcConstant.ThunderVideoCaptureOrientation.THUNDER_VIDEO_CAPTURE_ORIENTATION_PORTRAIT);
        }
    }

    public void slog(String msg) {
        Log.e("TAG", "slog: " + msg);
    }

    FacadeRtcManager.Observer observer = new FacadeRtcManager.Observer() {
        @Override
        public void onJoinRoomSuccess(String channel, String uid, int elapsed) {
            super.onJoinRoomSuccess(channel, uid, elapsed);
            slog("onJoinRoomSuccess:channel = " + channel + " - uid=" + uid);
            FacadeRtcManager.getInstance()
                    .startPush(mPreviewView, Constant.mLocalUid,
                            THUNDERPUBLISH_VIDEO_MODE_SUPERQULITY);

        }

        @Override
        public void onLocalVideoStats(ThunderEventHandler.LocalVideoStats stats) {
            super.onLocalVideoStats(stats);
            // Log.e(TAG, "onLocalVideoStats: --------------------------" );
            // Log.e(TAG, "onLocalVideoStats: 实际发生码率："+stats.sentBitrate );
            // Log.e(TAG, "onLocalVideoStats: 实际发生帧率："+stats.sentFrameRate );
            // Log.e(TAG, "onLocalVideoStats: 实际宽："+stats.encodedFrameWidth );
            // Log.e(TAG, "onLocalVideoStats: 实际高："+stats.encodedFrameHeight );
            // Log.e(TAG, "onLocalVideoStats: 配置码率："+stats.configBitRate );
            // Log.e(TAG, "onLocalVideoStats: 配置帧率："+stats.configFrameRate );
            // Log.e(TAG, "onLocalVideoStats: 配置宽："+stats.configWidth );
            // Log.e(TAG, "onLocalVideoStats: 配置高："+stats.configHeight );
        }
    };

    /**
     * 填充模式
     */
    private void showFillModePop() {
        if (mModelPopupWindow == null) {
            View view = getLayoutInflater().inflate(R.layout.pop_fill_mode, null);
            mModelPopupWindow = new PopupWindow(view, DisplayUtils.dp2px(mContext, 340),
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    true);
            view.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            modePopHeight = view.getMeasuredHeight();
            mModelPopupWindow.setOutsideTouchable(true);
            mModelPopupWindow.setBackgroundDrawable(new BitmapDrawable());

            tvFillMode = view.findViewById(R.id.tv_fillMode);
            tvClipMode = view.findViewById(R.id.tv_clipMode);
            tvFitMode = view.findViewById(R.id.tv_fitMode);

            tvFillMode.setOnClickListener(this);
            tvClipMode.setOnClickListener(this);
            tvFitMode.setOnClickListener(this);
        }

        selectFillMode();

        int[] location = new int[2];
        btnFillModel.getLocationOnScreen(location);

        mModelPopupWindow.showAtLocation(btnFillModel, Gravity.NO_GRAVITY,
                DisplayUtils.dp2px(mContext, 12),
                location[1] - modePopHeight - DisplayUtils.dp2px(mContext, 12));
    }

    private void selectFillMode() {
        if (fillMode == THUNDERVIDEOVIEW_SCALE_MODE_FILL) {
            tvFillMode.setTextColor(Color.parseColor("#4877FF"));
            tvClipMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvFitMode.setTextColor(Color.parseColor("#FFFFFF"));
        } else if (fillMode == THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS) {
            tvFillMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvClipMode.setTextColor(Color.parseColor("#4877FF"));
            tvFitMode.setTextColor(Color.parseColor("#FFFFFF"));
        } else if (fillMode == THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT) {
            tvFillMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvClipMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvFitMode.setTextColor(Color.parseColor("#4877FF"));
        }
    }

    /**
     * 镜像模式
     */
    private void showMirrorModePop() {
        if (mirrorModePop == null) {
            View view = getLayoutInflater().inflate(R.layout.pop_mirror_mode, null);
            mirrorModePop = new PopupWindow(view, DisplayUtils.dp2px(mContext, 340),
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    true);
            view.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            mirrorPopHeight = view.getMeasuredHeight();
            mirrorModePop.setOutsideTouchable(true);
            mirrorModePop.setBackgroundDrawable(new BitmapDrawable());

            tvPreviewMirror = view.findViewById(R.id.tvPreviewMirror);
            tvPreviewNoMirror = view.findViewById(R.id.tvPreviewNoMirror);
            tvPushMirror = view.findViewById(R.id.tvPushMirror);
            tvPushNoMirror = view.findViewById(R.id.tvPushNoMirror);

            tvPreviewMirror.setOnClickListener(this);
            tvPreviewNoMirror.setOnClickListener(this);
            tvPushMirror.setOnClickListener(this);
            tvPushNoMirror.setOnClickListener(this);
        }

        if (previewMirror) {
            tvPreviewMirror.setTextColor(Color.parseColor("#4877FF"));
            tvPreviewNoMirror.setTextColor(Color.parseColor("#FFFFFF"));
        } else {
            tvPreviewMirror.setTextColor(Color.parseColor("#FFFFFF"));
            tvPreviewNoMirror.setTextColor(Color.parseColor("#4877FF"));
        }

        if (pushMirror) {
            tvPushMirror.setTextColor(Color.parseColor("#4877FF"));
            tvPushNoMirror.setTextColor(Color.parseColor("#FFFFFF"));
        } else {
            tvPushMirror.setTextColor(Color.parseColor("#FFFFFF"));
            tvPushNoMirror.setTextColor(Color.parseColor("#4877FF"));
        }

        int[] location = new int[2];
        btnMir.getLocationOnScreen(location);

        mirrorModePop.showAtLocation(btnMir, Gravity.NO_GRAVITY,
                DisplayUtils.dp2px(mContext, 12),
                location[1] - mirrorPopHeight - DisplayUtils.dp2px(mContext, 12));
    }

    private void selectMirrorMode() {
        if (previewMirror && pushMirror) {//预览推流都镜像
            tvPreviewMirror.setTextColor(Color.parseColor("#4877FF"));
            tvPreviewNoMirror.setTextColor(Color.parseColor("#FFFFFF"));
            tvPushMirror.setTextColor(Color.parseColor("#4877FF"));
            tvPushNoMirror.setTextColor(Color.parseColor("#FFFFFF"));
            FacadeRtcManager.getInstance().setLocalVideoMirrorMode(
                    THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_MIRROR);
        } else if (previewMirror && !pushMirror) {//预览镜像，推流不镜像
            tvPreviewMirror.setTextColor(Color.parseColor("#4877FF"));
            tvPreviewNoMirror.setTextColor(Color.parseColor("#FFFFFF"));
            tvPushMirror.setTextColor(Color.parseColor("#FFFFFF"));
            tvPushNoMirror.setTextColor(Color.parseColor("#4877FF"));
            FacadeRtcManager.getInstance().setLocalVideoMirrorMode(
                    THUNDER_VIDEO_MIRROR_MODE_PREVIEW_MIRROR_PUBLISH_NO_MIRROR);
        } else if (!previewMirror && pushMirror) {//预览不镜像，开播镜像
            tvPreviewMirror.setTextColor(Color.parseColor("#FFFFFF"));
            tvPreviewNoMirror.setTextColor(Color.parseColor("#4877FF"));
            tvPushMirror.setTextColor(Color.parseColor("#4877FF"));
            tvPushNoMirror.setTextColor(Color.parseColor("#FFFFFF"));
            FacadeRtcManager.getInstance().setLocalVideoMirrorMode(
                    THUNDER_VIDEO_MIRROR_MODE_PREVIEW_NO_MIRROR_PUBLISH_MIRROR);
        } else if (!previewMirror && !pushMirror) {//预览推流都不镜像
            tvPreviewMirror.setTextColor(Color.parseColor("#FFFFFF"));
            tvPreviewNoMirror.setTextColor(Color.parseColor("#4877FF"));
            tvPushMirror.setTextColor(Color.parseColor("#FFFFFF"));
            tvPushNoMirror.setTextColor(Color.parseColor("#4877FF"));
            FacadeRtcManager.getInstance().setLocalVideoMirrorMode(
                    THUNDER_VIDEO_MIRROR_MODE_PREVIEW_PUBLISH_BOTH_NO_MIRROR);
        }
    }

    /**
     * 档位模式选择
     */
    private void showTranscodingModePop() {
        if (transcodingModePop == null) {
            View view = getLayoutInflater().inflate(R.layout.pop_transcoding_mode, null);
            transcodingModePop = new PopupWindow(view, DisplayUtils.dp2px(mContext, 340),
                    ViewGroup.LayoutParams.WRAP_CONTENT,
                    true);
            view.measure(View.MeasureSpec.UNSPECIFIED, View.MeasureSpec.UNSPECIFIED);
            transcodingModePopHeight = view.getMeasuredHeight();
            transcodingModePop.setOutsideTouchable(true);
            transcodingModePop.setBackgroundDrawable(new BitmapDrawable());

            tvFluencyMode = view.findViewById(R.id.tv_ModeFluency);
            tvNormalMode = view.findViewById(R.id.tv_ModeNormal);
            tvHighqulityMode = view.findViewById(R.id.tv_ModeHighqulity);
            tvSuperqulityMode = view.findViewById(R.id.tv_ModeSuperqulity);

            tvFluencyMode.setOnClickListener(this);
            tvNormalMode.setOnClickListener(this);
            tvHighqulityMode.setOnClickListener(this);
            tvSuperqulityMode.setOnClickListener(this);
        }

        selectTrancodingMode();

        int[] location = new int[2];
        btnTranscodingMode.getLocationOnScreen(location);

        transcodingModePop.showAtLocation(btnTranscodingMode, Gravity.NO_GRAVITY,
                DisplayUtils.dp2px(mContext, 12),
                location[1] - transcodingModePopHeight - DisplayUtils.dp2px(mContext, 12));
    }

    private void selectTrancodingMode() {
        if (transcodingMode == THUNDERPUBLISH_VIDEO_MODE_NORMAL) {//流畅
            tvFluencyMode.setTextColor(Color.parseColor("#4877FF"));
            tvNormalMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvHighqulityMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvSuperqulityMode.setTextColor(Color.parseColor("#FFFFFF"));
        } else if (transcodingMode == THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY) {//标清
            tvFluencyMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvNormalMode.setTextColor(Color.parseColor("#4877FF"));
            tvHighqulityMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvSuperqulityMode.setTextColor(Color.parseColor("#FFFFFF"));
        } else if (transcodingMode == THUNDERPUBLISH_VIDEO_MODE_SUPERQULITY) {//高清
            tvFluencyMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvNormalMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvHighqulityMode.setTextColor(Color.parseColor("#4877FF"));
            tvSuperqulityMode.setTextColor(Color.parseColor("#FFFFFF"));
        } else if (transcodingMode == THUNDERPUBLISH_VIDEO_MODE_BLUERAY_2M) {//超清
            tvFluencyMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvNormalMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvHighqulityMode.setTextColor(Color.parseColor("#FFFFFF"));
            tvSuperqulityMode.setTextColor(Color.parseColor("#4877FF"));
        }
    }

    /**
     * 开关麦克风
     */
    private void switchMic() {
        isOnMicrophone = !isOnMicrophone;
        if (isOnMicrophone) {
            FacadeRtcManager.getInstance().startAudio();
        } else {
            FacadeRtcManager.getInstance().stopAudio();
        }

        btnCloseMic.setText(isOnMicrophone
                ? getResources().getString(R.string.advanced_close_mic)
                : getResources().getString(R.string.advanced_open_mic));
    }

    /**
     * switch camera
     * 切换前后摄像头
     */
    private void switchFrontCamera() {
        if (isOnCamera){
            bFront = !bFront;
            FacadeRtcManager.getInstance().switchFrontCamera(bFront);
            btnSwitchCamera.setText(bFront
                    ? getResources().getString(R.string.advanced_bfront_camera)
                    : getResources().getString(R.string.advanced_front_camera));
        }
    }

    /**
     * On-off camera
     * 开关摄像头
     */
    private void onOffCamera() {
        isOnCamera = !isOnCamera;
        if (isOnCamera) {
            FacadeRtcManager.getInstance().startVideo();
        } else {
            FacadeRtcManager.getInstance().stopVideo();
        }

        btnOnOffCamera.setText(isOnCamera
                ? getResources().getString(R.string.advanced_close_camera)
                : getResources().getString(R.string.advanced_open_camera));
        btnSwitchCamera.setEnabled(isOnCamera);
    }

    private void go2Api() {
        Intent intent = new Intent(this, WebViewActivity.class);
        intent.putExtra(WebViewActivity.URL, Constant.VIDEO_ADVANCED_API_URL);
        startActivity(intent);
    }

    private void go2Log() {
        startActivity(new Intent(this, FloatLogActivity.class));
    }

    private void go2Feedback() {
        startActivity(new Intent(this, FeedBackActivity.class));
    }

    private boolean currentLangIsEng() {
        return "en".equals(currentLang);
    }

    private void changeLang() {
        Locale locale;
        if (currentLangIsEng()) {
            locale = Locale.ENGLISH;
        } else {
            locale = Locale.CHINA;
        }
        Configuration configuration = mContext.getResources().getConfiguration();
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.JELLY_BEAN_MR1) {
            configuration.setLocale(locale);
        } else {
            configuration.locale = locale;
        }
        Resources resources = mContext.getResources();
        DisplayMetrics dm = resources.getDisplayMetrics();
        resources.updateConfiguration(configuration, dm);//语言更换生效的代码!
    }

    private void initStatubar(){
        ImmersionBar.with(this)
                .fitsSystemWindows(true)
                .navigationBarColor(R.color.black)
                .init();
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        if(!bFront){
            switchFrontCamera();
        }
        if (getRequestedOrientation() == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            FacadeRtcManager.getInstance().setVideoCaptureOrientation(
                    ThunderRtcConstant.ThunderVideoCaptureOrientation.THUNDER_VIDEO_CAPTURE_ORIENTATION_PORTRAIT);
        }
        FacadeRtcManager.getInstance().stopPush();
        FacadeRtcManager.getInstance().leaveRoom();
    }
}
