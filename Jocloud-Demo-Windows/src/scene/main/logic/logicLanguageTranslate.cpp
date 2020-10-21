#include "stdafx.h"
#include "logicLanguageTranslate.h"

LogicLanguageTranslate::LogicLanguageTranslate() {
	_oLanguageMap.insert(std::pair<UIPageTranslateLanguage, TCHAR*>(UIPageTranslateLanguage::PAGE_TRANSLATE_ZH, const_cast<TCHAR*>(UIRES.translator.lang_cn)));
	_oLanguageMap.insert(std::pair<UIPageTranslateLanguage, TCHAR*>(UIPageTranslateLanguage::PAGE_TRANSLATE_EN, const_cast<TCHAR*>(UIRES.translator.lang_en)));
}

LogicLanguageTranslate::~LogicLanguageTranslate() {

}

void LogicLanguageTranslate::setSWindow(SOUI::SWindow* pWindow) {
	_pWindow = pWindow;
}

void LogicLanguageTranslate::switchLanguate(UIPageTranslateLanguage language) {
	ITranslatorMgr *pTransMgr = SApplication::getSingletonPtr()->GetTranslator();
	SASSERT(pTransMgr);
	pugi::xml_document xmlLang;
	if (SApplication::getSingletonPtr()->LoadXmlDocment(xmlLang, _oLanguageMap[language])) {
		CAutoRefPtr<ITranslator> lang;
		pTransMgr->CreateTranslator(&lang);
		lang->Load(&xmlLang.child(L"language"), 1);//1=LD_XML
		TCHAR lngName[TR_MAX_NAME_LEN] = { 0 };
		lang->GetName(lngName);
		pTransMgr->SetLanguage(lngName);
		pTransMgr->InstallTranslator(lang);
		_pWindow->SDispatchMessage(UM_SETLANGUAGE, 0, 0);
	}
}
