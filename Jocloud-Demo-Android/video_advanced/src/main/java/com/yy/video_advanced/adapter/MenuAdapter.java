package com.yy.video_advanced.adapter;

import com.yy.video_advanced.R;

import org.jetbrains.annotations.NotNull;

import java.util.List;

public class MenuAdapter extends BaseAdapter<String> {

    public MenuAdapter(List<String> datas) {
        super(datas);
    }

    @Override
    public int getLayoutId(int viewType) {
        return R.layout.layout_menu_item;
    }

    @Override
    public void onCreateViewHolder(@NotNull VH holder, int viewType) {

    }

    @Override
    public void onBindViewHolder(VH holder, String data, int position) {
        holder.setText(R.id.tv, data);
    }
}
