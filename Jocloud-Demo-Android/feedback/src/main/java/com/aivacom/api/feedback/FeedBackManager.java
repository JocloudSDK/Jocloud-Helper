package com.aivacom.api.feedback;

import android.app.ActivityManager;
import android.app.Application;
import android.text.TextUtils;

import androidx.annotation.NonNull;

import com.aivacom.api.utils.Constant;
import com.yy.sdk.crashreport.CrashReport;
import com.yy.sdk.crashreport.Log;
import com.yy.sdk.crashreport.anr.ANRDetector;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Objects;

import tv.athena.core.axis.Axis;
import tv.athena.feedback.api.FeedbackData;
import tv.athena.feedback.api.IFeedbackService;
import tv.athena.klog.api.ILogService;
import tv.athena.klog.api.LogLevel;
import tv.athena.util.FP;
import tv.athena.util.ProcessorUtils;
import tv.athena.util.RuntimeInfo;


public class FeedBackManager {

    private final static String mLogReportAppId = Constant.FEEDBACK_CRASHLOGID;
    private final static String mLogFileTag = Constant.FEEDBACK_CRASHLOGID;
    private final static String mCrashReportAppId = Constant.FEEDBACK_CRASHLOGID;
    private final static long mkLogMaxSize = 100 * 1024 * 1024; // 100M
    private static FeedBackManager instance;

    public static FeedBackManager getInstance() {
        if (instance == null) {
            instance = new FeedBackManager();
        }
        return instance;
    }

    private FeedBackManager() {
    }

    public void init(Application application) {
        try {
            RuntimeInfo.INSTANCE.appContext(application)
                    /*** 设置包名* */
                    .packageName(application.getPackageName())
                    /*** 保存进程名* */
                    .processName(ProcessorUtils.INSTANCE.getMyProcessName())
                    /** 设置是否是debug 模式* */
                    .isDebuggable(true)
                    /*** 保存当前进程是否是主进程* */
                    .isMainProcess(FP.eq(RuntimeInfo.sPackageName, RuntimeInfo.sProcessName));

            if (TextUtils.equals(application.getPackageName(), ProcessorUtils.INSTANCE.getMyProcessName())) {
                /*** 初始化 KLog  现在是默认配置* */
                Objects.requireNonNull(Axis.Companion.getService(ILogService.class)
                        .config())
                        /*** 设置存储日志内存上限*/
                        .logCacheMaxSiz(mkLogMaxSize)
                        /*** 单个log文件最大值*/
                        .singleLogMaxSize(4 * 1024 * 1024)
                        /*** 设置日志写入级别*/
                        .logLevel(LogLevel.INSTANCE.getLEVEL_VERBOSE())
                        /*** 设置进程标识* */
                        .processTag(RuntimeInfo.sProcessName).apply();

//                //通过Axis初始化log服务
//                Axis.Companion.getService(ILogService.class).config().processTag(mLogFileTag).
//                logPath(Constant.logFilePath).logCacheMaxSiz(mkLogMaxSize);

//                //通过Axis初始化crash服务
//                Axis.Companion.getService(ICrashService.class).start(mCrashReportAppId, "");
//                //崩溃捕捉上报
//                Axis.Companion.getService(ICrashService.class).config().setGUid(Constant.uid).setAppId
//                (mCrashReportAppId);
            }

            RuntimeInfo.sAppContext = application;

            CrashReport.init(new CrashReport.CrashReportBuilder().setContext(application).setAppId(mCrashReportAppId));
            CrashReport.startANRDetecting(application);
            CrashReport.setANRListener(new ANRDetector.ANRListener() {
                @Override
                public void onANRDetected(ActivityManager.ProcessErrorStateInfo errorStateInfo) {
                    Log.i("AivacomApplication", "onANRDetected");
                }
            });

//        CrashReport.setUid(Integer.valueOf(Constant.mUid));
//        HashMap<String,String> map = new HashMap<>();
//        map.put("a","b");
//        CrashReport.addExtInfo(map);

        } catch (Exception e) {
            e.printStackTrace();
        }

    }

    public void feedBackLog(String msg,
                            FeedbackData.FeedbackStatusListener feedbackStatusListener) {
        try {
            File fileLogs = new File(Constant.logFilePath);
            List<File> files = new ArrayList<>();
            addFiles(files, fileLogs);

            FeedbackData feedbackData = new FeedbackData.Builder(mLogReportAppId,
                    Long.parseLong(Constant.mLocalUid), msg)
                    .setExternPathlist(files)
                    .setFeedbackStatusListener(feedbackStatusListener)
                    .create();
//            FeedbackData feedbackData = new FeedbackData.Builder(mLogReportAppId, Long.parseLong(Constant.uid), msg).
//                    setFeedbackStatusListener(feedbackStatusListener).
//                    create();
            Axis.Companion.getService(IFeedbackService.class).
                    sendNewLogUploadFeedback(feedbackData);
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    /**
     * The default feedback will only upload the logs under the main directory, not the logs under the folder,
     * so we need to add them manually.
     * 默认反馈只会上传主目录下的日志，不能上传文件夹下面日志，所以需要我们手动添加。
     */
    private void addFiles(@NonNull List<File> files, @NonNull File fileDirectory) {
        if (fileDirectory.exists()) {
            if (fileDirectory.isDirectory()) {
                File[] listFiles = fileDirectory.listFiles();
                if (listFiles == null) {
                    return;
                }

                for (File file : listFiles) {
                    if (file.exists()) {
                        if (file.isDirectory()) {
                            addFiles(files, file);
                        } else {
                            files.add(file);
                        }
                    }
                }
            } else {
                files.add(fileDirectory);
            }
        }
    }

//    public void setCrashConfig(String appid, String uid){
//        Axis.Companion.getService(ICrashService.class).config()
//                .setAppId(appid)
//                .setGUid(uid);
//    }

    public void setCrashConfigAndInfo(String uid, Map<String, String> extInfo) {
        CrashReport.setUid(Long.parseLong(uid));
//        HashMap<String,String> map = new HashMap<>();
//        map.put("a","b");
        CrashReport.addExtInfo(extInfo);
    }

}
