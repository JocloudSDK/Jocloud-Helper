*[简体中文](README.zh.md) | [English](README.md)*
## 1.概览
该Demo示例主要演示了如何快速集成聚联云音视频SDK和实时消息SDK，实现同房间连麦、跨房间连麦。

实现逻辑详见本工程module: video_samechannel、video_crosschannel。

## 2.快速接入
### 2.1 前提条件
在开始开发之前您必须满足如下条件：
- Android Studio 3.0 或以上版本

- Android SDK API 等级 16 或以上

- 支持 Android 4.1 或以上版本的移动设备

### 2.2 创建聚联云账号并获取AppID
- 有效的聚联云账号(有效的APPID)，详见[APPID申请](https://docs.aivacom.com/cloud/cn/platform/other/user_auth.html#e9a1b9e79bae-e4b88e-app-id)

### 2.3 准备开发环境
#### 2.3.1 创建项目
- 打开 Android Studio，点击 Start a new Android Studio project。

- 在 Choose your project 界面，选择 Phone and Tablet > Empty Activity，然后点击 Next。

- 在 Configure your project 界面，依次填入Android 项目名称,包的名称,存储路径等。

#### 2.3.2 集成 SDK
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
- 3.在使用到SDK的Module中添加SDK要求的权限：

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
- 5.点击Sync，同步项目，完成集成。

### 2.4 编译运行Demo
- 方法一：使用 Android Studio 打开该Demo，连上Android设备，编译并运行。

- 方法二：使用 Gradle 直接编译运行。

## 4.联系我们
- 完整的 API 文档见[开发者中心](https://docs.aivacom.com/cn)。
- 相关Demo下载，请访问：[SDK及Demo下载](https://docs.aivacom.com/download)。
- 如果有售前咨询问题, 可以拨打电话:020-82120482 或 联系邮箱:marketing@aivacom.com。



