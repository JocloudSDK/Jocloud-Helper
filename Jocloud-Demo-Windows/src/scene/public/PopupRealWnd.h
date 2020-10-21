#pragma once


#define WM_USERMSG_PLAYING_NOTIFY (WM_USER + 1002)
//class CVideoPlayingLogic;

typedef void(*onButtonChick)(HANDLE haneld_, int nBtnType);
class CPopupRealWnd :public SHostWnd
{
public:
	CPopupRealWnd(LPCTSTR pszResName = _T("LAYOUT:dlg_popupDlg"));

	void SetEventCall(HANDLE wnd_, onButtonChick omFun);
	void UpdataCameraState(bool cameraSta);
	void UpdataAudioState(bool audioSta);

	~CPopupRealWnd();
public:
	void OnMove(CPoint ptPos);
	//CVideoPlayingLogic* GetVideoPlayingLogic();
protected:
	int OnCreate(LPCREATESTRUCT lpCreateStruct);
	BOOL OnInitDialog(HWND wndFocus, LPARAM lInitParam);
	void OnDestroy();
	LRESULT OnMsgNotify(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	void OnShowWindow(BOOL bShow, UINT nStatus);
	void OnSize(UINT nType, CSize size);
	void UpdateVedioWndPos();
	void  onClickBtnCameraOpen();
	void onClickBtnAudioOpen();
	void SetLanguageTranslate(bool chiness);
protected:
	EVENT_MAP_BEGIN()
		EVENT_NAME_COMMAND(L"realwnd_btn_canvas_mic_1", onClickBtnAudioOpen)
		EVENT_NAME_COMMAND(L"realwnd_btn_canvas_camera_1", onClickBtnCameraOpen)
	EVENT_MAP_END()
	BEGIN_MSG_MAP_EX(CVideoPlayingWnd)
		MSG_WM_CREATE(OnCreate)
		MSG_WM_INITDIALOG(OnInitDialog)
		MSG_WM_SHOWWINDOW(OnShowWindow)
		MSG_WM_DESTROY(OnDestroy)
		MSG_WM_MOVE(OnMove)
		MSG_WM_SIZE(OnSize)
		MESSAGE_HANDLER(WM_USERMSG_PLAYING_NOTIFY, OnMsgNotify)
		CHAIN_MSG_MAP(SHostWnd)
		REFLECT_NOTIFICATIONS_EX()
	END_MSG_MAP()


		//EVENT_CHECK_SENDER_ROOT(this)

		/*
		* Description: register button click event
		*/
	
private:
	//SRealWnd* m_pSWndPlay;
	HANDLE m_hMainWnd;
	onButtonChick m_onButtonChick;
	
};

