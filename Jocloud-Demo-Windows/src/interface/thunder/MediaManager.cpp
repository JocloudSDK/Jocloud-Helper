#include "stdafx.h"
#include "MediaManager.h"

using namespace base;

static const char* TAG = "MediaManager";

MediaManager* MediaManager::m_pInstance = NULL;
ThunderMessage *m_pSendMessage = NULL;
void MediaManager::create()
{
	if (m_pInstance == NULL)
	{
		m_pInstance = new MediaManager();
	}
	
}

void MediaManager::release()
{
	if (m_pInstance != NULL)
	{
		delete m_pInstance;
		m_pInstance = NULL;
	}
}

MediaManager* MediaManager::instance()
{
	return m_pInstance;
}

MediaManager::MediaManager()
{
	m_thunderManager = new ThunderManager();
	m_pSendMessage = new ThunderMessage();
}

MediaManager::~MediaManager()
{
	delete m_thunderManager;
	m_thunderManager = NULL;
	delete m_pSendMessage;
	m_pSendMessage = NULL;
}

int MediaManager::init(const char* appId, int sceneId)
{
	return m_thunderManager->init(appId, sceneId, this);
}

int MediaManager::deInit()
{
	return m_thunderManager->deInit();
}

void MediaManager::setMessageDlg(HWND dlg)
{
	m_hMessageDlg = dlg;
}

void MediaManager::onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed)
{
	JoinRoomPar *par = new JoinRoomPar();
	strcpy(par->roomName, roomName);
	strcpy(par->uid, uid);
	par->elapsed = elapsed;

	SSMessageToDlg(WM_JOIN_ROOM_SUCCESS, par);
}

void MediaManager::onRoomStats(RoomStats stats)
{
	RoomStats *par = new RoomStats();
	memset(par, 0, sizeof(RoomStats));
	memcpy(par, &stats, sizeof(RoomStats));

	SSMessageToDlg(WM_ROOMSTATE, par);
}

void MediaManager::onConnectionStatus(ThunderConnectionStatus status)
{
	ThunderConnectionStatus *par = new ThunderConnectionStatus();
	memset(par, 0, sizeof(ThunderConnectionStatus));
	memcpy(par, &status, sizeof(ThunderConnectionStatus));

	SSMessageToDlg(WM_NETWORKDATA_COME, par);
}

void MediaManager::onPublishStreamToCDNStatus(const char* url, ThunderPublishCDNErrorCode errorCode)
{
	ThunderPublishCDNErrorCode *par = new ThunderPublishCDNErrorCode();
	memset(par, 0, sizeof(ThunderPublishCDNErrorCode));
	*par = errorCode;
	SSMessageToDlg(WM_PUBLISHSTREAM, par);
}
void MediaManager::onNetworkQuality(const char* uid, NetworkQuality txQuality, NetworkQuality rxQuality)
{
	TTNetworkQuality *par = new TTNetworkQuality();
	memset(par, 0, sizeof(TTNetworkQuality));
	par->strUid = uid;
	par->rxQuality = txQuality;
	par->rxQuality = rxQuality;

	SSMessageToDlg(WM_QUALITY, par);
	
}
void MediaManager::onLocalVideoStats(const LocalVideoStats stats)
{
	LocalVideoStats *pSta = new LocalVideoStats();
	memset(pSta, 0, sizeof(LocalVideoStats));
	memcpy(pSta, &stats, sizeof(LocalVideoStats));
	SSMessageToDlg(WM_VIDEO_CAPTURE_STATUS, pSta);
}

void MediaManager::onFirstLocalVideoFrameSent(int elapsed)
{
	JoinRoomPar par;
	par.elapsed = elapsed;

}

void MediaManager::onLeaveRoom()
{
	::PostMessage(m_hMessageDlg, WM_LEAVE_ROOM, 0, 0);
}

void MediaManager::onRemoteAudioStopped(const char * uid, bool stop)
{
	RemoteUserPar *lpRemoteUser = new RemoteUserPar();
	memset(lpRemoteUser, 0, sizeof(RemoteUserPar));
	strcat(lpRemoteUser->uid, uid);
	lpRemoteUser->elapsed = stop;

	SSMessageToDlg(WM_USER_STOP_AUDIO, lpRemoteUser);
}

void MediaManager::onRemoteVideoStopped(const char* uid, bool stop)
{
	RemoteUserPar *lpRemoteUser = new RemoteUserPar();
	memset(lpRemoteUser, 0, sizeof(RemoteUserPar));
	strcat(lpRemoteUser->uid, uid);
	lpRemoteUser->elapsed = stop;

	SSMessageToDlg(WM_USER_STOP_VIDEO, lpRemoteUser);
}

void  MediaManager::onUserJoined(const char* uid, int elapsed)
{
	RemoteUserPar *lpRemoteUser = new RemoteUserPar();
	memset(lpRemoteUser, 0, sizeof(RemoteUserPar));
	strcat(lpRemoteUser->uid, uid);
	lpRemoteUser->elapsed = elapsed;
	SSMessageToDlg(WM_USER_JOIN_ROOM, lpRemoteUser);
}

void  MediaManager::onUserOffline(const char* uid, USER_OFFLINE_REASON_TYPE reason)
{
	RemoteUserPar *lpRemoteUser = new RemoteUserPar();
	memset(lpRemoteUser, 0, sizeof(RemoteUserPar));
	strcat(lpRemoteUser->uid, uid);
	lpRemoteUser->elapsed = 1;
	SSMessageToDlg(WM_USER_OFF_ROOM, lpRemoteUser);
}
void MediaManager::onTokenWillExpire(const char * token)
{
	::PostMessage(m_hMessageDlg, WM_TOKEN_WILL_EXPIRE, 0, 0);
}

ThunderManager* MediaManager::getThunderManager()
{
	return m_thunderManager;
}

void MediaManager::onVideoCaptureStatus(int status) {
	::PostMessage(m_hMessageDlg, WM_VIDEO_CAPTURE_STATUS, 0, status);
}

void MediaManager::OnAudioDeviceStateChange(const char* deviceId, int deviceType, int deviceState) {
	Logd(TAG, Log(__FUNCTION__).addDetail("deviceId", deviceId).addDetail("deviceState", std::to_string(deviceState))
		.addDetail("deviceType", std::to_string(deviceType)));

	DeviceDetected* device = new DeviceDetected();
	device->deviceId = new char[strlen(deviceId) + 1];
	memset(device->deviceId, 0, strlen(deviceId) + 1);
	memcpy(device->deviceId, deviceId, strlen(deviceId));
	device->deviceState = (MEDIA_DEVICE_STATE_TYPE)deviceState;
	device->deviceType = (MEDIA_DEVICE_TYPE)deviceType;
	SSMessageToDlg(WM_DEVICE_DETECTED, device);
}

void MediaManager::onVideoDeviceStateChanged(const char* deviceId, MEDIA_DEVICE_TYPE deviceType, MEDIA_DEVICE_STATE_TYPE deviceState)
{
	DeviceDetected* device = new DeviceDetected();
	device->deviceId = new char[strlen(deviceId) + 1];
	memset(device->deviceId, 0, strlen(deviceId) + 1);
	memcpy(device->deviceId, deviceId, strlen(deviceId));
	device->deviceType = deviceType;
	device->deviceState = (MEDIA_DEVICE_STATE_TYPE)deviceState;
	SSMessageToDlg(WM_DEVICE_DETECTED, device);
}

void MediaManager::SSMessageToDlg(const UINT32 EventID, void* lpBuffer)
{
	if (m_pSendMessage == NULL)return;
	memset(m_pSendMessage, 0, sizeof(ThunderMessage));
	m_pSendMessage->dwEventID = EventID;
	m_pSendMessage->lpBuffer = lpBuffer;
	::SendMessage(m_hMessageDlg, WM_THUNDER_MESSAGE, 0, (LPARAM)m_pSendMessage);
}
