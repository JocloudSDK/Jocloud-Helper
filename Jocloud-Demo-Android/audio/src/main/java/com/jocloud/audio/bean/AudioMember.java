package com.jocloud.audio.bean;

public class AudioMember {
    public String uid;
    public boolean audioStop;
    public int micVolume = 0; //0 to 100
    public boolean mute;

    public AudioMember(String uid, boolean audioStop) {
        this.uid = uid;
        this.audioStop = audioStop;
    }
}
