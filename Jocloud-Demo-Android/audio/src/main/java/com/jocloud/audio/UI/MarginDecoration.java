package com.jocloud.audio.UI;

import android.content.Context;
import android.graphics.Rect;
import android.view.View;

import androidx.recyclerview.widget.RecyclerView;

import com.aivacom.api.utils.UIUtil;

import org.jetbrains.annotations.NotNull;

class MarginDecoration extends RecyclerView.ItemDecoration {

    private int margin;

    public MarginDecoration(Context context) {
        margin = UIUtil.dip2px(context, 12);

    }

    @Override
    public void getItemOffsets(@NotNull Rect outRect, @NotNull View view, RecyclerView parent,
                               @NotNull RecyclerView.State state) {
        int position = parent.getChildLayoutPosition(view) % 3;
        if (position == 0) {
            outRect.set(0, margin, margin, 0);
        } else if (position == 1) {
            outRect.set(0, margin, margin, 0);
        } else {
            outRect.set(0, margin, 0, 0);
        }

    }
}