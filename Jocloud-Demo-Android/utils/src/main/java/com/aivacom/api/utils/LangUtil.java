package com.aivacom.api.utils;

import android.content.Context;
import android.content.res.Configuration;
import android.content.res.Resources;
import android.util.DisplayMetrics;

import java.util.Locale;

public class LangUtil {

    private static final String LANG_KEY = "AIVACOM_LANG_KEY";

    public static void changeLang(Context context, Locale locale) {
        Resources resources = context.getResources();
        DisplayMetrics dm = resources.getDisplayMetrics();
        Configuration config = resources.getConfiguration();
        config.setLocale(locale);
        resources.updateConfiguration(config, dm);
        SpUtil.putString(context, LANG_KEY, locale.getLanguage());
    }

    public static void initLang(Context context) {
        String lang = SpUtil.getString(context, LANG_KEY);
        if (lang != null) {
            Resources resources = context.getResources();
            DisplayMetrics dm = resources.getDisplayMetrics();
            Configuration config = resources.getConfiguration();
            if ("en".equals(lang)) {
                config.setLocale(Locale.ENGLISH);
            } else {
                config.setLocale(Locale.CHINA);
            }
            resources.updateConfiguration(config, dm);
        }

    }

    public static String getLang(Context context) {
        return SpUtil.getString(context, LANG_KEY);
    }

}
