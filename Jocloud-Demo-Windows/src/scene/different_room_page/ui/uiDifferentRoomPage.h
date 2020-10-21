/*
 * File: uiDifferentRoomPage
 * Author: LanPZzzz
 * Date: 2020/06/04
 * Description: 
 */
#pragma once

#include "stdafx.h"
#include "../src/scene/public/MediaDeviceManage.h"

struct DiffRemoteUserInfo
{
	bool bAudioStop;
	bool bVideoStop;
	bool video;
	bool audio;
	string strUid;
	SRealWnd *m_pSWindow;
};
#define MAX_DIFF_USER_SIZE 2
class UIDifferentRoomPage : public IUIBasePage {
public:
	UIDifferentRoomPage();
	virtual ~UIDifferentRoomPage();

	virtual void init(SOUI::SWindow *pRoot) override;

	virtual void unInit() override;

	virtual void beforeAppear() override;

	virtual void beforeDisappear() override;
	virtual LRESULT onThunderManagerCB(UINT uMsg, WPARAM wp, LPARAM lp, BOOL &bHandle);

	virtual void switchLanguage() override;

protected:
	void switchCapture(bool switch_);
	void switchAudioInput();
	void switchAudioOutput();
	void resetVideoConfig();
	void restartVideoDevice();
	void restartMicphoneDevice();
	void CancelSubscribe();
	void onClickBtnStartPlay();
	void onClickBtnConnectMic(); 
	void onClickBtnClearRtmp();
	void onClickBtnOpenCamera();
	void onClickBtnOpenAudio();
	void onQuitPage();
	void onPushRtmp();
	void onConnectionStatus(ThunderConnectionStatus status);
	void onRoomStats(RoomStats stats);
	void onNetworkQuality(const char* uid, NetworkQuality txQuality, NetworkQuality rxQuality);
	CSize getPushSize(int mode);

	void onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed);
	void onRemoteAudioStopped(const char* uid, bool isStop);
	void onRemoteVideoStopped(const char* uid, bool isStop);
	void onClickBtnClearUid();
	void onClickBtnClearTargetUid();
	void onClickBtnClearRoomID();
	void onClickBtnClearTargetRoomID();
	void SetRealWndCanvasIndex();
	void onRealWndChick(int wndID, int type, bool bBtnState);
	void onPublishStreamToCDNStatus(ThunderPublishCDNErrorCode errorCode);

	void leaveRoom();
	void PutMessageInfo(const string &strInfo);
	void refreshVideoCanvas(int index, bool isPlaying);
	void onWndPosChanged();
	void onClickBtnDoc();
	void startPushStream();
	void stopPushStream();
	bool OnCbxVideoChange(EventArgs *e);
	bool OnCbxAudioInputChange(EventArgs *e);
	bool OnCbxAudioOutPutChange(EventArgs *e);
	void WidgetStateChange(bool bIsPlaying);
	void PushButtonStateChange(bool bIsPushing);
	bool PushStreamToCDN(const char *pUrl,bool isStop);
	void RestartPushStreamToCDN();
	void SetDefaultRealWndBag(const char* uid_, bool isShow);

protected:
	EVENT_MAP_BEGIN()
		EVENT_CHECK_SENDER_ROOT(_pPageRoot)
		EVENT_NAME_COMMAND(L"diff_room_btn_start", onClickBtnStartPlay)
		EVENT_NAME_COMMAND(L"diff_room_btn_connect_mic", onClickBtnConnectMic)
		EVENT_NAME_COMMAND(L"diff_room_btn_clear_uid", onClickBtnClearUid)
		EVENT_NAME_COMMAND(L"diff_room_btn_target_clear_uid", onClickBtnClearTargetUid)
		EVENT_NAME_COMMAND(L"diff_room_btn_clear_roomid", onClickBtnClearRoomID)
		EVENT_NAME_COMMAND(L"diff_room_btn_target_clear_roomid", onClickBtnClearTargetRoomID)
		EVENT_NAME_COMMAND(L"diff_room_btn_target_clear_rtmp", onClickBtnClearRtmp)
		EVENT_NAME_COMMAND(L"diff_room_btn_camera", onClickBtnOpenCamera)
		EVENT_NAME_COMMAND(L"diff_room_btn_mic", onClickBtnOpenAudio)
		EVENT_NAME_COMMAND(L"diff_room_btn_quit", onQuitPage)
		EVENT_NAME_COMMAND(L"diff_room_btn_api", onClickBtnDoc)
		EVENT_NAME_COMMAND(L"diff_room_btn_rtmp", onPushRtmp)
		EVENT_ID_HANDLER(R.id.diff_room_cbx_camera, EventCBSelChange::EventID, OnCbxVideoChange)
		EVENT_ID_HANDLER(R.id.diff_room_cbx_audio_input, EventCBSelChange::EventID, OnCbxAudioInputChange)
		EVENT_ID_HANDLER(R.id.diff_room_cbx_audio_output, EventCBSelChange::EventID, OnCbxAudioOutPutChange)
		
		
	EVENT_MAP_BREAK()

private:
	CMediaDeviceManage *m_pMediaDeviceManage;
	JoinRoomStatus m_iJoinRoomStatus;
	__int64 m_localUid;
	__int64 m_RemoteUid;
	string m_RemoteUidJoined;
	string m_strMessageInfo;
	SStatic *MessageText;
	DiffRemoteUserInfo m_videoCanvs[MAX_DIFF_USER_SIZE];
	bool m_bIsSubSuccess;
	bool m_bIsPushSuccess;
	string m_remoteRoomId;
	string m_localRoomId;
	string m_taskId;
	
	SButton *m_pBtnStarPlay;
	SButton *m_pBtnConnectMic;
	SButton *m_pBtnPushRtmp;
	SButton *m_pBtnAudioCtrl;
	SButton *m_pBtnVideoCtrl;
	//string strRandomuid;
	//string strRandomRoomid;
};
