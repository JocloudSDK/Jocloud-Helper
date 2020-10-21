/*
 * File: ConfigFile
 * Author: LanPZzzz
 * Date: 2020/06/01
 * Description: Write and read ini config
 */

#pragma once

#include "stdafx.h"

class ConfigFile : public SOUI::SSingleton<ConfigFile>
{
public:
	ConfigFile() {};
	virtual ~ConfigFile() {};
	
	bool parse(const std::wstring path);

	bool readLLFromKey(const std::wstring setion, const std::wstring key, long long& value);

	bool readStringFromKey(const std::wstring setion, const std::wstring key, const std::wstring default, std::wstring& value);

	bool writeLLForKey(const std::wstring setion, const std::wstring key, long long value);

	bool writeStringForKey(const std::wstring setion, const std::wstring key, const std::wstring value);

private:
	std::wstring _strPath;
};
