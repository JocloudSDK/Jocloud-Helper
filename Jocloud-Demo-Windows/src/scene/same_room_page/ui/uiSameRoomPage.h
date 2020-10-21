/*
 * File: uiSameRoomPage
 * Author: LanPZzzz
 * Date: 2020/06/04
 * Description: 
 */
#pragma once

#include "stdafx.h"
#include "../src/scene/public/MediaDeviceManage.h"
#include "../src/scene/public/RemoteUserList.h"


#define VideoCanvasMaxSize 4
typedef struct UserVideoCanvas
{
	SStatic* m_uidText;
	SRealWnd* m_videoCavas;
	string m_uid;
	bool m_bigCanvas;
	SButton* m_StopVideoBtn;
	SButton* m_StopAudioBtn;

}tUserVideoCanvas;


class UISameRoomPage : public IUIBasePage {
public:
	UISameRoomPage();
	virtual ~UISameRoomPage();

	virtual void init(SOUI::SWindow *pRoot) override;

	virtual void unInit() override;

	virtual void beforeAppear() override;

	virtual void beforeDisappear() override;

	void switchLanguage() override;
	virtual LRESULT onThunderManagerCB(UINT uMsg, WPARAM wp, LPARAM lp, BOOL &bHandle);

protected:
	void onClickBtnSameQuit();
	void onClickBtnStartPlay();
	void onClickBtnOpenCamera();
	void onClickBtnOpenAudio();
	void onClickBtnClearUid();
	void onClickBtnClearRoomId();
	void onWndPosChanged();

	void resetVideoConfig();
	void restartVideoDevice();
	void restartMicphoneDevice();

	void switchCapture(bool switch_);
	void switchAudioInput(bool switch_);
	void switchAudioOutput(bool switch_);
	void onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed);
	void onRemoteAudioStopped(const char* uid, bool stop);
	void onRemoteVideoStopped(const char* uid, bool stop);
	void onLocalVideoStats(const LocalVideoStats* stats);
	void onClickBtnQuit();
	void onRealWndChick(int wndID, int type,bool bBtnState);
	void onRealWndCilck(UINT32 index);
	void UpdataUserData(const char* uid, bool stop);
	
	void bindVideoCanvas();
	int setRemoteVideoCanvas(const char* uid, HWND hwnd);
	void bindUserToCanvas(int index, const char* uid);
	void leaveRoom();
	void refreshVideoCanvas(int index,bool isPlaying);
	
	void SetRealWndCanvasIndex();

	void VideoChangeCanvas(UINT32 index,bool siUseBig);
	string FindUidFormMap(UINT32 key_);
	int getCanvas(const char* uid, bool local);
	int RemoteUserCanvasChange(int srcIndex);
	void PutMessageInfo(const string &strInfo);
	void PackageMessage(LPCWSTR info);
	void onClickBtnDoc();
	void SetButtonVisible(int id, bool sta);
	void UpdataWindowsPaint(bool bIsUpdata);
	void WidgetStateChange(bool bIsPlaying);
	void InitialiVideoRealWnd();
	
	bool OnCbxVideoChange(EventArgs *e);
	bool OnCbxAudioInputChange(EventArgs *e);
	bool OnCbxAudioOutPutChange(EventArgs *e);
	void SetDefaultRealWndBag(const char* uid_,bool isShow);
protected:
	EVENT_MAP_BEGIN()
		EVENT_CHECK_SENDER_ROOT(_pPageRoot)

		/*
		* Description: register button click event
		*/
		EVENT_NAME_COMMAND(L"btn_quick_same_quit", onClickBtnSameQuit)
		EVENT_NAME_COMMAND(L"same_room_btn_start", onClickBtnStartPlay)
		EVENT_NAME_COMMAND(L"same_room_btn_camera", onClickBtnOpenCamera)
		EVENT_NAME_COMMAND(L"same_room_btn_quit", onClickBtnQuit)
		//EVENT_NAME_COMMAND(L"same_room_big_canvas_1", onClickBtnQuit)
		EVENT_NAME_COMMAND(L"same_room_btn_mic", onClickBtnOpenAudio)
		EVENT_NAME_COMMAND(L"same_room_btn_clear_uid", onClickBtnClearUid)
		EVENT_NAME_COMMAND(L"same_room_btn_clear_roomid", onClickBtnClearRoomId)
		EVENT_NAME_COMMAND(L"same_room_btn_api", onClickBtnDoc)
		EVENT_ID_HANDLER(R.id.same_room_cbx_camera, EventCBSelChange::EventID, OnCbxVideoChange)
		EVENT_ID_HANDLER(R.id.same_room_cbx_audio_input, EventCBSelChange::EventID, OnCbxAudioInputChange)
		EVENT_ID_HANDLER(R.id.same_room_cbx_audio_output, EventCBSelChange::EventID, OnCbxAudioOutPutChange)
	EVENT_MAP_BREAK()

private:
	string m_localUid;
	UserVideoCanvas m_videoCanvs[VideoCanvasMaxSize];
	CMediaDeviceManage *m_pMediaDeviceManage;
	UINT32  m_UseBigCanvasIndex;
	string m_strMessageInfo;
	SStatic *MessageText;
	JoinRoomStatus m_iJoinRoomStatus;
	SButton *m_pBtnStarPlay;
	SButton *m_pBtnAudioCtrl;
	SButton *m_pBtnVideoCtrl;
	CRemoteUserList m_RemoteUserList;
};
