package com.jocloud.audio.adapter;

import android.content.Context;
import android.widget.ImageView;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.aivacom.api.rtc.FacadeRtcManager;
import com.aivacom.api.utils.Constant;
import com.jocloud.audio.R;
import com.jocloud.audio.UI.AudioActivity;
import com.jocloud.audio.bean.AudioMember;

import org.jetbrains.annotations.NotNull;

public class MemberAdapter extends RVBaseAdapter<AudioMember> {

    private static final int HEADER_LAYOUT = 1;
    private static final int CONTENT_LAYOUT = 2;

    public MemberAdapter(@NotNull Context context) {
        super(context);
    }

    @Override
    protected int getLayoutId(int viewType) {
        if (HEADER_LAYOUT == viewType) {
            return R.layout.audio_member_header;
        }
        return R.layout.audio_member;
    }

    @Override
    public int getItemViewType(int position) {
        if (position == 0) {
            return HEADER_LAYOUT;
        }
        return CONTENT_LAYOUT;
    }

    @Override
    protected void bindItemView(@NotNull RVViewHolder<AudioMember> holder, AudioMember item, int position) {
        if (position == 0) {
            return;
        }
        String textUid = item.uid;
        if (item.uid.equals(Constant.mLocalUid)) {
            textUid = textUid + "(" + mContext.getString(R.string.me) + ")";
        }
        holder.setText(R.id.item_tv_uid, textUid);
        ImageView imageView = holder.getChildView(R.id.item_iv_volume);
        if (item.mute) {
            imageView.setImageResource(R.mipmap.audio_close_icon);
        } else {
            int imageResource;
            if (item.micVolume < 33) {
                imageResource = R.mipmap.audio_select_1_icon;
            } else if (item.micVolume < 66) {
                imageResource = R.mipmap.audio_select_2_icon;
            } else {
                imageResource = R.mipmap.audio_select_3_icon;
            }
            imageView.setImageResource(imageResource);
        }
        imageView.setOnClickListener(v -> {
            item.mute = !item.mute;
            if (item.mute) {
                if (item.uid.equals(Constant.mLocalUid)) {
                    FacadeRtcManager.getInstance().stopLocalAudioStream(true);
                } else {
                    FacadeRtcManager.getInstance().stopRemoteAudioStream(item.uid, true);
                    ((AudioActivity) mContext).addLog("You muted UID=" + item.uid);
                }

            } else {
                if (item.uid.equals(Constant.mLocalUid)) {
                    FacadeRtcManager.getInstance().stopLocalAudioStream(false);
                } else {
                    FacadeRtcManager.getInstance().stopRemoteAudioStream(item.uid, false);
                }
            }
            updateItemData(position, item);
        });

    }

    @Override
    public void addItemData(AudioMember item) {
        if (getItemCount() == 0) {
            getDataList().add(new AudioMember("", false));
        }
        super.addItemData(item);
    }

    @Override
    public void addItemData(int position, AudioMember item) {
        if (getItemCount() == 0) {
            getDataList().add(new AudioMember("", false));
        }
        super.addItemData(position, item);
    }

    public void clear() {
        getDataList().clear();
        notifyDataSetChanged();
    }

    public boolean deleteItem(String uid) {
        int index = -1;
        for (int i = 0; i < getDataList().size(); i++) {
            if (uid.equals(getDataList().get(i).uid)) {
                index = i;
                break;
            }
        }
        if (index != -1) {
            deleteItem(index);
        }
        return index != -1;
    }

    public int getMemberIndexByUid(String uid) {
        int index = -1;
        for (int i = 0; i < getDataList().size(); i++) {
            if (uid.equals(getDataList().get(i).uid)) {
                index = i;
                break;
            }
        }
        return index;
    }


}
