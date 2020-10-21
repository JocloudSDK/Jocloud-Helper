#include "stdafx.h"
#include "uiSettingPage.h"

#define LANGUAGE_MAX int(UIPageTranslateLanguage::PAGE_TRANSLATE_MAX) - int(UIPageTranslateLanguage::PAGE_TRANSLATE_ZH)
static std::wstring g_LanguageStr[LANGUAGE_MAX] = {
	L"zh",
	L"en"
};

UISettingPage::UISettingPage() {
	for (int i = 0; i < LANGUAGE_MAX; i++) {
		_oLanguageMap.insert(std::pair<std::wstring, UIPageTranslateLanguage>(g_LanguageStr[i], UIPageTranslateLanguage(int(UIPageTranslateLanguage::PAGE_TRANSLATE_ZH) + i)));
	}
}

UISettingPage::~UISettingPage() {

}

void UISettingPage::init(SOUI::SWindow *pRoot) {
	IUIBasePage::init(pRoot);

	_pComboBox = pRoot->FindChildByID2<SComboBox>(R.id.cbx_language);
	_pEdit = pRoot->FindChildByID2<SEdit>(R.id.edit_dir);

	// 1. read language from ini file
	std::wstring strLanguage;
	bool ret = ConfigFile::getSingletonPtr()->readStringFromKey(_T("Setting"), _T("Language"), _T("zh"), strLanguage);
	if (!ret) {
		SMessageBox(NULL, SStringT().Format(_T("%s"), _T("get language from config.ini failed")), TR(_T("messgebox_title_warning"), _T("dlg_main")), MB_OK);
	}
	else {
		// 2. switch language
		switchLanguage(_oLanguageMap[strLanguage]);

		// 3. set combobox current select
		int curSel = 0;
		for (int i = 0; i < _pComboBox->GetCount(); i++) {
			int data = (int)_pComboBox->GetItemData(i);
			if (int(_oLanguageMap[strLanguage]) == data) {
				curSel = i;
				break;
			}
		}
		_pComboBox->SetCurSel(curSel);
	}

	// 4. set appid edit input
	long long appid = 0;
	ret = ConfigFile::getSingletonPtr()->readLLFromKey(_T("Setting"), _T("APPID"), appid);
	if (!ret) {
		SMessageBox(NULL, SStringT().Format(_T("%s"), _T("get appid from config.ini failed")), TR(_T("messgebox_title_warning"), _T("dlg_main")), MB_OK);
	}
	else {
		if (appid != 0) {
			_pEdit->SetWindowText(std::to_wstring(appid).c_str());
		}
	}
}

void UISettingPage::unInit() {
}

void UISettingPage::beforeAppear() {
}

void UISettingPage::beforeDisappear() {
}

void UISettingPage::switchLanguage(UIPageTranslateLanguage l) {
	if (_oPageEvent) {
		_oPageEvent(UIPageEvent::PAGE_EVENT_SWITCH_LANGUAGE, &l, this);
	}
}

void UISettingPage::switchLanguage() {
}

bool UISettingPage::checkEditNull() {
	// 1. check edit null
	return _pEdit->GetWindowTextW().IsEmpty();
}

// for test
void UISettingPage::onQuitPage() {
	if (_oPageEvent) {
		_oPageEvent(UIPageEvent::PAGE_EVENT_DISAPPEAR_INITIATIVE, nullptr, this);
	}
}

void UISettingPage::onClickBtnSave() {
	if (checkEditNull()) {
		SMessageBox(NULL, SStringT().Format(_T("%s"), _T("edit input must not be empty!!!!")), TR(_T("messgebox_title_warning"), _T("dlg_main")), MB_OK);
		return;
	}

	// 1. get language
	UIPageTranslateLanguage l = UIPageTranslateLanguage(_pComboBox->GetItemData(_pComboBox->GetCurSel()));
	switchLanguage(l);

	// 2. get appid and save
	SStringT strAppid = _pEdit->GetWindowTextW();
	long long appId = std::stoll(strAppid.c_str());
	bool ret = ConfigFile::getSingletonPtr()->writeLLForKey(_T("Setting"), _T("APPID"), appId);
	if (!ret) {
		SMessageBox(NULL, SStringT().Format(_T("%s"), _T("write appid to config.ini failed")), TR(_T("messgebox_title_warning"), _T("dlg_main")), MB_OK);
	}

	// 3. get language
	std::wstring strLanguage;
	for (auto p = _oLanguageMap.begin(); p != _oLanguageMap.end(); p++) {
		if ((*p).second == l) {
			strLanguage = (*p).first;
			break;
		}
	}

	ret = ConfigFile::getSingletonPtr()->writeStringForKey(_T("Setting"), _T("Language"), strLanguage);
	if (!ret) {
		SMessageBox(NULL, SStringT().Format(_T("%s"), _T("write language to config.ini failed")), TR(_T("messgebox_title_warning"), _T("dlg_main")), MB_OK);
	}
}
