package com.aivacom.api.utils;

import android.app.ActivityManager;
import android.content.Context;

/**
 * Created by zhouwen on 2020/5/9.
 */
public class AppContextUtil {

    private static Context mContext;

    public static void setContext(Context context) {
        mContext = context;
    }

    public static Context getAppContext() {
        return mContext;
    }


    public static String getCurProcessName(Context context) {
        int pid = android.os.Process.myPid();
        ActivityManager mActivityManager = (ActivityManager) mContext.getSystemService(Context.ACTIVITY_SERVICE);
        for (ActivityManager.RunningAppProcessInfo appProcess : mActivityManager.getRunningAppProcesses()) {
            if (appProcess.pid == pid) {
                return appProcess.processName;
            }
        }
        return null;
    }

}
