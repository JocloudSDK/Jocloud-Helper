package com.jocloud.rays.bean;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by zhouwen on 2020/6/1.
 */
public class AdvanceSceneInfo implements Parcelable {
    public static int TYPE_VIDEO = 0;
    public static int TYPE_AUDIO = 1;
    public static int TYPE_CHAT_ROOM = 2;
    public static int TYPE_STREAM_PUSHING = 3;

    public int itemTitle;
    public int itemSubTitle;
    public int icon;
    public int type;
    public boolean enable;

    public AdvanceSceneInfo() {
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeInt(this.itemTitle);
        dest.writeInt(this.itemSubTitle);
        dest.writeInt(this.icon);
        dest.writeInt(this.type);
        dest.writeBoolean(this.enable);
    }

    protected AdvanceSceneInfo(Parcel in) {
        this.itemTitle = in.readInt();
        this.itemSubTitle = in.readInt();
        this.icon = in.readInt();
        this.type = in.readInt();
        this.enable = in.readBoolean();
    }

    public static final Creator<AdvanceSceneInfo> CREATOR = new Creator<AdvanceSceneInfo>() {
        @Override
        public AdvanceSceneInfo createFromParcel(Parcel source) {
            return new AdvanceSceneInfo(source);
        }

        @Override
        public AdvanceSceneInfo[] newArray(int size) {
            return new AdvanceSceneInfo[size];
        }
    };
}
