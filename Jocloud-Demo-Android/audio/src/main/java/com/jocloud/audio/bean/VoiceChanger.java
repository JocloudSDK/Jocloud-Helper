package com.jocloud.audio.bean;

public class VoiceChanger {
    public int mode;
    public String text;

    public VoiceChanger(String text, int mode) {
        this.text = text;
        this.mode = mode;
    }
}
