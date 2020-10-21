#include "stdafx.h"
#include "UISameRoomPage.h"
#include "../src/scene/public/VideoNativeWnd.h"
#include <ShellAPI.h>
#include "../src/scene/public/RaysMessageBox.h"
#include "../src/scene/public/RaysPublics.h"
static const char* SameTAG = "UISameRoomPage";

string CTSTR_Randomuid = "";
string CTSTR_RandomRoomid ="";

extern string CT_strLanguageType;

UISameRoomPage::UISameRoomPage() {
	m_localUid = "";
	m_pMediaDeviceManage = NULL;
	m_UseBigCanvasIndex = 0;
	m_iJoinRoomStatus = JoinRoomStatus::Leave;
}

UISameRoomPage::~UISameRoomPage() {

}

void UISameRoomPage::init(SOUI::SWindow *pRoot) {
	IUIBasePage::init(pRoot);
	if (CTSTR_Randomuid == "")CTSTR_Randomuid = CRaysPublics::GetRandom(6);
	if (CTSTR_RandomRoomid == "")CTSTR_RandomRoomid = CRaysPublics::GetRandom(4);
}

void UISameRoomPage::unInit() {
	
}


void UISameRoomPage::beforeAppear() {
	if (m_pMediaDeviceManage == NULL)
	{
		m_pMediaDeviceManage = new CMediaDeviceManage(_pPageRoot,_pPageRoot->FindChildByID2<SComboBox>(R.id.same_room_cbx_camera),
			_pPageRoot->FindChildByID2<SComboBox>(R.id.same_room_cbx_audio_input),
			_pPageRoot->FindChildByID2<SComboBox>(R.id.same_room_cbx_audio_output));

		m_pMediaDeviceManage->ScanVideoDevice();
		m_pMediaDeviceManage->ScanAudioInputDevice();
		m_pMediaDeviceManage->ScanAudioOutputDevice();

		//m_pMediaDeviceManage->SubscribeEvent(std::bind(&UISameRoomPage::OnSubscribeEventCB,this, std::placeholders::_1, std::placeholders::_2));	
	}
	SEdit *pEditUiD = _pPageRoot->FindChildByID2<SEdit>(R.id.same_room_edit_uid);
	SEdit *pEditRoomId = _pPageRoot->FindChildByID2<SEdit>(R.id.same_room_edit_roomid);
	pEditUiD->SetWindowTextW(s2ws(CTSTR_Randomuid).c_str());
	pEditRoomId->SetWindowTextW(s2ws(CTSTR_RandomRoomid).c_str());
	
	m_pBtnStarPlay = _pPageRoot->FindChildByID2<SButton>(R.id.same_room_btn_start);
	m_pBtnAudioCtrl = _pPageRoot->FindChildByID2<SButton>(R.id.same_room_btn_mic);
	m_pBtnVideoCtrl = _pPageRoot->FindChildByID2<SButton>(R.id.same_room_btn_camera);
	m_pBtnVideoCtrl->SetAttribute(L"skin", L"skin_close_camera_btn_same");
	m_pBtnAudioCtrl->SetAttribute(L"skin", L"skin_close_audio_btn_same");
	m_pBtnStarPlay->SetUserData(0);
	m_pBtnAudioCtrl->SetUserData(0);
	m_pBtnVideoCtrl->SetUserData(0);
	bindVideoCanvas();
	SetRealWndCanvasIndex();
	WidgetStateChange(false);
	m_strMessageInfo = "";
	MessageText->SetWindowTextW(L"");

}

void UISameRoomPage::beforeDisappear() {
	for (int i = 0; i < VideoCanvasMaxSize; i++)
	{
		SRealWnd * pRealWnd = m_videoCanvs[i].m_videoCavas;
		if (pRealWnd)
		{
			CVideoNativeWnd *pNativeWnd = (CVideoNativeWnd *)pRealWnd->GetData();
			if (pNativeWnd)
			{
				pNativeWnd->DestroyWindow();
				//delete pNativeWnd;
			}
		}
	}
	if (m_pMediaDeviceManage != NULL)
	{
		delete m_pMediaDeviceManage;
		m_pMediaDeviceManage = NULL;
	}
}

void UISameRoomPage::switchLanguage() {
	if (m_iJoinRoomStatus != JoinRoomStatus::Joined)return;
	if (m_localUid != "")
	{
		wstring cslocal = CRaysPublics::GetLanguageInfoText(L"messgebox_Preview");
		cslocal.append(s2ws(m_localUid));
		((CVideoNativeWnd*)m_videoCanvs[0].m_videoCavas->GetData())->SetUidText(cslocal.c_str());
	}
}

void UISameRoomPage::onClickBtnSameQuit() {
	if (_oPageEvent) {
		_oPageEvent(UIPageEvent::PAGE_EVENT_DISAPPEAR_INITIATIVE, nullptr, this);
	}
}

void UISameRoomPage::PackageMessage(LPCWSTR info)
{
	
	return;
}

bool UISameRoomPage::OnCbxVideoChange(EventArgs *pEvtBase)
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

bool UISameRoomPage::OnCbxAudioInputChange(EventArgs *pEvtBase)
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)
	{
		//事件对象强制转换 
		EventHeaderClick *pEvt = (EventHeaderClick*)pEvtBase;
		SComboBox *pComBox = (SComboBox*)pEvt->sender;
		int nSel = pComBox->GetCurSel();
		switchAudioInput(true);
	}
	return true;
}

bool UISameRoomPage::OnCbxAudioOutPutChange(EventArgs *pEvtBase)
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)
	{
		//事件对象强制转换 
		EventHeaderClick *pEvt = (EventHeaderClick*)pEvtBase;
		SComboBox *pComBox = (SComboBox*)pEvt->sender;
		int nSel = pComBox->GetCurSel();
		switchAudioOutput(true);
	}
	return true;
}

void UISameRoomPage::onClickBtnClearUid()
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)return;
	SEdit *pEditUiD = _pPageRoot->FindChildByID2<SEdit>(R.id.same_room_edit_uid);
	pEditUiD->SetWindowTextW(L"");
}

void UISameRoomPage::onClickBtnClearRoomId()
{
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)return;
	SEdit *pEditRoomId = _pPageRoot->FindChildByID2<SEdit>(R.id.same_room_edit_roomid);
	pEditRoomId->SetWindowTextW(L"");
}

void UISameRoomPage::onClickBtnOpenCamera()
{
	//restartVideoDevice();
	//resetVideoConfig();
	if (m_iJoinRoomStatus != JoinRoomStatus::Joined)
	{
		return;
	}

	bool bIsClick = m_pBtnVideoCtrl->GetUserData();
	if (!bIsClick)
	{
		switchCapture(false);
		m_pBtnVideoCtrl->SetAttribute(L"skin", L"skin_close_camera_btn_same");
	}
	else
	{
		switchCapture(true);
		m_pBtnVideoCtrl->SetAttribute(L"skin", L"skin_btn_camera_open_main");
	}
	m_pBtnVideoCtrl->SetUserData(!bIsClick);
}

void UISameRoomPage::onClickBtnOpenAudio()
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
		//MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setInputtingMute(false);
		MediaManager::instance()->getThunderManager()->stopLocalAudioStream(false);
		m_pBtnAudioCtrl->SetAttribute(L"skin", L"skin_btn_audio_open");
	}
	m_pBtnAudioCtrl->SetUserData(!bIsClick);
	
}

void UISameRoomPage::UpdataWindowsPaint(bool bIsUpdata)
{
	//SRealWnd *m_pRealWnd = _pPageRoot->FindChildByID2<SRealWnd>(R.id.same_room_canvas_0);
	//if(m_pRealWnd)((CVideoNativeWnd*)m_pRealWnd->GetData())->UpdataWindowsPaint(true);
}

void UISameRoomPage::onClickBtnDoc()
{
	ShellExecute(NULL, _T("open"), s2ws(g_AppDocUrl).c_str(), NULL, NULL, SW_SHOWNORMAL);
}
void UISameRoomPage::onClickBtnQuit()
{

	if (m_iJoinRoomStatus == JoinRoomStatus::Joined)
	{
		if (CRaysPublics::SendMessageBox(CRaysPublics::GetLanguageInfoText(L"messgebox_Logging_out").c_str(), MB_OKCANCEL)==0)
		return;
		// 退出房间
		leaveRoom();
	}

	if (_oPageEvent) {
		_oPageEvent(UIPageEvent::PAGE_EVENT_DISAPPEAR_INITIATIVE, nullptr, this);
	}
}

void UISameRoomPage::resetVideoConfig() {
	VideoEncoderConfiguration config;
	config.playType = VIDEO_PUBLISH_PLAYTYPE_SINGLE;
	config.publishMode = VIDEO_PUBLISH_MODE_NORMAL_DEFINITION;
	MediaManager::instance()->getThunderManager()->setVideoEncoderConfig(config);
}

void UISameRoomPage::restartVideoDevice() {
	m_pMediaDeviceManage->ScanVideoDevice();
}

void UISameRoomPage::restartMicphoneDevice() {
	m_pMediaDeviceManage->ScanAudioInputDevice();
}

void UISameRoomPage::switchCapture(bool switch_) {

	Logd(SameTAG, Log("switchCapture").addDetail("begin", std::to_string(0)));
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined) {
		//Logd(TAG, Log(__FUNCTION__).setMessage("User in room").addDetail("camera index", std::to_string(m_videoDevicesCombo.GetCurSel())));
		
		if (switch_ && MediaManager::instance()->getThunderManager()->getVideoDeviceMgr() != NULL)
		{
			MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->startVideoDeviceCapture(m_pMediaDeviceManage->getVideoDevice());
			MediaManager::instance()->getThunderManager()->stopLocalVideoStream(false);
			((CVideoNativeWnd*)m_videoCanvs[0].m_videoCavas->GetData())->UpdataCameraState(true);
		}
		else if (MediaManager::instance()->getThunderManager()->getVideoDeviceMgr() != NULL)
		{
			MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->stopVideoDeviceCapture();
			MediaManager::instance()->getThunderManager()->stopLocalVideoStream(true);
			((CVideoNativeWnd*)m_videoCanvs[0].m_videoCavas->GetData())->UpdataCameraState(false);
		}
	}
}

void UISameRoomPage::switchAudioInput(bool switch_) {
	Logd(SameTAG, Log("switchAudioInput").addDetail("begin", std::to_string(0)));
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined) {
		if (switch_ && MediaManager::instance()->getThunderManager()->getAudioDeviceMgr() != NULL)
		{
			MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setInputtingDevice(m_pMediaDeviceManage->getAudioInputDevice());
		}
	}
}

void UISameRoomPage::switchAudioOutput(bool switch_) {
	if (m_iJoinRoomStatus == JoinRoomStatus::Joined) {
		if (MediaManager::instance()->getThunderManager()->getAudioDeviceMgr() != NULL)
		{
			MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->setOutputtingDevice(m_pMediaDeviceManage->getAudioOutputDevice());
		}
	}
}

void UISameRoomPage::leaveRoom()
{
	Logd(SameTAG, Log("leaveRoom"));
	//m_joinRoomBtn.EnableWindow(FALSE);

	// To exit the room, call the following process
	int count = m_RemoteUserList.GetRemoteUserCount();
	for (int i=0; i<count; i++)
	{
		std::shared_ptr<RemoteUserInfo > pUser = m_RemoteUserList.GetRemoteUserFromList(i);
		if (pUser->bAudioStop) {
			if (pUser->strUid == m_localUid) {
				MediaManager::instance()->getThunderManager()->stopLocalAudioStream(true);
			}
			else {
				MediaManager::instance()->getThunderManager()->stopRemoteAudioStream(pUser->strUid.c_str(), true);
			}
		}

		if (pUser->bVideoStop) {
			if (pUser->strUid == m_localUid) {
				setRemoteVideoCanvas(m_localUid.c_str(),NULL);
				MediaManager::instance()->getThunderManager()->stopLocalVideoStream(true);
			}
			else {
				setRemoteVideoCanvas(pUser->strUid.c_str(),NULL);
				MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(pUser->strUid.c_str(), true);
			}
		}
	}

	//本地流结束
	MediaManager::instance()->getThunderManager()->stopVideoPreview();
	MediaManager::instance()->getThunderManager()->getVideoDeviceMgr()->stopVideoDeviceCapture();
	MediaManager::instance()->getThunderManager()->leaveRoom();
	m_iJoinRoomStatus = JoinRoomStatus::Leave;
	char msg[128] = { 0 };
	sprintf_s(msg, "UID=%s has left the room", m_localUid.c_str());
	PutMessageInfo(msg);
	PutMessageInfo("Stop live successfully");
	refreshVideoCanvas(0,false);
}

void UISameRoomPage::VideoChangeCanvas(UINT32 index,bool siUseBig)
{
	VideoCanvas canvas = { 0 };
	canvas.renderMode = VIDEO_RENDER_MODE_CLIP_TO_BOUNDS;
	if (siUseBig)
	{
		SRealWnd *pSWindow0 = _pPageRoot->FindChildByID2<SRealWnd>(R.id.same_room_big_canvas_1);
		canvas.hWnd = pSWindow0->GetRealHwnd();
		m_UseBigCanvasIndex = index;
	}
	else
	{
		canvas.hWnd = m_videoCanvs[m_UseBigCanvasIndex].m_videoCavas->GetRealHwnd();
	}

	if (index == 0 && m_UseBigCanvasIndex == 0)//local
	{
		MediaManager::instance()->getThunderManager()->stopLocalVideoStream(true);
		int nResult = 0;
		if ((nResult = MediaManager::instance()->getThunderManager()->setLocalVideoCanvas(canvas))) // Set the local view
		{
			Logd(SameTAG, Log("setLocalVideoCanvas").addDetail("nResult", std::to_string(nResult)));
			return;
		}
		MediaManager::instance()->getThunderManager()->stopLocalVideoStream(false);
	}
	else
	{
		string strUid = FindUidFormMap(m_UseBigCanvasIndex);
		if (strcmp(strUid.c_str(), "") == 0)return;
		strcpy(canvas.uid, strUid.c_str());
		MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(strUid.c_str(),true);
		int nResult = 0;
		if ((nResult = MediaManager::instance()->getThunderManager()->setRemoteVideoCanvas(canvas))) // Set the local view
		{
			Logd(SameTAG, Log("setLocalVideoCanvas").addDetail("nResult", std::to_string(nResult)));
			return;
		}
		MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(strUid.c_str(),false);
	}	
}

void UISameRoomPage::PutMessageInfo(const string &strInfo)
{
	struct tm t;
	time_t now;  
	time(&now);   
	localtime_s(&t, &now);   
	char szTimeNow[20] = "\0";
	sprintf_s(szTimeNow, 20, "%.2d:%.2d:%.2d ",t.tm_hour, t.tm_min, t.tm_sec);
	static int writeMsgCount = 0;
	if (writeMsgCount++ > MAX_MESSAGE_COUNT_TEXT)
	{
		m_strMessageInfo.clear();
		writeMsgCount = 0;
	}
	if (m_strMessageInfo.length()>0)m_strMessageInfo.append("\n");

	m_strMessageInfo.append(szTimeNow);
	m_strMessageInfo.append(strInfo.c_str());
	MessageText->SetWindowTextW(s2ws(m_strMessageInfo.c_str()).c_str());
}

void UISameRoomPage::SetButtonVisible(int id, bool sta)
{
	SButton *m_pVideo = _pPageRoot->FindChildByID2<SButton>(id);
	if (m_pVideo)m_pVideo->EnableWindow(sta);
}

void UISameRoomPage::WidgetStateChange(bool bIsPlaying)
{
	SEdit *pEditUiD = _pPageRoot->FindChildByID2<SEdit>(R.id.same_room_edit_uid);
	SEdit *pEditRoomId = _pPageRoot->FindChildByID2<SEdit>(R.id.same_room_edit_roomid);
	
	SButton *m_pClearUid = _pPageRoot->FindChildByID2<SButton>(R.id.same_room_btn_clear_uid);
	SButton *m_pClearRoomID = _pPageRoot->FindChildByID2<SButton>(R.id.same_room_btn_clear_roomid);
	if (bIsPlaying) //开播中
	{
		pEditUiD->SetAttribute(L"colorText", L"@color/font_text_color_gray3");
		pEditRoomId->SetAttribute(L"colorText", L"@color/font_text_color_gray3");
		m_pBtnStarPlay->SetAttribute(L"text", L"same_room_btn_stop_text");
		m_pBtnVideoCtrl->SetAttribute(L"skin", L"skin_btn_camera_open_main");
		m_pBtnAudioCtrl->SetAttribute(L"skin", L"skin_btn_audio_open");
		pEditUiD->EnableWindow(false);
		pEditRoomId->EnableWindow(false);
		m_pClearUid->SetVisible(false, TRUE);
		m_pClearRoomID->SetVisible(false, TRUE);
		((CVideoNativeWnd*)m_videoCanvs[0].m_videoCavas->GetData())->SetUidText(L"");
	}
	else
	{
		m_pBtnStarPlay->SetAttribute(L"text", L"same_room_btn_start_text");
		pEditUiD->EnableWindow(true);
		pEditRoomId->EnableWindow(true);
		m_pClearUid->SetVisible(true, TRUE);
		m_pClearRoomID->SetVisible(true, TRUE);
		pEditUiD->SetAttribute(L"colorText", L"@color/edit_text_color");
		pEditRoomId->SetAttribute(L"colorText", L"@color/edit_text_color");
		m_pBtnVideoCtrl->SetAttribute(L"skin", L"skin_btn_camera_normal");
		m_pBtnAudioCtrl->SetAttribute(L"skin", L"skin_btn_audio_normal");
		
	}
}

//开播
void UISameRoomPage::onClickBtnStartPlay()
{
	SEdit *pEditUiD = _pPageRoot->FindChildByID2<SEdit>(R.id.same_room_edit_uid);
	SEdit *pEditRoomId = _pPageRoot->FindChildByID2<SEdit>(R.id.same_room_edit_roomid);
	string strUid = ws2s((wstring)pEditUiD->GetWindowTextW());
	string strRoomId = ws2s((wstring)pEditRoomId->GetWindowTextW());
	if (CRaysPublics::CheckUidAndRoomId(CRaysPublics::GetLanguageInfoText(L"messgebox_input_uid_roomid"),strUid.c_str(), strRoomId.c_str()))return;
	CTSTR_Randomuid = strUid;
	CTSTR_RandomRoomid = strRoomId;
	if (m_pBtnStarPlay->GetUserData()==1)
	{
		leaveRoom();
		InitialiVideoRealWnd();
		WidgetStateChange(false);
		m_pBtnStarPlay->SetUserData(0);
		return;
	}
	else
	{
		if (!CRaysPublics::checkIsNetwork())
		{
			CRaysPublics::SendMessageBox(CRaysPublics::GetLanguageInfoText(L"messgebox_network_error").c_str(), MB_OK);
			return;
		}
		WidgetStateChange(true);
		m_pBtnStarPlay->SetUserData(1);
	}
	
	m_iJoinRoomStatus = JoinRoomStatus::Joining;
	m_localUid = strUid;
	//设置媒体模式
	MediaManager::instance()->getThunderManager()->setMediaMode(PROFILE_NORMAL);
	//设置房间场景模式
	MediaManager::instance()->getThunderManager()->setRoomMode(ROOM_CONFIG_LIVE);
	int nResult = 0;
	//加入房间
	const char* pToken = "";  //本DEMO测试使用空，具体请参考官网。
	if ((nResult = MediaManager::instance()->getThunderManager()->joinRoom(pToken, strlen(pToken), strRoomId.c_str(), strUid.c_str())) != 0)
	{
		Logd(SameTAG, Log("stopLocalVideoStream").addDetail("nResult", std::to_string(nResult)));
	}
	return;
}


void UISameRoomPage::refreshVideoCanvas(int index,bool isPlaying)
{
	if (index<0 || index>VideoCanvasMaxSize)return;
	SRealWnd *m_pRealWnd = m_videoCanvs[index].m_videoCavas;
	if(m_pRealWnd)((CVideoNativeWnd*)m_pRealWnd->GetData())->UpdataWindowsPaint(E_SAMEROOM,isPlaying);
}


void UISameRoomPage::onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed)
{
	m_iJoinRoomStatus = JoinRoomStatus::Joined;
	switchCapture(true);
	switchAudioInput(true);
	switchAudioOutput(true);
	
	m_RemoteUserList.AddRemoteUser(uid);
	m_RemoteUserList.SetRemoteUserCanvasIndex(0, 0);
	SRealWnd *pSWindow = m_videoCanvs[getCanvas("",true)].m_videoCavas;

	VideoCanvas canvas = { 0 };
	canvas.renderMode = VIDEO_RENDER_MODE_CLIP_TO_BOUNDS;
	strcpy(canvas.uid, uid);
	canvas.hWnd = pSWindow->GetRealHwnd();
	int nResult = 0;
	if ((nResult = MediaManager::instance()->getThunderManager()->setLocalVideoCanvas(canvas))) // Set the local view
	{
		Logd(SameTAG, Log("setLocalVideoCanvas").addDetail("nResult", std::to_string(nResult)));
		return;
	}
	VideoEncoderConfiguration config;
	config.playType = VIDEO_PUBLISH_PLAYTYPE_SINGLE;
	config.publishMode = VIDEO_PUBLISH_MODE_SMOOTH_DEFINITION;
	MediaManager::instance()->getThunderManager()->setVideoEncoderConfig(config); // Set encoding configuration
	MediaManager::instance()->getThunderManager()->setAudioConfig(AUDIO_PROFILE_SPEECH_STANDARD, COMMUT_MODE_LOW, SCENARIO_MODE_STABLE_FIRST);

	 // 打开预览
	if (nResult = MediaManager::instance()->getThunderManager()->startVideoPreview() != 0)
	{
		Logd(SameTAG, Log("startVideoPreview").addDetail("nResult", std::to_string(nResult)));
		return;
	}
	//发送本地视频
	if (nResult = MediaManager::instance()->getThunderManager()->stopLocalVideoStream(false) != 0)
	{
		Logd(SameTAG, Log("stopLocalVideoStream").addDetail("nResult", std::to_string(nResult)));
		return;
	}
	//发送音频视频
	if (nResult = MediaManager::instance()->getThunderManager()->stopLocalAudioStream(false) != 0)
	{
		Logd(SameTAG, Log("stopLocalAudioStream").addDetail("nResult", std::to_string(nResult)));
		return;
	}
	Logd(SameTAG, Log("onJoinRoomSuccess Success").addDetail("nResult", std::to_string(nResult)));

	PutMessageInfo("Go live successfully");
	char msg[128] = { 0 };
	sprintf_s(msg, "UID=%s joined roomID=%s", uid, roomName);
	PutMessageInfo(msg);
	wstring cslocal = CRaysPublics::GetLanguageInfoText(L"messgebox_Preview");
	cslocal.append(s2ws(uid));
	((CVideoNativeWnd*)m_videoCanvs[0].m_videoCavas->GetData())->SetUidText(cslocal.c_str());
	refreshVideoCanvas(0, true);
	return;
}


void UISameRoomPage::InitialiVideoRealWnd()
{
	int count = m_RemoteUserList.GetRemoteUserCount();
	for(int i=0; i<count; i++)
	{
		std::shared_ptr<RemoteUserInfo > pUser = m_RemoteUserList.GetRemoteUserFromList(i);
		string strUid = pUser->strUid;
		int index = getCanvas(strUid.c_str(), false);
		if (index > 0)
		{
			m_videoCanvs[index].m_videoCavas->SetVisible(TRUE, TRUE);
			MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(strUid.c_str(), true);
			((CVideoNativeWnd*)m_videoCanvs[index].m_videoCavas->GetData())->UpdataCameraState(false);
			((CVideoNativeWnd*)m_videoCanvs[index].m_videoCavas->GetData())->UpdataAudioState(false);
			refreshVideoCanvas(index, false);
		}
	}
	m_RemoteUserList.ClearAllUser();
}

int UISameRoomPage::RemoteUserCanvasChange(int srcIndex)
{
	int notShowPos_ = m_RemoteUserList.GetRemoteUserNotShowFormList();
	if (notShowPos_ < 0)
	{
		//没有其他用户需要显示
		int lastOne = 0;
		for (int i = 1; i < VideoCanvasMaxSize; i++)
		{
			if (strcmp(m_videoCanvs[i].m_uid.c_str(), "") != 0)
			{
				lastOne = i;
			}
		}
		if (lastOne != 0 && srcIndex < lastOne) //如果退出的不是最后一个，把最后一个移到对应位置
		{
			string lasrOneUid = m_videoCanvs[lastOne].m_uid;
			int listPos = m_RemoteUserList.GetRemoteUserPosFromList(lasrOneUid.c_str());
			if (listPos < 0)return false;
			setRemoteVideoCanvas(lasrOneUid.c_str(), NULL);
			m_videoCanvs[lastOne].m_uid = "";
			refreshVideoCanvas(lastOne, false);

			m_RemoteUserList.SetRemoteUserCanvasIndex(listPos, srcIndex);
			bindUserToCanvas(srcIndex, lasrOneUid.c_str());
			setRemoteVideoCanvas(lasrOneUid.c_str(), m_videoCanvs[srcIndex].m_videoCavas->GetRealHwnd());
			refreshVideoCanvas(srcIndex, true);

			std::shared_ptr<RemoteUserInfo > pUser = m_RemoteUserList.GetRemoteUserFromList(listPos);
			if (pUser != NULL)
			{
				MediaManager::instance()->getThunderManager()->stopRemoteAudioStream(lasrOneUid.c_str(), pUser->bAudioStop);
				MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(lasrOneUid.c_str(), pUser->bVideoStop);
			}
		}
	}
	else
	{
		std::shared_ptr<RemoteUserInfo > pUser = m_RemoteUserList.GetRemoteUserFromList(notShowPos_);
		if (pUser != NULL)
		{
			int nNewIndex_ = getCanvas(pUser->strUid.c_str(), false);
			bindUserToCanvas(nNewIndex_, pUser->strUid.c_str());
			setRemoteVideoCanvas(pUser->strUid.c_str(), m_videoCanvs[nNewIndex_].m_videoCavas->GetRealHwnd());
			m_RemoteUserList.SetRemoteUserCanvasIndex(notShowPos_,nNewIndex_);
			refreshVideoCanvas(srcIndex, true);
			MediaManager::instance()->getThunderManager()->stopRemoteAudioStream(pUser->strUid.c_str(), pUser->bAudioStop);
			MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(pUser->strUid.c_str(), pUser->bVideoStop);
		}
		
	}
	return 0;
}

/*远端打开MIC进入房间（摄像头关闭）这时候视频背景需要显示黑色*/
void UISameRoomPage::SetDefaultRealWndBag(const char* uid_, bool isShow)
{
	int index = getCanvas(uid_, false);
	if (index > 0)
	{
		m_videoCanvs[index].m_videoCavas->SetVisible(isShow, TRUE);
	}	
}

void UISameRoomPage::onRemoteAudioStopped(const char* uid, bool isStop)
{
	Logd(SameTAG, Log("onRemoteAudioStopped").addDetail("uid=[%s]", uid).addDetail("isStop = [%d]", std::to_string(isStop)));
	//UpdateRemoteUidToMap(E_AUDIO, uid, isStop);

	bool isOut = false;
	int pos_ = m_RemoteUserList.GetRemoteUserPosFromList(uid);
	if (isStop == 0) {
		if (pos_ < 0) {
			int nNewUserPos_ = m_RemoteUserList.AddRemoteUser(uid);
			m_RemoteUserList.UpdataRemoteUser(uid, E_AUDIO, isStop);
			int index = getCanvas(uid, false);
			if (index >= 0) {
				
				bindUserToCanvas(index, uid);
				m_videoCanvs[index].m_uid = uid;
				setRemoteVideoCanvas(uid, m_videoCanvs[index].m_videoCavas->GetRealHwnd());
				((CVideoNativeWnd*)m_videoCanvs[index].m_videoCavas->GetData())->SetUidText(s2ws(uid).c_str());
				m_RemoteUserList.SetRemoteUserCanvasIndex(nNewUserPos_, index);
				refreshVideoCanvas(index, true);
				MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(uid, false);
				SetDefaultRealWndBag(uid, false);
				char msg[128] = { 0 };
				
				sprintf_s(msg, "UID=%s joined", uid);
				PutMessageInfo(msg);
			}
		}
		else {
			m_RemoteUserList.UpdataRemoteUser(uid, E_AUDIO, isStop);
		}
	}
	else {
		if (pos_ > 0) {
			m_RemoteUserList.UpdataRemoteUser(uid, E_AUDIO, isStop);
			if (m_RemoteUserList.IsleaveRoomed(pos_)) {
				int index = m_RemoteUserList.GetRemoteUserCanvasIndex(pos_);

				m_RemoteUserList.DeleteRemoteUser(uid);
				isOut = true;
				if (index >= 0) {
					m_videoCanvs[index].m_uid = "";
					setRemoteVideoCanvas(uid, NULL);
					refreshVideoCanvas(index, false);
					RemoteUserCanvasChange(index);
				}
			}
		}
	}

	MediaManager::instance()->getThunderManager()->stopRemoteAudioStream(uid, isStop);
	char msg[128] = { 0 };
	sprintf_s(msg, "UID=%s turned %s microphone", uid, isStop ? "off" : "on");
	PutMessageInfo(msg);
	if (isOut)
	{
		SetDefaultRealWndBag(uid, true);
		memset(msg, 0, sizeof(msg));
		sprintf_s(msg, "UID=%s has left the room", uid);
		PutMessageInfo(msg);
	}
}

//摄像头开关回调
void UISameRoomPage::onRemoteVideoStopped(const char* uid, bool isStop)
{
	if (NULL == uid)return;
	Logd(SameTAG, Log("onRemoteAudioStopped").addDetail("uid=[%s]", uid).addDetail("isStop = [%d]", std::to_string(isStop)));
	//UpdateRemoteUidToMap(E_VIDEO, uid, isStop);
	
	bool isOut = false;
	int pos_ = m_RemoteUserList.GetRemoteUserPosFromList(uid);
	if (isStop == 0) {
		//std::shared_ptr<RemoteUserInfo > pUser = m_RemoteUserList.GetRemoteUserFromList(uid);
		if (pos_ < 0) {
			int nNewUserPos_ = m_RemoteUserList.AddRemoteUser(uid);
			m_RemoteUserList.UpdataRemoteUser(uid, E_VIDEO, isStop);
			int index = getCanvas(uid, false);
			if (index >= 0 && nNewUserPos_ > 0) {
				bindUserToCanvas(index, uid);
				setRemoteVideoCanvas(uid, m_videoCanvs[index].m_videoCavas->GetRealHwnd());

				((CVideoNativeWnd*)m_videoCanvs[index].m_videoCavas->GetData())->SetUidText(s2ws(uid).c_str());
				refreshVideoCanvas(index, true);
				m_RemoteUserList.SetRemoteUserCanvasIndex(nNewUserPos_, index);
				char msg[128] = { 0 };
				sprintf_s(msg, "UID=%s joined", uid);
				PutMessageInfo(msg);
				m_videoCanvs[index].m_uid = string(uid);
			}
		}
		else {
			m_RemoteUserList.UpdataRemoteUser(uid, E_VIDEO, isStop);
			int Canindex = m_RemoteUserList.GetRemoteUserCanvasIndex(pos_);
			if (Canindex > 0) {
				setRemoteVideoCanvas(uid, m_videoCanvs[Canindex].m_videoCavas->GetRealHwnd());
			}
		}
	}
	else {
		if (pos_ > 0) {
			m_RemoteUserList.UpdataRemoteUser(uid, E_VIDEO, isStop);
			if (m_RemoteUserList.IsleaveRoomed(pos_)) {
				int index = m_RemoteUserList.GetRemoteUserCanvasIndex(pos_);
				m_RemoteUserList.DeleteRemoteUser(uid);
				
				setRemoteVideoCanvas(uid, NULL);
				isOut = true;
				if (index >= 0) {
					m_videoCanvs[index].m_uid = "";
					refreshVideoCanvas(index, false);
					RemoteUserCanvasChange(index);
				}	
			}
		}
	}

	SetDefaultRealWndBag(uid, true);
	MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(uid, isStop);
	char msg[128] = { 0 };
	sprintf_s(msg, "UID=%s turned %s camera", uid, isStop ? "off" : "on");
	PutMessageInfo(msg);
	if (isOut)
	{
		SetDefaultRealWndBag(uid, true);
		memset(msg, 0, sizeof(msg));
		sprintf_s(msg, "UID=%s has left the room", uid);
		PutMessageInfo(msg);
	}
}

void UISameRoomPage::bindUserToCanvas(int index, const char* uid)
{
	if (index >= 0 && index < _countof(m_videoCanvs)) {
		m_videoCanvs[index].m_uid = uid;
		m_videoCanvs[index].m_bigCanvas = false;
		//m_videoCanvs[index].m_uidText->SetWindowText(std::to_wstring(uid).c_str());
		((CVideoNativeWnd*)m_videoCanvs[index].m_videoCavas->GetData())->SetUidText(s2ws(uid).c_str());
	}
}

string UISameRoomPage::FindUidFormMap(UINT32 key_)
{
	int count = m_RemoteUserList.GetRemoteUserCount();
	for (int i=0;i<count;i++)
	{
		std::shared_ptr<RemoteUserInfo > pUser = m_RemoteUserList.GetRemoteUserFromList(i);
		if (pUser->index == key_)
			return pUser->strUid;
	}
	return "";
}

int UISameRoomPage::setRemoteVideoCanvas(const char* uid, HWND hwnd)
{
	VideoCanvas canvas = {0};
	canvas.renderMode = VIDEO_RENDER_MODE_CLIP_TO_BOUNDS;
	strcpy(canvas.uid, uid);
	canvas.hWnd = hwnd;
	return MediaManager::instance()->getThunderManager()->setRemoteVideoCanvas(canvas);
}

void UISameRoomPage::UpdataUserData(const char* uid, bool stop)
{
	if (NULL == uid)return;
}

void UISameRoomPage::bindVideoCanvas()
{
	UserVideoCanvas Canvas0 = {0};
	SRealWnd *pSWindow0 = _pPageRoot->FindChildByID2<SRealWnd>(R.id.same_room_canvas_0);
	Canvas0.m_videoCavas = (SRealWnd *)pSWindow0;
	m_videoCanvs[0] = Canvas0;
	//CNativeWnd *pNativewnd0 = (CNativeWnd *)pSWindow0->GetData();
	//pNativewnd0->SetIndex(0);

	UserVideoCanvas Canvas1 = { 0 };
	SRealWnd *pSWindow1 = _pPageRoot->FindChildByID2<SRealWnd>(R.id.same_room_canvas_1);
	Canvas1.m_videoCavas = pSWindow1;
	m_videoCanvs[1] = Canvas1;
	//CNativeWnd *pNativewnd1 = (CNativeWnd *)pSWindow0->GetData();
	//pNativewnd1->SetIndex(1);

	UserVideoCanvas Canvas2 = { 0 };
	SRealWnd *pSWindow2 = _pPageRoot->FindChildByID2<SRealWnd>(R.id.same_room_canvas_2);
	Canvas2.m_videoCavas = pSWindow2;
	m_videoCanvs[2] = Canvas2;
	//CNativeWnd *pNativewnd2 = (CNativeWnd *)pSWindow0->GetData();
	//pNativewnd2->SetIndex(2);

	UserVideoCanvas Canvas3 = { 0 };
	SRealWnd *pSWindow3 = _pPageRoot->FindChildByID2<SRealWnd>(R.id.same_room_canvas_3);
	Canvas3.m_videoCavas = pSWindow3;
	m_videoCanvs[3] = Canvas3;
	//CNativeWnd *pNativewnd3 = (CNativeWnd *)pSWindow0->GetData();
	//pNativewnd3->SetIndex(3);

	MessageText = _pPageRoot->FindChildByID2<SStatic>(R.id.MessageInfo_text);
}

void UISameRoomPage::SetRealWndCanvasIndex()
{
	for (int i = 0; i < VideoCanvasMaxSize; i++)
	{
		SRealWnd *pSWindow = (SRealWnd *)m_videoCanvs[i].m_videoCavas;
		const SRealWndParam &param = pSWindow->GetRealWndParam();
		wstring str = param.m_strClassName;
		CVideoNativeWnd *pNativewnd2 = (CVideoNativeWnd *)pSWindow->GetData();
		if(pNativewnd2)pNativewnd2->SetIndex(i);
	}
}

int UISameRoomPage::getCanvas(const char* uid, bool local)
{
	if (local)return 0;  //本地
	int index = -1;
	if (uid == NULL)return index;
	for (int i = 1; i <VideoCanvasMaxSize; i++) {
		string str = m_videoCanvs[i].m_uid;
		if (-1 == index && strcmp(m_videoCanvs[i].m_uid.c_str(),"")==0)
		{
			index = i;
		}else if(m_videoCanvs[i].m_uid == uid) 
		{
			return i;
		}
	}
	return index;
}

void UISameRoomPage::onLocalVideoStats(const LocalVideoStats* stats)
{
	Logd(SameTAG, Log("onLocalVideoStats").addDetail("sendBitrate", std::to_string(stats->sendBitrate))
		.addDetail("encodedFrameCount", std::to_string(stats->encodedFrameCount))
		.addDetail("encoderOutputFrameRate", std::to_string(stats->encoderOutputFrameRate)));
	
}

void UISameRoomPage::onRealWndCilck(UINT32 index)
{
	if (index > VideoCanvasMaxSize)return;
	SWindow *pSmallWnd = _pPageRoot->FindChildByID2<SWindow>(R.id.same_room_small_canvas);
	SWindow *pBigWnd = _pPageRoot->FindChildByID2<SWindow>(R.id.same_room_big_canvas);

	static int onClickCount = 0;
	onClickCount++;
	if (onClickCount == 2)
	{
		onClickCount = 0;
		pSmallWnd->SetVisible(true);
		pBigWnd->SetVisible(false);
		VideoChangeCanvas(index,false);
	}
	else
	{
		pBigWnd->SetVisible(true);
		pSmallWnd->SetVisible(false);
		VideoChangeCanvas(index,true);
	}
}

void UISameRoomPage::onWndPosChanged()
{
	for (int i = 0; i < VideoCanvasMaxSize; i++)
	{
		SRealWnd * pRealWnd = m_videoCanvs[i].m_videoCavas;
		if (pRealWnd)
		{
			CVideoNativeWnd *pNativeWnd = (CVideoNativeWnd *)pRealWnd->GetData();
			if (pNativeWnd)pNativeWnd->UpdateVedioWndPos();
		}
	}
}

void UISameRoomPage::onRealWndChick(int wndID,int type, bool bBtnState)
{
	if (wndID > VideoCanvasMaxSize)return;
	if (type == 0)//camera
	{
		MediaManager::instance()->getThunderManager()->stopRemoteVideoStream(FindUidFormMap(wndID).c_str(), bBtnState);
	}
	else if (type == 1)//audio
	{
		MediaManager::instance()->getThunderManager()->stopRemoteAudioStream(FindUidFormMap(wndID).c_str(), bBtnState);
	}
}

LRESULT UISameRoomPage::onThunderManagerCB(UINT uMsg, WPARAM wp, LPARAM lp, BOOL &bHandle)
{
	switch (uMsg)
	{
	case WM_WND_POSCHANGE:
	{
		onWndPosChanged();
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
	case WM_JOIN_ROOM_SUCCESS:
	{
		JoinRoomPar *pRoomPar = (JoinRoomPar *)lp;
		if (pRoomPar){
			onJoinRoomSuccess(pRoomPar->roomName, pRoomPar->uid, pRoomPar->elapsed);
			delete pRoomPar;
		}
		break;
	}case WM_USER_STOP_VIDEO:
	{
		RemoteUserPar *pUserPar = (RemoteUserPar *)lp;
		if (pUserPar){
			onRemoteVideoStopped(pUserPar->uid, pUserPar->elapsed);
			delete pUserPar;
		}
		break; 
	}case WM_USER_STOP_AUDIO:
	{
		RemoteUserPar *pUserPar = (RemoteUserPar *)lp;
		if (pUserPar) {
			onRemoteAudioStopped(pUserPar->uid, pUserPar->elapsed);
			delete pUserPar;
		}
		break;
	}
	case WM_VIDEO_CAPTURE_STATUS:
	{
		LocalVideoStats *pUserPar = (LocalVideoStats *)lp;
		if (pUserPar) {
			onLocalVideoStats(pUserPar);
			delete pUserPar;
		}
		break;
	}case WM_REALWND_CLICK:
	{
		int *pUserPar = (int *)lp;
		if (pUserPar) {
			onRealWndCilck(*pUserPar);
			delete pUserPar;
		}
		break;
	}case WM_USER_JOIN_ROOM:
	{
		RemoteUserPar *pUserPar = (RemoteUserPar *)lp;
		if (pUserPar) {
			char msg[128] = { 0 };
			sprintf_s(msg, "UID=%s joined", pUserPar->uid);
			PutMessageInfo(msg);
			delete pUserPar;
		}
		break;
	}case WM_USER_OFF_ROOM:
	{
		RemoteUserPar *pUserPar = (RemoteUserPar *)lp;
		if (pUserPar) {
			char msg[128] = { 0 };
			sprintf_s(msg, "UID=%s has left the room", pUserPar->uid);
			PutMessageInfo(msg);
			delete pUserPar;
		}
		break;
	}case WM_WND_INITCOMMPLETE:
	{
		//SetRealWndCanvasIndex();
		break;
	}case WM_NETWORKDATA_COME:
	{
		ThunderConnectionStatus *pSta = (ThunderConnectionStatus *)lp;
		if (pSta) {
			//onConnectionStatus(*pSta);
			delete pSta;
		}
		break;
	}
	case WM_ROOMSTATE:
	{
		RoomStats *pSta = (RoomStats *)lp;
		if (pSta) {
			delete pSta;
		}
		break;
	}
	case WM_QUALITY:
	{
		TTNetworkQuality  *pSta = (TTNetworkQuality *)lp;
		if (pSta) {
			//onNetworkQuality(pSta->strUid.c_str(), pSta->txQuality, pSta->rxQuality);
			delete pSta;
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
		break;
	}

	default:
		break;
	}
	return 0;
}
