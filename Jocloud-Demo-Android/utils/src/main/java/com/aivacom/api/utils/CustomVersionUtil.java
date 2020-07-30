package com.aivacom.api.utils;

public class CustomVersionUtil {
    private static String sVersionString;

    public static void setVersionString(String versionString) {
        sVersionString = versionString;
    }

    public static String getsVersionString() {
        return sVersionString;
    }

}
