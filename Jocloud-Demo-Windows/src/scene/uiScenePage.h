/*
 * File: uiScenePage
 * Author: LanPZzzz
 * Date: 2020/05/29
 * Description: Create scene
 */
#pragma once

#include "uiIBasePage.h"
#include "uiPageConstant.h"

class UISencePageFactory {
public:

	//************************************
	// Method:    CreateSencePage
	// Date: 2020/05/29
	// Description: Scene factory
	// FullName:  UISencePage::CreateSencePage
	// Access:    public static 
	// Returns:   IUIBasePage*
	// Parameter: UIScenePageType t
	//************************************
	static IUIBasePage* CreateSencePage(UIScenePageType t);
};
