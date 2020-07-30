## 聊天室
[中文](README.zh.md) | [English](README.md)

该Demo演示了如何快速集成聚联云SDK，实现同房间聊天室功能。包含了以下功能：
- 加入/离开房间
- 发送消息
- 监听房间状态，消息
- 监听房间成员进入/离开，成员状态变化

### API调用流程图
![avatar](chat_room.png)

### API说明

（1）初始化HMR
 ```
    HMR.init(context, appId, appVersion, listener)
```
 （2）登入
 ```
   HMR.login(uid, region, token, completion);
 ```
 （3）登出
 ```
   HMR.logout();
 ```
（4）添加/移除监听房间属性，消息
```
    //添加
     HMR.getService(RoomService.class).addRoomEventListener(listener);

     //移除
     HMR.getService(RoomService.class).removeRoomEventListener(listener);
```
（5）添加/移除监听房间内成员属性，加入/离开，总人数变化
```
    //添加
    HMR.getService(RoomService.class).addMemberEventListener(listener);

    //移除
    HMR.getService(RoomService.class).removeMemberEventListener(listener);
```
（6）加入房间
```
   HMR.getService(RoomService.class).join(roomId, map, roomJoiningOptions, completion);
```

（7）离开房间
```
 HMR.getSrvice(RoomService.class).leave(roomId, completion);
```
（8）发送消息
```
 HMR.getService(RoomService.class).sendMessage(roomId, message, options, completion);
```
（9）查询房间内成员
```
 HMR.getService(RoomService.class).queryMembers(roomId, completion);
```