#include "stdafx.h"
#include "RaysMessageBox.h"
//#include "VideoPlayingLogic.h"
#include "../src/scene/uiPageConstant.h"

HANDLE hEvent = CreateEvent(NULL, TRUE, FALSE, NULL);
CRaysMessageBox::CRaysMessageBox(LPCTSTR pszResName)
	:SHostWnd(pszResName)
{
	m_pSWndPlay = NULL;
	
	
}

CRaysMessageBox::~CRaysMessageBox()
{
	
}


LRESULT CRaysMessageBox::OnMsgNotify(UINT uMsg, WPARAM wParam, LPARAM lParam, BOOL& bHandled)
{
	return 0L;
}

int CRaysMessageBox::OnCreate(LPCREATESTRUCT lpCreateStruct)
{
	__super::OnCreate(lpCreateStruct);
	return 0;
}

BOOL CRaysMessageBox::OnInitDialog(HWND wndFocus, LPARAM lInitParam)
{
	m_pSWndPlay = FindChildByName2<SRealWnd>(_T("videoplay_playing_realwnd_player"));
	//m_pLoggic = new CVideoPlayingLogic(m_pSWndPlay->GetRealHwnd());
	
	return TRUE;
}

void CRaysMessageBox::OnDestroy()
{

}

void CRaysMessageBox::OnShowWindow(BOOL bShow, UINT nStatus)
{
	
}

void CRaysMessageBox::SetLanguageTranslate(bool chiness)
{
	
}

void  CRaysMessageBox::onClickBtnOK()
{
	m_onButtonChick(0, 0);
}

void CRaysMessageBox::UpdataCameraState(bool cameraSta)
{
	//SButton *m_pVideoBtn = FindChildByName2<SButton>(_T("same_room_btn_canvas_camera_1"));
	if (cameraSta)
	{
		//SImageWnd *m_pImage = FindChildByID2<SImageWnd>(R.id.same_room_canvas_default_1);
		//m_pImage->SetVisible(false);
	}
}

void CRaysMessageBox::UpdataAudioState(bool audioSta)
{

	SButton *m_pAudioBtn = this->FindChildByName2<SButton>(_T("realwnd_btn_canvas_camera_1"));
	if (audioSta)
	{
		
	}
}


void CRaysMessageBox::onClickBtnCancle()
{
	m_onButtonChick(1, 0);
}

void CRaysMessageBox::UpdateVedioWndPos()
{
	if (m_pSWndPlay)
	{
		RECT rcVideo;
		m_pSWndPlay->GetClientRect(&rcVideo);
		if (::IsWindow(m_hWnd))
		{
			::ClientToScreen(m_hWnd, (LPPOINT)&rcVideo);
			::ClientToScreen(m_hWnd, (LPPOINT)&rcVideo + 1);
		}
		::SetWindowPos(m_pSWndPlay->GetRealHwnd(), NULL, rcVideo.left, rcVideo.top, rcVideo.right - rcVideo.left, rcVideo.bottom - rcVideo.top, SWP_NOZORDER);
	}
}

void CRaysMessageBox::OnMove(CPoint ptPos)
{
	CRaysMessageBox();
}

void CRaysMessageBox::PushMessage(onComboBoxClickCB e, int type, LPCTSTR msg)
{
	m_onButtonChick = e;
	SStatic *m_pText = this->FindChildByName2<SStatic>(_T("messagebox_text"));
	//m_pText->SetWindowTextW(msg);

}

void CRaysMessageBox::OnSize(UINT nType, CSize size)
{
	SetMsgHandled(FALSE);
}


RaysMsgBox::RaysMsgBox(HWND hd_, onComboBoxClickCB e, int type,LPCTSTR msg)
{
	msgBox  = new CRaysMessageBox();
	msgBox->Create(hd_, WS_POPUP | WS_CLIPCHILDREN | WS_TABSTOP, WS_EX_TOOLWINDOW, 0, 0, 0, 0);
	msgBox->SendMessage(WM_INITDIALOG);
	msgBox->ShowWindow(SW_SHOW);
	//msgBox->PushMessage(e, type, msg);

}


RaysMsgBox::~RaysMsgBox()
{
	/*if (msgBox)
	{
		msgBox->DestroyWindow();
		delete msgBox;
	}*/
}





