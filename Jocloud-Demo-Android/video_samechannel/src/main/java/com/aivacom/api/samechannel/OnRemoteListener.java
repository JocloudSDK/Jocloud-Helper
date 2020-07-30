package com.aivacom.api.samechannel;

/**
 * Listener about the state of Remote User
 * 远程用户状态监听器
 */
public interface OnRemoteListener {
    void onJoinRoom(String uid);

    void onLeaveRoom(String uid);
}
