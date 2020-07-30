*[简体中文](README.zh.md) | [English](README.md)*
## 1.Overview

The Demo example mainly demonstrates how to quickly integrate the Jocloud Audio and Video SDK and the RTS SDK to implement co-hosting in a room or co-hosting across rooms.

See the project modules: video_samechannel, video_crosschannel for the implementation logic.

## 2.Quick Start
### 2.1 Prerequisites
You must meet the following conditions before starting development:
- Android Studio 3.0 or above

- Android SDK API level 16 or above

- Supports mobile devices with Android 4.1 or above

### 2.2 Create a Jocloud Account and Get an AppID
- Valid Jocloud account (valid APPID)，See details in [AppID Application](https://docs.aivacom.com/cloud/cn/platform/other/user_auth.html#e9a1b9e79bae-e4b88e-app-id)

### 2.3 Prepare the Development Environment
#### 2.3.1 Create a project
- 1.Open Android Studio and click Start a new Android Studio project.

- 2.Choose Phone and Tablet > Empty Activity, and then click Next.

- 3.Set the Android project name, package name, project location, language, and the minimum API level.

- 4.Click Finish.

#### 2.3.2 Integrate the SDK
- 1.Locate build.gradle from the root directory of the project, open it, and add maven source.
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
- 2.Add the specified SDK version

```js
dependencies {
    implementation fileTree(dir: 'libs', include: ['*.jar'])
    //Add ThunderBolt SDK here, x.y.z refers to a specific SDK version, for example: 2.8.2
    implementation "com.rtc.thunder:thunderbolt:x.y.z"

    //Add RTS SDK here, x.y.z refers to a specific SDK version, for example:3.1.5
    implementation "com.hummer:hmr:x.y.z"
    implementation "com.hummer:rts:x.y.z"
    .....
}
```
- 3.Add permissions required by SDK to the used SDK modules:

```xml
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:tools="http://schemas.android.com/tools"
    package="com.xxx.xxxx">
    .....
    //Add permissions
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

    //Add software features
    <uses-feature android:name="android.hardware.audio.low_latency" />
    <uses-feature android:name="android.hardware.audio.pro" />
    <uses-feature android:name="android.hardware.microphone" android:required="true" />
    <uses-feature android:name="android.hardware.camera.autofocus" />
    <uses-feature android:name="android.hardware.camera" android:required="true" />
    <uses-feature android:name="android.hardware.camera.front" android:required="true" />
</manifest>
```
- 4. Prevent code obfuscation

If code obfuscation is enabled during application compilation, the obfuscation must be prevented. Add the following information to the rule file proguard-rules.pro (/app/proguard-rules.pro) to prevent mixing public names in the library:

```js
-keep class com.rtc.thunder.** { *; }
-keep class org.webrtc.audioengine.** { *; }
-keep class com.yy.yyvideolib.** { *; }
-keep class com.yy.yyvideoplayer.** { *; }
-keep class com.yy.android.medialibrary.audiocodec.** { *; }
```
- 5.Click Sync to synchronize the project and complete the integration.

### 2.4 Run the Demo
- Method 1: Open the demo with Android Studio, connect to your Android device, and then build and run.

- Method 2: Use Gradle to build and run directly.

## 4.Contact Us
- For full API manual, refer to:[Developer Center](https://docs.aivacom.com/en).
- For more demos, refer to:[SDK and Demo Download](https://docs.aivacom.com/download).
- If you have pre-sales consultation questions, you can call: +86-020-82120482 or contact email: marketing@aivacom.com.

