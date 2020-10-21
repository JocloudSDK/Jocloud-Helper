#pragma once
#include<string.h>
using namespace std;

//typedef void(*onComboBoxChangeCB)(HANDLE haneld_, int nComType,int nSel);
typedef std::function<void(int nComType, int nSel) > onComboBoxChangeCB;
class CMediaDeviceManage
{
public:
	CMediaDeviceManage(SOUI::SWindow *,SComboBox *videoCombobox, SComboBox *aInPutCombobox, SComboBox *aOutPutCombobox);
	~CMediaDeviceManage();

	bool ScanAudioInputDevice();
	bool ScanAudioOutputDevice();
	bool ScanVideoDevice();

	void SubscribeEvent(onComboBoxChangeCB e);
	GUID getAudioInputDevice();
	GUID getAudioOutputDevice();
	UINT32 getVideoDevice();
	void OnDeviceDetected(DeviceDetected *pSta);
protected:

private:
	SComboBox *m_VideoCombobox;
	SComboBox *m_AudioOutPutCombobox;
	SComboBox *m_AudioInPutCombobox;

	std::vector<GUID> m_oAudioInputDeviceVector;
	std::vector<GUID> m_oAudioOutputDeviceVector;
	std::vector<UINT32> m_oVideoDeviceVector;
	SOUI::SWindow *_pPageRootWnd;
	onComboBoxChangeCB m_onComboBoxChange;
};