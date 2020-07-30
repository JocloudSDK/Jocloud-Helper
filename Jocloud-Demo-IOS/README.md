# IOS Samples for Jocloud Advanced Audio And Video Features
[中文](README.zh.md) | [English](README.md)
## 1 OverView
This Demo mainly describes how to quickly integrate the Jocloud Audio/Video SDK and the RTS SDK to implement:
- co-hosting in a room
- Co-hosting across rooms
- Video Publishing
- Audio Publishing
- Chat Room

See the project modules `video_samechannel` , `video_crosschannel`,`video_advanced`,`audio`,`chat_room` for the implementation logic.

## 2 Quick Start
### 2.1 Prerequisites
You must meet the following conditions before starting development:
- XCode 10.0 +
- iOS 8.0 +
- iPhone device
- Valid Jocloud account (valid APPID)，See details in [Jocloud account](https://jocloud.com/en/reg), [AppID](https://docs.jocloud.com/cloud/en/platform/other/user_auth.html#e9a1b9e79bae-e4b88e-app-id)

### 2.2 Run the Demo
- Use Xcode to open the demo, connect the iPhone device, compile and run.

## 3 FAQ
### 1. Integrate the SDK
- 1.Open the project directory in the terminal, execute the following command
```objc
    pod init
```
- 2.Open `Podfile` file，enter the following content

```xml
    source 'https://github.com/CocoaPods/Specs.git'
    source 'https://github.com/yyqapm/specs.git'
    target 'XXX' do
    pod 'thunder',      'x.y.z'   //x.y.z refers to a specific SDK version, for example: 2.9.0 
```

- 3.Execute the following command in the terminal
```objc
    pod update
```
- 4.Add the permissions required by the SDK to the module that uses the SDK：

```xml
    <key>NSCameraUsageDescription</key>
    <string>We need your camera permission</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>We need your microphone permission</string>
```

## 4 Contact Us
- For full API manual, refer to: [Developer Center](https://docs.jocloud.com/cn).
- For more demos, refer to:[SDK and Demo Download](https://docs.jocloud.com/download).
- If you have pre-sales consultation questions, you can call: +86-020-82120482 or contact email: marketing@jocloud.com.
