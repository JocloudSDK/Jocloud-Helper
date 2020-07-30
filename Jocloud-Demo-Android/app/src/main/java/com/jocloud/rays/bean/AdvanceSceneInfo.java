package com.jocloud.rays.bean;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by zhouwen on 2020/6/1.
 */
public class AdvanceSceneInfo implements Parcelable {
    public int itemTitle;
    public int itemSubTitle;
    public int icon;

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
    }

    protected AdvanceSceneInfo(Parcel in) {
        this.itemTitle = in.readInt();
        this.itemSubTitle = in.readInt();
        this.icon = in.readInt();
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
