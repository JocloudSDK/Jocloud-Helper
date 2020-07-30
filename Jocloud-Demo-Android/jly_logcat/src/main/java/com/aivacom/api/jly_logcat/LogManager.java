package com.aivacom.api.jly_logcat;

import com.aivacom.api.jly_logcat.bean.LogData;

import java.util.ArrayList;

/**
 * 日志管理类
 * */
public class LogManager {
    private static LogManager instance = new LogManager();

    public static LogManager getInstance() {
        return instance;
    }

    private ILog callback;
    private ArrayList<LogData> logDataList = new ArrayList<>();

    public void setCallback(ILog callback) {
        this.callback = callback;
    }

    /**
     * 打印 DEBUG 级别日志
     * @param tag:记录打印日志方TAG，暂无用
     * @param log:日志内容
     * */
    public void logI(String tag, String log) {
        LogData logData = buildLogModel(ILog.LogTag.INFO, log);
        logDataList.add(logData);
        checkCallBack(logData);
    }

    /**
     * 打印 WARN 级别日志
     * @param tag:记录打印日志方TAG，暂无用
     * @param log:日志内容
     * */
    public void logW(String tag, String log) {
        LogData logData = buildLogModel(ILog.LogTag.WARN, log);
        logDataList.add(logData);
        checkCallBack(logData);
    }

    /**
     * 打印 ERROR 级别日志
     * @param tag:记录打印日志方TAG，暂无用
     * @param log:日志内容
     * */
    public void logE(String tag, String log) {
        LogData logData = buildLogModel(ILog.LogTag.ERROR, log);
        logDataList.add(logData);
        checkCallBack(logData);
    }

    public ArrayList<LogData> getLogList() {
        return logDataList;
    }

    private void checkCallBack(LogData logData) {
        if (callback != null) {
            callback.addLog(logData);
        }
    }

    private LogData buildLogModel(String level, String log) {
        LogData logData = new LogData();
        logData.logStr = log;
        logData.time = System.currentTimeMillis();
        logData.logTag = level;
        return logData;
    }
}
