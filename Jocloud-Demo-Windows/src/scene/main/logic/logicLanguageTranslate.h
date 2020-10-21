/*
 * File: logicLanguageTranslate
 * Author: LanPZzzz
 * Date: 2020/05/29
 * Description: Language Translate
 */
#pragma once

#include "stdafx.h"
#include <map>

class LogicLanguageTranslate
{
public:
	LogicLanguageTranslate();
	~LogicLanguageTranslate();

	void setSWindow(SOUI::SWindow* pWindow);

	void switchLanguate(UIPageTranslateLanguage language);
	
private:
	SOUI::SWindow* _pWindow;
	std::map<UIPageTranslateLanguage, TCHAR*> _oLanguageMap;
};