#pragma once

#include <WinDef.h>
#include "PopupRealWnd.h"
//#include "../src/scene/main/logic/logicLanguageTranslate.h"

typedef enum ERoomType
{
	E_SAMEROOM = 0,
	E_DIFFROOM = 1
}eRoomType;

class CVideoNativeWnd : public SNativeWnd
{

public:
	CVideoNativeWnd(HWND minWnd);
	~CVideoNativeWnd();
	
	void SetIndex(int dex) {
		m_nIndex = dex;
		
	}
	void SetDefaultWindowShow(ERoomType eType,int index);
	void UpdateVedioWndPos();
	void SetUidText(LPCTSTR text);
	void UpdataCameraState(bool cameraSta);
	void UpdataAudioState(bool audioSta);
	void onRealWndChickBtn(int type);
	void UpdataLinkWorkData(LPCTSTR);
	void UpdataNetWorkData(int type);
	void UpdataWindowsPaint(ERoomType eType,bool bPlaying);
protected:
	void onClose();
	int onMouseActiavte(HWND wndTopLevel, UINT nHitTest, UINT message);
	void onRestore(){}
	void onMinimize() {}
	void OnMove(CPoint ptPos);
	void OnSize(UINT nType, CSize size);
	void OnDestroy();
	BOOL OnInitDialog(HWND wndFocus, LPARAM lInitParam);
	void onClickBtnAudioOpen();
	void onClickBtnCameraOpen();
	void onInitComplete();
	
	BEGIN_MSG_MAP_EX(CVideoNativeWnd)
		//托盘消息处理
		MSG_WM_INITDIALOG(OnInitDialog)
		MSG_WM_CLOSE(onClose)
		//MSG_WM_MOUSEACTIVATE(onMouseActiavte)
		MSG_WM_MOVE(OnMove)
		MSG_WM_SIZE(OnSize)
		MSG_WM_DESTROY(OnDestroy)
		CHAIN_MSG_MAP(SNativeWnd)
		END_MSG_MAP()
	
private:
	HWND m_Wnd;
	UINT32 m_nIndex;
	CPopupRealWnd *m_pPopupRealWnd;
	//LogicLanguageTranslate _oLogicLanguageTranslate;
};

