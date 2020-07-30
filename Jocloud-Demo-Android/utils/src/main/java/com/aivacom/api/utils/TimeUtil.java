package com.aivacom.api.utils;

import java.text.SimpleDateFormat;
import java.util.Date;

/**
 * created by chenshibiao on 2020/6/11.
 */
public class TimeUtil {

    /**
     * 获取当前时间戳(秒 级别)
     */
    public static long getCurrentSecondTimestamp() {
        String timestamp = String.valueOf(new Date().getTime() / 1000);
        return Long.valueOf(timestamp);
    }

    /*
     * 将时间戳转换为时间
     */
    public static String stampToDate(long stamp) {
        String res;
        SimpleDateFormat simpleDateFormat = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
        Date date = new Date(stamp);
        res = simpleDateFormat.format(date);
        return res;
    }
}
