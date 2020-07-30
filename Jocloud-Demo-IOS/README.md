*[简体中文](README.zh.md) | [English](README.md)*
## 1.OverView
This Demo mainly describes how to quickly integrate the Jocloud Audio/Video SDK and the RTS SDK to implement co-hosting in a room or co-hosting across rooms.

See the project modules `video_samechannel` and `video_crosschannel` for the implementation logic.

## 2.Quick Start
### 2.1 Prerequisites
You must meet the following conditions before starting development:
- XCode 10.0 +

- iOS 8.0 +

- iPhone device

### 2.2 Create a Jocloud Account and Get an AppID
- Valid Jocloud account (valid APPID)，See details in [APPID application](https://docs.aivacom.com/cloud/cn/platform/other/user_auth.html#e9a1b9e79bae-e4b88e-app-id) for details

### 2.3 Prepare the Development Environment
#### 2.3.1 Create a project
- Open Xcode，Click `Create a new Xcode project`。

- In the `Choose a template for your new project` interface，choose  `iOS -> Single View App`，click `Next`。

- In the  `Choose options for your new project` interface，enter `Product Name`、`Organization Identifier` etc，click `Next`。

- Select the storage path of the project，click `Create`。

#### 2.3.2 Integrate the SDK
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

### 2.4 Run the Demo
- Use Xcode to open the demo, connect the iPhone device, compile and run.


## 4.Contact Us
- For full API manual, refer to: [Developer Center](https://docs.aivacom.com/cn).
- For more demos, refer to:[SDK and Demo Download](https://docs.aivacom.com/download).
- If you have pre-sales consultation questions, you can call: +86-020-82120482 or contact email: marketing@aivacom.com.
