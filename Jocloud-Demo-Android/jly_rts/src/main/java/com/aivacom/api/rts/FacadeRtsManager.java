package com.aivacom.api.rts;

import android.content.Context;

import com.aivacom.api.jly_logcat.LogManager;
import com.hummer.Error;
import com.hummer.HMR;
import com.hummer.model.Message;
import com.hummer.model.MessagingOptions;
import com.hummer.model.RequestId;
import com.hummer.model.RoomId;
import com.hummer.rts.PeerService;
import com.hummer.rts.RoomService;

import java.util.HashMap;
import java.util.List;

/**
 * Created by zhouwen on 2020/5/28.
 */
public class FacadeRtsManager {

    private static FacadeRtsManager sFacadeRtsManager;

    public static FacadeRtsManager getIns() {
        if (sFacadeRtsManager == null) {
            synchronized (FacadeRtsManager.class) {
                if (sFacadeRtsManager == null) {
                    sFacadeRtsManager = new FacadeRtsManager();
                }
            }
        }
        return sFacadeRtsManager;
    }

    /**
     * return version code of HMR
     *
     * @return version
     */
    public String getVersion() {
        return HMR.getVersion();
    }

    /**
     * init rts SDK
     * 初始化RTS SDK
     *
     * @param appContext context
     * @param appId      appid
     * @param appVersion version
     */
    public void initRtsSdk(Context appContext, long appId, String appVersion) {
        logD("initRtsSdk init appId " + appId + " appVersion " + appVersion);
        HMR.init(appContext, appId, appVersion, new HMR.HummerEventListener() {
            @Override
            public void onHummerStateChanged(HMR.State fromState, HMR.State toState,
                                             String reason) {
                logD("initRtsSdk onHummerStateChanged fromState " + fromState + " toState " + toState +
                        " reason " + reason);
            }

            @Override
            public void onHummerKicked(int code, String description) {
                logD("initRtsSdk onHummerKicked code " + code + " description " + description);
            }

            @Override
            public void onHummerPreviousTokenExpired() {
                logD("initRtsSdk onHummerPreviousTokenExpired");
            }
        });
    }

    /**
     * login
     * 登录接口
     *
     * @param uid    uid
     * @param region region
     * @param token  token
     */
    public void login(long uid, String region, String token, final LoginCallBack loginCallBack) {
        logD("login uid " + uid + " region " + region + " token " + token);
        HMR.login(uid, region, token, new HMR.Completion() {
            @Override
            public void onSuccess(RequestId requestId) {
                logD("login onSuccess requestId " + requestId);
                if (loginCallBack != null) {
                    loginCallBack.onSuccess(requestId);
                }

            }

            @Override
            public void onFailed(RequestId requestId, Error err) {
                logE("login onFailed requestId " + requestId + " err " + err);
                if (loginCallBack != null) {
                    loginCallBack.onFailed(requestId, err);
                }
            }

        });
    }

    public interface LoginCallBack {
        void onSuccess(RequestId requestId);

        void onFailed(RequestId requestId, Error err);
    }

    /**
     * send p2p messages
     * 发送点对点信令消息
     *
     * @param uid     uid
     * @param message msg
     */
    public void sendPeerMsg(String uid, Message message) {
//        Message message = new Message("10086", text.getBytes(), new HashMap<String, String>(0));
        logD("sendPeerMsg sendMessage uid " + uid);
        HMR.getService(PeerService.class)
                .sendMessage(Long.valueOf(uid), message, new MessagingOptions(),
                        new HMR.Completion() {
                            @Override
                            public void onSuccess(RequestId requestId) {
                                logD("sendPeerMsg onSuccess requestId " + requestId);
                            }

                            @Override
                            public void onFailed(RequestId requestId, Error err) {
                                logE("sendPeerMsg onFailed requestId " + requestId + " err " + err);
                            }
                        });
    }

    /**
     * send p2p messages with send callback
     * 发送点对点信令消息(带发送回调)
     *
     * @param uid        uid
     * @param message    msg
     * @param completion completion callback
     */
    public void sendPeerMsg(String uid, Message message, HMR.Completion completion) {
//        Message message = new Message("10086", text.getBytes(), new HashMap<String, String>(0));
        logD("sendPeerMsg sendMessage uid " + uid);
        HMR.getService(PeerService.class).sendMessage(Long.valueOf(uid), message,
                new MessagingOptions(), completion);
    }

    /**
     * send message in the room
     * 发送房间内发送消息
     *
     * @param roomId  roomId
     * @param message message
     */
    public void sendRoomMsg(RoomId roomId, Message message) {
        logD("sendPeerMsg sendRoomMsg roomId " + roomId);
        HMR.getService(RoomService.class)
                .sendMessage(roomId, message, new MessagingOptions(), new HMR.Completion() {
                    @Override
                    public void onSuccess(RequestId requestId) {
                        logD("sendPeerMsg onSuccess requestId " + requestId);
                    }

                    @Override
                    public void onFailed(RequestId requestId, Error err) {
                        logE("sendRoomMsg onFailed requestId " + requestId + " err " + err);
                    }
                });
    }

    /**
     * Add message listener
     * 添加消息监听
     *
     * @param listener listener
     */
    public void addMsgListener(PeerService.EventListener listener) {
        HMR.getService(PeerService.class).addEventListener(listener);
    }

    /**
     * remove message listener
     * 移除消息监听
     *
     * @param listener listener
     */
    public void removeMsgListener(PeerService.EventListener listener) {
        HMR.getService(PeerService.class).removeEventListener(listener);
    }

    /**
     * logout
     * This operation should be performed before the actual user logout of the business
     * 登出用户上下文
     * 该操作应该在业务进行实际的用户注销（退出登录）之前执行
     */
    public void logout() {
        logD("logout");
        HMR.logout();
    }

    /**
     * join room
     * 加入房间
     *
     * @param roomId room id
     */
    public void join(RoomId roomId, final HMR.Completion completion) {
        logD("join roomId " + roomId);
        HMR.getService(RoomService.class)
                .join(roomId, new HashMap<String, String>(0), null, new HMR.Completion() {
                    @Override
                    public void onSuccess(RequestId requestId) {
                        logD("join onSuccess requestId " + requestId);
                        if (completion != null) {
                            completion.onSuccess(requestId);
                        }
                    }

                    @Override
                    public void onFailed(RequestId requestId, Error err) {
                        logE("join onFailed requestId " + requestId + " err " + err);
                        if (completion != null) {
                            completion.onFailed(requestId, err);
                        }
                    }
                });
    }

    /**
     * leave room
     * 离开房间
     *
     * @param roomId room id
     */
    public void leave(RoomId roomId, final HMR.Completion completion) {
        logD("leave roomId " + roomId);
        HMR.getService(RoomService.class).leave(roomId, new HMR.Completion() {
            @Override
            public void onSuccess(RequestId requestId) {
                logD("leave onSuccess requestId " + requestId);
                if (completion != null) {
                    completion.onSuccess(requestId);
                }
            }

            @Override
            public void onFailed(RequestId requestId, Error err) {
                logE("leave onFailed requestId " + requestId + " err " + err);
                if (completion != null) {
                    completion.onFailed(requestId, err);
                }
            }
        });
    }

    public void queryMembers(RoomId roomId, HMR.CompletionArg<List<Long>> completion) {
        HMR.getService(RoomService.class).queryMembers(roomId, completion);
    }

    public void addRoomEventListener(RoomService.RoomEventListener listener) {
        HMR.getService(RoomService.class).addRoomEventListener(listener);
    }

    public void removeRoomEventListener(RoomService.RoomEventListener listener) {
        HMR.getService(RoomService.class).removeRoomEventListener(listener);
    }

    public void addMemberEventListener(RoomService.MemberEventListener listener) {
        HMR.getService(RoomService.class).addMemberEventListener(listener);
    }

    public void removeMemberEventListener(RoomService.MemberEventListener listener) {
        HMR.getService(RoomService.class).removeMemberEventListener(listener);
    }

    public void sendMessage(RoomId roomId, Message message, MessagingOptions options, HMR.Completion completion) {
        HMR.getService(RoomService.class).sendMessage(roomId, message, options, completion);
    }


    private static final String HMR_LOG_TAG = "HMR";

    private void logD(String info) {
        LogManager.getInstance().logI(HMR_LOG_TAG, info);
    }

    private void logW(String info) {
        LogManager.getInstance().logW(HMR_LOG_TAG, info);
    }

    private void logE(String info) {
        LogManager.getInstance().logE(HMR_LOG_TAG, info);
    }
}
