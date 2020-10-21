/*
 * File: pageManager
 * Author: LanPZzzz
 * Date: 2020/06/04
 * Description: 
 */

#pragma once

#include "stdafx.h"

class  LogicPageManager {
public:
	 LogicPageManager();
	~ LogicPageManager();

	void registerPage(UIScenePageType pageType);

	IUIBasePage* getPageFromType(UIScenePageType pageType);

	void init(UIPageEventHandleProc onPageEvent, SOUI::SWindow *pRoot);

	void switchLanguage();

	void beforeDisappear(UIScenePageType pageType);

	void beforeAppear(UIScenePageType pageType);

	void unInit();
	
private:
	IUIBasePage* _pUIBasePageArray[int(UIScenePageType::SCENE_PAGE_MAX)];
};