package com.aivacom.api.baseui.adapter.rvadapter

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.annotation.LayoutRes
import androidx.recyclerview.widget.RecyclerView

/**
 *Created by zhouwen on 2020-05-13.
 */
abstract class RVBaseAdapter<T> :
    RecyclerView.Adapter<RecyclerView.ViewHolder> {

    private var mLists: ArrayList<T> = ArrayList()
    private lateinit var mContext: Context
    private var mItemViewRes: Int


    constructor(context: Context, @LayoutRes layoutRes: Int) {
        mContext = context
        mItemViewRes = layoutRes
    }


    fun setDataList(datas: ArrayList<T>) {
        mLists = datas
        notifyDataSetChanged()
    }

    fun updateItemData(item: T) {
        mLists.add(item)
        notifyDataSetChanged()
    }

    fun updateDataList(datas: ArrayList<T>) {
        datas.clear()
        mLists = datas
        notifyDataSetChanged()
    }

    fun getDataList(): ArrayList<T> {
        return mLists
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        val itemView: View =
            LayoutInflater.from(mContext).inflate(mItemViewRes, parent, false)
        return RVViewHolder<T>(itemView)
    }

    override fun getItemCount(): Int {
        return mLists.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val viewHolder = holder as RVViewHolder<T>
        bindItemView(viewHolder, mLists.get(position), position)
    }

    protected abstract fun bindItemView(holder: RVViewHolder<T>, item: T, position: Int)
}