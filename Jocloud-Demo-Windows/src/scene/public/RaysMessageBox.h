#pragma once

#define WM_USERMSG_PLAYING_NOTIFY (WM_USER + 1002)

typedef std::function<void(int nComType, int nSel) > onComboBoxClickCB;
class CRaysMessageBox :public SHostWnd
{
public:
	CRaysMessageBox(LPCTSTR pszResName = _T("LAYOUT:xml_messagebox"));

	//void SetEventCall(HANDLE wnd_, onButtonChick omFun);
	void UpdataCameraState(bool cameraSta);
	void UpdataAudioState(bool audioSta);

	~CRaysMessageBox();
public:
	void OnMove(CPoint ptPos);
	void PushMessage(onComboBoxClickCB e,int type,LPCTSTR msg);
protected:
	int OnCreate(LPCREATESTRUCT lpCreateStruct);
	BOOL OnInitDialog(HWND wndFocus, LPARAM lInitParam);
	void OnDestroy();
	LRESULT OnMsgNotify(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled);
	void OnShowWindow(BOOL bShow, UINT nStatus);
	void OnSize(UINT nType, CSize size);
	void UpdateVedioWndPos();
	void  onClickBtnCancle();
	void onClickBtnOK();
	void SetLanguageTranslate(bool chiness);
protected:
	EVENT_MAP_BEGIN()
		EVENT_NAME_COMMAND(L"realwnd_btn_ok", onClickBtnOK)
		EVENT_NAME_COMMAND(L"realwnd_btn_cancel", onClickBtnCancle)
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
	//CVideoPlayingLogic* m_pLoggic;
	SRealWnd* m_pSWndPlay;
	HANDLE m_hMainWnd;
	onComboBoxClickCB m_onButtonChick;
	
};


class RaysMsgBox
{
public:
	RaysMsgBox(HWND hd_, onComboBoxClickCB e, int type, LPCTSTR msg);
	void PushMessage(LPCTSTR msg);
	~RaysMsgBox();

private:
	CRaysMessageBox *msgBox;
};



