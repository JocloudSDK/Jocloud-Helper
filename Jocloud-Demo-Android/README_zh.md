# Android Samples for Jocloud Advanced Audio And Video Features
[中文](README.zh.md) | [English](README.md)
## 1 概览
该Demo示例主要演示了如何快速集成聚联云音视频SDK和实时消息SDK
- 实现同房间连麦
- 跨房间连麦
- 视频开播进阶功能
- 音频开播
- 聊天室

实现逻辑详见本工程module: video_samechannel,  video_crosschannel, video_advanced, audio, chat_room

## 2 快速开始
### 2.1 前提条件
- Android Studio 3.0 或以上版本
- Android SDK API 等级 16 或以上
- 支持 Android 4.1 或以上版本的移动设备
- 有效的聚联云账号和有效的APPID，[注册聚联云账号](https://jocloud.com/cn/reg)、[APPID申请](https://docs.jocloud.com/cloud/cn/platform/other
/user_auth.html#e9a1b9e79bae-e4b88e-app-id)

### 2.2 运行示例程序
- 使用Android Studio打开工程后同步
- 修改com.aivacom.api.utils.Constant.java 下的mAppId,填入申请的APPID
- 编译代码安装到手机上


## 3 FAQ
1. 集成 SDK
- 1.修改项目外层build.gradle 文件，添加仓库路径（两处）
```js
buildscript {
    repositories {
        maven { url "http://nexus.sunclouds.com:8081/nexus/content/groups/public/" }
        ......
    }
}

allprojects {
    repositories {
        ......
        maven { url "http://nexus.sunclouds.com:8081/nexus/content/groups/public/" }
        ......
    }
}
```
- 2.添加指定的SDK版本

```js
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar'])
    //此处添加ThunderBolt SDK, x.y.z表示引入SDK版本,例如：2.8.2
    implementation "com.rtc.thunder:thunderbolt:x.y.z"   

    //此处添加RTS SDK, x.y.z表示引入SDK版本,例如：3.1.5
    implementation "com.hummer:hmr:x.y.z"
    implementation "com.hummer:rts:x.y.z"
    .....
}
```
- 3.添加SDK要求的权限
```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.xxx.xxxx">
    .....
    //添加权限
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN" />
    <uses-permission android:name="android.permission.INTERNET" />
    <uses-permission android:name="android.permission.ACCESS_NETWORK_STATE" />
    <uses-permission android:name="android.permission.READ_PHONE_STATE" />
    <uses-permission android:name="android.permission.MODIFY_AUDIO_SETTINGS" />
    <uses-permission android:name="android.permission.RECORD_AUDIO" />
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.WAKE_LOCK" />
    <uses-permission android:name="android.permission.CAMERA" />

    //添加软件特征
    <uses-feature android:name="android.hardware.audio.low_latency" />
    <uses-feature android:name="android.hardware.audio.pro" />
    <uses-feature android:name="android.hardware.microphone" android:required="true" />
    <uses-feature android:name="android.hardware.camera.autofocus" />
    <uses-feature android:name="android.hardware.camera" android:required="true" />
    <uses-feature android:name="android.hardware.camera.front" android:required="true" />
</manifest>
```
- 4.防止混淆代码：
如果应用编译时开启混淆，需要防止混淆，在规则文件proguard-rules.pro（/app/proguard-rules.pro）中添加以下内容，这样可以防止混淆库中的公共类名称：
```js
-keep class com.rtc.thunder.** { *; }
-keep class org.webrtc.audioengine.** { *; }
-keep class com.yy.yyvideolib.** { *; }
-keep class com.yy.yyvideoplayer.** { *; }
-keep class com.yy.android.medialibrary.audiocodec.** { *; }
```

## 4 联系我们
- 完整的 API 文档见[开发者中心](https://docs.jocloud.com/cn)。
- 相关Demo下载，请访问：[SDK及Demo下载](https://docs.jocloud.com/download)。
- 如果有售前咨询问题, 可以拨打电话:020-82120482 或 联系邮箱:marketing@jocloud.com。