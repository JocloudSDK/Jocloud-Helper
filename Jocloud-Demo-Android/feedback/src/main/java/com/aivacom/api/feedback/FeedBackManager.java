package com.aivacom.api.feedback;

import android.app.Application;

import androidx.annotation.NonNull;

import com.aivacom.api.utils.Constant;

import java.io.File;
import java.util.ArrayList;
import java.util.List;

import tv.athena.core.axis.Axis;
import tv.athena.crash.api.ICrashService;
import tv.athena.feedback.api.FeedbackData;
import tv.athena.feedback.api.IFeedbackService;
import tv.athena.klog.api.ILogService;
import tv.athena.klog.api.LogLevel;
import tv.athena.util.FP;
import tv.athena.util.ProcessorUtils;
import tv.athena.util.RuntimeInfo;


public class FeedBackManager {

    private static FeedBackManager instance;

    public static FeedBackManager getInstance() {
        if (instance == null) {
            instance = new FeedBackManager();
        }
        return instance;
    }

    public void init(Application application) {
        try {
            // 初始化 Runtime 信息
            String processName = ProcessorUtils.INSTANCE.getMyProcessName();
            RuntimeInfo.INSTANCE.appContext(application)
                    .packageName(application.getPackageName())
                    .processName((null != processName) ? processName : "")
                    .isDebuggable(true)
                    .isMainProcess(FP.eq(RuntimeInfo.sPackageName, RuntimeInfo.sProcessName));

            // 初始化 KLog 服务
            ILogService logService = Axis.Companion.getService(ILogService.class);
            if (null != logService) {
                logService.config()
                        .logCacheMaxSiz(100 * 1024 * 1024)
                        .singleLogMaxSize(4 * 1024 * 1024)
                        .logLevel(LogLevel.INSTANCE.getLEVEL_VERBOSE())
                        .processTag(Constant.FEEDBACK_CRASHLOGID)
                        .logPath(Constant.logFilePath)
                        .apply();
            }

            // 初始化 Crash 服务
            ICrashService crashService = Axis.Companion.getService(ICrashService.class);
            if (null != crashService) {
                crashService.start(Constant.FEEDBACK_CRASHLOGID, "");
            }

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

            FeedbackData feedbackData = new FeedbackData.Builder(Constant.FEEDBACK_CRASHLOGID,
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

}
