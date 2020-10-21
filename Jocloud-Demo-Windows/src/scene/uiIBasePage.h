/*
 * File: uiIBasePage
 * Author: LanPZzzz
 * Date: 2020/05/29
 * Description: Scene UI Base Interface
 */

#pragma once

#include "stdafx.h"
#include "uiPageConstant.h"
#include <string>
class IUIBasePage {
public:

	//************************************
	// Method:    init
	// Date: 2020/05/29
	// Description: invoke after construction
	// FullName:  IUIBasePage::init
	// Access:    virtual public 
	// Returns:   void
	// Parameter: SOUI::SWindow * pRoot
	//************************************
	virtual void init(SOUI::SWindow *pRoot) {
		_pPageRoot = pRoot;
	}

	//************************************
	// Method:    unInit
	// Date: 2020/05/29
	// Description: invoke before destruction
	// FullName:  IUIBasePage::unInit
	// Access:    virtual public 
	// Returns:   void
	//************************************
	virtual void unInit() = 0;

	//************************************
	// Method:    beforeAppear
	// Date: 2020/05/29
	// Description: invoke before the page appear
	// FullName:  IUIBasePage::beforeAppear
	// Access:    virtual public 
	// Returns:   void
	//************************************
	virtual void beforeAppear() {};

	virtual void afterAppear() {};
	//************************************
	// Method:    beforeDisappear
	// Date: 2020/05/29
	// Description: invoke before page disappear
	// FullName:  IUIBasePage::beforeDisappear
	// Access:    virtual public 
	// Returns:   void
	//************************************
	virtual void beforeDisappear() {};

	//************************************
	// Method:    registerPageEvent
	// Date: 2020/05/29
	// Description: register page event to outer
	// FullName:  IUIBasePage::registerPageEvent
	// Access:    virtual public 
	// Returns:   void
	// Parameter: PageEventHandleProc
	//************************************
	virtual void registerPageEvent(UIPageEventHandleProc onPageEvent) { _oPageEvent = onPageEvent; }

	//************************************
	// Method:    switchLanguage
	// Date: 2020/06/01
	// Description: switch language after click language button. need to self switch language controller
	// FullName:  IUIBasePage::switchLanguage
	// Access:    virtual public 
	// Returns:   void
	//************************************
	virtual void switchLanguage() {};

	//************************************
	// Method:    switchScene
	// Date: 2020/06/05
	// Description: switch scene from - to
	// FullName:  IUIBasePage::switchScene
	// Access:    virtual public 
	// Returns:   void
	// Parameter: UIScenePageType from
	// Parameter: UIScenePageType to
	//************************************
	virtual void switchScene(UIScenePageType from, UIScenePageType to) {};

	//************************************
	// Method:    setScenePageType
	// Date: 2020/06/05
	// Description: setScenePageType 
	// FullName:  IUIBasePage::setScenePageType
	// Access:    virtual public 
	// Returns:   void
	// Parameter: UIScenePageType t
	//************************************
	virtual void setScenePageType(UIScenePageType t) { _eScenePageType = t; }

	//************************************
	// Method:    getScenePageType
	// Date: 2020/06/05
	// Description: getScenePageType
	// FullName:  IUIBasePage::getScenePageType
	// Access:    virtual public 
	// Returns:   const UIScenePageType
	//************************************
	virtual const UIScenePageType getScenePageType() const { return _eScenePageType; }

	//************************************
	// Method:    _HandleEvent
	// Date: 2020/05/29
	// Description: SOUI window handle event, please use:
				// EVENT_MAP_BEGIN()
				//	  EVENT_CHECK_SENDER_ROOT(_pPageRoot)
				// EVENT_MAP_BREAK()
	// FullName:  IUIBasePage::_HandleEvent
	// Access:    virtual public 
	// Returns:   BOOL
	// Parameter: SOUI::EventArgs * pEvt
	//************************************
	virtual BOOL _HandleEvent(SOUI::EventArgs *pEvt) = 0;

	//************************************
	// Method:    onThunderManagerCB
	// Date: 2020/09/16
	// Description: e:
	// FullName:  IUIBasePage::onThunderManagerCB
	// Access:    virtual public 
	// Returns:   LRESULT
	// Parameter: 
	//************************************
	virtual LRESULT onThunderManagerCB(UINT uMsg, WPARAM wp, LPARAM lp, BOOL &bHandle) { return true; };

protected:
	SOUI::SWindow *_pPageRoot;
	UIPageEventHandleProc _oPageEvent;
	UIScenePageType _eScenePageType;
};