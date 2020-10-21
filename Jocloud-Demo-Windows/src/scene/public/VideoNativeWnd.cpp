#include "stdafx.h"
#include "VideoNativeWnd.h"


CVideoNativeWnd::CVideoNativeWnd(HWND minWnd)
{
		m_Wnd = minWnd;
		m_nIndex = 0;
		m_pPopupRealWnd = NULL;
}

static void onRealWndChickBtnFun(HANDLE han_, int type)
{
	CVideoNativeWnd *pWnd = (CVideoNativeWnd*)han_;
	if (pWnd)pWnd->onRealWndChickBtn(type);
}

void CVideoNativeWnd::UpdataCameraState(bool cameraSta)
{
	SButton *m_pVideo = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_camera_1);
	SButton *m_pAudio = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_mic_1);
	if (m_nIndex != 0)
	{
		m_pVideo->SetVisible(TRUE, TRUE);
		m_pAudio->SetVisible(TRUE, TRUE);
	}
	if (!cameraSta)
	{
		SImageWnd *m_pImage = m_pPopupRealWnd->FindChildByID2<SImageWnd>(R.id.realwnd_canvas_default_1);
		m_pVideo->SetAttribute(L"skin", L"skin_btn_camera_open");
		m_pImage->SetVisible(false, TRUE);
	}
	else
	{
		m_pVideo->SetAttribute(L"skin", L"skin_btn_camera_close");
	}
	m_pVideo->SetUserData(cameraSta);
}

void CVideoNativeWnd::UpdataAudioState(bool audioSta)
{
	SButton *m_pVideo = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_camera_1);
	SButton *m_pAudio = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_mic_1);
	if (m_nIndex != 0)
	{
		m_pVideo->SetVisible(TRUE, TRUE);
		m_pAudio->SetVisible(TRUE, TRUE);
	}
	if (!audioSta)
	{
		 m_pAudio->SetAttribute(L"skin", L"skin_btn_mic_open");
		SImageWnd *m_pImage = m_pPopupRealWnd->FindChildByID2<SImageWnd>(R.id.realwnd_canvas_default_1);
		m_pImage->SetVisible(false, TRUE);
	}
	else
	{
		m_pAudio->SetAttribute(L"skin", L"skin_btn_mic_close");
	}
	m_pAudio->SetUserData(audioSta);
}

void CVideoNativeWnd::onInitComplete()
{
	ThunderMessage *thunderMsg = new ThunderMessage();
	memset(thunderMsg, 0, sizeof(ThunderMessage));
	thunderMsg->dwEventID = WM_WND_INITCOMMPLETE;
	thunderMsg->lpBuffer = NULL;
	::SendMessage(m_Wnd, WM_THUNDER_MESSAGE, 0, (LPARAM)thunderMsg);
}
void CVideoNativeWnd::onRealWndChickBtn(int type)
{
	bool nState = 0;
	if (type == 0)
	{
		SButton *m_pAudio = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_camera_1);
		nState = m_pAudio->GetUserData();
		m_pAudio->SetUserData(!nState);
		UpdataCameraState(!nState);
		//UpdataCameraState(nState);
	}
	else
	{
		SButton *m_pVideo = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_mic_1);
		nState = m_pVideo->GetUserData();
		m_pVideo->SetUserData(!nState);
		UpdataAudioState(!nState);
	}
	ThunderMessage *thunderMsg = new ThunderMessage();
	memset(thunderMsg, 0, sizeof(ThunderMessage));
	thunderMsg->dwEventID = WM_WND_REALWMDBTN_CHICK;
	RealWndClickPar *pPar = new RealWndClickPar();
	pPar->nRealWndId = m_nIndex;
	pPar->nBtnClick = type;
	pPar->bBtnStatic = (bool)!nState;
	thunderMsg->lpBuffer = pPar;
	::SendMessage(m_Wnd, WM_THUNDER_MESSAGE, 0, (LPARAM)thunderMsg);
}

CVideoNativeWnd::~CVideoNativeWnd()
{
	if (m_pPopupRealWnd)
	{
		delete m_pPopupRealWnd;
		m_pPopupRealWnd = NULL;
	}
}

void CVideoNativeWnd::onClose()
{

}

 
void CVideoNativeWnd::OnSize(UINT nType, CSize size)
{
	if (true)
	{
		CRect xrcWnd;
		GetClientRect(&xrcWnd);
		HWND hParent = ::GetParent(m_hWnd);
		CRect rcWnd;
		CRect rcWndxx;
		CRect ctrlRect1;
		::GetClientRect(hParent,&rcWndxx);
		::GetClientRect(m_hWnd, &ctrlRect1);
	}
}

void CVideoNativeWnd::SetDefaultWindowShow(ERoomType eType, int index)
{
	if (eType == ERoomType::E_DIFFROOM)
	{
		SWindow *m_pWindow = m_pPopupRealWnd->FindChildByID2<SWindow>(R.id.same_room_canvas_state_top_1);
		SImageWnd *m_pImage = m_pPopupRealWnd->FindChildByID2<SImageWnd>(R.id.realwnd_signal_default_1);
		m_pWindow->SetVisible(true, TRUE);
		m_pImage->SetVisible(true, TRUE);
		if (index == 0)
		{
			//SStatic *pLocalText = m_pPopupRealWnd->FindChildByID2<SStatic>(R.id.realwnd_canvas_state_local);
			//pLocalText->SetWindowTextW(_T("Preview"));
		}else
		{
			//SStatic *pLocalText = m_pPopupRealWnd->FindChildByID2<SStatic>(R.id.realwnd_canvas_state_local);
			//pLocalText->SetWindowTextW(_T("Remote"));
		}
		SButton *m_pMic = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_mic_1);
		SButton *m_pVideo = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_camera_1);
		m_pMic->SetVisible(false, TRUE);
		m_pVideo->SetVisible(false, TRUE);
	}
}

void CVideoNativeWnd::UpdataWindowsPaint(ERoomType eType, bool bPlaying)
{
	SImageWnd *m_pImage = m_pPopupRealWnd->FindChildByID2<SImageWnd>(R.id.realwnd_canvas_default_1);
	SWindow *m_pWindow = m_pPopupRealWnd->FindChildByID2<SWindow>(R.id.same_room_canvas_state_top_1);
	
	m_pImage->SetVisible(!bPlaying, TRUE);
	SButton *m_pMic = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_mic_1);
	SButton *m_pVideo = m_pPopupRealWnd->FindChildByID2<SButton>(R.id.realwnd_btn_canvas_camera_1);
	
	if (m_nIndex != 0 && eType!= E_DIFFROOM)
	{
		m_pMic->SetVisible(bPlaying, TRUE);
		m_pVideo->SetVisible(bPlaying, TRUE);
	}
	if (eType == E_SAMEROOM) //同房间显示不一样
	{
		m_pWindow->SetVisible(bPlaying, TRUE);
		//m_pMic->SetVisible(false, TRUE);
		//m_pVideo->SetVisible(false, TRUE);
	}
	else if (eType == ERoomType::E_DIFFROOM)
	{
		SImageWnd *m_pSignal = m_pPopupRealWnd->FindChildByID2<SImageWnd>(R.id.realwnd_signal_default_1);
		//SStatic *pLocalText = m_pPopupRealWnd->FindChildByID2<SStatic>(R.id.realwnd_canvas_state_local);
		m_pWindow->SetVisible(true, TRUE);
		m_pMic->SetVisible(false, TRUE);
		m_pVideo->SetVisible(false, TRUE);
		if (!bPlaying)
		{
			//pLocalText->SetWindowTextW(_T("Preview"));
			m_pSignal->SetAttribute(L"skin", L"skin_signal_not");
		}
	}
	if (!bPlaying)
	{
		RECT rcPlayWnd;
		GetClientRect(&rcPlayWnd);
		InvalidateRect(&rcPlayWnd, TRUE);	
	}
}

BOOL CVideoNativeWnd::OnInitDialog(HWND wndFocus, LPARAM lInitParam)
{
	//m_pSwndStaticImage = FindChildByName2<CStaticImage>(_T("videoplayer_brower_img_bkg"));

	m_pPopupRealWnd = new CPopupRealWnd();
	m_pPopupRealWnd->SetEventCall(this, onRealWndChickBtnFun);
	m_pPopupRealWnd->Create(m_hWnd, WS_POPUP | WS_CLIPCHILDREN | WS_TABSTOP, WS_EX_TOOLWINDOW, 0, 0, 0, 0);
	m_pPopupRealWnd->SendMessage(WM_INITDIALOG);
	m_pPopupRealWnd->ShowWindow(SW_SHOW);

	//_oLogicLanguageTranslate.setSWindow(m_pPopupRealWnd->GetWindow(0));
	//_oLogicLanguageTranslate.switchLanguate(UIPageTranslateLanguage::PAGE_TRANSLATE_ZH);
	onInitComplete();
	return TRUE;
}

void CVideoNativeWnd::UpdataLinkWorkData(LPCTSTR text)
{
	SStatic *pUidText = m_pPopupRealWnd->FindChildByID2<SStatic>(R.id.realwnd_network_data_1);
	if (pUidText)pUidText->SetWindowTextW(text);
}

void CVideoNativeWnd::UpdataNetWorkData(int type)
{
	SImageWnd *pUidText = m_pPopupRealWnd->FindChildByID2<SImageWnd>(R.id.realwnd_signal_default_1);
	if (type == 0)
	{
		pUidText->SetAttribute(L"skin", L"skin_signal_good_default");
	}else if (type == 1)
	{
		pUidText->SetAttribute(L"skin", L"skin_signal_ordinary_default");
	}
	else if (type == 2)
	{
		pUidText->SetAttribute(L"skin", L"skin_signal_bad_default");
	}
	pUidText->SetVisible(true);
}

void CVideoNativeWnd::SetUidText(LPCTSTR text)
{
	SStatic *pUidText = m_pPopupRealWnd->FindChildByID2<SStatic>(R.id.realwnd_canvas_state_uid_1);
	if (pUidText)pUidText->SetWindowTextW(text);
}

void CVideoNativeWnd::onClickBtnCameraOpen()
{
	SStatic *pUidText = m_pPopupRealWnd->FindChildByID2<SStatic>(R.id.realwnd_canvas_state_uid_1);
	//if (pUidText)pUidText->SetWindowTextW(text);
}

void CVideoNativeWnd::onClickBtnAudioOpen()
{
	SStatic *pUidText = m_pPopupRealWnd->FindChildByID2<SStatic>(R.id.realwnd_canvas_state_uid_1);
	//if (pUidText)pUidText->SetWindowTextW(text);
}
void CVideoNativeWnd::OnMove(CPoint ptPos)
{
	if (m_pPopupRealWnd)
	{
		 RECT rcVideo;
		 GetClientRect(&rcVideo);
		if (::IsWindow(m_hWnd))
		{
			::ClientToScreen(m_hWnd, (LPPOINT)&rcVideo);
		}
		::SetWindowPos(m_pPopupRealWnd->m_hWnd, NULL, rcVideo.left, rcVideo.top, rcVideo.right, rcVideo.bottom, SWP_NOZORDER);
	}
}

void CVideoNativeWnd::OnDestroy()
{
	if (m_pPopupRealWnd)
	{
		m_pPopupRealWnd->DestroyWindow();
		delete m_pPopupRealWnd;
		m_pPopupRealWnd = NULL;
	}
}

void CVideoNativeWnd::UpdateVedioWndPos()
{
	if (m_pPopupRealWnd)
	{
		RECT rcVideo;
		GetClientRect(&rcVideo);
		if (::IsWindow(m_hWnd))
		{
			::ClientToScreen(m_hWnd, (LPPOINT)&rcVideo);
		}
		if (rcVideo.left < 0 || rcVideo.top < 0)  //使用SOUI 最小化时关闭场景UI恢复不了，原因暂时未找到这里做了兼容处理（实际上不需要这样做）
		{
			m_pPopupRealWnd->ShowWindow(SW_HIDE);
			return;
		}
		else
		{
			m_pPopupRealWnd->ShowWindow(SW_SHOW);
		}
		::SetWindowPos(m_pPopupRealWnd->m_hWnd, NULL, rcVideo.left, rcVideo.top, rcVideo.right, rcVideo.bottom, SWP_NOZORDER);
	}
}
int CVideoNativeWnd::onMouseActiavte(HWND wndTopLevel, UINT nHitTest, UINT message) {
	ThunderMessage *thunderMsg = new ThunderMessage();
	memset(thunderMsg, 0, sizeof(ThunderMessage));
	thunderMsg->dwEventID = WM_REALWND_CLICK;
	int *pIndex = new int();
	*pIndex = m_nIndex;
	thunderMsg->lpBuffer = pIndex;
	::SendMessage(m_Wnd, WM_THUNDER_MESSAGE, 0, (LPARAM)thunderMsg);
	return 0;
}
