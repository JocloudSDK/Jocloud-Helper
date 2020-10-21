#include "stdafx.h"
#include "UILeftPage.h"

extern const char* g_AppDocUrl;
struct LanguageInfo {
	std::string _strLanguage;
	UIPageTranslateLanguage _eTranslateLanguage;
	int _iLanguageImgIcon;
};

string CT_strLanguageType = "zh";
#define LANGUAGE_MAX int(UIPageTranslateLanguage::PAGE_TRANSLATE_MAX) - int(UIPageTranslateLanguage::PAGE_TRANSLATE_ZH)

static LanguageInfo g_LanguageInfo[LANGUAGE_MAX] = {
	{"zh", UIPageTranslateLanguage::PAGE_TRANSLATE_ZH, int(int(UIPageTranslateLanguage::PAGE_TRANSLATE_ZH) - int(UIPageTranslateLanguage::PAGE_TRANSLATE_ZH))},
	{"en", UIPageTranslateLanguage::PAGE_TRANSLATE_EN, int(int(UIPageTranslateLanguage::PAGE_TRANSLATE_EN) - int(UIPageTranslateLanguage::PAGE_TRANSLATE_ZH)) },
};

UILeftPage::UILeftPage() {
	_eCurrentScenePage = UIScenePageType::SCENE_PAGE_NULL;
}

UILeftPage::~UILeftPage() {
}

void UILeftPage::init(SOUI::SWindow *pRoot) {
	IUIBasePage::init(pRoot);

	initLanguage();
}

void UILeftPage::unInit() {

}

void UILeftPage::switchScene(UIScenePageType, UIScenePageType to) {
	_eCurrentScenePage = to;
}

void UILeftPage::onClickBtnQuickDifferentRoom() {
	switchSceneFromTo(_eCurrentScenePage, UIScenePageType::SCENE_PAGE_VIDEO_DIFFERENT_ROOM);
}

void UILeftPage::onClickBtnQuickSameRoom() {
	switchSceneFromTo(_eCurrentScenePage, UIScenePageType::SCENE_PAGE_VIDEO_SAME_ROOM);
}

void UILeftPage::onClickBtnVideoAdvance() {

}

void UILeftPage::onClickBtnAudioAdvance() {

}

void UILeftPage::onClickBtnQuickRts() {

}

void UILeftPage::onClickBtnMixPicture() {

}

void UILeftPage::onClickBtnDoc() {
	SOUI::SWindow *dowRight = _pPageRoot->FindChildByID(R.id.main_window_right_dlg);

	//dowRight->SetVisible(FALSE, TRUE);
	//dowRight->SetAttribute(L"display", L"0", true);
	openWebUrl(s2ws(g_AppDocUrl));
}

void UILeftPage::onClickBtnSwitchLanguage() {
	// 1. find next language
	for (int i = 0; i < LANGUAGE_MAX; i++) {
		if (_pCurrentLanguageInfo == &g_LanguageInfo[i]) {
			if (i == LANGUAGE_MAX - 1) {
				_pCurrentLanguageInfo = &g_LanguageInfo[0];
			}
			else {
				_pCurrentLanguageInfo = &g_LanguageInfo[i + 1];
			}
			break;
		}
	}

	// 2. switch language image icon

	if (_pCurrentLanguageInfo->_strLanguage.compare(g_LanguageInfo[0]._strLanguage))
	{
		_pImageWndLeftSwitchLanguage->SetAttribute(L"skin", L"skin_left_switch_language");
	}
	else
	{
		_pImageWndLeftSwitchLanguage->SetAttribute(L"skin", L"skin_left_switch_en_language");
	}
	switchLanguage();
	CT_strLanguageType = _pCurrentLanguageInfo->_strLanguage;
	// 3. switch language
	switchToLanguage(_pCurrentLanguageInfo->_eTranslateLanguage);
	
	// 4. save language
	bool ret = ConfigFile::getSingletonPtr()->writeStringForKey(_T("Setting"), _T("Language"), s2ws(_pCurrentLanguageInfo->_strLanguage));
	if (!ret) {
		SMessageBox(NULL, SStringT().Format(_T("%s"), _T("write language to config.ini failed")), TR(_T("messgebox_title_warning"), _T("dlg_main")), MB_OK);
	}
}

/// =================== private ======================
void UILeftPage::initLanguage() {
	_pImageWndLeftSwitchLanguage = _pPageRoot->FindChildByID2<SImageWnd>(R.id.img_left_switch_language);

	// 1. read language from ini file
	std::wstring strLanguage;
	bool ret = ConfigFile::getSingletonPtr()->readStringFromKey(_T("Setting"), _T("Language"), _T("zh"), strLanguage);
	std::string strCurrentLangage = ws2s(strLanguage);
	for (int i = 0; i < LANGUAGE_MAX; i++) {
		if (strCurrentLangage.compare(g_LanguageInfo[i]._strLanguage) == 0) {
			_pCurrentLanguageInfo = &g_LanguageInfo[i];
			break;
		}
	}

	if (!ret) {
		SMessageBox(NULL, SStringT().Format(_T("%s"), _T("get language from config.ini failed")), TR(_T("messgebox_title_warning"), _T("dlg_main")), MB_OK);
	}

	// 2. switch language
	
	switchToLanguage(_pCurrentLanguageInfo->_eTranslateLanguage);
	if (strCurrentLangage.compare(g_LanguageInfo[0]._strLanguage))
	{
		_pImageWndLeftSwitchLanguage->SetAttribute(L"skin", L"skin_left_switch_language");
	}
	else
	{
		_pImageWndLeftSwitchLanguage->SetAttribute(L"skin", L"skin_left_switch_en_language");
	}
	CT_strLanguageType = _pCurrentLanguageInfo->_strLanguage;
	//_pImageWndLeftSwitchLanguage->SetIcon(_pCurrentLanguageInfo->_iLanguageImgIcon);
	switchLanguage();
}

void UILeftPage::switchToLanguage(UIPageTranslateLanguage l) {
	if (_oPageEvent) {
		_oPageEvent(UIPageEvent::PAGE_EVENT_SWITCH_LANGUAGE, &l, this);
	}
}

void UILeftPage::switchSceneFromTo(UIScenePageType from, UIScenePageType to) {
	// 1. check _eCurrentScenePage
	if (_eCurrentScenePage == to) {
		return;
	}

	// 2. message box to warning switch scene

	// 3. if step 2 is ok, switch scene
	if (_oPageEvent) {
		UISceneSwitchEvent switchEvent;
		switchEvent._eFrom = from;
		switchEvent._eTo = to;
		_oPageEvent(UIPageEvent::PAGE_EVENT_SWITCH_SCENE, &switchEvent, this);

		_eCurrentScenePage = to;

		// 4. change button image
	}
}
