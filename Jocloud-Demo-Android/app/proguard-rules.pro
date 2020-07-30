# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.
#
# For more details, see
#   http://developer.android.com/guide/developing/tools/proguard.html

# If your project uses WebView with JS, uncomment the following
# and specify the fully qualified class name to the JavaScript interface
# class:
#-keepclassmembers class fqcn.of.javascript.interface.for.webview {
#   public *;
#}

# Uncomment this to preserve the line number information for
# debugging stack traces.
#-keepattributes SourceFile,LineNumberTable

# If you keep the line number information, uncomment this to
# hide the original source file name.
#-renamesourcefileattribute SourceFile

# rtc 音视频
-keep class com.rtc.thunder.** { *; }
-keep class org.webrtc.audioengine.** { *; }
-keep class com.yy.yyvideolib.** { *; }
-keep class com.yy.yyvideoplayer.** { *; }
-keep class com.yy.android.medialibrary.audiocodec.** { *; }

# rts 实时信令
-keep class com.hummer.**{*;}
-keepclassmembers class com.hummer.** {
   public *;
}