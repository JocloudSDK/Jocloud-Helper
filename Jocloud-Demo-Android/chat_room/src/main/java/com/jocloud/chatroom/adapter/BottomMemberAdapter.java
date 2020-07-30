package com.jocloud.chatroom.adapter;

import android.content.Context;
import android.widget.TextView;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.aivacom.api.utils.Constant;
import com.jocloud.chatroom.R;

import org.jetbrains.annotations.NotNull;

import java.util.ArrayList;

public class BottomMemberAdapter extends RVBaseAdapter<String> {

    public BottomMemberAdapter(ArrayList<String> list, @NotNull Context context) {
        super(context, R.layout.bottom_member_item);
        setDataList(list);
    }

    @Override
    protected void bindItemView(@NotNull RVViewHolder<String> holder, String item, int position) {
        if (item.equals(Constant.mLocalUid)) {
            item = mContext.getString(R.string.member_me, item);
        }
        ((TextView) holder.getRootView()).setText(item);
    }
}
