package com.aivacom.api.utils;

import com.google.gson.Gson;

public class JsonUtil  {
    private static final Gson gson = new Gson();

    public static String toJson(Object src) {
        return gson.toJson(src);
    }

    public static <T> T toObject(String src, Class<T> clz) {
        try {
            return gson.fromJson(src, clz);
        } catch (Exception var3) {
            var3.printStackTrace();
            return null;
        }
    }
}