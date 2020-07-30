package com.aivacom.api.samechannel.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.widget.ImageView;

import com.aivacom.api.rtc.FacadeRtcManager;
import com.aivacom.api.samechannel.R;
import com.aivacom.api.samechannel.bean.UserInfo;
import com.aivacom.api.samechannel.UI.VideoSameChannelActivity;
import com.aivacom.api.samechannel.UI.RemoteUserView;
import com.aivacom.api.samechannel.UI.LocalUserView;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

/**
 * Video View Adapter
 * 视频视图适配器
 */
public class RoomAdapter extends BaseAdapter<UserInfo> {

    private static final String TAG = "RoomAdapter";
    private static final int TYPE_PREVIEW = 1;
    private static final int TYPE_PLAY_VIEW = 2;

    private Context context;

    private Map<String, UserInfo> maps = new HashMap<>();

    public RoomAdapter(List<UserInfo> dataList, Context context) {
        super(dataList);
        this.context = context;
    }

    @Override
    public int getLayoutId(int viewType) {
        int layoutId = 0;
        switch (viewType) {
            case TYPE_PREVIEW:
                layoutId = R.layout.item_local;
                break;
            case TYPE_PLAY_VIEW:
                layoutId = R.layout.item_remove_user;
                break;
            default:
        }
        return layoutId;
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return TYPE_PREVIEW;
        }
        return TYPE_PLAY_VIEW;
    }

    @Override
    public void onBindViewHolder(VH holder, UserInfo data, int position) {
        VideoSameChannelActivity act = ((VideoSameChannelActivity) context);
        act.hideIvPreviewByPosition(position);
        if (TextUtils.equals(data.getUid(), FacadeRtcManager.getInstance().getUid())) {
            LocalUserView view = holder.getView(R.id.myview);
            view.joinRoom(data.getUid());
        } else {
            RemoteUserView view = holder.getView(R.id.myview);
            view.joinRoom(data.getUid());

            act.userInfo = data;
            ImageView ivCamera = holder.getView(R.id.ivCamera);
            if (data.isMuteVideo()) {
                ivCamera.setBackgroundResource(R.drawable.player_btn_camera_disable);
            } else {
                ivCamera.setBackgroundResource(R.drawable.player_btn_camera);
            }
            ivCamera.setOnClickListener(v -> act.handleVideo(view, data));

            ImageView ivMicrophone = holder.getView(R.id.ivMicrophone);
            if (data.isMuteAudio()) {
                ivMicrophone.setBackgroundResource(R.drawable.player_btn_microphone_disable);
            } else {
                ivMicrophone.setBackgroundResource(R.drawable.player_btn_microphone);
            }
            ivMicrophone.setOnClickListener(v -> act.handleAudio(view, data));
        }
    }

    public UserInfo getUserInfo(String targetUID) {
        return maps.get(targetUID);
    }

    public void updateItemWithoutNotify(int position, UserInfo data) {
        mDatas.set(position, data);
    }

    @Override
    public void addItem(int position, UserInfo data) {
        super.addItem(position, data);
        maps.put(data.getUid(), data);
    }

    @Override
    public void addItem(UserInfo data) {
        super.addItem(data);
        maps.put(data.getUid(), data);
    }

    public void addItemWithoutNotify(UserInfo data) {
        mDatas.add(data);
        maps.put(data.getUid(), data);
    }

    @Override
    public void deleteItem(UserInfo data) {
        super.deleteItem(data);
        maps.remove(data.getUid());
    }

    public void deleteItemWithoutNotify(UserInfo data) {
        mDatas.remove(data);
        maps.remove(data.getUid());
    }

    @Override
    public void clear() {
        super.clear();
        maps.clear();
    }
}
