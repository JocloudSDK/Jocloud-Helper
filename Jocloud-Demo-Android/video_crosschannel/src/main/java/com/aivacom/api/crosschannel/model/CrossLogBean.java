package com.aivacom.api.crosschannel.model;

/**
 * created by chenshibiao on 2020/6/20.
 */
public class CrossLogBean {
    private String time;
    private String msg = "";
    private boolean isDark = false;

    public CrossLogBean(String time, String msg, boolean isDark) {
        this.time = time;
        this.msg = msg;
        this.isDark = isDark;
    }

    public String getTime() {
        return time;
    }

    public void setTime(String time) {
        this.time = time;
    }

    public String getMsg() {
        return msg;
    }

    public void setMsg(String msg) {
        this.msg = msg;
    }

    public boolean isDark() {
        return isDark;
    }

    public void setDark(boolean dark) {
        isDark = dark;
    }
}
