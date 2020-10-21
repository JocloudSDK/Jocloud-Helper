#pragma once
#include "stdafx.h"
#include <WinDef.h>
#include<string>
using namespace std;
#include <time.h> 
#include <cstdlib>
#include <ctime>
#define random(a,b) (rand()%(b-a+1)+ a )

#include <Netlistmgr.h>

extern string CT_strLanguageType;

struct LanguageInfoText {
	string type;
	wstring _zhLanguage;
	wstring _enLanguage;
};

class CRaysPublics
{
public:

	static wstring GetLanguageInfoText(wstring strType)
	{
		wchar_t str[128] = { 0 };
		SApplication::getSingleton().GetTranslator()->tr(strType.c_str(), L"dlg_main", str, 128);
		return wstring(str);
	}

	static string GetRandom(int len)
	{
		srand((unsigned)time(NULL));
		int firstNum = random(1, 9);
		string strRet = to_string(firstNum);
		for (int i = 0; i < len - 1; i++)
		{
			int ran = random(0, 9);
			strRet.append(to_string(ran));
		}
		return strRet;
	}

	static bool checkIsNetwork()
	{
		CoInitialize(NULL);
		//  通过NLA接口获取网络状态
		IUnknown *pUnknown = NULL;
		BOOL   bOnline = TRUE;//是否在线  
		HRESULT Result = CoCreateInstance(CLSID_NetworkListManager, NULL, CLSCTX_ALL, IID_IUnknown, (void **)&pUnknown);
		if (SUCCEEDED(Result))
		{
			INetworkListManager *pNetworkListManager = NULL;
			if (pUnknown)
				Result = pUnknown->QueryInterface(IID_INetworkListManager, (void **)&pNetworkListManager);
			if (SUCCEEDED(Result))
			{
				VARIANT_BOOL IsConnect = VARIANT_FALSE;
				if (pNetworkListManager)
					Result = pNetworkListManager->get_IsConnectedToInternet(&IsConnect);
				if (SUCCEEDED(Result))
				{
					bOnline = (IsConnect == VARIANT_TRUE) ? true : false;
				}
			}
			if (pNetworkListManager)
				pNetworkListManager->Release();
		}
		if (pUnknown)
			pUnknown->Release();
		CoUninitialize();
		return bOnline;
	}

	static bool IsdigitAll(const char *pSrc)
	{
		if (pSrc == NULL)return false;
		if (*pSrc == '0')return false;
		const char *pTemp = pSrc;
		while (*pTemp != '\0')
		{
			char p = *pTemp;
			if (!isdigit(*pTemp))
			{
				return false;
			}
			pTemp++;
		}
		return true;
	}

	static bool IsUrlLegal(const char *pSrc)
	{
		string strCom = "rtmp://";
		if (pSrc == NULL)return false;
		if (strlen(pSrc) < strCom.length())return false;
		if(strCom.compare(0, strCom.length(), pSrc, 0, strCom.length()) != 0)return false;
		const char *pTemp = pSrc;
		while (*pTemp != '\0')
		{
			if (*pTemp < 0x1E || *pTemp > 0x7F)
			{
				return false;
			}
			pTemp++;
		}
		return true;
	}

	static int SendMessageBox(LPCWSTR info, int type)
	{
		int souiType = MB_OK;
		if (strcmp(CT_strLanguageType.c_str(), "zh") == 0)
		{	
			if (type == MB_OKCANCEL)
			{
				souiType = MB_YESNO;
			}
		}
		else
		{
			if (type == MB_OKCANCEL)
			{
				souiType = MB_OKCANCEL;
			}
		}
		int nRet = SOUI::SMessageBox(NULL, info, _T(""), souiType);
		if (nRet == 6)nRet = 1; //ok
		if (nRet == 7 || nRet == 2)nRet = 0; //cancle
		return nRet;
	}

	static bool CheckUidAndRoomId(const wstring &defaultText,const char* uid_, const char* roomid_)
	{
		bool bIllegality = true;
		wstring str = defaultText;
		do
		{
			if (uid_ == NULL || roomid_ == NULL)break;

			if (strlen(uid_) == 0 || strlen(roomid_) == 0)break;
			if (!IsdigitAll(uid_))
			{
				str = GetLanguageInfoText(L"messgebox_digitsuid");
				break;
			}
			if (!IsdigitAll(roomid_))
			{
				str = GetLanguageInfoText(L"messgebox_digitsroom");
				break;
			}
			bIllegality = false;
		} while (FALSE);

		if (bIllegality)
		{
			SendMessageBox(str.c_str(), 0);
		}
		return bIllegality;
	}
};

