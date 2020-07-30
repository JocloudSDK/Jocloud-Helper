package com.aivacom.api.baseui.adapter.rvadapter

import android.os.Build
import android.view.View
import android.widget.ImageView
import android.widget.TextView
import androidx.annotation.RequiresApi
import androidx.recyclerview.widget.RecyclerView

/**
 *Created by zhouwen on 2020-05-13.
 */
open class RVViewHolder<T>(itemView: View) : RecyclerView.ViewHolder(itemView) {
    val itemV = itemView

    open fun getRootView(): View {
        return itemView
    }

    fun <E : View?> getChildView(res: Int): E {
        return itemView.findViewById<E>(res) as E
    }

    fun setText(resId: Int, str: String) {
        val textView: TextView = getChildView<TextView>(resId)
        textView.setText(str)
    }

    fun setTextSize(resId: Int, textSize: Float) {
        val textView = getChildView<TextView>(resId)
        textView.textSize = textSize
    }

    fun setTextColor(resId: Int, colorRes: Int) {
        val textView = getChildView<TextView>(resId)
        textView.setTextColor(colorRes)
    }


    @RequiresApi(Build.VERSION_CODES.LOLLIPOP)
    fun setImageView(resId: Int, ivRes: Int) {
        val iv = getChildView<ImageView>(resId)
        iv.setImageResource(ivRes)
    }
}