package com.aivacom.api.samechannel.adapter;

import android.content.Context;
import android.text.TextUtils;
import android.widget.ImageView;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.aivacom.api.rtc.FacadeRtcManager;
import com.aivacom.api.samechannel.R;
import com.aivacom.api.samechannel.UI.LocalUserView;
import com.aivacom.api.samechannel.UI.RemoteUserView;
import com.aivacom.api.samechannel.UI.VideoSameChannelActivity;
import com.aivacom.api.samechannel.bean.UserInfo;

import org.jetbrains.annotations.NotNull;

/**
 * Video View Adapter
 * 视频视图适配器
 */
public class RoomAdapter extends RVBaseAdapter<UserInfo> {

    private static final String TAG = "RoomAdapter";
    private static final int TYPE_PREVIEW = 1;
    private static final int TYPE_PLAY_VIEW = 2;

    private Context context;


    public RoomAdapter(Context context) {
        super(context);
        this.context = context;
    }

    @Override
    protected int getLayoutId(int viewType) {
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
    protected void bindItemView(@NotNull RVViewHolder<UserInfo> holder, UserInfo data, int position) {

        VideoSameChannelActivity act = ((VideoSameChannelActivity) context);
        act.hideIvPreviewByPosition(position);
        if (TextUtils.equals(data.getUid(), FacadeRtcManager.getInstance().getUid())) {
            LocalUserView view = holder.getChildView(R.id.myview);

            view.joinRoom(data.getUid());
        } else {
            RemoteUserView view = holder.getChildView(R.id.myview);
            view.joinRoom(data.getUid());

            act.userInfo = data;
            ImageView ivCamera = holder.getChildView(R.id.ivCamera);
            if (data.isMuteVideo()) {
                ivCamera.setBackgroundResource(R.drawable.player_btn_camera_disable);
            } else {
                ivCamera.setBackgroundResource(R.drawable.player_btn_camera);
            }
            ivCamera.setOnClickListener(v -> act.handleVideo(view, data));

            ImageView ivMicrophone = holder.getChildView(R.id.ivMicrophone);
            if (data.isMuteAudio()) {
                ivMicrophone.setBackgroundResource(R.drawable.player_btn_microphone_disable);
            } else {
                ivMicrophone.setBackgroundResource(R.drawable.player_btn_microphone);
            }
            ivMicrophone.setOnClickListener(v -> act.handleAudio(view, data));
        }
    }


    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return TYPE_PREVIEW;
        }
        return TYPE_PLAY_VIEW;
    }

    public UserInfo getUserInfo(String targetUid) {
        UserInfo result = null;
        for (UserInfo userInfo : getDataList()) {
            if (result == null && userInfo.getUid().equals(targetUid)) {
                result = userInfo;
            }
        }
        return result;
    }

    public void updateItemWithoutNotify(int position, UserInfo data) {
        getDataList().set(position, data);
    }


    public void addItemWithoutNotify(UserInfo data) {
        getDataList().add(data);
    }

    public void deleteItemWithoutNotify(UserInfo data) {
        getDataList().remove(data);
    }

    public void clear() {
        getDataList().clear();
        notifyDataSetChanged();
    }
}
