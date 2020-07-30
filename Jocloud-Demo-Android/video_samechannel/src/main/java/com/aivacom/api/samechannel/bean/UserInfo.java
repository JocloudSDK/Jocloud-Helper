package com.aivacom.api.samechannel.bean;

import com.thunder.livesdk.ThunderEventHandler;

public class UserInfo {

    private String uid;
    private boolean muteAudio = false;
    private boolean muteVideo = false;
    private boolean videoStreamStopped = true;
    private boolean audioStreamStopped = true;
    private int txQuality;
    private int micVolume;

    public UserInfo() {
    }

    public UserInfo(String uid) {
        this.uid = uid;
    }

    public void onNetworkQuality(String uid, int txQuality, int rxQuality) {
        this.txQuality = txQuality;
    }

    public void onPlayVolumeIndication(ThunderEventHandler.AudioVolumeInfo speaker) {
        this.micVolume = speaker.volume;
    }

    public void onCaptureVolumeIndication(int totalVolume, int cpt, int micVolume) {
        this.micVolume = micVolume;
    }

    public String getUid() {
        return uid;
    }

    public void setUid(String uid) {
        this.uid = uid;
    }

    public boolean isMuteAudio() {
        return muteAudio;
    }

    public void setMuteAudio(boolean muteAudio) {
        this.muteAudio = muteAudio;
    }

    public boolean isMuteVideo() {
        return muteVideo;
    }

    public void setMuteVideo(boolean muteVideo) {
        this.muteVideo = muteVideo;
    }

    public boolean isVideoStreamStopped() {
        return videoStreamStopped;
    }

    public void setVideoStreamStopped(boolean videoStreamStopped) {
        this.videoStreamStopped = videoStreamStopped;
    }

    public boolean isAudioStreamStopped() {
        return audioStreamStopped;
    }

    public void setAudioStreamStopped(boolean audioStreamStopped) {
        this.audioStreamStopped = audioStreamStopped;
    }

    public int getTxQuality() {
        return txQuality;
    }

    public void setTxQuality(int txQuality) {
        this.txQuality = txQuality;
    }

    public int getMicVolume() {
        return micVolume;
    }

    public void setMicVolume(int micVolume) {
        this.micVolume = micVolume;
    }
}
