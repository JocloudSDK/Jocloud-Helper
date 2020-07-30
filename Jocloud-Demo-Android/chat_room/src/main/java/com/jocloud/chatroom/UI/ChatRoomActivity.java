package com.jocloud.chatroom.UI;

import android.annotation.SuppressLint;
import android.content.Intent;
import android.os.Build;
import android.text.Editable;
import android.text.InputFilter;
import android.text.TextUtils;
import android.text.TextWatcher;
import android.util.Log;
import android.view.View;
import android.widget.EditText;
import android.widget.TextView;

import androidx.annotation.NonNull;
import androidx.annotation.RequiresApi;
import androidx.recyclerview.widget.LinearLayoutManager;
import androidx.recyclerview.widget.RecyclerView;

import com.aivacom.api.baseui.WebViewActivity;
import com.aivacom.api.baseui.base.BaseActivity;
import com.aivacom.api.baseui.widget.dialog.puredialog.BottomMenuDialog;
import com.aivacom.api.feedback.view.FeedBackActivity;
import com.aivacom.api.jly_logcat.FloatLogActivity;
import com.aivacom.api.rts.FacadeRtsManager;
import com.aivacom.api.utils.Constant;
import com.aivacom.api.utils.JsonUtil;
import com.aivacom.api.utils.NetworkUtil;
import com.hummer.Error;
import com.hummer.HMR;
import com.hummer.model.Message;
import com.hummer.model.RequestId;
import com.hummer.model.RoomId;
import com.hummer.rts.RoomService;
import com.jocloud.chatroom.R;
import com.jocloud.chatroom.adapter.MessageAdapter;
import com.jocloud.chatroom.bean.ChatMessage;

import java.util.ArrayList;
import java.util.List;
import java.util.Map;
import java.util.Set;

public class ChatRoomActivity extends BaseActivity {

    private EditText mEtUid;
    private EditText mEtRoomId;
    private TextView mTvJoinRoom;
    private TextView mTvMemberCount;
    private RecyclerView mRvMessage;
    private MessageAdapter mMessageAdapter;
    private TextView mTvGoChat;
    private boolean mHasJoinRoom = false;
    private boolean mHasLogin = false;
    private RoomId mRoomId;
    private InputMessageDialog mInputMessageDialog;
    private boolean mIsScrollToBottom = true;
    private View mIvClearLocalUid;
    private View mIvClearLocalRid;
    private boolean mHasOffline = false;

    private RoomService.RoomEventListener mRoomEventListener = new RoomService.RoomEventListener() {
        @Override
        public void onRoomAttributesSet(@NonNull RoomId roomId, long l, @NonNull Map<String, String> map) {
        }

        @Override
        public void onRoomAttributesDeleted(@NonNull RoomId roomId, long l, @NonNull Map<String, String> map) {
        }

        @Override
        public void onRoomAttributesCleared(@NonNull RoomId roomId, long l, @NonNull Map<String, String> map) {
        }

        @Override
        public void onRoomAttributesAddedOrUpdated(@NonNull RoomId roomId, long l, @NonNull Map<String, String> map) {
        }

        @Override
        public void onRoomMessageReceived(@NonNull RoomId roomId, long l, Message message) {
            ChatMessage chatMessage = JsonUtil.toObject(new String(message.getContent()), ChatMessage.class);
            addMessage(chatMessage);
        }
    };

    private RoomService.MemberEventListener mMemberEventListener = new RoomService.MemberEventListener() {
        @Override
        public void onRoomMemberJoined(@NonNull RoomId roomId, @NonNull Set<Long> set) {
            Log.i(TAG, "onRoomMemberJoined: " + set);
            for (Long id : set) {
                addMessage(new ChatMessage(id.toString(),
                        getString(R.string.system_message) + getString(R.string.user_join_room),
                        System.currentTimeMillis(),
                        ChatMessage.SYSTEM));
            }
        }

        @Override
        public void onRoomMemberLeft(@NonNull RoomId roomId, @NonNull Set<Long> set) {
            Log.i(TAG, "onRoomMemberLeft: " + set);
            for (Long id : set) {
                addMessage(new ChatMessage(id.toString(),
                        getString(R.string.system_message) + getString(R.string.user_leave_room),
                        System.currentTimeMillis(),
                        ChatMessage.SYSTEM));

            }
        }

        @Override
        public void onRoomMemberOffline(Set<RoomId> set) {
            Log.i(TAG, "onRoomMemberOffline: " + set);
            mHasOffline = true;
        }

        @Override
        public void onRoomMemberCountChanged(@NonNull RoomId roomId, Integer integer) {
            Log.i(TAG, "onRoomMemberCountChanged: " + integer);
            if (integer == 0) {
                mTvMemberCount.setVisibility(View.GONE);
            } else {
                mTvMemberCount.setVisibility(View.VISIBLE);
            }
            mTvMemberCount.setText(getString(R.string.room_member_count, integer));
        }

        @Override
        public void onRoomMemberAttributesSet(@NonNull RoomId roomId, long l, @NonNull Map<String, String> map) {
        }

        @Override
        public void onRoomMemberAttributesAddedOrUpdated(@NonNull RoomId roomId, long l,
                                                         @NonNull Map<String, String> map) {
        }

        @Override
        public void onRoomMemberAttributesDeleted(@NonNull RoomId roomId, long l, @NonNull Map<String, String> map) {
        }

        @Override
        public void onRoomMemberAttributesCleared(@NonNull RoomId roomId, long l, @NonNull Map<String, String> map) {
        }
    };

    private HMR.Completion mJoinRoomCallBack = new HMR.Completion() {
        @Override
        public void onSuccess(RequestId requestId) {
            mHasJoinRoom = true;
            setButtonEnable(true);
            mTvJoinRoom.setText(R.string.text_leave_room);
            dismissDialogProgress();
        }

        @Override
        public void onFailed(RequestId requestId, Error err) {
            setButtonEnable(false);
            dismissDialogProgress();
            showToast(R.string.toast_failed_join);
        }
    };

    private HMR.Completion mLeaveRoomCallBack = new HMR.Completion() {
        @Override
        public void onSuccess(RequestId requestId) {
            mHasOffline = false;
            Log.i(TAG, "mLeaveRoomCallBack onSuccess");
            mHasJoinRoom = false;
            setButtonEnable(false);
            mTvJoinRoom.setText(R.string.text_join_room);
            mMessageAdapter.clear();
            mRvMessage.setVisibility(View.INVISIBLE);
            mTvMemberCount.setVisibility(View.GONE);
        }

        @Override
        public void onFailed(RequestId requestId, Error err) {
            Log.i(TAG, "mLeaveRoomCallBack onFailed " + err);
            setButtonEnable(true);
        }
    };

    @Override
    protected int getLayoutResId() {
        return R.layout.chat_room;
    }

    @SuppressLint("ClickableViewAccessibility")
    @RequiresApi(api = Build.VERSION_CODES.M)
    @Override
    protected void initView() {

        mTvMemberCount = findViewById(R.id.tv_member_count);
        mTvMemberCount.setOnClickListener(this);

        mEtUid = findViewById(R.id.et_uid);
        mEtRoomId = findViewById(R.id.et_room_id);
        initEditTextUid();
        initEditTextRoomId();

        mTvJoinRoom = findViewById(R.id.tv_join_room);
        mTvJoinRoom.setOnClickListener(this);

        mRvMessage = findViewById(R.id.rv_message);
        mRvMessage.addOnScrollListener(new RecyclerView.OnScrollListener() {
            @Override
            public void onScrollStateChanged(@NonNull RecyclerView recyclerView, int newState) {
                super.onScrollStateChanged(recyclerView, newState);
                mIsScrollToBottom = !recyclerView.canScrollVertically(1);
            }
        });

        mTvGoChat = findViewById(R.id.tv_go_chat);
        mTvGoChat.setOnClickListener(this);

        mIvClearLocalUid = findViewById(R.id.iv_clear_local_uid);
        mIvClearLocalUid.setOnClickListener(this);
        mIvClearLocalRid = findViewById(R.id.iv_clear_local_rid);
        mIvClearLocalRid.setOnClickListener(this);

        findViewById(R.id.iv_log).setOnClickListener(this);
        findViewById(R.id.iv_api).setOnClickListener(this);
        findViewById(R.id.iv_feedback).setOnClickListener(this);
    }

    @Override
    protected void initData() {
        mRvMessage.setLayoutManager(new LinearLayoutManager(getContext()));
        mMessageAdapter = new MessageAdapter(this);
        mRvMessage.setAdapter(mMessageAdapter);

        mEtUid.setText(Constant.mLocalUid);
        mEtRoomId.setText(Constant.mLocalRoomId);

        FacadeRtsManager.getIns().addRoomEventListener(mRoomEventListener);
        FacadeRtsManager.getIns().addMemberEventListener(mMemberEventListener);
    }

    /**
     * init user id edit text
     */
    private void initEditTextUid() {
        mEtUid.setText(Constant.mLocalUid);
        mEtUid.setOnFocusChangeListener((v, hasFocus) -> setHideIvClearUid(hasFocus));
        mEtUid.setFilters(new InputFilter[]{new InputFilter.LengthFilter(6)});
        mEtUid.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!s.toString().equals("0")) {
                    Constant.mLocalUid = s.toString();
                    setJoinRoomBtnEnable();
                    if (mHasLogin) {
                        mHasLogin = false;
                        FacadeRtsManager.getIns().logout();
                    }
                    setHideIvClearUid(true);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.toString().equals("0")) {
                    s.clear();
                }
            }
        });
    }

    /**
     * init room id edit text
     */
    private void initEditTextRoomId() {
        mEtRoomId.setText(Constant.mLocalRoomId);
        mEtRoomId.setOnFocusChangeListener((v, hasFocus) -> setHideIvClearRoomId(hasFocus));
        mEtRoomId.setFilters(new InputFilter[]{new InputFilter.LengthFilter(8)});
        mEtRoomId.addTextChangedListener(new TextWatcher() {
            @Override
            public void beforeTextChanged(CharSequence s, int start, int count, int after) {
            }

            @Override
            public void onTextChanged(CharSequence s, int start, int before, int count) {
                if (!s.toString().equals("0")) {
                    Constant.mLocalRoomId = s.toString();
                    setJoinRoomBtnEnable();
                    setHideIvClearRoomId(true);
                }
            }

            @Override
            public void afterTextChanged(Editable s) {
                if (s.toString().equals("0")) {
                    s.clear();
                }
            }
        });
    }

    private void setJoinRoomBtnEnable() {
        if (TextUtils.isEmpty(Constant.mLocalUid) || TextUtils.isEmpty(Constant.mLocalRoomId)) {
            mTvJoinRoom.setEnabled(false);
        } else {
            mTvJoinRoom.setEnabled(true);
        }
    }

    @Override
    protected int getTitleResId() {
        return R.string.chat_room_title;
    }

    @Override
    protected void onClickBack() {
        if (mHasJoinRoom) {
            showQuitConfirmDialog();
        } else {
            super.onClickBack();
        }
    }

    @Override
    public void onClick(View v) {
        if (v.getId() == R.id.tv_join_room) {
            if (!checkNetwork()) {
                showToast(R.string.network_error);
                return;
            }
            mHasJoinRoom = !mHasJoinRoom;
            if (mHasJoinRoom) {
                handleJoinRoom();
            } else {
                FacadeRtsManager.getIns().leave(mRoomId, mLeaveRoomCallBack);
            }
        } else if (v.getId() == R.id.tv_go_chat) {
            showInputMessageDialog();
        } else if (v.getId() == R.id.iv_api) {
            Intent intent = new Intent(this, WebViewActivity.class);
            intent.putExtra(WebViewActivity.URL, Constant.CHAT_ROOM_API_URL);
            startActivity(intent);
        } else if (v.getId() == R.id.iv_log) {
            startActivity(new Intent(this, FloatLogActivity.class));
        } else if (v.getId() == R.id.iv_feedback) {
            startActivity(new Intent(this, FeedBackActivity.class));
        } else if (v.getId() == R.id.iv_clear_local_uid) {
            mEtUid.setText("");
        } else if (v.getId() == R.id.iv_clear_local_rid) {
            mEtRoomId.setText("");
        } else if (v.getId() == R.id.tv_member_count) {
            handleClickMemberCount();
        }
    }

    private boolean checkNetwork() {
        return checkNetwork(0);
    }

    private boolean checkNetwork(int id) {
        if (!NetworkUtil.isNetworkAvailable(this)) {
            if (id != 0) {
                showToast(id);
            } else {
                showToast(R.string.network_error);
            }
            return false;
        }
        return true;
    }

    private void handleClickMemberCount() {
        if (!checkNetwork()) {
            return;
        }
        if (mHasOffline) {
            showToast(R.string.timeout_leave_room);
            return;
        }
        showDialogProgress();
        FacadeRtsManager.getIns().queryMembers(mRoomId, new HMR.CompletionArg<List<Long>>() {
            @Override
            public void onSuccess(RequestId requestId, List<Long> arg) {
                ArrayList<String> arrayList = new ArrayList();
                for (Long uid : arg) {
                    arrayList.add(uid.toString());
                }
                arrayList.sort((o1, o2) ->
                        o1.equals(Constant.mLocalUid) ? -1 : 0
                );

                BottomMemberView bottomMemberView = new BottomMemberView(ChatRoomActivity.this, arrayList);
                BottomMenuDialog bottomMenuDialog = new BottomMenuDialog(ChatRoomActivity.this,
                        bottomMemberView.getContentView());
                bottomMenuDialog.show();
                dismissDialogProgress();
            }

            @Override
            public void onFailed(RequestId requestId, Error err) {
                dismissDialogProgress();
            }
        });


    }

    /**
     * set ivClearLocalUid Visibility
     *
     * @param hasFocus user id editText has focus
     */
    private void setHideIvClearUid(boolean hasFocus) {
        int oldVisible = mIvClearLocalUid.getVisibility();
        int visible = getClearBtnVisible(oldVisible, hasFocus, TextUtils.isEmpty(Constant.mLocalUid));
        if (oldVisible != visible) {
            mIvClearLocalUid.setVisibility(visible);
        }
    }

    /**
     * set ivClearLocalRid Visibility
     *
     * @param hasFocus room id editText has focus
     */
    private void setHideIvClearRoomId(boolean hasFocus) {
        int oldVisible = mIvClearLocalRid.getVisibility();
        int visible = getClearBtnVisible(oldVisible, hasFocus, TextUtils.isEmpty(Constant.mLocalRoomId));
        if (oldVisible != visible) {
            mIvClearLocalRid.setVisibility(visible);
        }
    }

    /**
     * get new ivClearLocalRid or setHideIvClearUid Visibility
     *
     * @param visible     current visibility
     * @param hasFocus    editText has focus
     * @param textIsEmpty editText is empty
     */
    private int getClearBtnVisible(int visible, boolean hasFocus, boolean textIsEmpty) {
        if (hasFocus) {
            if (textIsEmpty) {
                if (visible != View.GONE) {
                    visible = View.GONE;
                }
            } else {
                if (visible != View.VISIBLE) {
                    visible = View.VISIBLE;
                }
            }
        } else {
            if (visible != View.GONE) {
                visible = View.GONE;
            }
        }
        return visible;
    }

    private void handleJoinRoom() {
        setHideIvClearRoomId(false);
        setHideIvClearUid(false);
        showDialogProgress();
        mEtUid.setEnabled(false);
        mEtRoomId.setEnabled(false);
        mRoomId = new RoomId(Constant.mLocalRoomId);
        if (mHasLogin) {
            FacadeRtsManager.getIns().join(mRoomId, mJoinRoomCallBack);
        } else {
            FacadeRtsManager.getIns()
                    .login(Long.parseLong(Constant.mLocalUid), Constant.CROSS_REGION, null,
                            new FacadeRtsManager.LoginCallBack() {
                                @Override
                                public void onSuccess(RequestId requestId) {
                                    Log.i(TAG, "onSuccess: joinRoomSuccess");
                                    mHasLogin = true;
                                    FacadeRtsManager.getIns().join(mRoomId, mJoinRoomCallBack);
                                }

                                @Override
                                public void onFailed(RequestId requestId, Error err) {
                                    mHasJoinRoom = false;
                                    setButtonEnable(false);
                                }
                            });
        }
    }

    private void setButtonEnable(boolean joinRoomSuccess) {
        mEtUid.setEnabled(!joinRoomSuccess);
        mEtRoomId.setEnabled(!joinRoomSuccess);
        mTvGoChat.setEnabled(joinRoomSuccess);
    }


    @Override
    public void finish() {
        super.finish();
        if (mHasJoinRoom) {
            FacadeRtsManager.getIns().leave(mRoomId, null);
        }
        if (mHasLogin) {
            FacadeRtsManager.getIns().logout();
        }

        FacadeRtsManager.getIns().removeRoomEventListener(mRoomEventListener);
        FacadeRtsManager.getIns().removeMemberEventListener(mMemberEventListener);
    }

    private InputMessageDialog.ISendMessageCallback iSendMessageCallback =
            this::sendMessage;

    private void showInputMessageDialog() {

        if (mInputMessageDialog == null) {
            mInputMessageDialog = new InputMessageDialog(this);
        }
        mInputMessageDialog.show(iSendMessageCallback);
    }

    private void closeInputMessageDialog() {
        if (mInputMessageDialog != null) {
            mInputMessageDialog.dismiss();
        }
    }

    private void sendMessage(String text) {
        if (!checkNetwork()) {
            return;
        }
        if (mHasOffline) {
            showToast(R.string.timeout_leave_room);
            return;
        }
        ChatMessage chatMessage = new ChatMessage(Constant.mLocalUid, text, System.currentTimeMillis(),
                ChatMessage.USER);

        FacadeRtsManager.getIns().sendMessage(mRoomId, new Message("message",
                        JsonUtil.toJson(chatMessage).getBytes()), null,
                new HMR.Completion() {
                    @Override
                    public void onSuccess(RequestId requestId) {
                        Log.i(TAG, "onSuccess: sendMessage success");
                    }

                    @Override
                    public void onFailed(RequestId requestId, Error err) {
                        showToast(R.string.send_failed);
                        Log.i(TAG, "onFailed: sendMessage fail " + err);
                    }
                });
    }

    private void addMessage(ChatMessage chatMessage) {
        mMessageAdapter.addItemData(chatMessage);
        if (mMessageAdapter.getItemCount() == 1) {
            mRvMessage.setVisibility(View.VISIBLE);
        }
        if (mIsScrollToBottom) {
            mRvMessage.scrollToPosition(mMessageAdapter.getItemCount() - 1);
        }
    }

    @Override
    protected void onDestroy() {
        super.onDestroy();
        closeInputMessageDialog();
        if (mHasJoinRoom) {
            FacadeRtsManager.getIns().leave(mRoomId, mLeaveRoomCallBack);
        }
    }
}