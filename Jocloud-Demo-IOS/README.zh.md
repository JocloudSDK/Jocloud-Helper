# IOS Samples for Jocloud Advanced Audio And Video Features
[简体中文](README.zh.md) | [English](README.md)
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
在开始开发之前您必须满足如下条件：
- XCode 10.0 +
- iOS 8.0 +
- 真机设备
- 有效的聚联云账号和有效的APPID，[注册聚联云账号](https://jocloud.com/cn/reg)、[APPID申请](https://docs.jocloud.com/cloud/cn/platform/other
/user_auth.html#e9a1b9e79bae-e4b88e-app-id)

### 2.2 运行示例程序
- 在终端中执行下面命令
```objc
    pod update
```
- 使用 Xcode 打开该Demo，连上iPhone设备，编译并运行。

## 3 FAQ
1. 集成 SDK
- 1.打开终端，在终端中打开项目目录，执行下面命令
```objc
    pod init
```
- 2.打开 `Podfile` 文件，输入下面内容

```xml
    source 'https://github.com/CocoaPods/Specs.git'
    source 'https://github.com/yyqapm/specs.git'
    target 'XXX' do
    pod 'thunder',      'x.y.z'   //x.y.z 为指定的SDK版本, 例如: 2.9.0 
```

- 3.在终端中执行下面命令
```objc
    pod update
```
- 4.在使用到SDK的Module中添加SDK要求的权限：

```xml
    <key>NSCameraUsageDescription</key>
    <string>我们需要您的摄像头权限</string>
    <key>NSMicrophoneUsageDescription</key>
    <string>我们需要您的麦克风权限</string>
```

## 4 联系我们
- 完整的 API 文档见[开发者中心](https://docs.jocloud.com/cn)。
- 相关Demo下载，请访问：[SDK及Demo下载](https://docs.jocloud.com/download)。
- 如果有售前咨询问题, 可以拨打电话:020-82120482 或 联系邮箱:marketing@jocloud.com。



