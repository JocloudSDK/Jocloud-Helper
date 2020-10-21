/*
 * File: uiSettingPage
 * Author: LanPZzzz
 * Date: 2020/05/29
 * Description: UI Setting page
 */
#pragma once

#include "stdafx.h"

class UISettingPage : public IUIBasePage {
public:
	UISettingPage();
	virtual ~UISettingPage();

	void init(SOUI::SWindow *pRoot) override;

	void unInit() override;

	void beforeAppear() override;

	void beforeDisappear() override;

	void switchLanguage() override;

private:
	void switchLanguage(UIPageTranslateLanguage l);

	bool checkEditNull();

protected:
	void onClickBtnSave();

	// for test
	void onQuitPage();

	EVENT_MAP_BEGIN()
		EVENT_CHECK_SENDER_ROOT(_pPageRoot)
		/*
		 * Description: register button click event
		*/
		EVENT_NAME_COMMAND(L"same_room_btn", onClickBtnSave)
	EVENT_MAP_BREAK()

private:
	std::map<std::wstring, UIPageTranslateLanguage> _oLanguageMap;
	SComboBox* _pComboBox;
	SEdit* _pEdit;
};