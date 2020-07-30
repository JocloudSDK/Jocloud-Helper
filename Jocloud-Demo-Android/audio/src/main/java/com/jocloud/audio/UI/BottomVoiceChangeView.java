package com.jocloud.audio.UI;

import android.content.Context;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.widget.Switch;

import androidx.recyclerview.widget.DefaultItemAnimator;
import androidx.recyclerview.widget.GridLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.jocloud.audio.R;
import com.jocloud.audio.adapter.BottomVoiceChangerAdapter;
import com.jocloud.audio.bean.VoiceChanger;
import com.thunder.livesdk.ThunderRtcConstant;

import java.util.ArrayList;

public class BottomVoiceChangeView {
    private Context mContext;
    private View mContentView;
    private OnItemClickListener mOnItemClickListener;
    private int mClickItemPosition = 0;

    public BottomVoiceChangeView(Context context, ArrayList<VoiceChanger> list, boolean enable, int mode,
                                 OnItemClickListener onItemClickListener) {
        mContext = context;
        mOnItemClickListener = onItemClickListener;
        init(list, enable, mode);
    }

    public void init(ArrayList<VoiceChanger> arrayList, boolean enable, int mode) {
        mContentView = LayoutInflater.from(mContext).inflate(R.layout.bottom_voice_changer_layout, null);
        int i = 0;
        for (VoiceChanger v : arrayList) {
            if (v.mode == mode) {
                mClickItemPosition = i;
                break;
            }
            i++;
        }
        RecyclerView recyclerView = mContentView.findViewById(R.id.rv_list);
        recyclerView.setLayoutManager(new GridLayoutManager(mContext, 3));
        recyclerView.addItemDecoration(new MarginDecoration(mContext));
        recyclerView.setItemAnimator(new DefaultItemAnimator());
        BottomVoiceChangerAdapter adapter = new BottomVoiceChangerAdapter(arrayList, enable, mode, mContext);
        adapter.setOnItemClickListener((view, position) -> {
            mClickItemPosition = position;
            if (mOnItemClickListener != null) {
                mOnItemClickListener.onClick(position);
            }
        });

        Switch s = mContentView.findViewById(R.id.sw_voice_changer);
        s.setChecked(enable);
        s.setOnCheckedChangeListener((buttonView, isChecked) -> {
            if (isChecked) {
                Log.i("TTTT", "init: " + mClickItemPosition);
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onClick(mClickItemPosition);
                }
            } else {
                if (mOnItemClickListener != null) {
                    mOnItemClickListener.onClick(-1);
                }
            }
            adapter.setEnable(isChecked);
        });
        recyclerView.setAdapter(adapter);
    }

    public View getContentView() {
        return mContentView;
    }

}
