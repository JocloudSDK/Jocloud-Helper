#include "stdafx.h"
#include "uiScenePage.h"
#include "null_page\ui\uiNullPage.h"
#include "left_page\ui\uiLeftPage.h"
#include "same_room_page\ui\uiSameRoomPage.h"
#include "different_room_page\ui\uiDifferentRoomPage.h"

IUIBasePage* UISencePageFactory::CreateSencePage(UIScenePageType t) {
	IUIBasePage* page = nullptr;
	switch (t)
	{
	case UIScenePageType::SCENE_PAGE_NULL:
		page = new UINullPage();
		break;
	case UIScenePageType::SCENE_PAGE_VIDEO_SAME_ROOM:
		page = new UISameRoomPage();
		break;
	case UIScenePageType::SCENE_PAGE_VIDEO_DIFFERENT_ROOM:
		page = new UIDifferentRoomPage();
		break;
	case UIScenePageType::SCENE_PAGE_LEFT:
		page = new UILeftPage();
		break;
	default:
		break;
	}
	if (page) {
		page->setScenePageType(t);
	}
	return page;
}
