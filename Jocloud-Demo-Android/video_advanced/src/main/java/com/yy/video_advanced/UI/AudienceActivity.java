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
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.video.ThunderPlayerView;
import com.yy.video_advanced.R;

import java.util.Locale;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS;
import static com.thunder.livesdk.ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_FILL;

/**
 * 观众 activity
 */
public class AudienceActivity extends Activity implements View.OnClickListener {

    private Context mContext;
    private Button btnOrientation;
    private Button btnFillMode;

    private ThunderPlayerView mThunderPlayerView;

    private TextView tvRoomID;
    private TextView tvRemoteUid;
    private TextView tvLocalUid;

    private ImageView ivBack;
    private ImageView ivFeedback;
    private ImageView ivApi;
    private ImageView ivLog;

    //填充模式
    private PopupWindow mModelPopupWindow;
    private int modePopHeight = 0;
    private int fillMode = THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS;
    private TextView tvFillMode;
    private TextView tvClipMode;
    private TextView tvFitMode;

    private String remoteUid = null;
    private String roomID = "";

    private String currentLang = "zh";

    @Override
    protected void onCreate(@Nullable Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        mContext = this;
        setContentView(R.layout.audience_layout);
        initView();
        initData();
    }

    protected void initView() {
        mThunderPlayerView = findViewById(R.id.audiencePlayerview);
        btnOrientation = findViewById(R.id.btn_orientation);
        btnFillMode = findViewById(R.id.btn_fillModel);
        tvRoomID = findViewById(R.id.tv_roomid);
        tvRemoteUid = findViewById(R.id.tv_uid);
        tvLocalUid = findViewById(R.id.tv_localuid);
        ivBack = findViewById(R.id.iv_ad_back);
        ivFeedback = findViewById(R.id.iv_feedback);
        ivApi = findViewById(R.id.iv_api);
        ivLog = findViewById(R.id.iv_log);

        btnOrientation.setOnClickListener(this);
        btnFillMode.setOnClickListener(this);
        ivBack.setOnClickListener(this);
        ivFeedback.setOnClickListener(this);
        ivApi.setOnClickListener(this);
        ivLog.setOnClickListener(this);
        initStatubar();
    }

    protected void initData() {
        String lang = LangUtil.getLang(mContext);
        if (lang != null) {
            currentLang = lang;
        }
        roomID = getIntent().getStringExtra("roomID");

        String roomformat = getResources().getString(R.string.advanced_room_id);
        String roomTxt = String.format(roomformat, roomID);
        tvRoomID.setText(roomTxt);

        String userformat = getResources().getString(R.string.advanced_local_id);
        String userTxt = String.format(userformat, Constant.mLocalUid);
        tvLocalUid.setText(userTxt);

        String remoteuserformat = getResources().getString(R.string.advanced_user_id);
        String remoteuserTxt = String.format(remoteuserformat, "");
        tvRemoteUid.setText(remoteuserTxt);

        FacadeRtcManager.getInstance().setObserver(observer);
        FacadeRtcManager.getInstance()
                .setRoomConfig(ThunderRtcConstant.ThunderRtcProfile.THUNDER_PROFILE_DEFAULT,
                        ThunderRtcConstant.RoomConfig.THUNDER_ROOMCONFIG_LIVE);
        FacadeRtcManager.getInstance()
                .joinRoom(null, roomID, Constant.mLocalUid);
    }

    @Override
    public void onClick(View v) {
        int id = v.getId();
        if (id == R.id.btn_orientation) {
            changeOrientation();
        } else if (id == R.id.btn_fillModel) {
            showFillModePop();
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
            FacadeRtcManager.getInstance().setRemoteCanvasScaleMode(remoteUid, fillMode);
        } else if (id == R.id.tv_clipMode) {//填充模式-裁剪
            fillMode = THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS;
            selectFillMode();
            FacadeRtcManager.getInstance().setRemoteCanvasScaleMode(remoteUid, fillMode);
        } else if (id == R.id.tv_fitMode) {//填充模式-适应，留黑边
            fillMode = THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT;
            selectFillMode();
            FacadeRtcManager.getInstance().setRemoteCanvasScaleMode(remoteUid, fillMode);
        }
    }

    FacadeRtcManager.Observer observer = new FacadeRtcManager.Observer() {
        @Override
        public void onJoinRoomSuccess(String channel, String uid, int elapsed) {
            super.onJoinRoomSuccess(channel, uid, elapsed);
            FacadeRtcManager.getInstance().stopAudioAndVideo();
        }

        @Override
        public void onRemoteVideoStopped(String uid, boolean muted) {
            super.onRemoteVideoStopped(uid, muted);
            if (!muted) {
                remoteUid = uid;
                FacadeRtcManager.getInstance().prepareRemoteView(mThunderPlayerView, uid);

                String remoteuserformat = getResources().getString(R.string.advanced_user_id);
                String remoteuserTxt = String.format(remoteuserformat, uid);
                tvRemoteUid.setText(remoteuserTxt);
            } else {
                remoteUid = null;
            }
        }
    };

    @Override
    public void onConfigurationChanged(@NonNull Configuration newConfig) {
        super.onConfigurationChanged(newConfig);
        changeLang();
        initStatubar();
        if (newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE) {
            FacadeRtcManager.getInstance().setVideoCaptureOrientation(
                    ThunderRtcConstant.ThunderVideoCaptureOrientation.THUNDER_VIDEO_CAPTURE_ORIENTATION_LANDSCAPE);
        } else {
            FacadeRtcManager.getInstance().setVideoCaptureOrientation(
                    ThunderRtcConstant.ThunderVideoCaptureOrientation.THUNDER_VIDEO_CAPTURE_ORIENTATION_PORTRAIT);
        }

        btnOrientation.setText((newConfig.orientation == Configuration.ORIENTATION_LANDSCAPE)
                ? getResources().getString(R.string.advanced_portrait)
                : getResources().getString(R.string.advanced_landscape));
    }

    /**
     * 横竖屏切换
     */
    private void changeOrientation() {
        if (getRequestedOrientation() == ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE) {
            //切换竖屏
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_PORTRAIT);
            initStatubar();
        } else {
            //切换横屏
            setRequestedOrientation(ActivityInfo.SCREEN_ORIENTATION_LANDSCAPE);
            initStatubar();
        }
    }

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
        btnFillMode.getLocationOnScreen(location);

        mModelPopupWindow.showAtLocation(btnFillMode, Gravity.NO_GRAVITY,
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

    public void slog(String msg) {
        Log.e("TAG", "slog: " + msg);
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        FacadeRtcManager.getInstance().leaveRoom();
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

    private void initStatubar() {
        ImmersionBar.with(this)
                .fitsSystemWindows(true)
                .navigationBarColor(R.color.black)
                .init();
    }
}
