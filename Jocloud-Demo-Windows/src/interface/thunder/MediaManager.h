#pragma once

#include "ThunderManager.h"
#include <sstream>
using namespace std;

#define  WM_THUNDER_MESSAGE		WM_USER + 100    
 
#define  WM_JOIN_ROOM_SUCCESS	WM_USER + 101
#define  WM_LEAVE_ROOM			WM_USER + 102
#define  WM_USER_STOP_VIDEO     WM_USER + 103
#define  WM_USER_STOP_AUDIO     WM_USER + 104
#define  WM_TOKEN_WILL_EXPIRE   WM_USER + 105
#define  WM_VIDEO_CAPTURE_STATUS   WM_USER + 106
#define  WM_DEVICE_DETECTED		WM_USER + 107
#define  WM_REALWND_CLICK		WM_USER + 108
#define	 WM_USER_JOIN_ROOM		WM_USER + 109
#define	 WM_USER_OFF_ROOM		WM_USER + 110

#define  WM_WND_POSCHANGE		WM_USER + 130
#define  WM_WND_REALWMDBTN_CHICK	WM_USER + 131
#define  WM_WND_INITCOMMPLETE	WM_USER + 132
#define  WM_NETWORKDATA_COME	WM_USER + 133
#define  WM_ROOMSTATE	        WM_USER + 134
#define  WM_QUALITY				WM_USER + 135
#define  WM_PUBLISHSTREAM		WM_USER + 136
/// Added hot swap of equipment
struct DeviceDetected {
	char* deviceId;
	MEDIA_DEVICE_TYPE deviceType;
	MEDIA_DEVICE_STATE_TYPE deviceState;
};

/// thunder event implement
class  MediaManager 
	: public IThunderEventHandler
{
public:
	virtual ~ MediaManager();
	static void create();
	static void release();
	static MediaManager* instance();

	int init(const char* appId, int sceneId);
	int deInit();
	void setMessageDlg(HWND dlg);
	virtual void onJoinRoomSuccess(const char* roomName, const char* uid, int elapsed);
	virtual void onLeaveRoom();
	virtual void onPlayVolumeIndication(const AudioVolumeInfo* speakers, int speakerCount, int totalVolume) {};
	virtual void onInputVolume(unsigned volume) {}
	virtual void onOutputVolume(unsigned volume) {}
	virtual void onRemoteAudioStopped(const char* uid, bool stop);
	virtual void onRemoteVideoStopped(const char* uid, bool stop);
	virtual void onVideoSizeChanged(const char* uid, int width, int height, int rotation) {};
	virtual void onRemoteVideoPlay(const char* uid, int width, int height, int elapsed) {}
	virtual void onBizAuthResult(bool bPublish, AUTH_RESULT result) {}
	virtual void onSdkAuthResult(AUTH_RESULT result) {}
	virtual void onTokenWillExpire(const char* token);
	virtual void onTokenRequest() {}
	virtual void onUserBanned(bool status) {}
	virtual void onUserJoined(const char* uid, int elapsed);
	virtual void onUserOffline(const char* uid, USER_OFFLINE_REASON_TYPE reason);
	virtual void onNetworkQuality(const char* uid, NetworkQuality txQuality, NetworkQuality rxQuality);
	virtual void onFirstLocalVideoFrameSent(int elapsed);
	virtual void onFirstLocalAudioFrameSent(int elapsed) {}
	virtual void onConnectionStatus(ThunderConnectionStatus status);
	virtual void onConnectionLost() {}
	virtual void onNetworkTypeChanged(ThunderNetworkType type) {}
	virtual void onPublishStreamToCDNStatus(const char* url, ThunderPublishCDNErrorCode errorCode);
	virtual void onRoomStats(RoomStats stats);
	virtual void onAudioCaptureStatus(ThunderAudioDeviceStatus type) {}
	virtual void OnAudioDeviceStateChange(const char* deviceId, int deviceType, int deviceState);
	virtual void onVideoDeviceStateChanged(const char* deviceId, MEDIA_DEVICE_TYPE deviceType, MEDIA_DEVICE_STATE_TYPE deviceState);
	virtual void onRecvUserAppMsgData(const char* uid, const char* msgData) {}
	virtual void onSendAppMsgDataFailedStatus(int status) {}
	virtual void onVideoCaptureStatus(int status);
	virtual void onLocalVideoStats(const LocalVideoStats stats);
	virtual void onLocalAudioStats(const LocalAudioStats stats) {}
	virtual void onRemoteVideoStatsOfUid(const char* uid, const RemoteVideoStats stats) {}
	virtual void onRemoteAudioStatsOfUid(const char* uid, const RemoteAudioStats stats) {}
	ThunderManager*	getThunderManager();

private:
	MediaManager();
	void SSMessageToDlg(const UINT32 id, void* lpBuffer);
private:
	ThunderManager*	m_thunderManager;
	HWND m_hMessageDlg;
	static MediaManager* m_pInstance;
	
};

 