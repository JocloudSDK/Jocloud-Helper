package com.aivacom.api.baseui.adapter.lvadapter;

import android.content.Context;
import android.graphics.drawable.Drawable;
import android.util.SparseArray;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.CheckBox;
import android.widget.ImageView;
import android.widget.TextView;


/**
 * Created by zhouwen on 2020-05-13.
 */
public class LvViewHolder {

    private SparseArray<View> mSparseArray;

    private View mConvertView;

    private Context mContext;

    private int mPosition;

    public LvViewHolder(Context context, int itemViewRes, View convertView, ViewGroup parent, int position) {
        mContext = context;
        mPosition = position;
        mSparseArray = new SparseArray<>();
        mConvertView = LayoutInflater.from(mContext).inflate(itemViewRes, null);
        mConvertView.setTag(this);
    }

    public View getConvertView() {
        return mConvertView;
    }

    public static LvViewHolder getViewHolder(Context context, int position, int itemViewRes,
                                             View convertView, ViewGroup parent) {
        if (convertView == null) {
            return new LvViewHolder(context, itemViewRes, convertView, parent, position);
        }
        return (LvViewHolder) convertView.getTag();
    }

    public <T extends View> T getItemView(int id) {
        View view = mSparseArray.get(id);
        if (view == null) {
            view = mConvertView.findViewById(id);
            mSparseArray.put(id, view);
        }
        return (T) view;
    }

    public LvViewHolder setText(int viewIdRes, CharSequence text) {
        TextView textView = getItemView(viewIdRes);
        textView.setText(text);
        return this;
    }

    public LvViewHolder setImageView(int viewIdRes, int resId) {
        ImageView imageView = getItemView(viewIdRes);
        imageView.setImageResource(resId);
        return this;
    }

    public LvViewHolder setImageViewResUrl(int viewIdRes, String imageUrl) {
        ImageView imageView = getItemView(viewIdRes);
//        ImageLoader.getInstance().displayImage(imageUrl, imageView, UIUtils.getDefaultIconOptions());
        return this;
    }

    public LvViewHolder setImageViewDrawable(int viewIdRes, Drawable drawableRes) {
        ImageView imageView = getItemView(viewIdRes);
        imageView.setImageDrawable(drawableRes);
        return this;
    }

    public LvViewHolder setCheckable(int viewIdRes, boolean enable) {
        CheckBox checkable = getItemView(viewIdRes);
        checkable.setChecked(enable);
        return this;
    }

    public LvViewHolder setBackgroundColor(int viewId, int color) {
        View view = getItemView(viewId);
        view.setBackgroundColor(color);
        return this;
    }

    public LvViewHolder setTextColor(int viewId, int color) {
        TextView view = getItemView(viewId);
        view.setTextColor(mContext.getResources().getColor(color));
        return this;
    }

    public LvViewHolder setVisiby(int viewIdRes, boolean isVisbility) {
        View view = getItemView(viewIdRes);
        view.setVisibility(isVisbility ? View.VISIBLE : View.GONE);
        return this;
    }

    public LvViewHolder setOnClickListener(int viewIdRes, View.OnClickListener listener) {
        View view = getItemView(viewIdRes);
        view.setOnClickListener(listener);
        return this;
    }

    public LvViewHolder setOnLongClickListener(int viewIdRes, View.OnLongClickListener listener) {
        View view = getItemView(viewIdRes);
        view.setOnLongClickListener(listener);
        return this;
    }

    public LvViewHolder setOnLongClickListener(int viewIdRes, View.OnTouchListener listener) {
        View view = getItemView(viewIdRes);
        view.setOnTouchListener(listener);
        return this;
    }

    public int getPosition() {
        return mPosition;
    }
}
