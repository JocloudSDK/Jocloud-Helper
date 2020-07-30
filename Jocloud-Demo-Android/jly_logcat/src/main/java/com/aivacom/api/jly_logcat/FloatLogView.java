package com.aivacom.api.jly_logcat;

import android.content.Context;
import android.util.AttributeSet;
import android.view.View;
import android.widget.Button;
import android.widget.RelativeLayout;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aivacom.api.jly_logcat.adapter.FloatLogAdapter;
import com.aivacom.api.jly_logcat.bean.LogData;

import java.util.ArrayList;

/**
 * Created by zhouwen on 2020/5/18.
 */
public class FloatLogView extends RelativeLayout implements ILog {
    private RecyclerView mRecyclerView;
    private Button mBtnClean;
    private FloatLogAdapter mRVBaseAdapter;

    private ArrayList<LogData> logDataList = new ArrayList<>();

    private ArrayList<LogData> cacheLogData = new ArrayList<>();
    private long lastAddLogTime = System.currentTimeMillis();

    public FloatLogView(@NonNull Context context) {
        super(context);
    }

    public FloatLogView(@NonNull Context context, @Nullable AttributeSet attrs) {
        super(context, attrs);
    }

    public FloatLogView(@NonNull Context context, @Nullable AttributeSet attrs, int defStyleAttr) {
        super(context, attrs, defStyleAttr);
    }

    @Override
    protected void onFinishInflate() {
        super.onFinishInflate();
        mRecyclerView = findViewById(R.id.rv_log);
        mBtnClean = findViewById(R.id.btn_clean);
        initLogData();
        setListener();
    }

    private void setListener() {
        mBtnClean.setOnClickListener(new OnClickListener() {
            @Override
            public void onClick(View v) {
                cleanAllData();
                resetAddLogRunnable();
            }
        });

        mRVBaseAdapter.setRecycleViewListener(new FloatLogAdapter.OnRecycleItemViewListener() {
            @Override
            public void onItemView(int position) {
                // TODO: 2020/5/25 log点击 
            }
        });
    }

    private void updateDataList(ArrayList<LogData> itemLogs) {
        mRVBaseAdapter.getDataList().clear();
        mRVBaseAdapter.setDataList(itemLogs);
        scrollRvToBottom();
    }

    private void addDataList(ArrayList<LogData> itemLogs) {
        mRVBaseAdapter.getDataList().addAll(itemLogs);
        mRVBaseAdapter.notifyDataSetChanged();
    }

    public void cleanAllData() {
        mRVBaseAdapter.getDataList().clear();
        mRVBaseAdapter.notifyDataSetChanged();
    }

    private void updateItemData(LogData itemLog) {
        mRVBaseAdapter.getDataList().add(itemLog);
        mRVBaseAdapter.notifyDataSetChanged();
        scrollRvToBottom();
    }

    private void initLogData() {
        mRecyclerView.setLayoutManager(new LinearLayoutManager(getContext()));
        mRVBaseAdapter = new FloatLogAdapter(getContext(), R.layout.float_item_view);
        mRVBaseAdapter.setDataList(logDataList);
        mRecyclerView.setAdapter(mRVBaseAdapter);
    }

    private void scrollRvToBottom() {
        if (mRecyclerView != null) {
            int count = mRVBaseAdapter.getItemCount();
            if (count > 20) {
                mRecyclerView.scrollToPosition(count - 1);
            }
        }
    }

    @Override
    public void addLog(final LogData logData) {
        cacheLogData.add(logData);
        resetAddLogRunnable();
    }

    @Override
    public void addLogs(final ArrayList<LogData> logData) {
        post(new Runnable() {
            @Override
            public void run() {
                updateDataList(logData);
            }
        });
    }

    private void resetAddLogRunnable() {
        if (System.currentTimeMillis() - lastAddLogTime >= 5 * 1000 && !cacheLogData.isEmpty()) {
            removeCallbacks(addLogRunnable);
            lastAddLogTime = System.currentTimeMillis();
            post(new Runnable() {
                @Override
                public void run() {
                    addDataList(cacheLogData);
                    cacheLogData.clear();
                }
            });
        } else {
            removeCallbacks(addLogRunnable);
            postDelayed(addLogRunnable, 5 * 1000);
        }
    }

    private Runnable addLogRunnable = new Runnable() {
        @Override
        public void run() {
            resetAddLogRunnable();
        }
    };

    @Override
    protected void onDetachedFromWindow() {
        super.onDetachedFromWindow();
        removeCallbacks(addLogRunnable);
    }
}
