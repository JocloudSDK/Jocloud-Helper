#include "stdafx.h"
#include "config.h"

template<>
ConfigFile* SSingleton<ConfigFile>::ms_Singleton = NULL;

bool ConfigFile::parse(const std::wstring path) {
	bool ret = false;
	FILE* fp = nullptr;
	// neet to create the config.ini
	fp = _wfopen( path.c_str(), L"ab+");
	if (fp) {
		ret = true;
		fclose(fp);
	}

	_strPath = path;
	return ret;
}

bool ConfigFile::readLLFromKey(const std::wstring setion, const std::wstring key, long long& value) {
	wchar_t tmp[MAX_PATH];
	BOOL ret = ::GetPrivateProfileStringW(setion.c_str(), key.c_str(), _T("0"), tmp, MAX_PATH, _strPath.c_str());
	if (ret) {
		swscanf(tmp, _T("%lld"), &value);
	}
	return ret ? true : false;
}

bool ConfigFile::readStringFromKey(const std::wstring setion, const std::wstring key, const std::wstring default, std::wstring& value) {
	wchar_t tmp[MAX_PATH];
	BOOL ret = ::GetPrivateProfileStringW(setion.c_str(), key.c_str(), default.c_str(), tmp, MAX_PATH, _strPath.c_str());
	value += tmp;
	return ret ? true : false;
}

bool ConfigFile::writeLLForKey(const std::wstring setion, const std::wstring key, long long value) {
	wchar_t tmp[MAX_PATH];
	wsprintf(tmp, _T("%ld"), value);
	return ::WritePrivateProfileString(setion.c_str(), key.c_str(), tmp, _strPath.c_str()) ? true : false;
}

bool ConfigFile::writeStringForKey(const std::wstring setion, const std::wstring key, const std::wstring value) {
	return ::WritePrivateProfileString(setion.c_str(), key.c_str(), value.c_str(), _strPath.c_str()) ? true : false;
}
