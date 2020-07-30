package com.jocloud.rays;

import android.content.Intent;
import android.os.Bundle;
import android.view.View;
import android.widget.ImageView;
import android.widget.TextView;

import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aivacom.api.baseui.base.BaseActivity;
import com.aivacom.api.crosschannel.UI.CrossChannelActivity;
import com.aivacom.api.feedback.view.FeedBackActivity;
import com.aivacom.api.samechannel.UI.VideoSameChannelActivity;
import com.aivacom.api.utils.CustomVersionUtil;
import com.aivacom.api.utils.LangUtil;
import com.jocloud.audio.UI.AudioActivity;
import com.jocloud.chatroom.UI.ChatRoomActivity;
import com.jocloud.rays.bean.AdvanceSceneInfo;
import com.yy.video_advanced.VideoAdvancedActivity;

import java.util.ArrayList;
import java.util.Locale;
import java.util.logging.Logger;

public class MainActivity extends BaseActivity implements View.OnClickListener {

    private static Logger sLogger = Logger.getLogger("MainActivity");
    private RecyclerView mRvList;
    private ArrayList<AdvanceSceneInfo> itemList = new ArrayList<>();
    private MainListAdapter mRvBaseAdapter;
    //    private FloatWindowManager mFloatWindowManager;
    private AdvanceSceneInfo mAdvanceSceneInfo;
    private int[] icons = {R.mipmap.home_real_video_icon, R.mipmap.home_real_audio_icon,
            R.mipmap.home_real_msg_icon, R.mipmap.home_mix_video_icon};
    private int[] titles = {R.string.main_video_tips, R.string.main_audio_tips, R.string.main_msg_tips,
            R.string.main_mix_video_tips};
    private int[] types = {AdvanceSceneInfo.TYPE_VIDEO, AdvanceSceneInfo.TYPE_AUDIO, AdvanceSceneInfo.TYPE_CHAT_ROOM,
            AdvanceSceneInfo.TYPE_STREAM_PUSHING};
    private int[] subTitles = {R.string.main_video_sub_tips, R.string.main_audio_sub_tips,
            R.string.main_msg_sub_tips, R.string.main_mix_video_sub_tips};
    private boolean[] enables = {true, true, true, false};

    private TextView tvAcVideo;
    private TextView tvSaVideo;
    private ImageView ivChangeLang;
    private String currentLang = "zh";

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        if (!isTaskRoot()) {
            finish();
        }
    }

    @Override
    protected int getLayoutResId() {
        return R.layout.activity_main;
    }

    @Override
    protected void initView() {

    }

    @Override
    protected int getTitleResId() {
        return 0;
    }

    @Override
    protected void initData() {
        String lang = LangUtil.getLang(getContext());
        if (lang != null) {
            currentLang = lang;
        }
        initRvAndData();
        setEventListener();

    }

//    private void initWindow() {
//        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && !Settings.canDrawOverlays(MainActivity.this)) {
//            Intent intent = new Intent(Settings.ACTION_MANAGE_OVERLAY_PERMISSION,
//                    Uri.parse("package:" + getPackageName()));
//            startActivityForResult(intent, 10);
//            return;
//        }
//
//        mFloatWindowManager = new FloatWindowManager(this);
//        mFloatWindowManager.showFloatWindow();
//
//        mFloatWindowManager.setFloatViewListener(new FloatWindowManager.FloatViewListener() {
//            @Override
//            public void onFloatView() {
//                Intent intent = new Intent(MainActivity.this, FloatLogActivity.class);
//                startActivity(intent);
//            }
//        });
//    }

    private void setEventListener() {
        mRvBaseAdapter.setRecycleViewListener(new MainListAdapter.OnRecycleItemViewListener() {
            @Override
            public void onItemView(int position) {
                int type = mRvBaseAdapter.getDataList().get(position).type;
                if (type == AdvanceSceneInfo.TYPE_VIDEO) {
                    go2AdvancedActivity();
                } else if (type == AdvanceSceneInfo.TYPE_AUDIO) {
                    startActivity(new Intent(MainActivity.this, AudioActivity.class));
                } else if (type == AdvanceSceneInfo.TYPE_CHAT_ROOM) {
                    startActivity(new Intent(MainActivity.this, ChatRoomActivity.class));
                } else {
                    showToast(R.string.main_features_not_implemented);
                }
            }
        });
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
    }

    private void initRvAndData() {
        mRvList = findViewById(R.id.rv_home);
        tvAcVideo = findViewById(R.id.tv_ac_video);
        tvAcVideo.setOnClickListener(this);
        tvSaVideo = findViewById(R.id.tv_sa_video);
        tvSaVideo.setOnClickListener(this);

        ivChangeLang = findViewById(R.id.iv_change_lang);
        ivChangeLang.setOnClickListener(this);
        if (currentLangIsEng()) {
            ivChangeLang.setImageResource(R.mipmap.home_ch_icon);
        } else {
            ivChangeLang.setImageResource(R.mipmap.home_en_icon);
        }
        findViewById(R.id.iv_feedback).setOnClickListener(this);
        findViewById(R.id.iv_doc).setOnClickListener(this);

        for (int i = 0; i < 4; i++) {
            mAdvanceSceneInfo = new AdvanceSceneInfo();
            mAdvanceSceneInfo.icon = icons[i];
            mAdvanceSceneInfo.itemTitle = titles[i];
            mAdvanceSceneInfo.type = types[i];
            mAdvanceSceneInfo.itemSubTitle = subTitles[i];
            mAdvanceSceneInfo.enable = enables[i];
            itemList.add(mAdvanceSceneInfo);
        }

        mRvList.setLayoutManager(new LinearLayoutManager(this));

        mRvBaseAdapter = new MainListAdapter(this);
        mRvBaseAdapter.setDataList(itemList);
        mRvList.setAdapter(mRvBaseAdapter);

        TextView tvVersion = findViewById(R.id.tv_version);
        tvVersion.setText(CustomVersionUtil.getsVersionString());

    }

    private void go2CrossChannel() {
        Intent intent = new Intent(MainActivity.this, CrossChannelActivity.class);
        startActivity(intent);
    }

    private void go2SameChannel() {
        Intent intent = new Intent(MainActivity.this, VideoSameChannelActivity.class);
        startActivity(intent);
    }

    private void go2AdvancedActivity() {
        Intent intent = new Intent(MainActivity.this, VideoAdvancedActivity.class);
        startActivity(intent);
    }

    @Override
    public void onClick(View v) {
        switch (v.getId()) {
            case R.id.tv_ac_video://跨房间连麦
                go2CrossChannel();
                break;
            case R.id.tv_sa_video://同房间连麦
                go2SameChannel();
                break;
            case R.id.iv_change_lang:
                changeLang();
                break;
            case R.id.iv_feedback:
                startActivity(new Intent(this, FeedBackActivity.class));
                break;
//            case R.id.iv_doc:
//                break;
            default:
        }
    }

    private boolean currentLangIsEng() {
        return "en".equals(currentLang);
    }

    private void changeLang() {
        Locale locale;
        if (currentLangIsEng()) {
            locale = Locale.CHINA;
        } else {
            locale = Locale.ENGLISH;
        }
        LangUtil.changeLang(getContext(), locale);

        Intent intent = new Intent(this, MainActivity.class);
        intent.setFlags(Intent.FLAG_ACTIVITY_NEW_TASK | Intent.FLAG_ACTIVITY_CLEAR_TASK);
        startActivity(intent);

        // 杀掉进程
        android.os.Process.killProcess(android.os.Process.myPid());
        System.exit(0);
    }
}
