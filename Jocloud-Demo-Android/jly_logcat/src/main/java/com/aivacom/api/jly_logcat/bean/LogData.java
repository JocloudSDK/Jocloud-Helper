package com.aivacom.api.jly_logcat.bean;

import android.os.Parcel;
import android.os.Parcelable;

/**
 * Created by zhouwen on 2020/5/19.
 */
public class LogData implements Parcelable {

    public String logTag;

    public long time;

    public String logStr;

    public LogData() {
    }

    @Override
    public int describeContents() {
        return 0;
    }

    @Override
    public void writeToParcel(Parcel dest, int flags) {
        dest.writeString(this.logTag);
        dest.writeLong(this.time);
        dest.writeString(this.logStr);
    }

    protected LogData(Parcel in) {
        this.logTag = in.readString();
        this.time = in.readLong();
        this.logStr = in.readString();
    }

    public static final Creator<LogData> CREATOR = new Creator<LogData>() {
        @Override
        public LogData createFromParcel(Parcel source) {
            return new LogData(source);
        }

        @Override
        public LogData[] newArray(int size) {
            return new LogData[size];
        }
    };
}
