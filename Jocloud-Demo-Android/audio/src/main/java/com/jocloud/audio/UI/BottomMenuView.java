package com.jocloud.audio.UI;

import android.app.Dialog;
import android.content.Context;
import android.view.LayoutInflater;
import android.view.View;

import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.jocloud.audio.R;
import com.jocloud.audio.adapter.BottomMenuAdapter;

import java.util.ArrayList;
import java.util.List;

public class BottomMenuView {

    private Context mContext;
    private ArrayList<String> arrayList;
    private View mContentView;
    private BottomMenuAdapter mAdapter;
    private OnItemClickListener mOnItemClickListener;
    private Dialog mDialog;

    public BottomMenuView(Context context, List<String> list, OnItemClickListener onItemClickListener) {
        mContext = context;
        arrayList = new ArrayList();
        arrayList.addAll(list);
        arrayList.add(mContext.getString(R.string.cancel));
        mOnItemClickListener = onItemClickListener;
        init();
    }

    public void init() {
        mContentView = LayoutInflater.from(mContext).inflate(R.layout.bottom_menu_layout, null);

        RecyclerView recyclerView = mContentView.findViewById(R.id.rvList);
        recyclerView.setLayoutManager(new LinearLayoutManager(mContext));
        recyclerView.setItemAnimator(new DefaultItemAnimator());

        mAdapter = new BottomMenuAdapter(arrayList, mContext);
        mAdapter.setOnItemClickListener((view, position) -> {
            if (position != mAdapter.getItemCount() - 1) {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onClick(position);
                }
            }

            if (mDialog != null) {
                mDialog.dismiss();
            }
        });
        recyclerView.setAdapter(mAdapter);
    }

    public void setDialog(Dialog dialog) {
        mDialog = dialog;
    }

    public View getContentView() {
        return mContentView;
    }
}
