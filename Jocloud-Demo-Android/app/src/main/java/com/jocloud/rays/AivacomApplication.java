package com.jocloud.rays;

import android.app.Application;
import android.content.Context;

import androidx.multidex.MultiDex;

import com.aivacom.api.feedback.FeedBackManager;
import com.aivacom.api.rtc.FacadeRtcManager;
import com.aivacom.api.rts.FacadeRtsManager;
import com.aivacom.api.utils.AppContextUtil;
import com.aivacom.api.utils.Constant;
import com.aivacom.api.utils.CustomVersionUtil;
import com.aivacom.api.utils.LangUtil;

/**
 * Created by zhouwen on 2020/5/9.
 */
public class AivacomApplication extends Application {

    @Override
    public void onCreate() {
        super.onCreate();
        LangUtil.initLang(this);
        MultiDex.install(this);
        initRtcSDk();
        FeedBackManager.getInstance().init(this);

        setVersionString();

    }

    @Override
    protected void attachBaseContext(Context base) {
        super.attachBaseContext(base);
        AppContextUtil.setContext(this);
    }

    public void initRtcSDk() {
        FacadeRtcManager.getInstance()
                .init(this, String.valueOf(Constant.mAppId), Constant.mSceneId,
                        FacadeRtcManager.getInstance().getThunderEventHandler())
                .setLogFilePath(Constant.logFilePath);

        FacadeRtsManager.getIns().initRtsSdk(this, Constant.mAppId, "");
    }

    private void setVersionString() {
        String thunderVersion = FacadeRtcManager.getInstance().getVersion();
        int index = thunderVersion.indexOf('(');
        if (index != -1) {
            thunderVersion = thunderVersion.substring(0, index);
        }
        String versionString = "Rays V" +
                BuildConfig.VERSION_NAME +
                " #" +
                BuildConfig.VERSION_CODE
                + " TB " + thunderVersion
                + " RTS " + FacadeRtsManager.getIns().getVersion();
        CustomVersionUtil.setVersionString(versionString);
    }
}
