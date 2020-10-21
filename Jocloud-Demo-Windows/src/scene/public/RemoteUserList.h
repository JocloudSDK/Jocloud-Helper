#pragma once

struct RemoteUserInfo
{
	bool bAudioStop;
	bool bVideoStop;
	//bool video;
	//bool audio;
	int index;
	string strUid;
};

typedef enum EMediaType
{
	E_AUDIO = 0x01,
	E_VIDEO = 0x02
}MediaType;

class CRemoteUserList
{
public:
	CRemoteUserList();
	~CRemoteUserList();
	int AddRemoteUser(const char* uid);
	std::shared_ptr<RemoteUserInfo > GetRemoteUserFromList(int pos_);
	int GetRemoteUserPosFromList(const char* uid_);
	void UpdataRemoteUser(const char* uid_, EMediaType type_, bool isStop);
	void DeleteRemoteUser(const char* uid_);
	void ClearAllUser();
	int GetRemoteUserCanvasIndex(int pos_);
	void SetRemoteUserCanvasIndex(int pos_,int index_);
	bool IsleaveRoomed(int pos_);
	int GetRemoteUserNotShowFormList();
	int GetRemoteUserCount();
private:
	vector<std::shared_ptr<RemoteUserInfo >> m_JoinUserList;
};