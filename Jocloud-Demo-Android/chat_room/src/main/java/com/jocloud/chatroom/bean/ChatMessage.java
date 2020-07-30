package com.jocloud.chatroom.bean;

import java.util.Calendar;
import java.util.Date;

public class ChatMessage {
    public static final String SYSTEM = "notice_msg";
    public static final String USER = "broadcast_msg";

    public String Uid;
    public String message;
    public String time;
    public String type;

    public ChatMessage(String uid, String message, long time, String type) {
        this.Uid = uid;
        this.message = message;
        this.time = formatTime(time);
        this.type = type;
    }

    public String formatTime(long time) {
        Date d = new Date(time);
        Calendar c = Calendar.getInstance();
        c.setTime(d);
        int hour = c.get(Calendar.HOUR_OF_DAY);
        int min = c.get(Calendar.MINUTE);
        int sec = c.get(Calendar.SECOND);
        String hourString = hour > 10 ? String.valueOf(hour) : "0" + hour;
        String minString = min > 10 ? String.valueOf(min) : "0" + min;
        String secString = sec > 10 ? String.valueOf(sec) : "0" + sec;
        return hourString + ":" + minString + ":" + secString;
    }
}
