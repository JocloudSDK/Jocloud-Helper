#include "stdafx.h"
#include "PopupRealWnd.h"
//#include "VideoPlayingLogic.h"
#include "../src/scene/uiPageConstant.h"
CPopupRealWnd::CPopupRealWnd(LPCTSTR pszResName)
	:SHostWnd(pszResName)
{
	//m_pSWndPlay = NULL;
	
	
}

CPopupRealWnd::~CPopupRealWnd()
{
	
}

void CPopupRealWnd::SetEventCall(HANDLE wnd_, onButtonChick onFun)
{
	m_hMainWnd = wnd_;
	m_onButtonChick = onFun;
}

LRESULT CPopupRealWnd::OnMsgNotify(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	return 0L;
}

int CPopupRealWnd::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	__super::OnCreate(lpCreateStruct);
	return 0;
}

BOOL CPopupRealWnd::OnInitDialog(HWND wndFocus, LPARAM lInitParam)
{
	//m_pSWndPlay = FindChildByName2<SRealWnd>(_T("videoplay_playing_realwnd_player"));
	
	return TRUE;
}

void CPopupRealWnd::OnDestroy()
{

}

void CPopupRealWnd::OnShowWindow(BOOL bShow, UINT nStatus)
{
	
}

void CPopupRealWnd::SetLanguageTranslate(bool chiness)
{
	
}

void  CPopupRealWnd::onClickBtnCameraOpen()
{
	m_onButtonChick(m_hMainWnd, 0);
}

void CPopupRealWnd::UpdataCameraState(bool cameraSta)
{
	//SButton *m_pVideoBtn = FindChildByName2<SButton>(_T("same_room_btn_canvas_camera_1"));
	if (cameraSta)
	{
		//SImageWnd *m_pImage = FindChildByID2<SImageWnd>(R.id.same_room_canvas_default_1);
		//m_pImage->SetVisible(false);
	}
}

void CPopupRealWnd::UpdataAudioState(bool audioSta)
{

	SButton *m_pAudioBtn = this->FindChildByName2<SButton>(_T("realwnd_btn_canvas_camera_1"));
	if (audioSta)
	{
		
	}
}


void CPopupRealWnd::onClickBtnAudioOpen()
{
	m_onButtonChick(m_hMainWnd, 1);
}

void CPopupRealWnd::UpdateVedioWndPos()
{
	/*if (m_pSWndPlay)
	{
		RECT rcVideo;
		m_pSWndPlay->GetClientRect(&rcVideo);
		if (::IsWindow(m_hWnd))
		{
			::ClientToScreen(m_hWnd, (LPPOINT)&rcVideo);
			::ClientToScreen(m_hWnd, (LPPOINT)&rcVideo + 1);
		}
		::SetWindowPos(m_pSWndPlay->GetRealHwnd(), NULL, rcVideo.left, rcVideo.top, rcVideo.right - rcVideo.left, rcVideo.bottom - rcVideo.top, SWP_NOZORDER);
	}*/
}

void CPopupRealWnd::OnMove(CPoint ptPos)
{
	//UpdateVedioWndPos();
}

void CPopupRealWnd::OnSize(UINT nType, CSize size)
{
	SetMsgHandled(FALSE);
}





