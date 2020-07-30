package com.aivacom.api.rtc;


import android.content.Context;
import android.text.TextUtils;
import android.util.Log;
import android.view.View;

import androidx.annotation.NonNull;
import androidx.lifecycle.MutableLiveData;

import com.aivacom.api.jly_logcat.LogManager;
import com.thunder.livesdk.IThunderLogCallback;
import com.thunder.livesdk.IThunderMediaExtraInfoCallback;
import com.thunder.livesdk.LiveTranscoding;
import com.thunder.livesdk.ThunderBoltImage;
import com.thunder.livesdk.ThunderCustomVideoSource;
import com.thunder.livesdk.ThunderEngine;
import com.thunder.livesdk.ThunderEventHandler;
import com.thunder.livesdk.ThunderNotification;
import com.thunder.livesdk.ThunderRtcConstant;
import com.thunder.livesdk.ThunderVideoCanvas;
import com.thunder.livesdk.ThunderVideoEncoderConfiguration;
import com.thunder.livesdk.video.ThunderPlayerView;
import com.thunder.livesdk.video.ThunderPreviewView;

import java.nio.ByteBuffer;
import java.util.Arrays;
import java.util.List;
import java.util.concurrent.CopyOnWriteArrayList;


public class FacadeRtcManager {

    public static final String TAG = FacadeRtcManager.class.getSimpleName();

    public static final int ERROR_UN_INI = -1000;
    public static final int ERROR_DISABLE_VIDEO = -1001;
    public static final int ERROR_DISABLE_AUDIO = -1002;

    //The state of push stream to CDN
    //推流状态
    public volatile static Integer publishStreamToCDNStatus = null;

    //is pushing stream to CDN
    //是否正在推流
    public volatile static boolean isPublishStreamToCDN = false;

    //Whether local users join the room
    //本地用户是否加入房间
    public MutableLiveData<Boolean> isJoinRoom = new MutableLiveData<>();

    //Whether the front camera, if null means not available
    //是否前置摄像头，如果null表示不可用
    public MutableLiveData<Boolean> mIsFrontCamera = new MutableLiveData<>();

    //is Front Camera Last
    //上一次的
    public Boolean mIsFrontCameraLast = true;

    //Whether the local voice is turned off, if null means unavailable
    //本地语音是否关闭，如果null表示不可用
    public MutableLiveData<Boolean> isLocalAudioStreamStop = new MutableLiveData<>();

    //Whether the local video is closed, if null means unavailable
    //本地视频是否关闭，如果null表示不可用
    public MutableLiveData<Boolean> isLocalVidioStreamStop = new MutableLiveData<>();

    //current token
    //我当前的Token
    private byte[] token;

    //current roomId
    //我当前的RoomId
    private String roomId;

    //current uid
    //我当前的UID
    private String uid;

    private static volatile FacadeRtcManager instance;
    private ThunderEngine thunderEngine = null;
    private Observer observer;
    private JoinThunderRoomObserver joinThunderRoomObserver = null;
    private Context context;

    private FacadeRtcManager() {
    }

    public synchronized static FacadeRtcManager getInstance() {
        if (instance == null) {
            synchronized (FacadeRtcManager.class) {
                if (instance == null) {
                    instance = new FacadeRtcManager();
                }
            }
        }
        return instance;
    }


    public byte[] getToken() {
        return token;
    }

    public String getRoomId() {
        return roomId;
    }

    public String getUid() {
        return uid;
    }

    /**
     * init
     *
     * @param context applicationContext
     * @param appId   appId
     * @param sceneId sceneId
     * @param handler thunder event callback
     * @return FacadeRtcManager
     */
    public FacadeRtcManager init(Context context, String appId, long sceneId, ThunderEventHandler handler) {
        this.context = context;

        isJoinRoom.postValue(false);
        mIsFrontCamera.postValue(null);
        isLocalAudioStreamStop.postValue(null);
        isLocalVidioStreamStop.postValue(null);

        if (thunderEngine != null) {
            return this;
        }
        thunderEngine = ThunderEngine.createEngine(context, appId, sceneId, handler);
        thunderLogD("createEngine appId:" + appId + " sceneId:" + sceneId);
        return this;
    }


    /**
     * create engine
     *
     * @param appId   appId
     * @param sceneId sceneId
     * @param handler thunder event callback
     */
    public void createEngine(String appId, long sceneId, ThunderEventHandler handler) {
        if (thunderEngine != null) {
            return;
        }
        thunderLogD("createEngine appId:" + appId + " sceneId:" + sceneId);
        thunderEngine = ThunderEngine.createEngine(context, appId, sceneId, handler);
        Log.i(TAG, "createEngine");
    }

    /**
     * destroy engine
     */
    public void destroyEngine() {
        if (thunderEngine == null) {
            return;
        }

        ThunderEngine.destroyEngine();
        thunderEngine = null;
        thunderLogD("destroyEngine", true);
    }

    /**
     * set thunder room config
     *
     * @param mediaMode Media mode: pure audio or audio and video {@link ThunderRtcConstant.ThunderRtcProfile}
     * @param roomMode  roomMode {@link ThunderRtcConstant.RoomConfig}
     */
    public void setRoomConfig(int mediaMode, int roomMode) {
        //设置频道属性
        thunderLogD("setRoomConfig setMediaMode " + mediaMode);
        thunderLogD("setRoomConfig setRoomMode " + mediaMode);
        thunderEngine.setMediaMode(mediaMode);
        thunderEngine.setRoomMode(roomMode);
    }

    /**
     * set thunder room config
     *
     * @param mPreviewContainer preview view
     * @param uid               user id
     * @param publishMode       publishMode {@link ThunderRtcConstant.ThunderPublishVideoMode}
     */
    public void startPush(ThunderPreviewView mPreviewContainer, String uid, int publishMode) {

        //开启视频模块
//        thunderEngine.enableVideoEngine();
        //Set local view
        setVideoEncoderConfig(publishMode);
        //设置本地预览视图
        //Set local view display mode
        ThunderVideoCanvas mPreviewView = new ThunderVideoCanvas(mPreviewContainer,
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT, uid);
        thunderLogD("startPush setLocalVideoCanvas");
        thunderEngine.setLocalVideoCanvas(mPreviewView);
        //设置视频模式
        thunderLogD("startPush setLocalCanvasScaleMode");
        thunderEngine.setLocalCanvasScaleMode(
                ThunderRtcConstant.ThunderVideoRenderMode.THUNDER_RENDER_MODE_CLIP_TO_BOUNDS);
        //开启预览
        //enable video preview
        thunderLogD("startPush startVideoPreview");
        thunderEngine.startVideoPreview();
        //开播 音频
        //enabling sending of local audio
        thunderLogD("startPush stopLocalAudioStream");
        thunderEngine.stopLocalAudioStream(false);
        //开播 视频
        //enable sending of local video stream
        thunderLogD("startPush stopLocalVideoStream");
        thunderEngine.stopLocalVideoStream(false);
    }

    /**
     * set thunder video encoder config
     *
     * @param publishMode publishMode {@link ThunderRtcConstant.ThunderPublishVideoMode}
     */
    public void setVideoEncoderConfig(int publishMode) {
        ThunderVideoEncoderConfiguration vConfig = new ThunderVideoEncoderConfiguration();
        vConfig.publishMode = publishMode;
        vConfig.playType = ThunderRtcConstant.ThunderPublishPlayType.THUNDERPUBLISH_PLAY_INTERACT;
        thunderLogD("setVideoEncoderConfig setVideoEncoderConfig");
        thunderEngine.setVideoEncoderConfig(vConfig);
    }

    /**
     * stop push video and audio steam
     */
    public void stopPush() {
        thunderLogD("stopPush stopLocalVideoStream true");
        thunderLogD("stopPush stopLocalAudioStream true");
        thunderLogD("stopPush stopVideoPreview");
        thunderEngine.stopLocalVideoStream(true);
        thunderEngine.stopLocalAudioStream(true);
        thunderEngine.stopVideoPreview();
    }


    /**
     * prepare remote user view
     *
     * @param thunderPlayerView preview of remote user
     * @param remoteUid         remote user id
     */
    public void prepareRemoteView(ThunderPlayerView thunderPlayerView, String remoteUid) {
        ThunderVideoCanvas mPlayView = new ThunderVideoCanvas(thunderPlayerView,
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT, remoteUid);
        thunderEngine.setRemoteVideoCanvas(mPlayView);
        thunderLogD("prepareRemoteView setRemoteCanvasScaleMode");
        int code = thunderEngine.setRemoteCanvasScaleMode(remoteUid,
                ThunderRtcConstant.ThunderVideoRenderMode.THUNDER_RENDER_MODE_CLIP_TO_BOUNDS);
        Log.i(TAG, "prepareRemoteView: " + code);
    }

    /**
     * set thunder log call back
     *
     * @param callback callback
     */
    public void setLogCallback(IThunderLogCallback callback) {
        thunderLogD("setLogCallback");
        ThunderEngine.setLogCallback(callback);
    }

    /**
     * Join the room
     * 加入房间
     *
     * @param token  token
     * @param roomId room id
     * @param uid    user id
     * @return 0:success {@link ThunderRtcConstant.ThunderRet}
     */
    public int joinRoom(byte[] token, String roomId, String uid) {
        if (thunderEngine == null) {
            Log.i(TAG, "joinRoom 未初始化");
            return ERROR_UN_INI;
        }

        if (TextUtils.isEmpty(roomId)) {
            Log.i(TAG, "joinRoom roomId empty");
            return ERROR_UN_INI;
        }

        if (TextUtils.isEmpty(uid)) {
            Log.i(TAG, "joinRoom uid empty");
            return ERROR_UN_INI;
        }

        this.token = token;
        this.roomId = roomId;
        this.uid = uid;
        thunderLogD("joinRoom");
        int result = thunderEngine.joinRoom(token, roomId, uid);
        Log.i(TAG, "joinRoom：" + "token=" + Arrays.toString(token) + " roomId=" + roomId
                + " uid=" + uid + " result=" + result);
        return result;
    }

    /**
     * stop local audio stream
     *
     * @param isStop isStop
     */
    public void stopLocalAudioStream(boolean isStop) {
        thunderEngine.stopLocalAudioStream(isStop);
    }

    /**
     * Subscription across rooms
     * 跨房间订阅
     *
     * @param roomId room id
     * @param uid    user id
     * @return 0:success ,{@link ThunderRtcConstant.ThunderRet}
     */
    public int addSubscribe(String roomId, String uid) {
        if (thunderEngine == null) {
            Log.i(TAG, "addSubscribe 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("addSubscribe roomId=" + roomId + " uid=" + uid, true);
        int result = thunderEngine.addSubscribe(roomId, uid);
        Log.i(TAG, "addSubscribe roomId=" + roomId + " uid=" + uid + " result=" + result);
        return result;
    }

    /**
     * unsubscribe
     * 取消订阅
     *
     * @param roomId room id
     * @param uid    user id
     * @return 0:success ,{@link ThunderRtcConstant.ThunderRet}
     */
    public int removeSubscribe(String roomId, String uid) {
        if (thunderEngine == null) {
            Log.i(TAG, "removeSubscribe 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("removeSubscribe roomId=" + roomId + " uid=" + uid, true);
        int result = thunderEngine.removeSubscribe(roomId, uid);
        Log.i(TAG, "removeSubscribe roomId=" + roomId + " uid=" + uid + " result=" + result);
        return result;
    }

    /**
     * set video watermark
     * 设置水印
     *
     * @param watermark watermark
     */
    public void setVideoWatermark(ThunderBoltImage watermark) {
        if (thunderEngine != null) {
            thunderLogD("setVideoWatermark");
            thunderEngine.setVideoWatermark(watermark);
        }
    }

    /**
     * Leave the room
     * 离开房间
     *
     * @return 0:success ,{@link ThunderRtcConstant.ThunderRet}
     */
    public int leaveRoom() {
        if (thunderEngine == null) {
            Log.i(TAG, "leaveRoom 未初始化");
            return 0;
        }

        int result = 0;
        if (isJoinRoom.getValue()) {
            thunderLogD("leaveRoom");
            thunderEngine.setLocalVideoCanvas(null);
            thunderEngine.setRemoteVideoCanvas(null);
            result = thunderEngine.leaveRoom();
        }
        Log.i(TAG,
                "leaveRoom：" + "roomId=" + roomId + " uid=" + uid + " result=" + result);
        return result;
    }

    /**
     * set transcoding tasks
     * 添加/更新转码任务
     *
     * @param taskId      task id
     * @param transcoding transcoding
     */
    public void setLiveTranscodingTask(String taskId, LiveTranscoding transcoding) {
        if (thunderEngine != null) {
            thunderLogD("setLiveTranscodingTask");
            thunderEngine.setLiveTranscodingTask(taskId, transcoding);
        }
    }

    /**
     * Set up a custom video source
     * 设置外部视频源，自定义视频源（屏幕分享等）
     *
     * @param videoSource videoSource
     */
    public void setCustomVideoSource(ThunderCustomVideoSource videoSource) {
        if (thunderEngine == null) {
            Log.i(TAG, "setCustomVideoSource 未初始化");
            return;
        }
        thunderLogD("setCustomVideoSource");
        thunderEngine.setCustomVideoSource(videoSource);
    }

    /**
     * Add push address of transcode stream
     * 添加转码流的推流地址
     *
     * @param taskId task id
     * @param url    url
     * @return 0:success, {@link ThunderRtcConstant.ThunderRet}
     */
    public int addPublishTranscodingStreamUrl(String taskId, String url) {
        if (thunderEngine == null) {
            Log.i(TAG, "addPublishTranscodingStreamUrl 未初始化");
            return ERROR_UN_INI;
        }

        isPublishStreamToCDN = true;
        thunderLogD("addPublishTranscodingStreamUrl");
        return thunderEngine.addPublishTranscodingStreamUrl(taskId, url);
    }

    /**
     * Delete the push address of the transcoded stream
     * 删除转码流的推流地址
     *
     * @param taskId task id
     * @param url    url
     * @return 0:success, {@link ThunderRtcConstant.ThunderRet}
     */
    public int removePublishTranscodingStreamUrl(String taskId, String url) {
        if (thunderEngine == null) {
            Log.i(TAG, "removePublishTranscodingStreamUrl 未初始化");
            return ERROR_UN_INI;
        }

        isPublishStreamToCDN = false;
        thunderLogD("removePublishTranscodingStreamUrl");
        return thunderEngine.removePublishTranscodingStreamUrl(taskId, url);
    }

    /**
     * set thunder log path
     *
     * @param filePath path of the log ,dir need to be exist
     */
    public FacadeRtcManager setLogFilePath(String filePath) {
        if (thunderEngine != null) {
            thunderLogD("setLogFilePath");
            thunderEngine.setLogFilePath(filePath);
        }
        return this;
    }

    /**
     * @return the version of thunder
     */
    public String getVersion() {
        return ThunderEngine.getVersion();
    }

    public synchronized void sendMediaExtraInfo(byte[] msgData) {
        if (thunderEngine != null) {
            ByteBuffer extraInfo = ByteBuffer.wrap(msgData);
            thunderLogD("sendMediaExtraInfo");
            thunderEngine.sendMediaExtraInfo(extraInfo, extraInfo.remaining());
        }
    }

    /**
     * send extra media messages
     * 发送媒体次要信息
     *
     * @param callback callback
     */
    public void setMediaExtraInfoCallback(IThunderMediaExtraInfoCallback callback) {
        if (thunderEngine != null) {
            thunderLogD("setMediaExtraInfoCallback");
            thunderEngine.setMediaExtraInfoCallback(callback);
        }
    }

    public void setVideoCaptureOrientation(int orientation) {
        if (thunderEngine != null) {
            thunderLogD("setVideoCaptureOrientation");
            thunderEngine.setVideoCaptureOrientation(orientation);
        }
    }

    public void setLocalCanvasScaleMode(int mode) {
        if (thunderEngine != null) {
            thunderLogD("setLocalCanvasScaleMode");
            thunderEngine.setLocalCanvasScaleMode(mode);
        }
    }

    public void setRemoteCanvasScaleMode(String uid, int mode) {
        if (thunderEngine != null) {
            thunderLogD("setRemoteCanvasScaleMode");
            thunderEngine.setRemoteCanvasScaleMode(uid, mode);
        }
    }

    public void startPreview(ThunderPreviewView mPreviewContainer, String uid){
        if (thunderEngine!=null) {
            //Set local view display mode
            ThunderVideoCanvas mPreviewView = new ThunderVideoCanvas(mPreviewContainer,
                    ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT,
                    uid);
            thunderLogD("startPush setLocalVideoCanvas");
            thunderEngine.setLocalVideoCanvas(mPreviewView);
            //设置视频模式
            thunderLogD("startPush setLocalCanvasScaleMode");
            thunderEngine.setLocalCanvasScaleMode(
                    ThunderRtcConstant.ThunderVideoRenderMode.THUNDER_RENDER_MODE_CLIP_TO_BOUNDS);
            //开启预览
            //enable video preview
            thunderLogD("startPush startVideoPreview");
            thunderEngine.startVideoPreview();
        }
    }

    public void setPreview(ThunderPreviewView mPreviewContainer, String uid){
        if (thunderEngine!=null) {
            //Set local view display mode
            ThunderVideoCanvas mPreviewView = new ThunderVideoCanvas(mPreviewContainer,
                    ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_ASPECT_FIT,
                    uid);
            thunderLogD("startPush setLocalVideoCanvas");
            thunderEngine.setLocalVideoCanvas(mPreviewView);
            //设置视频模式
            thunderLogD("startPush setLocalCanvasScaleMode");
            thunderEngine.setLocalCanvasScaleMode(
                    ThunderRtcConstant.ThunderVideoRenderMode.THUNDER_RENDER_MODE_CLIP_TO_BOUNDS);
        }
    }


    private List<ThunderEventHandler> myThunderEventHandlers = new CopyOnWriteArrayList<>();

    /**
     * register thunder event callback
     */
    public void register(ThunderEventHandler myThunderEventHandler) {
        this.myThunderEventHandlers.add(myThunderEventHandler);
    }

    /**
     * unregister thunder event callback
     */
    public void unRegister(ThunderEventHandler myThunderEventHandler) {
        this.myThunderEventHandlers.remove(myThunderEventHandler);
    }

    public ThunderEventHandler getThunderEventHandler() {
        return mThunderEventHandler;
    }

    private ThunderEventHandler mThunderEventHandler = new ThunderEventHandler() {

        /**
         * SDK error message callback
         */
        @Override
        public void onError(int error) {
            thunderLogE("onError" + error, true);
        }

        /**
         * join room success callback
         */
        @Override
        public void onJoinRoomSuccess(String room, String uid, int elapsed) {
            thunderLogD("onJoinRoomSuccess: room=" + room + " uid =" + uid + " elapsed =" + elapsed, true);

            mIsFrontCamera.postValue(null);
            isLocalAudioStreamStop.postValue(null);
            isLocalVidioStreamStop.postValue(null);
            isJoinRoom.postValue(true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onJoinRoomSuccess(room, uid, elapsed);
            }

            if (FacadeRtcManager.getInstance().getObserver() != null) {
                FacadeRtcManager.getInstance().getObserver().onJoinRoomSuccess(room, uid, elapsed);
            }
            if (FacadeRtcManager.getInstance().getJoinThunderRoomObserver() != null) {
                FacadeRtcManager.getInstance().getJoinThunderRoomObserver().onJoinRoomSuccess(room, uid, elapsed);
            }
        }

        /**
         * leave room callback
         * */
        @Override
        public void onLeaveRoom(ThunderEventHandler.RoomStats status) {
            thunderLogD("onLeaveRoom: " + status.temp, true);

            mIsFrontCamera.postValue(null);
            isLocalAudioStreamStop.postValue(null);
            isLocalVidioStreamStop.postValue(null);
            FacadeRtcManager.this.token = null;
            FacadeRtcManager.this.roomId = null;
            FacadeRtcManager.this.uid = null;
            isJoinRoom.postValue(false);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onLeaveRoom(status);
            }

            if (FacadeRtcManager.getInstance().getObserver() != null) {
                FacadeRtcManager.getInstance().getObserver().onLeaveRoom(status);
            }
        }

        /**
         * Business authentication result callback
         * */
        @Override
        public void onBizAuthResult(boolean bPublish, int result) {
            thunderLogD("onBizAuthResult: bPublish = " + bPublish + "::::result =" + result, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onBizAuthResult(bPublish, result);
            }
        }

        /**
         * Sdk authentication result callback
         * */
        @Override
        public void onSdkAuthResult(int result) {
            thunderLogD("onSdkAuthResult: result = " + result, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onSdkAuthResult(result);
            }
        }

        /**
         * User ban notification callback
         * */
        @Override
        public void onUserBanned(boolean status) {
            thunderLogD("onUserBanned: status = " + status, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onUserBanned(status);
            }
        }

        /**
         * user join room callback
         * */
        @Override
        public void onUserJoined(String uid, int elapsed) {
            thunderLogD("onUserJoined: uid = " + uid + "::::elapsed =" + elapsed, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onUserJoined(uid, elapsed);
            }
        }

        /**
         * User offline callback
         * */
        @Override
        public void onUserOffline(String uid, int reason) {
            thunderLogD("onUserOffline: uid = " + uid + "::::reason =" + reason, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onUserOffline(uid, reason);
            }
        }

        /**
         * token will expire callback
         * */
        @Override
        public void onTokenWillExpire(byte[] token) {
            thunderLogD("onTokenWillExpire: token = " + token, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onTokenWillExpire(token);
            }
        }

        /**
         * token expire callback
         * */
        @Override
        public void onTokenRequested() {
            thunderLogD("onTokenRequested: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onTokenRequested();
            }
        }

        /**
         * Network quality callback
         * */
        @Override
        public void onNetworkQuality(String uid, int txQuality, int rxQuality) {
            thunderLogD("onNetworkQuality: uid = " + uid + ":::txQuality=" + txQuality +
                    ":::rxQuality=" + rxQuality, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onNetworkQuality(uid, txQuality, rxQuality);
            }

            if (FacadeRtcManager.getInstance().getObserver() != null) {
                FacadeRtcManager.getInstance().getObserver().onNetworkQuality(uid, txQuality, rxQuality);
            }
        }

        /**
         * Upstream and downstream traffic notification (periodic notification, every 2 seconds),
         * call when joinRoom is call
         * */
        @Override
        public void onRoomStats(ThunderNotification.RoomStats stats) {
            thunderLogD("onRoomStats: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRoomStats(stats);
            }

            if (FacadeRtcManager.getInstance().getObserver() != null) {
                FacadeRtcManager.getInstance().getObserver().onRoomStats(stats);
            }
        }

        @Override
        public void onLocalVideoStats(LocalVideoStats stats) {
            super.onLocalVideoStats(stats);
            if (FacadeRtcManager.getInstance().getObserver() != null) {
                FacadeRtcManager.getInstance().getObserver().onLocalVideoStats(stats);
            }
        }

        /**
         * Play volume callback
         * */
        @Override
        public void onPlayVolumeIndication(ThunderEventHandler.AudioVolumeInfo[] speakers,
                                           int totalVolume) {
            thunderLogD("onPlayVolumeIndication: totalVolume = " + totalVolume, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onPlayVolumeIndication(speakers, totalVolume);
            }
        }

        /**
         * Collection volume callback
         * */
        @Override
        public void onCaptureVolumeIndication(int totalVolume, int cpt, int micVolume) {
            thunderLogD("onCaptureVolumeIndication: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i)
                        .onCaptureVolumeIndication(totalVolume, cpt, micVolume);
            }
        }

        /**
         * Audio quality callback
         * */
        @Override
        public void onAudioQuality(String uid, int quality, short delay, short lost) {
            thunderLogD("onAudioQuality: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioQuality(uid, quality, delay, lost);
            }
        }

        /**
         * disconnection from the server callback
         * */
        @Override
        public void onConnectionLost() {
            thunderLogD("onConnectionLost: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onConnectionLost();
            }
        }

        @Override
        public void onConnectionInterrupted() {
            thunderLogD("onConnectionInterrupted: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onConnectionInterrupted();
            }
        }

        @Override
        public void onAudioRouteChanged(int routing) {
            thunderLogD("onAudioRouteChanged: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioRouteChanged(routing);
            }
        }

        /**
         * audio play data callback
         * */
        @Override
        public void onAudioPlayData(byte[] data, long cpt, long pts, String uid, long duration) {
            thunderLogD("onAudioPlayData: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioPlayData(data, cpt, pts, uid, duration);
            }
        }

        /**
         * audio play data callback
         * */
        @Override
        public void onAudioPlaySpectrumData(byte[] data) {
            thunderLogD("onAudioPlaySpectrumData: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioPlaySpectrumData(data);
            }
        }

        /**
         * Receive custom broadcast message callback
         */
        @Override
        public void onRecvUserAppMsgData(byte[] data, String uid) {
            thunderLogD("onRecvUserAppMsgData: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRecvUserAppMsgData(data, uid);
            }
        }

        /**
         * Custom broadcast message sending failure callback
         * */
        @Override
        public void onSendAppMsgDataFailedStatus(int status) {
            thunderLogD("onSendAppMsgDataFailedStatus: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onSendAppMsgDataFailedStatus(status);
            }
        }

        /**
         * Successfully sent back the first frame of local audio. (As the anchor,
         * this callback is received after successfully uploading the first frame of audio)
         * */
        @Override
        public void onFirstLocalAudioFrameSent(int elapsed) {
            thunderLogD("onFirstLocalAudioFrameSent: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onFirstLocalAudioFrameSent(elapsed);
            }
        }

        /**
         * Successfully sent back the first frame of local video. (As the anchor,
         * this callback is received after successfully uploading the first frame of video)
         * */
        @Override
        public void onFirstLocalVideoFrameSent(int elapsed) {
            thunderLogD("onFirstLocalVideoFrameSent: ", true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onFirstLocalVideoFrameSent(elapsed);
            }
        }

        /**
         * Cdn push stream result callback, which will be triggered when the push stream state changes.
         * */
        @Override
        public void onPublishStreamToCDNStatus(String url, int errorCode) {
            thunderLogD("onPublishStreamToCDNStatus: ", true);

            publishStreamToCDNStatus = errorCode;
            if (publishStreamToCDNStatus ==
                    ThunderRtcConstant.ThunderPublishCDNErrorCode.THUNDER_PUBLISH_CDN_ERR_SUCCESS) {
                isPublishStreamToCDN = true;
            } else {
                isPublishStreamToCDN = false;
            }

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onPublishStreamToCDNStatus(url, errorCode);
            }

            if (FacadeRtcManager.getInstance().getObserver() != null) {
                FacadeRtcManager.getInstance().getObserver().onPublishStreamToCDNStatus(url, errorCode);
            }
        }

        /**
         * Network connection type change callback
         * */
        @Override
        public void onNetworkTypeChanged(int type) {
            thunderLogD("onNetworkTypeChanged: " + type, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onNetworkTypeChanged(type);
            }
        }

        /**
         * Callback to the server network connection status
         * */
        @Override
        public void onConnectionStatus(int status) {
            thunderLogD("onConnectionStatus: " + status, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onConnectionStatus(status);
            }
        }

        /**
         * Audio equipment collection status change callback
         * */
        @Override
        public void onAudioCaptureStatus(int status) {
            thunderLogD("onAudioCaptureStatus: " + status, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onAudioCaptureStatus(status);
            }
        }

        /**
         * Camera collection status change callback
         * */
        @Override
        public void onVideoCaptureStatus(int status) {
            thunderLogD("onVideoCaptureStatus: " + status, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onVideoCaptureStatus(status);
            }
        }

        /**
         * Stop/start notification for remote user audio stream
         * */
        @Override
        public void onRemoteAudioStopped(String uid, boolean stop) {
            thunderLogD("onRemoteAudioStopped: " + "uid=" + uid + " stop=" + stop, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRemoteAudioStopped(uid, stop);
            }

            if (FacadeRtcManager.getInstance().getObserver() != null) {
                FacadeRtcManager.getInstance().getObserver().onRemoteAudioStopped(uid, stop);
            }
        }

        /**
         * Video streaming stop/start notification for remote users
         * */
        @Override
        public void onRemoteVideoStopped(String uid, boolean stop) {
            thunderLogD("onRemoteVideoStopped: " + "uid=" + uid + " stop=" + stop, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRemoteVideoStopped(uid, stop);
            }

            if (FacadeRtcManager.getInstance().getObserver() != null) {
                FacadeRtcManager.getInstance().getObserver().onRemoteVideoStopped(uid, stop);
            }
        }

        /**
         * The first frame callback of the far-end video is displayed
         * */
        @Override
        public void onRemoteVideoPlay(String uid, int width, int height, int elapsed) {
            thunderLogD("onRemoteVideoPlay: " + "uid=" + uid + " width=" + width + " height=" + height +
                    " elapsed=" + elapsed, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onRemoteVideoPlay(uid, width, height, elapsed);
            }
        }

        /**
         * Callback for changing the resolution of the remote video
         * */
        @Override
        public void onVideoSizeChanged(String uid, int width, int height, int rotation) {
            thunderLogD("onVideoSizeChanged: " + "uid=" + uid + " width=" + width + " height=" +
                    height + " rotation=" + rotation, true);

            for (int i = 0; i < myThunderEventHandlers.size(); i++) {
                myThunderEventHandlers.get(i).onVideoSizeChanged(uid, width, height, rotation);
            }

            if (FacadeRtcManager.getInstance().getObserver() != null) {
                FacadeRtcManager.getInstance().getObserver().onVideoSizeChanged(uid, width, height, rotation);
            }
        }
    };


    /**
     * Set SDK media mode
     * 设置sdk媒体模式
     *
     * @param mode mode
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int setMediaMode(int mode) {
        if (thunderEngine == null) {
            Log.i(TAG, "setMediaMode 未初始化");
            return ERROR_UN_INI;
        }
        thunderLogD("setMediaMode " + mode);
        return thunderEngine.setMediaMode(mode);
    }

    /**
     * Set room scene mode
     * 设置房间场景模式
     *
     * @param mode mode
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int setRoomMode(int mode) {
        if (thunderEngine == null) {
            Log.i(TAG, "setRoomMode 未初始化");
            return ERROR_UN_INI;
        }
        thunderLogD("setRoomMode " + mode);
        return thunderEngine.setRoomMode(mode);
    }

    /**
     * Set local preview
     * 设置本地预览视图
     *
     * @param mPreviewContainer view
     * @param uid               user id
     */
    public void setLocalVideoCanvas(View mPreviewContainer, String uid) {
        if (thunderEngine == null) {
            return;
        }

        ThunderVideoCanvas mPreviewView = new ThunderVideoCanvas(mPreviewContainer,
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS,
                uid);
        thunderLogD("setLocalVideoCanvas");
        thunderLogD("setLocalCanvasScaleMode");
        thunderEngine.setLocalVideoCanvas(mPreviewView);
        thunderEngine.setLocalCanvasScaleMode(
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS);
    }


    /**
     * Enable speaker volume prompt
     * 启用说话者音量提示
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int setAudioVolumeIndication() {
        if (thunderEngine == null) {
            Log.i(TAG, "setAudioVolumeIndication 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("setAudioVolumeIndication");
        int result = thunderEngine.setAudioVolumeIndication(500, 0, 0, 0);
        Log.i(TAG, "setAudioVolumeIndication result=" + result);
        return result;
    }

    /**
     * Turn on capture volume callback
     * 打开采集音量回调
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int enableCaptureVolumeIndication() {
        if (thunderEngine == null) {
            Log.i(TAG, "enableCaptureVolumeIndication 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("enableCaptureVolumeIndication");
        int result = thunderEngine.enableCaptureVolumeIndication(500, 0, 0, 0);
        Log.i(TAG, "enableCaptureVolumeIndication result=" + result);
        return result;
    }

    /**
     * Set audio mode
     * 设置音频模式
     *
     * @param profile      Audio type {@link ThunderRtcConstant.AudioConfig}
     * @param commutMode   Interactive mode {@link ThunderRtcConstant.CommutMode}
     * @param scenarioMode Scenario mode{@link ThunderRtcConstant.ScenarioMode}
     */
    public int setAudioConfig(int profile, int commutMode, int scenarioMode) {
        if (thunderEngine == null) {
            Log.i(TAG, "setAudioConfig 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("setAudioConfig");
        Log.d(TAG, "setAudioConfig profile=" + profile + " commutMode=" + commutMode + " " +
                "scenarioMode=" + scenarioMode);
        int result = thunderEngine.setAudioConfig(profile, commutMode, scenarioMode);
        Log.d(TAG, "setAudioConfig result=" + result);
        return result;
    }

    /**
     * Turn on or off ear monitor
     * 打开关闭耳返
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int setEnableInEarMonitor(boolean enabled) {
        if (thunderEngine == null) {
            Log.d(TAG, "setEnableInEarMonitor 未初始化");
            return 0;
        }

        thunderLogD("setEnableInEarMonitor enabled=" + enabled);
        Log.d(TAG, "setEnableInEarMonitor enabled=" + enabled);
        int result = thunderEngine.setEnableInEarMonitor(enabled);
        Log.d(TAG, "setEnableInEarMonitor enabled=" + enabled + " result=" + result);
        return result;
    }

    /**
     * enable speaker
     * 设置是否外放
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int enableLoudspeaker(boolean enabled) {
        if (thunderEngine == null) {
            Log.d(TAG, "enableLoudspeaker 未初始化");
            return 0;
        }

        thunderLogD("enableLoudspeaker enabled=" + enabled);
        Log.d(TAG, "enableLoudspeaker enabled=" + enabled);
        int result = thunderEngine.enableLoudspeaker(enabled);
        Log.d(TAG, "enableLoudspeaker enabled=" + enabled + " result=" + result);
        return result;
    }

    /**
     * Whether speakers is playing
     * 是否外放
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public boolean isLoudspeakerEnabled() {
        if (thunderEngine == null) {
            Log.d(TAG, "isLoudspeakerEnabled 未初始化");
            return false;
        }

        thunderLogD("isLoudspeakerEnabled");
        boolean enabled = thunderEngine.isLoudspeakerEnabled();
        Log.d(TAG, "isLoudspeakerEnabled enabled=" + enabled);
        return enabled;
    }

    /**
     * Set different sound modes
     * 设置不同的音效模式
     *
     * @param mode {@link ThunderRtcConstant.SoundEffectMode}
     */
    public void setSoundEffect(int mode) {
        if (thunderEngine == null) {
            Log.d(TAG, "setSoundEffect 未初始化");
            return;
        }
        thunderLogD("setSoundEffect mode " + mode);
        thunderEngine.setSoundEffect(mode);
    }

    /**
     * Set voice change mode
     * 设置变声模式
     *
     * @param mode {@link ThunderRtcConstant.VoiceChangerMode}
     */
    public void setVoiceChanger(int mode) {
        if (thunderEngine == null) {
            Log.d(TAG, "setVoiceChanger 未初始化");
            return;
        }
        thunderLogD("setVoiceChanger mode " + mode);
        thunderEngine.setVoiceChanger(mode);
    }

    /**
     * Open audio and video
     * 开启音视频
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int startAudioAndVideo() {
        if (thunderEngine == null) {
            Log.i(TAG, "startAudioAndVideo 未初始化");
            return ERROR_UN_INI;
        }

        //Switch to front camrea
        //切换到前置
        thunderLogD("startAudioAndVideo switchFrontCamera true");
        int result = thunderEngine.switchFrontCamera(true);
        if (result != 0) {
            thunderLogE("startAudioAndVideo switchFrontCamera error=" + result, true);
            return result;
        }
        mIsFrontCamera.postValue(true);

        //start preview
        //开启预览
        thunderLogD("startAudioAndVideo startVideoPreview");
        result = thunderEngine.startVideoPreview();
        if (result != 0) {
            thunderLogE("startAudioAndVideo startVideoPreview error=" + result, true);
            return result;
        }

        //Start to push local video stream
        //开始推送本地视频流
        thunderLogD("startAudioAndVideo stopLocalVideoStream");
        result = thunderEngine.stopLocalVideoStream(false);
        if (result != 0) {
            thunderLogE("startAudioAndVideo stopLocalVideoStream error=" + result, true);
            return result;
        }
        isLocalVidioStreamStop.postValue(false);

        //Start pushing local audio stream
        //开始推送本地音频流
        thunderLogD("startAudioAndVideo stopLocalAudioStream");
        result = thunderEngine.stopLocalAudioStream(false);
        if (result != 0) {
            thunderLogE("startAudioAndVideo stopLocalAudioStream error=" + result, true);
            return result;
        }
        thunderLogD("startAudioAndVideo setAudioSourceType");
        thunderEngine
                .setAudioSourceType(ThunderRtcConstant.SourceType.THUNDER_PUBLISH_MODE_MIX);
        isLocalAudioStreamStop.postValue(false);

        thunderLogD("startAudioAndVideo result=" + result, true);
        return result;
    }

    /**
     * stop / receive all audio data
     * 停止/接收所有音频数据
     *
     * @param stop stop
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int stopAllRemoteAudioStreams(boolean stop) {
        if (thunderEngine == null) {
            Log.i(TAG, "stopAllRemoteAudioStreams 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("stopAllRemoteAudioStreams stop=" + stop, true);
        int result = thunderEngine.stopAllRemoteAudioStreams(stop);
        Log.i(TAG, "stopAllRemoteAudioStreams result=" + result);
        return result;
    }

    /**
     * stop / receive all remote video
     * 停止／接收所有远端视频
     *
     * @param stop stop
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int stopAllRemoteVideoStreams(boolean stop) {
        if (thunderEngine == null) {
            Log.i(TAG, "stopAllRemoteVideoStreams 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("stopAllRemoteVideoStreams stop=" + stop, true);
        int result = thunderEngine.stopAllRemoteVideoStreams(stop);
        Log.i(TAG, "stopAllRemoteVideoStreams result=" + result);
        return result;
    }

    /**
     * Receive / stop receiving the specified video stream
     * 接收/停止接收指定视频流
     *
     * @param uid  user id
     * @param stop stop
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int stopRemoteVideoStream(String uid, boolean stop) {
        if (thunderEngine == null) {
            Log.i(TAG, "stopRemoteVideoStream 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("stopRemoteVideoStream uid=" + uid + " stop=" + stop, true);
        int result = thunderEngine.stopRemoteVideoStream(uid, stop);
        Log.i(TAG,
                "stopRemoteVideoStream result=" + result);
        return result;
    }

    /**
     * Receive / stop receiving specified audio stream
     * 接收/停止接收指定音频流
     *
     * @param uid  user id
     * @param stop stop
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int stopRemoteAudioStream(String uid, boolean stop) {
        if (thunderEngine == null) {
            Log.i(TAG, "stopRemoteAudioStream 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("stopRemoteAudioStream uid=" + uid + " stop=" + stop, true);
        int result = thunderEngine.stopRemoteAudioStream(uid, stop);
        Log.i(TAG, "stopRemoteAudioStream result=" + result);
        return result;
    }

    /**
     * Set video encoding configuration
     * 设置视频编码配置
     *
     * @param configuration configuration
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int setVideoEncoderConfig(ThunderVideoEncoderConfiguration configuration) {
        if (thunderEngine == null) {
            Log.i(TAG, "setVideoEncoderConfig 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("setVideoEncoderConfig configuration=" + configuration, true);
        int result = thunderEngine.setVideoEncoderConfig(configuration);
        Log.i(TAG, "setVideoEncoderConfig result=" + result);
        return result;
    }

    /**
     * Stop audio
     * 停止音频
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int stopAudio() {
        if (thunderEngine == null) {
            Log.i(TAG, "stopAudio 未初始化");
            return 0;
        }

        if (isJoinRoom.getValue() == null || !isJoinRoom.getValue()) {
            return 0;
        }

        //Stop pushing local audio streams
        //停止推送本地音频流
        thunderLogD("stopAudio stopLocalAudioStream");
        int result = thunderEngine.stopLocalAudioStream(true);
        if (result != 0) {
            thunderLogE("stopAudio stopLocalAudioStream error=" + result, true);
            return result;
        }
        isLocalAudioStreamStop.postValue(true);
        Log.i(TAG, "stopAudio result=" + result);
        return result;
    }

    /**
     * Stop video
     * 停止视频
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int stopVideo() {
        if (thunderEngine == null) {
            Log.i(TAG, "stopVideo 未初始化");
            return 0;
        }

        if (isJoinRoom.getValue() == null || !isJoinRoom.getValue()) {
            return 0;
        }

        //Stop pushing local video stream
        //停止推送本地视频流
        thunderLogD("stopVideo stopLocalVideoStream");
        int result = thunderEngine.stopLocalVideoStream(true);
        if (result != 0) {
            thunderLogE("stopVideo stopLocalVideoStream error=" + result, true);
            return result;
        }

        //Close preview
        //关闭预览
        thunderLogD("stopVideo stopVideoPreview");
        result = thunderEngine.stopVideoPreview();
        if (result != 0) {
            thunderLogE("stopVideo stopVideoPreview error=" + result, true);
            return result;
        }

        isLocalVidioStreamStop.postValue(true);
        mIsFrontCameraLast = mIsFrontCamera.getValue();
        mIsFrontCamera.postValue(null);

        thunderLogD("stopVideo result=" + result, true);
        return result;
    }

    /**
     * Stop audio and video
     * 停止音视频
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int stopAudioAndVideo() {
        if (thunderEngine == null) {
            Log.i(TAG, "stopAudioAndVideo 未初始化");
            return 0;
        }

        if (isJoinRoom.getValue() == null || !isJoinRoom.getValue()) {
            return 0;
        }

        //Stop pushing local audio streams
        //停止推送本地音频流
        thunderLogD("stopAudioAndVideo stopLocalAudioStream");
        int result = thunderEngine.stopLocalAudioStream(true);
        if (result != 0) {
            thunderLogE("stopAudioAndVideo stopLocalAudioStream error=" + result, true);
            return result;
        }
        isLocalAudioStreamStop.postValue(true);

        //Stop pushing local video stream
        //停止推送本地视频流
        thunderLogD("stopAudioAndVideo stopLocalVideoStream");
        result = thunderEngine.stopLocalVideoStream(true);
        if (result != 0) {
            thunderLogE("stopAudioAndVideo stopLocalVideoStream error=" + result, true);
            return result;
        }

        //Close preview
        //关闭预览
        thunderLogD("stopAudioAndVideo stopVideoPreview");
        result = thunderEngine.stopVideoPreview();
        if (result != 0) {
            thunderLogE("stopAudioAndVideo stopVideoPreview error=" + result, true);
            return result;
        }

        isLocalVidioStreamStop.postValue(true);
        mIsFrontCameraLast = mIsFrontCamera.getValue();
        mIsFrontCamera.postValue(null);

        thunderLogD("stopAudioAndVideo result=" + result, true);
        return result;
    }


    /**
     * switch camera
     *
     * @param bFront bFront
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int switchFrontCamera(boolean bFront) {
        thunderLogD("switchFrontCamera bFront " + bFront);
        int result = thunderEngine.switchFrontCamera(bFront);
        if (result == 0) {
            mIsFrontCamera.postValue(bFront);
        }
        Log.i(TAG, "switchFrontCamera：" + "newValue=" + bFront + " result=" + result);
        return result;
    }

    /**
     * Front and rear camera switching
     * 前后摄像头切换
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int switchFrontCamera() {
        if (thunderEngine == null) {
            Log.i(TAG, "switchFrontCamera 未初始化");
            return ERROR_UN_INI;
        }

        if (mIsFrontCamera.getValue() == null) {
            Log.i(TAG, "switchFrontCamera 未启用");
            return ERROR_DISABLE_AUDIO;
        }

        boolean newValue = !mIsFrontCamera.getValue();
        thunderLogD("switchFrontCamera newValue " + newValue);
        int result = thunderEngine.switchFrontCamera(newValue);
        if (result == 0) {
            mIsFrontCamera.postValue(newValue);
        }
        Log.i(TAG, "switchFrontCamera：" + "newValue=" + newValue + " result=" + result);
        return result;
    }

    /**
     * Open video
     * 打开视频
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int startVideo() {
        if (thunderEngine == null) {
            Log.i(TAG, "startVideo 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("startVideo startVideoPreview ");
        int result = thunderEngine.startVideoPreview();
        if (result != 0) {
            thunderLogE("startVideo startVideoPreview error=" + result, true);
            return result;
        }

        thunderLogD("startVideo stopLocalVideoStream ");
        result = thunderEngine.stopLocalVideoStream(false);
        if (result != 0) {
            thunderLogE("startAudio stopLocalVideoStream error=" + result, true);
            return result;
        }

        mIsFrontCamera.postValue(true);
        thunderLogD("startVideo result=" + result, true);
        return result;
    }

    /**
     * Open audio
     * 打开音频
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int startAudio() {
        if (thunderEngine == null) {
            Log.i(TAG, "startAudio 未初始化");
            return ERROR_UN_INI;
        }

        thunderLogD("startAudio stopLocalAudioStream ");
        int result = thunderEngine.stopLocalAudioStream(false);
        if (result != 0) {
            thunderLogE("startAudio stopLocalAudioStream error=" + result, true);
            return result;
        }
        isLocalAudioStreamStop.postValue(false);
        thunderLogD("startAudio result=" + result, true);
        return result;
    }

    /**
     * On / off local audio sending
     * 开/关本地音频发送
     *
     * @return 0:success,{@link ThunderRtcConstant.ThunderRet}
     */
    public int switchLocalAudioStreamStop() {
        if (thunderEngine == null) {
            Log.i(TAG, "switchLocalAudioStreamStop 未初始化");
            return ERROR_UN_INI;
        }

        if (isLocalAudioStreamStop.getValue() == null) {
            Log.i(TAG, "switchLocalAudioStreamStop 未启用Audio");
            return ERROR_DISABLE_AUDIO;
        }

        boolean newValue = !isLocalAudioStreamStop.getValue();
        thunderLogD("switchLocalAudioStreamStop stopLocalAudioStream newValue " + newValue);
        int result = thunderEngine.stopLocalAudioStream(newValue);
        if (result == 0) {
            isLocalAudioStreamStop.postValue(newValue);
        }
        Log.i(TAG,
                "switchLocalAudioStreamStop：" + "newValue=" + newValue + " result=" + result);
        return result;
    }

    /**
     * Set remote view
     * 设置远程视图
     *
     * @param remoteView view
     * @param uid        user id
     */
    public void setRemotePlayerView(View remoteView, @NonNull String uid) {
        if (thunderEngine == null) {
            return;
        }

        ThunderVideoCanvas canvas = new ThunderVideoCanvas(remoteView,
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS,
                uid);
        thunderLogD("setRemotePlayerView setRemotePlayerView");
        thunderLogD("setRemotePlayerView setRemoteCanvasScaleMode");
        thunderEngine.setRemoteVideoCanvas(canvas);
        thunderEngine.setRemoteCanvasScaleMode(uid,
                ThunderRtcConstant.ThunderVideoViewScaleMode.THUNDERVIDEOVIEW_SCALE_MODE_CLIP_TO_BOUNDS);
    }

    public void resumeVideoPreview() {
        if (thunderEngine == null) {
            Log.i(TAG, "resumeVideoPreview 未初始化");
            return;
        }

        thunderLogD("resumeVideoPreview enableLocalVideoCapture");
        thunderLogD("resumeVideoPreview startVideoPreview");
        thunderLogD("resumeVideoPreview stopLocalVideoStream");
        thunderEngine.enableLocalVideoCapture(true);
        thunderEngine.startVideoPreview();
        thunderEngine.stopLocalVideoStream(false);
    }

    /**
     * Open local video capture
     * 打开本地视频采集
     */
    public void startLocalVidioStream() {
        if (thunderEngine == null) {
            Log.i(TAG, "startLocalVidioStream 未初始化");
            return;
        }

        thunderLogD("startLocalVidioStream enableLocalVideoCapture");
        int result = thunderEngine.enableLocalVideoCapture(true);
        if (result != 0) {
            thunderLogE("startLocalVidioStream enableLocalVideoCapture error=" + result, true);
            return;
        }
        thunderLogD("startLocalVidioStream startVideoPreview");
        result = thunderEngine.startVideoPreview();
        if (result != 0) {
            thunderLogE("startLocalVidioStream startVideoPreview error=" + result, true);
            return;
        }
        thunderLogD("startLocalVidioStream stopLocalVideoStream");
        result = thunderEngine.stopLocalVideoStream(false);

        if (result == 0) {
            isLocalVidioStreamStop.postValue(false);
            mIsFrontCamera.postValue(mIsFrontCameraLast);
        }

        thunderLogD("startLocalVidioStream result=" + result, true);
    }

    /**
     * Turn on / off local video capture
     * 开/关本地视频采集
     */
    public int switchLocalVidioStreamStop() {
        if (thunderEngine == null) {
            Log.i(TAG, "switchLocalVidioStreamStop 未初始化");
            return ERROR_UN_INI;
        }

        if (isLocalVidioStreamStop.getValue() == null) {
            Log.i(TAG, "switchLocalVidioStreamStop 未启用Video");
            return ERROR_DISABLE_VIDEO;
        }

        boolean newValue = !isLocalVidioStreamStop.getValue();
        int result = 0;
        thunderLogD("switchLocalVidioStreamStop enableLocalVideoCapture enable " + !newValue);
        if (newValue) {
            result = thunderEngine.enableLocalVideoCapture(false);
        } else {
            result = thunderEngine.enableLocalVideoCapture(true);
            if (result != 0) {
                thunderLogE("switchLocalVidioStreamStop enableLocalVideoCapture error=" + result, true);
                return result;
            }

            thunderLogD("switchLocalVidioStreamStop startVideoPreview");
            result = thunderEngine.startVideoPreview();
            if (result != 0) {
                thunderLogE("switchLocalVidioStreamStop startVideoPreview error=" + result, true);
                return result;
            }
            thunderLogD("switchLocalVidioStreamStop stopLocalVideoStream");
            result = thunderEngine.stopLocalVideoStream(false);
        }

        if (result == 0) {
            isLocalVidioStreamStop.postValue(newValue);

            if (newValue) {
                mIsFrontCameraLast = mIsFrontCamera.getValue();
                mIsFrontCamera.postValue(null);
            } else {
                mIsFrontCamera.postValue(mIsFrontCameraLast);
            }
        }

        thunderLogD("switchLocalVidioStreamStop：" + "newValue=" + newValue + " result=" + result, true);
        return result;
    }

    /**
     * 设置镜像模式
     *
     * @param mirrorMode 镜像模式
     * @return
     */
    public int setLocalVideoMirrorMode(int mirrorMode) {
        if (thunderEngine == null) {
            Log.i(TAG, "switchLocalVidioStreamStop 未初始化");
            return ERROR_UN_INI;
        }

        int result = thunderEngine.setLocalVideoMirrorMode(mirrorMode);

        return result;
    }


    public IThunderLogCallback getThunderLogCallback() {
        return thunderLogCallback;
    }

    private IThunderLogCallback thunderLogCallback = new IThunderLogCallback() {
        @Override
        public void onThunderLogWithLevel(int level, String tag, String msg) {
            switch (level) {
                case ThunderRtcConstant.ThunderLogLevel.THUNDERLOG_LEVEL_WARN:
                    thunderLogW(tag + ":" + msg, true);
                    break;
                case ThunderRtcConstant.ThunderLogLevel.THUNDERLOG_LEVEL_ERROR:
                    thunderLogE(tag + ":" + msg, true);
                    break;
                case ThunderRtcConstant.ThunderLogLevel.THUNDERLOG_LEVEL_TRACE:
                case ThunderRtcConstant.ThunderLogLevel.THUNDERLOG_LEVEL_DEBUG:
                case ThunderRtcConstant.ThunderLogLevel.THUNDERLOG_LEVEL_INFO:
                default:
                    thunderLogD(tag + ":" + msg, true);
            }
        }
    };

    public Observer getObserver() {
        return observer;
    }

    public void setObserver(Observer observer) {
        this.observer = observer;
    }


    public abstract static class Observer {
        public void onJoinRoomSuccess(String channel, String uid, int elapsed) {
        }

        public void onVideoSizeChanged(String uid, int width, int height, int rotation) {
        }

        public void onRemoteVideoStopped(String uid, boolean muted) {
        }

        public void onRemoteAudioStopped(String uid, boolean muted) {
        }

        public void onLeaveRoom(ThunderEventHandler.RoomStats status) {
        }

        public void onPublishStreamToCDNStatus(String url, int errorCode) {
        }

        public void onNetworkQuality(String uid, int txQuality, int rxQuality) {
        }

        public void onRoomStats(ThunderNotification.RoomStats stats) {
        }
        public void onLocalVideoStats(ThunderEventHandler.LocalVideoStats stats) {}
    }

    public JoinThunderRoomObserver getJoinThunderRoomObserver() {
        return joinThunderRoomObserver;
    }

    public void setJoinThunderRoomObserver(JoinThunderRoomObserver joinThunderRoomObserver) {
        this.joinThunderRoomObserver = joinThunderRoomObserver;
    }

    public abstract static class JoinThunderRoomObserver {
        public void onJoinRoomSuccess(String room, String uid, int elapsed) {
        }
    }

    private static final String THUNDER_ENGINE_LOG_TAG = "thunderEngine";

    /**
     * log function
     */
    private void thunderLogD(String info) {
        thunderLogD(info, false);
    }

    private void thunderLogD(String info, boolean writeToLog) {
        if (writeToLog) {
            Log.i(TAG, info);
        }
        LogManager.getInstance().logI(THUNDER_ENGINE_LOG_TAG, info);
    }

    private void thunderLogW(String info) {
        thunderLogW(info, false);
    }

    private void thunderLogW(String info, boolean writeToLog) {
        if (writeToLog) {
            Log.w(TAG, info);
        }
        LogManager.getInstance().logW(THUNDER_ENGINE_LOG_TAG, info);
    }

    private void thunderLogE(String info) {
        thunderLogE(info, false);
    }

    private void thunderLogE(String info, boolean writeToLog) {
        if (writeToLog) {
            Log.e(TAG, info);
        }
        LogManager.getInstance().logE(THUNDER_ENGINE_LOG_TAG, info);
    }

//    private IThunderMediaExtraInfoCallback thunderMediaExtraInfoCallback = new IThunderMediaExtraInfoCallback() {
//        @Override
//        public void onSendMediaExtraInfoFailedStatus(int status) {
//
//        }
//
//        @Override
//        public void onRecvMediaExtraInfo(String uid, ByteBuffer data, int dataLen) {
//
//        }
//
//        @Override
//        public void onRecvMixAudioInfo(String uid, ArrayList<ThunderEventHandler.MixAudioInfo> infos) {
//
//        }
//
//        @Override
//        public void onRecvMixVideoInfo(String uid, ArrayList<ThunderEventHandler.MixVideoInfo> infos) {
//
//        }
//    };

//    public void initLiveMode(List<UserMode> userLiveModes) {
//        addLiveUsers("流畅", ThunderRtcConstant.
//        ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_FLUENCY, userLiveModes);
//        addLiveUsers("标清", ThunderRtcConstant.
//        ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_NORMAL, userLiveModes);
//        addLiveUsers("高清", ThunderRtcConstant.
//        ThunderPublishVideoMode.THUNDERPUBLISH_VIDEO_MODE_HIGHQULITY, userLiveModes);
//    }
//
//    private void addLiveUsers(String mode, int thunderpublishVideoMode, List<UserMode> userLiveModes) {
//        UserMode userMode = new UserMode();
//        userMode.setModeTip(mode);
//        userMode.setModeType(Constant.LIVE_MODETYPE);
//        userMode.setThunderMode(thunderpublishVideoMode);
//        userLiveModes.add(userMode);
//    }

}
