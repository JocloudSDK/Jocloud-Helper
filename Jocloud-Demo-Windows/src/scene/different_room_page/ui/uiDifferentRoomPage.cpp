#include "stdafx.h"
#include "UIDifferentRoomPage.h"
#include "../src/scene/public/VideoNativeWnd.h"
#include "../src/scene/public/RaysPublics.h"

#include <ShellAPI.h>
static const char* DiffTAG = "UISameRoomPage";

extern string CTSTR_Randomuid;
extern string CTSTR_RandomRoomid;
extern string CT_strLanguageType;

UIDifferentRoomPage::UIDifferentRoomPage() {
	m_pMediaDeviceManage = NULL;
	memset(&m_videoCanvs, MAX_DIFF_USER_SIZE*sizeof(DiffRemoteUserInfo), 0);
	m_remoteRoomId = "";
	m_localRoomId = "";
	m_taskId = "";
}

UIDifferentRoomPage::~UIDifferentRoomPage() {

}

void UIDifferentRoomPage::init(SOUI::SWindow *pRoot) {
	_pPageRoot = pRoot;
	m_localUid = 0;
	m_RemoteUid = 0;
	m_strMessageInfo = "";
	MessageText = _pPageRoot->FindChildByID2<SStatic>(R.id.MessageInfo_text);

	if(CTSTR_Randomuid == "")CTSTR_Randomuid = CRaysPublics::GetRandom(6);
	if (CTSTR_RandomRoomid == "")CTSTR_RandomRoomid = CRaysPublics::GetRandom(4);

	m_bIsSubSuccess = false;
	m_bIsPushSuccess = false;
	
}

void UIDifferentRoomPage::unInit() {
	
}

void UIDifferentRoomPage::beforeAppear() {
	m_iJoinRoomStatus = JoinRoomStatus::Leave;

	if (m_pMediaDeviceManage == NULL)
	{
		m_pMediaDeviceManage = new CMediaDeviceManage(_pPageRoot,_pPageRoot->FindChildByID2<SComboBox>(R.id.diff_room_cbx_camera),
			_pPageRoot->FindChildByID2<SComboBox>(R.id.diff_room_cbx_audio_input),
			_pPageRoot->FindChildByID2<SComboBox>(R.id.diff_room_cbx_audio_output));

		m_pMediaDeviceManage->ScanVideoDevice();
		m_pMediaDeviceManage->ScanAudioInputDevice();
		m_pMediaDeviceManage->ScanAudioOutputDevice();
	}
	SEdit *pEditUiD = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_edit_uid);
	SEdit *pEditRoomId = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_edit_roomid);
	SEdit *pRemodeEditUiD = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_uid);
	SEdit *ppRemodeEditRoomId = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_roomid);
	pEditUiD->SetWindowTextW(s2ws(CTSTR_Randomuid).c_str());
	pEditRoomId->SetWindowTextW(s2ws(CTSTR_RandomRoomid).c_str());
	pRemodeEditUiD->SetWindowTextW(L"");
	ppRemodeEditRoomId->SetWindowTextW(L"");
	m_videoCanvs[0].m_pSWindow = _pPageRoot->FindChildByID2<SRealWnd>(R.id.diff_room_canvas_0);
	m_videoCanvs[1].m_pSWindow = _pPageRoot->FindChildByID2<SRealWnd>(R.id.diff_room_canvas_1);

	SetRealWndCanvasIndex();
	((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->SetDefaultWindowShow(E_DIFFROOM, 0);
	((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->SetDefaultWindowShow(E_DIFFROOM, 1);
	m_pBtnConnectMic = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_connect_mic);
	m_pBtnPushRtmp = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_rtmp);
	m_pBtnStarPlay = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_start);
	m_pBtnAudioCtrl = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_mic);
	m_pBtnVideoCtrl = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_camera);
	m_pBtnConnectMic->SetUserData(0);
	m_pBtnPushRtmp->SetUserData(0);
	m_pBtnStarPlay->SetUserData(0);
	m_pBtnAudioCtrl->SetUserData(0);
	m_pBtnVideoCtrl->SetUserData(0);
	WidgetStateChange(false);
	m_bIsSubSuccess = false;
	m_bIsPushSuccess = false;
	m_strMessageInfo = "";
	MessageText->SetWindowTextW(L"");
	m_RemoteUidJoined = "";
}

void UIDifferentRoomPage::beforeDisappear() {
	for (int i = 0; i < MAX_DIFF_USER_SIZE; i++)
	{
		SRealWnd * pRealWnd = m_videoCanvs[i].m_pSWindow;
		if (pRealWnd)
		{
			CVideoNativeWnd *pNativeWnd = (CVideoNativeWnd *)pRealWnd->GetData();
			if (pNativeWnd)pNativeWnd->DestroyWindow();
		}
	}
	if (m_pMediaDeviceManage != NULL)
	{
		delete m_pMediaDeviceManage;
		m_pMediaDeviceManage = NULL;
	}
}

void UIDifferentRoomPage::switchLanguage() {
	if (m_iJoinRoomStatus != JoinRoomStatus::Joined)return;
	
	wchar_t text[128] = { 0 };
	if (m_localUid != 0)
	{
		wstring cslocal = CRaysPublics::GetLanguageInfoText(L"messgebox_Preview");
		swprintf_s(text, L"%s%I64d", cslocal.c_str(), m_localUid);
		((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->SetUidText(text);
	}
	
	if (m_RemoteUid != 0)
	{
		wstring csRemote = CRaysPublics::GetLanguageInfoText(L"messgebox_remote_uid");
		memset(text, 0, sizeof(text));
		swprintf_s(text, L"%s%I64d", csRemote.c_str(), m_RemoteUid);
		((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->SetUidText(text);
	}
}

void UIDifferentRoomPage::onClickBtnClearUid()
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)return;
	SEdit *pEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_edit_uid);
	pEdit->SetWindowTextW(L"");
}

void UIDifferentRoomPage::onClickBtnClearTargetUid()
{
	SEdit *pEdit =  _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_uid);
	pEdit->SetWindowTextW(L"");
}

void UIDifferentRoomPage::onClickBtnClearRoomID()
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)return;
	SEdit *pEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_edit_roomid);
	pEdit->SetWindowTextW(L"");
}

void UIDifferentRoomPage::onClickBtnClearRtmp()
{
	SEdit *pEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_rtmp);
	pEdit->SetWindowTextW(L"");
}

void UIDifferentRoomPage::onClickBtnClearTargetRoomID()
{
	SEdit *pEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_roomid);
	pEdit->SetWindowTextW(L"");
}

void UIDifferentRoomPage::SetRealWndCanvasIndex()
{
	for (int i = 0; i < MAX_DIFF_USER_SIZE; i++)
	{
		SRealWnd *pSWindow = (SRealWnd *)m_videoCanvs[i].m_pSWindow;
		const SRealWndParam &param = pSWindow->GetRealWndParam();
		wstring str = param.m_strClassName;
		CVideoNativeWnd *pNativewnd2 = (CVideoNativeWnd *)pSWindow->GetData();
		pNativewnd2->SetIndex(i);
	}
}
void UIDifferentRoomPage::onConnectionStatus(ThunderConnectionStatus status)
{
	
	
}

void UIDifferentRoomPage::onRoomStats(RoomStats stats)
{
	/*char buff[128] = { 0 };
	sprintf_s(buff,"%s:%d.kbps %s:%d.kbps %s:%d.kbps",ws2s(CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_upload_text")).c_str(), 
		ws2s(CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_audio_text")).c_str(),
		ws2s(CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_video_text")).c_str(),stats.txBitrate/1000, stats.txAudioBitrate / 1000, stats.txVideoBitrate / 1000);
	((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->UpdataLinkWorkData(s2ws(buff).c_str());

	if (m_bIsSubSuccess)
	{
		memset(buff, 0, sizeof(buff));
		sprintf_s(buff, "%s:%d.kbps %s:%d.kbps %s:%d.kbps", ws2s(CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_download_text")).c_str(),
			ws2s(CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_audio_text")).c_str(),
			ws2s(CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_video_text")).c_str(),stats.rxBitrate / 1000, stats.rxAudioBitrate / 1000, stats.rxVideoBitrate / 1000);
		((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->UpdataLinkWorkData(s2ws(buff).c_str());
	}*/
	
	wchar_t buff[128] = { 0 };
	swprintf_s(buff, L"%s:%d.kbps %s:%d.kbps %s:%d.kbps", CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_upload_text").c_str(), stats.txBitrate / 1000,
		CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_audio_text").c_str(), stats.txAudioBitrate / 1000,
		CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_video_text").c_str(), stats.txVideoBitrate / 1000);
	((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->UpdataLinkWorkData(buff);

	if (m_bIsSubSuccess)
	{
		memset(buff, 0, sizeof(buff));
		swprintf_s(buff, L"%s:%d.kbps %s:%d.kbps %s:%d.kbps", CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_download_text").c_str(), stats.rxBitrate / 1000,
			CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_audio_text").c_str(), stats.rxAudioBitrate / 1000,
			CRaysPublics::GetLanguageInfoText(L"diff_room_canvas_video_text").c_str(), stats.rxVideoBitrate / 1000);
		((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->UpdataLinkWorkData(buff);
	}
}

CSize UIDifferentRoomPage::getPushSize(int mode)
{
	static CSize pushSize[] = { CSize(640,480),CSize(960,544), CSize(1280,720), CSize(1920,1080) };
	if (mode >= 0 && mode < _countof(pushSize)) {
		return pushSize[mode];
	}
	return CSize(0, 0);
}

void UIDifferentRoomPage::startPushStream()
{

}

void UIDifferentRoomPage::stopPushStream()
{
	
}

bool UIDifferentRoomPage::OnCbxVideoChange(EventArgs *pEvtBase)
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)
	{
		//事件对象强制转换 
		EventHeaderClick *pEvt = (EventHeaderClick*)pEvtBase;
		SComboBox *pComBox = (SComboBox*)pEvt->sender;
		int nSel = pComBox->GetCurSel();
		switchCapture(false);
		switchCapture(true);
	}
	return true;
}

bool UIDifferentRoomPage::OnCbxAudioInputChange(EventArgs *pEvtBase)
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)
	{
		//事件对象强制转换 
		EventHeaderClick *pEvt = (EventHeaderClick*)pEvtBase;
		SComboBox *pComBox = (SComboBox*)pEvt->sender;
		int nSel = pComBox->GetCurSel();
		switchAudioInput();
	}
	return true;
}

bool UIDifferentRoomPage::OnCbxAudioOutPutChange(EventArgs *pEvtBase)
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)
	{
		//事件对象强制转换 
		EventHeaderClick *pEvt = (EventHeaderClick*)pEvtBase;
		SComboBox *pComBox = (SComboBox*)pEvt->sender;
		int nSel = pComBox->GetCurSel();
		switchAudioOutput();
	}
	return true;
}

void UIDifferentRoomPage::PushButtonStateChange(bool bIsPushing)
{
	SButton *m_pClearRtmp = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_target_clear_rtmp);
	SEdit *pTargetEditRtmp = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_rtmp);
	if (bIsPushing)
	{
		m_pBtnPushRtmp->SetAttribute(L"text", L"diff_room_stop_btn_rtmp_text");
		pTargetEditRtmp->EnableWindow(false, true);
		m_pClearRtmp->SetVisible(false, TRUE);
		pTargetEditRtmp->SetAttribute(L"colorText", L"@color/font_text_color_gray3");
	}
	else
	{
		m_pBtnPushRtmp->SetAttribute(L"text", L"diff_room_btn_rtmp_text");
		pTargetEditRtmp->EnableWindow(true, true);
		pTargetEditRtmp->SetAttribute(L"colorText", L"@color/edit_text_color");
		m_pClearRtmp->SetVisible(true, TRUE);
	}
	m_bIsPushSuccess = bIsPushing;
	m_pBtnPushRtmp->SetUserData(bIsPushing);
}

void UIDifferentRoomPage::RestartPushStreamToCDN()
{
	if (m_bIsPushSuccess)
	{
		SEdit *pRtmpUrl = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_rtmp);
		string strUrl = ws2s((wstring)pRtmpUrl->GetWindowTextW());
		PushStreamToCDN(strUrl.c_str(), true);
		PushStreamToCDN(strUrl.c_str(), false);
	}
}

bool UIDifferentRoomPage::PushStreamToCDN(const char *pUrl, bool isStop)
{
	
	if (pUrl == NULL)return false;
	if (isStop)
	{
		MediaManager::instance()->getThunderManager()->removePublishTranscodingStreamUrl(m_taskId.c_str(), pUrl);
		m_taskId = "";
		return true;
	}
	LiveTranscoding transcodingCfg;
	CSize pushSize = getPushSize(0);
	int index = 0;
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined) {
		transcodingCfg.userList[index].bStandard = true;
		transcodingCfg.userList[index].layoutX = 0;
		transcodingCfg.userList[index].layoutY = 0;
		transcodingCfg.userList[index].layoutW = (m_bIsSubSuccess && !m_videoCanvs[1].bVideoStop) ? pushSize.cx / 2 : pushSize.cx;
		transcodingCfg.userList[index].layoutH = pushSize.cy;
		transcodingCfg.userList[index].zOrder = 0;
		transcodingCfg.userList[index].bCrop = true;
		transcodingCfg.userList[index].cropX = 0;
		transcodingCfg.userList[index].cropY = 0;
		transcodingCfg.userList[index].cropW = transcodingCfg.userList[index].layoutW;
		transcodingCfg.userList[index].cropH = pushSize.cy;
		transcodingCfg.userList[index].alpha = 1;
		transcodingCfg.userList[index].audioChannel = 2;
		sprintf_s(transcodingCfg.userList[index].uid, "%I64d", m_localUid);
		strcpy_s(transcodingCfg.userList[index].roomId, sizeof(transcodingCfg.userList[index].roomId), m_localRoomId.c_str());
		index++;

		if (m_bIsSubSuccess && !m_videoCanvs[1].bVideoStop) {
			transcodingCfg.userList[index].bStandard = true;
			transcodingCfg.userList[index].layoutX = pushSize.cx / 2;
			transcodingCfg.userList[index].layoutY = 0;
			transcodingCfg.userList[index].layoutW = pushSize.cx / 2;
			transcodingCfg.userList[index].layoutH = pushSize.cy;
			transcodingCfg.userList[index].zOrder = 0;
			transcodingCfg.userList[index].bCrop = true;
			transcodingCfg.userList[index].cropX = 0;
			transcodingCfg.userList[index].cropY = 0;
			transcodingCfg.userList[index].cropW = pushSize.cx / 2;
			transcodingCfg.userList[index].cropH = pushSize.cy;
			transcodingCfg.userList[index].alpha = 1;
			transcodingCfg.userList[index].audioChannel = 2;
			sprintf_s(transcodingCfg.userList[index].uid, "%I64d", m_RemoteUid);
			strcpy_s(transcodingCfg.userList[index].roomId, sizeof(transcodingCfg.userList[index].roomId), m_remoteRoomId.c_str());
			index++;
		}

		if (index > 0) {
			m_taskId = transcodingCfg.userList[0].uid + m_localRoomId;
			transcodingCfg.transcodingMode = 4;
			transcodingCfg.userCount = index;
			MediaManager::instance()->getThunderManager()->setLiveTranscodingTask(m_taskId.c_str(), transcodingCfg);
		}
		int nResult = MediaManager::instance()->getThunderManager()->addPublishTranscodingStreamUrl(m_taskId.c_str(), pUrl);
		if (nResult == -10)
		{
			CRaysPublics::SendMessageBox(CRaysPublics::GetLanguageInfoText(L"messgebox_input_rtmp_error").c_str(), MB_OK);
			return false;
		}

	}
	return true;
}

void UIDifferentRoomPage::onPushRtmp()
{
	//string strUrl = "rtmp://aliyun-live.upstream.yy.com/live/testStream";
	SEdit *pRtmpUrl = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_rtmp);
	string strUrl = ws2s((wstring)pRtmpUrl->GetWindowTextW());
	if (strUrl.length() == 0 || !CRaysPublics::IsUrlLegal(strUrl.c_str())) {
		CRaysPublics::SendMessageBox(CRaysPublics::GetLanguageInfoText(L"messgebox_input_rtmp_error").c_str(), MB_OK);
		return;
	}

	//strUrl.append("testStream");
	
	if (m_pBtnPushRtmp->GetUserData())
	{
		PushStreamToCDN(strUrl.c_str(), true);
		PutMessageInfo("RTMP stream is stopped");
		PushButtonStateChange(false);
		return;
	}	
	if (PushStreamToCDN(strUrl.c_str(), false))
	{
		PushButtonStateChange(true);
	}
}

void UIDifferentRoomPage::onQuitPage()
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)
	{
		CRaysPublics::SendMessageBox(CRaysPublics::GetLanguageInfoText(L"messgebox_end_live").c_str(), MB_OK);
		return;
	}
	else
	{
		if(CRaysPublics::SendMessageBox(CRaysPublics::GetLanguageInfoText(L"messgebox_Logging_out").c_str(), MB_OKCANCEL)!=1)
		return;
	}

	// 退出房间
	leaveRoom();

	if (_oPageEvent) {
		_oPageEvent(UIPageEvent::PAGE_EVENT_DISAPPEAR_INITIATIVE, nullptr, this);
	}
}

void UIDifferentRoomPage::onClickBtnOpenAudio()
{
	if (m_iJoinRoomStatus != JoinRoomStatus::Joined)
	{
		return;
	}
	bool bIsClick = m_pBtnAudioCtrl->GetUserData();
	if (!bIsClick)
	{
		//MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setInputtingMute(true);
		MediaManager::instance()->getThunderManager()->stopLocalAudioStream(true);
		m_pBtnAudioCtrl->SetAttribute(L"skin", L"skin_close_audio_btn_same");
	}
	else
	{
		MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setInputtingMute(false);
		MediaManager::instance()->getThunderManager()->stopLocalAudioStream(false);
		m_pBtnAudioCtrl->SetAttribute(L"skin", L"skin_btn_audio_open");
	}
	m_pBtnAudioCtrl->SetUserData(!bIsClick);
}

void UIDifferentRoomPage::onClickBtnOpenCamera()
{
	if (m_iJoinRoomStatus != JoinRoomStatus::Joined)return;

	bool bIsClick = m_pBtnVideoCtrl->GetUserData();
	if (!bIsClick)
	{
		switchCapture(false);
		m_pBtnVideoCtrl->SetAttribute(L"skin", L"skin_close_camera_btn_same");
	}
	else
	{
		switchCapture(true);
		m_pBtnVideoCtrl->SetAttribute(L"skin", L"skin_btn_camera_normal");
	}
	m_pBtnVideoCtrl->SetUserData(!bIsClick);
}

void UIDifferentRoomPage::switchCapture(bool switch_) {
	Logd(DiffTAG, Log("switchCapture").addDetail("begin", std::to_string(switch_)));
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined && MediaManager::instance()->getThunderManager()->getVideoDeviceMgr() != NULL) {
		if (switch_)
		{
			MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->startVideoDeviceCapture(m_pMediaDeviceManage->getVideoDevice());
			((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->UpdataCameraState(true);
		}else
		{
			MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->stopVideoDeviceCapture();
			((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->UpdataCameraState(false);
		}
	}
}

void UIDifferentRoomPage::switchAudioInput() {
	Logd(DiffTAG, Log("switchAudioInput").addDetail("begin", std::to_string(0)));
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined) {
		if (MediaManager::instance()->getThunderManager()->getAudioDeviceMgr() != NULL)
		{
			MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setInputtingDevice(m_pMediaDeviceManage->getAudioInputDevice());
		}
	}
}

void UIDifferentRoomPage::switchAudioOutput() {
	Logd(DiffTAG, Log("switchAudioOutput").addDetail("begin", std::to_string(0)));
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined) {
		if (MediaManager::instance()->getThunderManager()->getAudioDeviceMgr() != NULL)
		{
			MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setOutputtingDevice(m_pMediaDeviceManage->getAudioOutputDevice());
		}
	}
}

void UIDifferentRoomPage::PutMessageInfo(const string &strInfo)
{
	struct tm t;
	time_t now;
	time(&now);
	localtime_s(&t, &now);
	char szTimeNow[20] = "\0";
	sprintf_s(szTimeNow, 20, "%.2d:%.2d:%.2d ", t.tm_hour, t.tm_min, t.tm_sec);
	static int writeMsgCount = 0;
	if (writeMsgCount++ > MAX_MESSAGE_COUNT_TEXT)
	{
		m_strMessageInfo.clear();
		writeMsgCount = 0;
	}
	if(m_strMessageInfo.length()>0)m_strMessageInfo.append("\n");

	m_strMessageInfo.append(szTimeNow);
	m_strMessageInfo.append(strInfo.c_str());

	MessageText->SetWindowTextW(s2ws(m_strMessageInfo.c_str()).c_str());
}

void UIDifferentRoomPage::refreshVideoCanvas(int index, bool isPlaying)
{
	if (index < 0 || index > MAX_DIFF_USER_SIZE)return;
	SRealWnd *m_pRealWnd = m_videoCanvs[index].m_pSWindow;
	if (m_pRealWnd)((CVideoNativeWnd*)m_pRealWnd->GetData())->UpdataWindowsPaint(E_DIFFROOM,isPlaying);
}

void UIDifferentRoomPage::onClickBtnDoc()
{
	ShellExecute(NULL, _T("open"), s2ws(g_AppDocUrl).c_str(), NULL, NULL, SW_SHOWNORMAL);
}

void UIDifferentRoomPage::SetDefaultRealWndBag(const char* uid_, bool isShow)
{
	//m_videoCanvs[1].m_pSWindow->SetVisible(isShow, TRUE);
}

void UIDifferentRoomPage::leaveRoom()
{
	Logd(DiffTAG, Log("leaveRoom"));
	
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)
	{
		MediaManager::instance()->getThunderManager()->stopLocalAudioStream(true);
		MediaManager::instance()->getThunderManager()->stopLocalVideoStream(true);
		MediaManager::instance()->getThunderManager()->stopVideoPreview();
		MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->stopVideoDeviceCapture();
		if (m_RemoteUid > 0)
		{
			char RemoteUid[65] = {0};
			sprintf_s(RemoteUid, "%I64d", m_RemoteUid);
			MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(RemoteUid, true);
		}
		m_RemoteUid = 0;
	}
	
	
	MediaManager::instance()->getThunderManager()->leaveRoom();
	m_iJoinRoomStatus = JoinRoomStatus::Leave;
	char msg[128] = { 0 };
	sprintf_s(msg, "UID=%I64d has left the room", m_localUid);
	PutMessageInfo(msg);
	refreshVideoCanvas(0,false);
	((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->SetUidText(L"");
	PutMessageInfo("End live successfully");
	
}

void UIDifferentRoomPage::WidgetStateChange(bool bIsPlaying)
{
	SEdit *pEditUiD = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_edit_uid);
	SEdit *pEditRoomId = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_edit_roomid);
	
	SButton *m_pVideo = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_camera);
	SButton *m_pAudio = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_mic);
	
	SEdit *pTargetEditUiD = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_uid);
	SEdit *pTargetEditRoomId = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_roomid);
	SEdit *pTargetEditRtmp = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_rtmp);

	SButton *m_pClearUid = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_clear_uid);
	SButton *m_pClearRoomid = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_clear_roomid);
	
	SButton *m_pClearTagUid = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_target_clear_uid);
	SButton *m_pClearTagRoomid = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_target_clear_roomid);
	SButton *m_pClearRtmp = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_target_clear_rtmp);

	
	if (bIsPlaying) //开播状态
	{
		pEditUiD->EnableWindow(false);
		pEditRoomId->EnableWindow(false);
		pTargetEditUiD->EnableWindow(true);
		pTargetEditRoomId->EnableWindow(true);
		pTargetEditRtmp->EnableWindow(true);
		m_pClearUid->SetVisible(false, TRUE);
		m_pClearRoomid->SetVisible(false, TRUE);
		m_pClearTagUid->SetVisible(true, TRUE);
		m_pClearTagRoomid->SetVisible(true, TRUE);
		m_pClearRtmp->SetVisible(true, TRUE);

		pEditUiD->SetAttribute(L"colorText", L"@color/font_text_color_gray3");
		pEditRoomId->SetAttribute(L"colorText", L"@color/font_text_color_gray3");
		m_pBtnStarPlay->SetAttribute(L"text", L"same_room_btn_stop_text");
		//m_pBtnStarPlay->SetWindowTextW(CRaysPublics::GetLanguageInfoText(CT_strLanguageType, "stopPlay").c_str());
		m_pVideo->SetAttribute(L"skin", L"skin_btn_camera_normal");
		m_pAudio->SetAttribute(L"skin", L"skin_btn_audio_open");

		pTargetEditUiD->SetAttribute(L"colorText", L"@color/edit_text_color");
		pTargetEditRoomId->SetAttribute(L"colorText", L"@color/edit_text_color");
		pTargetEditRtmp->SetAttribute(L"colorText", L"@color/edit_text_color");
		m_pBtnConnectMic->SetAttribute(L"alpha", L"255");
		m_pBtnPushRtmp->SetAttribute(L"alpha", L"255");
		m_pBtnConnectMic->EnableWindow(true);
		m_pBtnPushRtmp->EnableWindow(true);
		m_pBtnConnectMic->SetAttribute(L"skin", L"skin_png_main_btn");
		m_pBtnPushRtmp->SetAttribute(L"skin", L"skin_png_main_btn");

		((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->SetUidText(L"");
	}
	else
	{
		pEditUiD->EnableWindow(true);
		pEditRoomId->EnableWindow(true);
		pTargetEditUiD->EnableWindow(false);
		pTargetEditRoomId->EnableWindow(false);
		pTargetEditRtmp->EnableWindow(false);
		m_pBtnStarPlay->SetAttribute(L"text", L"same_room_btn_start_text");
		//m_pBtnStarPlay->SetWindowTextW(CRaysPublics::GetLanguageInfoText(CT_strLanguageType, "startPlay").c_str());
		pEditUiD->SetAttribute(L"colorText", L"@color/edit_text_color");
		pEditRoomId->SetAttribute(L"colorText", L"@color/edit_text_color");
		m_pVideo->SetAttribute(L"skin", L"skin_close_camera_btn_same");
		m_pAudio->SetAttribute(L"skin", L"skin_btn_audio_normal");
		pTargetEditUiD->SetAttribute(L"colorText", L"@color/font_text_color_gray3");
		pTargetEditRoomId->SetAttribute(L"colorText", L"@color/font_text_color_gray3");
		pTargetEditRtmp->SetAttribute(L"colorText", L"@color/font_text_color_gray3");

		m_pBtnConnectMic->EnableWindow(false);
		m_pBtnPushRtmp->EnableWindow(false);
		m_pBtnConnectMic->SetAttribute(L"alpha", L"150");
		m_pBtnPushRtmp->SetAttribute(L"alpha", L"150");
		m_pBtnConnectMic->SetAttribute(L"skin", L"skin_main_btn_normal");
		m_pBtnPushRtmp->SetAttribute(L"skin", L"skin_main_btn_normal");
		m_localRoomId = "";
		m_pClearUid->SetVisible(true,TRUE);
		m_pClearRoomid->SetVisible(true, TRUE);
		m_pClearTagUid->SetVisible(false, TRUE);
		m_pClearTagRoomid->SetVisible(false, TRUE);
		m_pClearRtmp->SetVisible(false, TRUE);
	}
}

//开播
void UIDifferentRoomPage::onClickBtnStartPlay()
{
	if (!CRaysPublics::checkIsNetwork())
	{
		CRaysPublics::SendMessageBox(CRaysPublics::GetLanguageInfoText(L"messgebox_network_error").c_str(), MB_OK);
		return;
	}
	int nResult = 0;
	SEdit *pEditUiD = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_edit_uid);
	SEdit *pEditRoomId = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_edit_roomid);
	string strUid = ws2s((wstring)pEditUiD->GetWindowTextW());
	string strRoomId = ws2s((wstring)pEditRoomId->GetWindowTextW());
	if (CRaysPublics::CheckUidAndRoomId(CRaysPublics::GetLanguageInfoText(L"messgebox_input_uid_roomid"),strUid.c_str(), strRoomId.c_str()))return;
	CTSTR_Randomuid = strUid;
	CTSTR_RandomRoomid = strRoomId;
	if (m_pBtnStarPlay->GetUserData())
	{
		if (m_bIsSubSuccess || m_bIsPushSuccess)
		{
			CRaysPublics::SendMessageBox(CRaysPublics::GetLanguageInfoText(L"messgebox_stop_push").c_str(), MB_OK);
			return;
		}
		WidgetStateChange(false);
		m_pBtnStarPlay->SetUserData(false);
		leaveRoom();
		return;
	}
	else
	{
		WidgetStateChange(true);
		m_pBtnStarPlay->SetUserData(true);
	}
	
	m_localUid = wcstoull(pEditUiD->GetWindowTextW(), nullptr, 10);
	char StrUid[65] = { 0 };
	sprintf_s(StrUid, "%I64d", m_localUid);

	m_localRoomId = strRoomId;
	//设置媒体模式
	MediaManager::instance()->getThunderManager()->setMediaMode(PROFILE_NORMAL);
	//设置房间场景模式
	MediaManager::instance()->getThunderManager()->setRoomMode(ROOM_CONFIG_LIVE);
	nResult = MediaManager::instance()->getThunderManager()->setAudioConfig(AUDIO_PROFILE_SPEECH_STANDARD, COMMUT_MODE_LOW, SCENARIO_MODE_STABLE_FIRST);
	//加入房间
	const char* pToken = "";  //本DEMO测试使用空，具体请参考官网。
								//if ((nResult = MediaManager::instance()->getThunderManager()->joinRoom(pToken, strlen(pToken), ws2s(uid).c_str(), ws2s(roomId).c_str())) != 0)
	if ((nResult = MediaManager::instance()->getThunderManager()->joinRoom(pToken, strlen(pToken), strRoomId.c_str(), StrUid)) != 0)
	{
		Logd(DiffTAG, Log("stopLocalVideoStream").addDetail("nResult", std::to_string(nResult)));
		return;
	}
	m_iJoinRoomStatus = JoinRoomStatus::Joining;
	return;
}

void UIDifferentRoomPage::resetVideoConfig() {
	VideoEncoderConfiguration config;
	config.playType = VIDEO_PUBLISH_PLAYTYPE_SINGLE;
	config.publishMode = VIDEO_PUBLISH_MODE_NORMAL_DEFINITION;
	MediaManager::instance()->getThunderManager()->setVideoEncoderConfig(config);
}

void UIDifferentRoomPage::restartVideoDevice() {
	m_pMediaDeviceManage->ScanVideoDevice();
}

void UIDifferentRoomPage::restartMicphoneDevice() {
	m_pMediaDeviceManage->ScanAudioInputDevice();
}

//连麦
void UIDifferentRoomPage::onClickBtnConnectMic()
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined) {
		
		SEdit *pUidEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_uid);
		SEdit *pRoomIdEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_roomid);
		string strTargetUid = ws2s((wstring)pUidEdit->GetWindowTextW());
		string strTargetRoomId = ws2s((wstring)pRoomIdEdit->GetWindowTextW());
		if (CRaysPublics::CheckUidAndRoomId(CRaysPublics::GetLanguageInfoText(L"messgebox_input_remote_uid_roomid"),strTargetUid.c_str(), strTargetRoomId.c_str()))return;

		SButton *pClearTargetuid = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_target_clear_uid);
		SButton *pClearTargetRoomid = _pPageRoot->FindChildByID2<SButton>(R.id.diff_room_btn_target_clear_roomid);

		VideoCanvas canvas = { 0 };
		canvas.renderMode = VIDEO_RENDER_MODE_CLIP_TO_BOUNDS;
		strcpy(canvas.uid, strTargetUid.c_str());

		if (strcmp(m_localRoomId.c_str(), strTargetRoomId.c_str()) == 0)
		{
			CRaysPublics::SendMessageBox(CRaysPublics::GetLanguageInfoText(L"messgebox_diff_RoomID").c_str(), MB_OK);
		}
		if (m_pBtnConnectMic->GetUserData())
		{
			
			m_bIsSubSuccess = false;
			m_pBtnConnectMic->SetAttribute(L"text", L"same_room_btn_connectmic_text");
			pUidEdit->EnableWindow(true);
			pRoomIdEdit->EnableWindow(true);
			pClearTargetuid->SetVisible(true, true);
			pClearTargetRoomid->SetVisible(true, true);
			pUidEdit->SetAttribute(L"colorText", L"@color/edit_text_color");
			pRoomIdEdit->SetAttribute(L"colorText", L"@color/edit_text_color");
			m_pBtnConnectMic->SetUserData(false);
			//取消订阅
			MediaManager::instance()->getThunderManager()->removeSubscribe(strTargetRoomId.c_str(), strTargetUid.c_str());
			canvas.hWnd = NULL;
			strcpy(canvas.uid, strTargetUid.c_str());
			int nResult = 0;
			if ((nResult = MediaManager::instance()->getThunderManager()->setRemoteVideoCanvas(canvas))) // Set the local view
			{
				Logd(DiffTAG, Log("setLocalVideoCanvas").addDetail("nResult", std::to_string(nResult)));
				return;
			}
			MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(strTargetUid.c_str(), true);
			RestartPushStreamToCDN();
			return;
		}
		else
		{
			//订阅
			int nResult = 0;
			if (nResult = MediaManager::instance()->getThunderManager()->addSubscribe(strTargetRoomId.c_str(), strTargetUid.c_str())) // Set the local view
			{
				Logd(DiffTAG, Log("addSubscribe").addDetail("nResult", std::to_string(nResult)));
				return;
			}
			m_remoteRoomId = strTargetRoomId;
			
			m_bIsSubSuccess = true;
			m_pBtnConnectMic->SetAttribute(L"text", L"same_room_btn_canclemic_text");
			pUidEdit->EnableWindow(false);
			pRoomIdEdit->EnableWindow(false);
			pClearTargetuid->SetVisible(false, true);
			pClearTargetRoomid->SetVisible(false, true);
			pUidEdit->SetAttribute(L"colorText", L"@color/font_text_color_gray3");
			pRoomIdEdit->SetAttribute(L"colorText", L"@color/font_text_color_gray3");
			m_pBtnConnectMic->SetUserData(true);
			SRealWnd *pSWindow0 = m_videoCanvs[1].m_pSWindow;
			canvas.hWnd = pSWindow0->GetRealHwnd();
			
			if ((nResult = MediaManager::instance()->getThunderManager()->setRemoteVideoCanvas(canvas))) // Set the local view
			{
				Logd(DiffTAG, Log("setLocalVideoCanvas").addDetail("nResult", std::to_string(nResult)));
				return;
			}
			MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(strTargetUid.c_str(), false);
			SetDefaultRealWndBag("", false);
		}	
	}
}

void UIDifferentRoomPage::CancelSubscribe()
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined) {
		SEdit *pUidEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_uid);
		wstring UId = pUidEdit->GetWindowTextW();
		SEdit *pRoomIdEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_roomid);
		wstring RoomID = pRoomIdEdit->GetWindowTextW();
		MediaManager::instance()->getThunderManager()->removeSubscribe(ws2s(RoomID).c_str(), ws2s(UId).c_str());
	}
}

void UIDifferentRoomPage::onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed)
{
	m_iJoinRoomStatus = JoinRoomStatus::Joined;
	switchCapture(true);
	switchAudioInput();
	switchAudioOutput();

	VideoCanvas canvas = { 0 };
	canvas.renderMode = VIDEO_RENDER_MODE_CLIP_TO_BOUNDS;
	strcpy(canvas.uid, uid);
	canvas.hWnd = m_videoCanvs[0].m_pSWindow->GetRealHwnd();
	int nResult = 0;
	if ((nResult = MediaManager::instance()->getThunderManager()->setLocalVideoCanvas(canvas))) // Set the local view
	{
		Logd(DiffTAG, Log("setLocalVideoCanvas").addDetail("nResult", std::to_string(nResult)));
		return;
	}
	VideoEncoderConfiguration config;
	config.playType = VIDEO_PUBLISH_PLAYTYPE_SINGLE;
	config.publishMode = VIDEO_PUBLISH_MODE_SMOOTH_DEFINITION;
	MediaManager::instance()->getThunderManager()->setVideoEncoderConfig(config); // Set encoding configuration

																				  // 打开预览
	if (nResult = MediaManager::instance()->getThunderManager()->startVideoPreview() != 0)
	{
		Logd(DiffTAG, Log("startVideoPreview").addDetail("nResult", std::to_string(nResult)));
		return;
	}
	//发送本地视频
	if (nResult = MediaManager::instance()->getThunderManager()->stopLocalVideoStream(false) != 0)
	{
		Logd(DiffTAG, Log("stopLocalVideoStream").addDetail("nResult", std::to_string(nResult)));
		return;
	}
	//发送音频视频
	if (nResult = MediaManager::instance()->getThunderManager()->stopLocalAudioStream(false) != 0)
	{
		Logd(DiffTAG, Log("stopLocalAudioStream").addDetail("nResult", std::to_string(nResult)));
		return;
	}
	refreshVideoCanvas(0, true);
	Logd(DiffTAG, Log("onJoinRoomSuccess Success").addDetail("nResult", std::to_string(nResult)));
	PutMessageInfo("Go live successfully");
	char msg[128] = { 0 };
	sprintf_s(msg, "UID=%s joined roomID=%s", uid, roomName);
	PutMessageInfo(msg);
	wstring cslocal = CRaysPublics::GetLanguageInfoText(L"messgebox_Preview");
	cslocal.append(s2ws(uid));
	((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->SetUidText(cslocal.c_str());
	
	return;
}

void UIDifferentRoomPage::onRemoteAudioStopped(const char* uid, bool isStop)
{
	SEdit *pUidEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_uid);
	string strTargetUid = ws2s((wstring)pUidEdit->GetWindowTextW());
	if (strcmp(uid, strTargetUid.c_str()) == 0)
	{
		if (strcmp(m_videoCanvs[1].strUid.c_str(), "") == 0)
		{
			char msg[128] = { 0 };
			sprintf_s(msg, "Subscribe UID=%s roomID=\n%s successfully", uid, m_remoteRoomId.c_str());
			PutMessageInfo(msg);
		}
		m_videoCanvs[1].strUid = uid;
		m_videoCanvs[1].bAudioStop = isStop;
		//((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->UpdataAudioState(!isStop);

		wstring csRemote = CRaysPublics::GetLanguageInfoText(L"messgebox_remote_uid");
		csRemote.append(s2ws(uid));
		((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->SetUidText(csRemote.c_str());
		MediaManager::instance()->getThunderManager()->stopRemoteAudioStream(uid, isStop);
		refreshVideoCanvas(1, true);
		if (m_videoCanvs[1].bVideoStop && isStop)
		{
			refreshVideoCanvas(1, false);
			char msg[128] = { 0 };
			sprintf_s(msg, "Unsubscribe UID=%s roomID=\n%s successfully", uid, m_remoteRoomId.c_str());
			PutMessageInfo(msg);
			((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->SetUidText(L"");
			RestartPushStreamToCDN();
		}
	}
}

void UIDifferentRoomPage::onRemoteVideoStopped(const char* uid, bool isStop)
{
	SEdit *pUidEdit = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_uid);
	string strTargetUid = ws2s((wstring)pUidEdit->GetWindowTextW());
	if (strcmp(uid, strTargetUid.c_str())==0)
	{
		if (strcmp(m_videoCanvs[1].strUid.c_str(), "") == 0)
		{
			char msg[128] = { 0 };
			sprintf_s(msg, "Subscribe UID=%s roomID=\n%s successfully", uid, m_remoteRoomId.c_str());
			PutMessageInfo(msg);
		}
		m_videoCanvs[1].strUid = uid;
		m_RemoteUid = strtoul((const char*)uid, 0, 10);
		m_videoCanvs[1].bVideoStop = isStop;
		wstring csRemote = CRaysPublics::GetLanguageInfoText(L"messgebox_remote_uid");
		csRemote.append(s2ws(uid));
		((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->SetUidText(csRemote.c_str());
		MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(uid, isStop);
		refreshVideoCanvas(1, true);
		SetDefaultRealWndBag("", true);
		if (m_videoCanvs[1].bAudioStop && isStop)
		{
			refreshVideoCanvas(1, false);
			char msg[128] = { 0 };
			sprintf_s(msg, "Unsubscribe UID=%s roomID=\n%s successfully", uid, m_remoteRoomId.c_str());
			PutMessageInfo(msg);
			((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->SetUidText(L"");
			RestartPushStreamToCDN();
		}else if (!isStop)
		{
			RestartPushStreamToCDN();
		}
	}
}

void UIDifferentRoomPage::onWndPosChanged()
{
	for (int i = 0; i < MAX_DIFF_USER_SIZE; i++)
	{
		SRealWnd * pRealWnd = m_videoCanvs[i].m_pSWindow;
		if (pRealWnd)
		{
			CVideoNativeWnd *pNativeWnd = (CVideoNativeWnd *)pRealWnd->GetData();
			if (pNativeWnd)pNativeWnd->UpdateVedioWndPos();
		}
	}
}

void UIDifferentRoomPage::onRealWndChick(int wndID, int type, bool bBtnState)
{
	if (wndID > MAX_DIFF_USER_SIZE)return;
	if (type == 0)//camera
	{
		MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(m_videoCanvs[wndID].strUid.c_str(), bBtnState);
	}
	else if (type == 1)//audio
	{
		MediaManager::instance()->getThunderManager()->stopRemoteAudioStream(m_videoCanvs[wndID].strUid.c_str(), bBtnState);
	}
}
void UIDifferentRoomPage::onNetworkQuality(const char* uid, NetworkQuality txQuality, NetworkQuality rxQuality)
{
	if (m_iJoinRoomStatus != JoinRoomStatus::Joined)return;
	((CVideoNativeWnd*)m_videoCanvs[0].m_pSWindow->GetData())->UpdataNetWorkData(0);
	if (strcmp(uid, m_videoCanvs[1].strUid.c_str()) == 0 && m_bIsSubSuccess)
	{
		if(rxQuality<THUNDER_QUALITY_POOR)
			((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->UpdataNetWorkData(0);
		else if(rxQuality == THUNDER_QUALITY_BAD)
			((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->UpdataNetWorkData(1);
		else 
			((CVideoNativeWnd*)m_videoCanvs[1].m_pSWindow->GetData())->UpdataNetWorkData(2);
	}	
}

void UIDifferentRoomPage::onPublishStreamToCDNStatus(ThunderPublishCDNErrorCode errorCode)
{
	SEdit *pRtmpUrl = _pPageRoot->FindChildByID2<SEdit>(R.id.diff_room_target_edit_rtmp);
	string strUrl = ws2s((wstring)pRtmpUrl->GetWindowTextW());
	if (errorCode == THUNDER_PUBLISH_CDN_ERR_SUCCESS)
	{
		PutMessageInfo("Pushing " + strUrl);
		//PushButtonStateChange(true);
	}
	else if (errorCode == THUNDER_PUBLISH_CDN_ERR_TOCDN_FAILED || errorCode == THUNDER_PUBLISH_CDN_ERR_THUNDERSERVER_FAILED)
	{
		//PushButtonStateChange(false);
		PutMessageInfo("Failed to push " + strUrl);
	}
	else if (errorCode == THUNDER_PUBLISH_CDN_ERR_THUNDERSERVER_STOP)
	{
		//PushButtonStateChange(false);
		PutMessageInfo("RTMP stream is stopped");
	}
}

LRESULT UIDifferentRoomPage::onThunderManagerCB(UINT uMsg, WPARAM wp, LPARAM lp, BOOL &bHandle)
{
	switch (uMsg)
	{
	case WM_WND_POSCHANGE:
	{
		onWndPosChanged();
		break;
	}
	case WM_JOIN_ROOM_SUCCESS:
	{
		JoinRoomPar *pRoomPar = (JoinRoomPar *)lp;
		if (pRoomPar) {
			onJoinRoomSuccess(pRoomPar->roomName, pRoomPar->uid, pRoomPar->elapsed);
			delete pRoomPar;
		}

		break;
	}case WM_USER_STOP_VIDEO:
	{
		RemoteUserPar *pUserPar = (RemoteUserPar *)lp;
		if (pUserPar) {
			onRemoteVideoStopped(pUserPar->uid, pUserPar->elapsed);
			delete pUserPar;
		}
		break;
	}case WM_WND_REALWMDBTN_CHICK:
	{
		RealWndClickPar *pUserPar = (RealWndClickPar *)lp;
		if (pUserPar) {
			onRealWndChick(pUserPar->nRealWndId, pUserPar->nBtnClick, pUserPar->bBtnStatic);
			delete pUserPar;
		}
		break;
	}
	case WM_USER_STOP_AUDIO:
	{
		RemoteUserPar *pUserPar = (RemoteUserPar *)lp;
		if (pUserPar) {
			if (pUserPar)onRemoteAudioStopped(pUserPar->uid, pUserPar->elapsed);
			delete pUserPar;
		}
		break;
	}
	case WM_VIDEO_CAPTURE_STATUS:
	{
		LocalVideoStats *pUserPar = (LocalVideoStats *)lp;
		if (pUserPar) {
			//onLocalVideoStats(pUserPar);
			delete pUserPar;
		}
		break;
	}
	case WM_WND_INITCOMMPLETE:
	{
		//SetRealWndCanvasIndex();
		break;
	}case WM_NETWORKDATA_COME:
	{
		ThunderConnectionStatus *pSta = (ThunderConnectionStatus *)lp;
		if (pSta) {
			onConnectionStatus(*pSta);
			delete pSta;
		}
		break;
	}
	case WM_ROOMSTATE:
	{
		RoomStats *pSta = (RoomStats *)lp;
		if (pSta) {
			onRoomStats(*pSta);
			delete pSta;
		}
		break;
	}
	case WM_QUALITY:
	{
		TTNetworkQuality *pSta = (TTNetworkQuality *)lp;
		if (pSta) {
			onNetworkQuality(pSta->strUid.c_str(), pSta->txQuality, pSta->rxQuality);
			delete pSta;
		}
		break;
	}case WM_PUBLISHSTREAM:
	{
		ThunderPublishCDNErrorCode *par = (ThunderPublishCDNErrorCode *)lp;
		if (par) {
			onPublishStreamToCDNStatus(*par);
			delete par;
		}
		break;
	}
	case WM_DEVICE_DETECTED:
	{
		DeviceDetected *pDevice = (DeviceDetected *)lp;
		if (pDevice)
		{
			m_pMediaDeviceManage->OnDeviceDetected(pDevice);
			delete pDevice->deviceId;
			delete pDevice;
		}
	}
	break;
	default:
		break;
	}
	return 0;
}
