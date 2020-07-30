package com.aivacom.api.utils;

import android.os.Environment;

import java.io.File;
import java.util.Random;

public class Constant {
    public static final int STATUS_FORCE_KILLED = -1; //应用在后台被强杀
    public static final int STATUS_NORMAL = 2; //APP正常态

    public static long mAppId = 1711983884;

    public static final String FEEDBACK_CRASHLOGID = "Aivacom-Android";

    public static long mSceneId = 0;
    public static String logFilePath =
            Environment.getExternalStorageDirectory().getAbsolutePath() + File.separator +
                    "aivacom" + File.separator + "logs/";

    public static final int CHAT_GROUPID = 888;
    public static final String ROOMID_KEY = "roomid";
    public static final String ROOMOWNERID_KEY = "roomowner";
    public static final String ROOMISLIVE_KEY = "roomlive";
    public static final String ROOMISSUBCRIBE_KEY = "roomsubcribe";
    public static final String ROOMISSUBCRIBE_MREMOTEUID_KEY = "roomsubcribemremoteuid";

    public static byte[] token;

    //平台化定义相同的语义
    public static final String LIVE_CONNECT_APPLY = "live_connect_apply";
    public static final String LIVE_CONNECT_ACCEPT = "live_connect_accept";
    public static final String LIVE_CONNECT_REFUSE = "live_connect_refuse";
    public static final String LIVE_CONNECT_CANCEL = "live_connect_cancel";

    public static final String LIVE_MODETYPE = "live_modetype";
    public static final String MEMBERS_MODETYPE = "members_modetype";

    public static final String SP_UID = "sp_uid";
    public static final String SP_ISLOGIN = "sp_islogin";

    public static final String CROSS_REGION = "cn"; //区域设置
    public static final String CROSS_SEND_MSG_TIMESTAMP = "send_timestamp"; //发送消息时间戳
    public static final String CROSS_INVITE_ONE2ONE_CALL = "1on1_invite"; //邀请连麦
    public static final String CROSS_BUSY_ONE2ONE_CALL = "1on1_busy"; //对方正在连麦中
    public static final String CROSS_CANCEL_ONE2ONE_CALL = "1on1_cancel"; //取消连麦
    public static final String CROSS_AGREE_ONE2ONE_CALL = "1on1_accept"; //同意连麦
    public static final String CROSS_REFUSE_ONE2ONE_CALL = "1on1_reject"; //拒绝连麦
    public static final long CROSS_COUNTDOWN_TIME = 15 * 1000; //倒计时15秒
    // public static final long CROSS_DOWNSIDE_TIME = 2 * 60 * 1000; //无下行时间
    public static String mLocalUid = String.valueOf(new Random().nextInt(899999) + 100000);
    public static String mLocalRoomId = String.valueOf(new Random().nextInt(8999) + 1000);
    public static String mRemoteUid = "";
    public static String mRemoteRoomId = "";

    public static final int CROSS_AGREE_TIME_OUT = 0; //被申请连麦无响应超时
    public static final int CROSS_AGREE_NO_RESPOSE = 1; //申请连麦对方没回复超时
    // public static final int CROSS_NO_AV_STREAM = 2; //没有音视频流下行

    public static final String SP_PUBLISHMODE = "publishmode";
    public static final String SP_MIXMODE = "mixmode";

    public static final String TASK_ID = "549527";
    public static boolean isMixSubscribeRemote = false;
    public static boolean isPushMixStream = false;
    public static boolean isUserStopPushMixStream = false;

    public static final String PUSH_BASE_URL = "rtmp://";
    public static String customPushUrl = ""; //设置自定义推流地址
    // public static boolean isStopRemoteVideo = true; //远端视频流
    // public static boolean isStopRemoteAudio = true; //远端音频流

    public static String API_URL_PRE = "https://github.com/Aivacom/Jocloud-Demo/tree/master/Jocloud-Demo-android/";

    public static String CROSS_API_URL = API_URL_PRE + "video_crosschannel";
    public static String VIDEO_ADVANCED_API_URL = API_URL_PRE + "video_advanced";
    public static String CHAT_ROOM_API_URL = API_URL_PRE + "chat_room";
    public static String SAME_API_URL = API_URL_PRE + "video_samechannel";
    public static String AUDIO_API_URL = API_URL_PRE + "audio";
}
