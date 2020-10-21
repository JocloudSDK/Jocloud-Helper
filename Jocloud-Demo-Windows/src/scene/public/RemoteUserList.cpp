#include "stdafx.h"
#include "RemoteUserList.h"

CRemoteUserList::CRemoteUserList()
{

}

CRemoteUserList::~CRemoteUserList()
{

}

int CRemoteUserList::GetRemoteUserPosFromList(const char* uid_)
{
	for (int i = 1; i < m_JoinUserList.size(); i++)
	{
		if (strcmp(m_JoinUserList[i]->strUid.c_str(), uid_) == 0)
		{
			return i;
		}
	}
	return -1;
}

std::shared_ptr<RemoteUserInfo > CRemoteUserList::GetRemoteUserFromList(int pos_)
{
	if (pos_ > m_JoinUserList.size() || pos_<0)return NULL;
	return m_JoinUserList[pos_];
}

int CRemoteUserList::AddRemoteUser(const char* uid_)
{
	if (NULL == uid_)return -1;
	int pos_ = -1;
	if (GetRemoteUserPosFromList(uid_) < 0)
	{
		std::shared_ptr<RemoteUserInfo> user(new RemoteUserInfo);
		user->strUid = uid_;
		user->bVideoStop = true;
		user->bAudioStop = true;
		user->index = -1;
		m_JoinUserList.push_back(user);
		pos_ = m_JoinUserList.size() - 1;
	}
	return pos_;
}

void CRemoteUserList::UpdataRemoteUser(const char* uid_, EMediaType type_, bool isStop)
{
	if (NULL == uid_)return;
	int pos_ = GetRemoteUserPosFromList(uid_);
	if (pos_ < 0)return;
	if(type_ == E_VIDEO)m_JoinUserList[pos_]->bVideoStop = isStop;
	if (type_ == E_AUDIO)m_JoinUserList[pos_]->bAudioStop = isStop;
}

void CRemoteUserList::DeleteRemoteUser(const char* uid_)
{
	int pos_ = GetRemoteUserPosFromList(uid_);
	if (pos_ < 0)return;
	m_JoinUserList.erase(m_JoinUserList.begin() + pos_);
}

void CRemoteUserList::ClearAllUser()
{
	m_JoinUserList.clear();
}

int CRemoteUserList::GetRemoteUserCanvasIndex(int pos_)
{
	if (pos_ > m_JoinUserList.size() || pos_<0)return -1;
	return m_JoinUserList[pos_]->index;
}

void CRemoteUserList::SetRemoteUserCanvasIndex(int pos_, int index_)
{
	if (pos_ > m_JoinUserList.size() || pos_<0)return;
	m_JoinUserList[pos_]->index = index_;
}

bool CRemoteUserList::IsleaveRoomed(int pos_)
{
	if (pos_ > m_JoinUserList.size() || pos_<0)return false;
	if (m_JoinUserList[pos_]->bAudioStop && m_JoinUserList[pos_]->bVideoStop)return true;
	return false;
}

int CRemoteUserList::GetRemoteUserNotShowFormList()
{
	for (int i = 1; i < m_JoinUserList.size(); i++)
	{
		std::shared_ptr<RemoteUserInfo> pUser = m_JoinUserList[i];
		if (m_JoinUserList[i]->index < 0 && !m_JoinUserList[i]->bVideoStop)
		{
			return i;
		}
	}
	return -1;
}

int CRemoteUserList::GetRemoteUserCount()
{
	return m_JoinUserList.size();
}