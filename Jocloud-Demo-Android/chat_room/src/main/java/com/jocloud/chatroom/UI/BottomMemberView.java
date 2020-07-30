package com.jocloud.chatroom.UI;

import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;

import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.jocloud.chatroom.R;
import com.jocloud.chatroom.adapter.BottomMemberAdapter;

import java.util.ArrayList;

public class BottomMemberView {

    private Context mContext;
    private ArrayList<String> arrayList;
    private View mContentView;
    private BottomMemberAdapter mAdapter;

    public BottomMemberView(Context context, ArrayList<String> list) {
        mContext = context;
        arrayList = list;
        init();
    }

    public void init() {
        mContentView = LayoutInflater.from(mContext).inflate(R.layout.bottom_member_layout, null);

        RecyclerView recyclerView = mContentView.findViewById(R.id.rv_list);
        recyclerView.setLayoutManager(new LinearLayoutManager(mContext));
        recyclerView.setItemAnimator(new DefaultItemAnimator());

        mAdapter = new BottomMemberAdapter(arrayList, mContext);
        recyclerView.setAdapter(mAdapter);
    }

    public View getContentView() {
        return mContentView;
    }
}
