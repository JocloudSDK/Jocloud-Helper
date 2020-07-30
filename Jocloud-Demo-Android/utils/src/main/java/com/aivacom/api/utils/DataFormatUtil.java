package com.aivacom.api.utils;

import android.text.format.DateFormat;

/**
 * Created by zhouwen on 2020/5/19.
 */
public class DataFormatUtil {

    public static String formatTime(long date) {
        return DateFormat.format("MM-dd kk:mm:ss", date).toString();
    }

    public static String formatTimeWithRim(long date) {
        return "[" + formatTime(date) + "]";
    }

    public static String formatTimeHMS(long date) {
        return DateFormat.format("kk:mm:ss", date).toString();
    }
}
