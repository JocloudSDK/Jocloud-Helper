package com.jocloud.chatroom.adapter;

import android.content.Context;
import android.widget.TextView;

import com.aivacom.api.baseui.adapter.rvadapter.RVBaseAdapter;
import com.aivacom.api.baseui.adapter.rvadapter.RVViewHolder;
import com.jocloud.chatroom.R;
import com.jocloud.chatroom.bean.ChatMessage;

import org.jetbrains.annotations.NotNull;

public class MessageAdapter extends RVBaseAdapter<ChatMessage> {
    public MessageAdapter(@NotNull Context context) {
        super(context, R.layout.message_layout);
    }

    @Override
    protected void bindItemView(@NotNull RVViewHolder<ChatMessage> holder, ChatMessage item, int position) {
        TextView uid = holder.getChildView(R.id.tv_uid);
        TextView time = holder.getChildView(R.id.tv_time);
        TextView text = holder.getChildView(R.id.tv_text);
        if (item.type.equals(ChatMessage.SYSTEM)) {
            uid.setTextColor(mContext.getResources().getColor(R.color.color_FFC94C));
            time.setTextColor(mContext.getResources().getColor(R.color.color_FFC94C));
            text.setTextColor(mContext.getResources().getColor(R.color.color_FFC94C));
        } else {
            uid.setTextColor(mContext.getResources().getColor(R.color.color_7A7A7A));
            time.setTextColor(mContext.getResources().getColor(R.color.color_CBCBCB));
            text.setTextColor(mContext.getResources().getColor(R.color.color_1C1C1C));
        }
        uid.setText(item.Uid);
        time.setText(item.time);
        text.setText(item.message);
    }

    public void clear() {
        getDataList().clear();
        notifyDataSetChanged();
    }
}
