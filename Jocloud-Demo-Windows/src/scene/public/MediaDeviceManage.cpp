#include "stdafx.h"
#include "MediaDeviceManage.h"

CMediaDeviceManage::CMediaDeviceManage(SOUI::SWindow * rootWnd,SComboBox *videoCombobox, SComboBox *aInPutCombobox, SComboBox *aOutPutCombobox)
{
	_pPageRootWnd = rootWnd;
	m_VideoCombobox = videoCombobox;
	m_AudioInPutCombobox = aInPutCombobox;
	m_AudioOutPutCombobox = aOutPutCombobox;
}

CMediaDeviceManage::~CMediaDeviceManage()
{

}

GUID CMediaDeviceManage::getAudioInputDevice()
{
	GUID guid = { 0 };
	if (m_AudioInPutCombobox != NULL)
	{
		int index = m_AudioInPutCombobox->GetCurSel();
		if (index < 0)return guid;
		guid = m_oAudioInputDeviceVector[index];
	}
	return guid;
}

GUID CMediaDeviceManage::getAudioOutputDevice()
{
	GUID guid = { 0 };
	if (m_AudioOutPutCombobox != NULL)
	{
		int index = m_AudioOutPutCombobox->GetCurSel();
		if (index < 0)return guid;
		guid = m_oAudioOutputDeviceVector[index];
	}
	return guid;
}

void CMediaDeviceManage::OnDeviceDetected(DeviceDetected *pSta)
{
	if (pSta->deviceType == AUDIO_RECORDING_DEVICE)
	{
		ScanAudioInputDevice();
	}
	else if (pSta->deviceType == AUDIO_PLAYOUT_DEVICE)
	{
		ScanAudioOutputDevice();
	}
	else if (pSta->deviceType == VIDEO_CAPTURE_DEVICE)
	{
		ScanVideoDevice();
	}

}

void CMediaDeviceManage::SubscribeEvent(onComboBoxChangeCB e)
{

}

UINT32 CMediaDeviceManage::getVideoDevice()
{
	if (m_VideoCombobox == NULL)return 0;
	int index = m_VideoCombobox->GetCurSel();
	if (index < 0)return 0;
	return m_oVideoDeviceVector[index];
}

bool CMediaDeviceManage::ScanAudioInputDevice()
{
	if (m_AudioInPutCombobox == NULL)return false;
	//获取音频输入设备
	AudioDeviceList audioInPutDeviceList;
	if (MediaManager::instance()->getThunderManager()->getAudioDeviceMgr() != NULL)
	{
		MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->enumInputDevices(audioInPutDeviceList);
		m_oAudioInputDeviceVector.clear();
		m_AudioInPutCombobox->ResetContent();
		for (int j = 0; j < audioInPutDeviceList.count; ++j)
		{
			wchar_t wname[1024] = { 0 };
			MultiByteToWideChar(CP_UTF8, 0, audioInPutDeviceList.device[j].desc, -1, wname, _countof(wname));
			m_oAudioInputDeviceVector.push_back(audioInPutDeviceList.device[j].id);
			m_AudioInPutCombobox->InsertItem(j, wname, 0, 0);
		}
	}
	m_AudioInPutCombobox->SetCurSel(0);
	return true;
}

bool CMediaDeviceManage::ScanAudioOutputDevice()
{
	if (m_AudioOutPutCombobox == NULL)return false;
	//获取音频输出设备
	AudioDeviceList audioOutPutDeviceList;
	if (MediaManager::instance()->getThunderManager()->getAudioDeviceMgr() != NULL)
	{
		MediaManager::instance()->getThunderManager()->getAudioDeviceMgr()->enumOutputDevices(audioOutPutDeviceList);
		m_oAudioOutputDeviceVector.clear();
		m_AudioOutPutCombobox->ResetContent();
		for (int j = 0; j < audioOutPutDeviceList.count; ++j)
		{
			wchar_t wname[1024] = { 0 };
			MultiByteToWideChar(CP_UTF8, 0, audioOutPutDeviceList.device[j].desc, -1, wname, _countof(wname));
			m_oAudioOutputDeviceVector.push_back(audioOutPutDeviceList.device[j].id);
			m_AudioOutPutCombobox->InsertItem(j, wname, 0, 0);
		}
	}
	m_AudioOutPutCombobox->SetCurSel(0);
	return true;
}

bool CMediaDeviceManage::ScanVideoDevice()
{
	if (m_VideoCombobox == NULL)return false;
	m_oVideoDeviceVector.clear();
	VideoDeviceList videoDevList = {0};
	IVideoDeviceManager* manager = MediaManager::instance()->getThunderManager()->getVideoDeviceMgr();
	m_VideoCombobox->ResetContent();
	if (manager != NULL) {
		manager->enumVideoDevices(videoDevList);
		for (int i = 0; i < videoDevList.count; i++)
		{
			wstring str = s2ws(videoDevList.device[i].name);
			wchar_t wname[1024] = { 0 };
			MultiByteToWideChar(CP_UTF8, 0, videoDevList.device[i].name, -1, wname, _countof(wname));
			m_VideoCombobox->InsertItem(i, wname, 0, 0);
			m_oVideoDeviceVector.push_back(videoDevList.device[i].index);
		}
	}
	m_VideoCombobox->SetCurSel(0);
	return true;
}
