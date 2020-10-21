#include "stdafx.h"
#include "logicPageManager.h"
#include "scene/uiScenePage.h"

#define SCENE_MAX int(UIScenePageType::SCENE_PAGE_MAX)

LogicPageManager::LogicPageManager() {
	memset(_pUIBasePageArray, 0, sizeof(void*) * SCENE_MAX);
}

LogicPageManager::~LogicPageManager() {
	for (int i = 0; i < SCENE_MAX; i++) {
		if (_pUIBasePageArray[i]) {
			delete _pUIBasePageArray[i];
		}
	}
}

void LogicPageManager::registerPage(UIScenePageType pageType) {
	_pUIBasePageArray[int(pageType)] = UISencePageFactory::CreateSencePage(pageType);
}

IUIBasePage* LogicPageManager::getPageFromType(UIScenePageType pageType) {
	return _pUIBasePageArray[int(pageType)];
}

void LogicPageManager::init(UIPageEventHandleProc onPageEvent, SOUI::SWindow *pRoot) {
	for (int i = 0; i < SCENE_MAX; i++) {
		_pUIBasePageArray[i]->registerPageEvent(onPageEvent);
		_pUIBasePageArray[i]->init(pRoot);
	}
}

void LogicPageManager::switchLanguage() {
	for (int i = 0; i < SCENE_MAX; i++) {
		_pUIBasePageArray[i]->switchLanguage();
	}
}

void LogicPageManager::beforeDisappear(UIScenePageType pageType) {
	_pUIBasePageArray[int(pageType)]->beforeDisappear();
}

void LogicPageManager::beforeAppear(UIScenePageType pageType) {
	_pUIBasePageArray[int(pageType)]->beforeAppear();
}

void LogicPageManager::unInit() {
	for (int i = 0; i < SCENE_MAX; i++) {
		_pUIBasePageArray[i]->unInit();
	}
}
