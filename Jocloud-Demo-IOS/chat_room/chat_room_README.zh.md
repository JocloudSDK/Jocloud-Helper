## 聊天室
*[简体中文](chat_room_README.zh.md) | [English](chat_room_README.md)*

该Demo演示了如何快速集成聚联云SDK，实现同房间聊天室功能。包含了以下功能：
- 加入/离开房间
- 发送消息
- 监听房间状态，消息
- 监听房间成员进入/离开，成员状态变化

> 集成SDK到APP，请参考：[SDK集成方法](http://test-docs.jocloud.com/cloud/cn/product_category/rtm_service/instant_messaging/integration_and_start/integration_and_start_ios.html)

> API开发手册，请访问： [iOS API](http://test-docs.jocloud.com/cloud/cn/product_category/rtm_service/instant_messaging/api/iOS/v3.1.3/category.html)

### API调用流程图
![avatar](chat_room.png)

### API说明

（1）初始化HMR

```objc
// appId 是服务平台为应用程序开发者签发的 AppId
// appVersion 为当前应用版本号
// self 为事件监听者，必须遵循 HMREventObserver 协议
[Hummer startWithAppId:appId appVersion:appVersion eventObserver:self];
```
 （2）登入
 
```objc
    [Hummer loginWithUid:uid region:region token:token completion:completion];
```

 （3）登出
 
```objc
    [Hummer logout];
```

（4）添加/移除监听房间属性，消息

```objc
    [[HMRRoomService instance] addRoomObserver:observer];
    [[HMRRoomService instance] removeRoomObserver:observer];
```

（5）添加/移除监听房间内成员属性，加入/离开，总人数变化

```objc
    [[HMRRoomService instance] addMemberObserver:observer];
    [[HMRRoomService instance] removeMemberObserver:observer];
```

（6）加入房间

```objc
   HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
   [[HMRRoomService instance] joinRoom:roomid withAppExtras:nil options:nil completion:completion];
```

（7）离开房间

```objc
   HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
   [[HMRRoomService instance]leaveRoom:roomid completion:completion];
```

（8）发送消息

```objc
   NSData *data = [content dataUsingEncoding:NSUTF8StringEncoding];
   HMRMessage *message = [HMRMessage messageWithType:nil content:data appExtras:nil];
   HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
   [[HMRRoomService instance] sendMessage:message withOptions:nil inRoom:roomid completion:^(HMRRequestId reqId, NSError *error) {
        if (error) {
            completionHandler(error);
        } else {
            completionHandler(nil);
        }
    }];
```

（9）查询房间内成员

```objc
   HMRRoomId *roomid = [HMRRoomId roomWithID:roomId];
   [[HMRRoomService instance] queryMembers:roomid completion:completion];
```

