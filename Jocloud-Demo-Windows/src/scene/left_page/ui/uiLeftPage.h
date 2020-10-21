/*
 * File: uiLeftPage
 * Author: LanPZzzz
 * Date: 2020/06/03
 * Description: Main page left
 */
#pragma once

#include "stdafx.h"

struct LanguageInfo;
class UILeftPage : public IUIBasePage {
public:
	UILeftPage();
	virtual ~UILeftPage();

	virtual void init(SOUI::SWindow *pRoot) override;

	virtual void unInit() override;

	virtual void switchScene(UIScenePageType from, UIScenePageType to) override;


private:
	void initLanguage();

	void switchToLanguage(UIPageTranslateLanguage l);

	void switchSceneFromTo(UIScenePageType from, UIScenePageType to);

protected:
	void onClickBtnQuickDifferentRoom();
	void onClickBtnQuickSameRoom();
	void onClickBtnVideoAdvance();
	void onClickBtnAudioAdvance();
	void onClickBtnQuickRts();
	void onClickBtnMixPicture();
	void onClickBtnDoc();
	void onClickBtnSwitchLanguage();

protected:
	EVENT_MAP_BEGIN()
		EVENT_CHECK_SENDER_ROOT(_pPageRoot)
		/*
		* Description: register button click event
		*/
		EVENT_NAME_COMMAND(L"btn_left_quick_different_room", onClickBtnQuickDifferentRoom)
		EVENT_NAME_COMMAND(L"btn_left_quick_same_room", onClickBtnQuickSameRoom)
		EVENT_NAME_COMMAND(L"btn_left_video_advance", onClickBtnVideoAdvance)
		EVENT_NAME_COMMAND(L"btn_left_audio_advance", onClickBtnAudioAdvance)
		EVENT_NAME_COMMAND(L"btn_left_rts", onClickBtnQuickRts)
		EVENT_NAME_COMMAND(L"btn_left_mix_picture", onClickBtnMixPicture)
		EVENT_NAME_COMMAND(L"btn_left_doc", onClickBtnDoc)
		EVENT_NAME_COMMAND(L"btn_left_switch_language", onClickBtnSwitchLanguage)
	EVENT_MAP_BREAK()

private:
	SImageWnd* _pImageWndLeftSwitchLanguage;
	LanguageInfo* _pCurrentLanguageInfo;
	UIScenePageType _eCurrentScenePage;
};
