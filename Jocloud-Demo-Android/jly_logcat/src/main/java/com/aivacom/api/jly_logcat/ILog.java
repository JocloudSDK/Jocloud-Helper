package com.aivacom.api.jly_logcat;

import com.aivacom.api.jly_logcat.bean.LogData;

import java.util.ArrayList;

/**
 * Created by zhouwen on 2020/5/18.
 */
public interface ILog {

    interface LogTag {
        String INFO = "INFO";
        String WARN = "WARN";
        String ERROR = "ERROR";
    }

//    void addLog(String type, String log);

    void addLog(LogData logData);

    void addLogs(ArrayList<LogData> logData);
//    void removeWithType(String type);
//    void removeLogs();
}
