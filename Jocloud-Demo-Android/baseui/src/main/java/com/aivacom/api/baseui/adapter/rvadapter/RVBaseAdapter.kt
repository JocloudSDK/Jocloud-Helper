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
    protected open lateinit var mContext: Context
    private var mItemViewRes: Int
    protected open var mOnClickListener: OnItemClickListener? = null

    constructor(context: Context) {
        mContext = context
        mItemViewRes = -1
    }

    constructor(context: Context, @LayoutRes layoutRes: Int) {
        mContext = context
        mItemViewRes = layoutRes
    }

    protected open fun getLayoutId(viewType: Int): Int {
        return -1
    }

    fun setDataList(datas: ArrayList<T>) {
        mLists = datas
        notifyDataSetChanged()
    }

    open fun addItemData(item: T) {
        mLists.add(item)
        notifyDataSetChanged()
    }

    open fun addItemData(position: Int, item: T) {
        mLists.add(position, item)
        notifyDataSetChanged()
    }


    fun updateItemData(position: Int, item: T) {
        mLists.set(position, item)
        notifyDataSetChanged()
    }

    fun updateDataList(dataList: ArrayList<T>) {
        mLists.clear()
        mLists = dataList
        notifyDataSetChanged()
    }

    fun deleteItem(position: Int) {
        mLists.removeAt(position)
        notifyDataSetChanged()
    }

    fun getDataList(): ArrayList<T> {
        return mLists
    }

    override fun onCreateViewHolder(parent: ViewGroup, viewType: Int): RecyclerView.ViewHolder {
        var layoutRes = mItemViewRes
        if (getLayoutId(viewType) != -1) {
            layoutRes = getLayoutId(viewType)
        }
        val itemView: View =
                LayoutInflater.from(mContext).inflate(layoutRes, parent, false)
        val holder = RVViewHolder<T>(itemView)
        itemView.setOnClickListener {
            mOnClickListener?.onItemClick(itemView, holder.adapterPosition)
        }
        return holder
    }

    override fun getItemCount(): Int {
        return mLists.size
    }

    override fun onBindViewHolder(holder: RecyclerView.ViewHolder, position: Int) {
        val viewHolder = holder as RVViewHolder<T>
        bindItemView(viewHolder, mLists.get(position), position)
    }

    protected abstract fun bindItemView(holder: RVViewHolder<T>, item: T, position: Int)

    public fun setOnItemClickListener(onItemClickListener: OnItemClickListener) {
        mOnClickListener = onItemClickListener
    }

    interface OnItemClickListener {
        fun onItemClick(view: View?, position: Int)
    }
}