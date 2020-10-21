/*
 * File: uiPageConstant
 * Author: LanPZzzz
 * Date: 2020/05/29
 * Description: UI Page constant
 */
#pragma once

#include <functional>

/*
 * Description: Scene create type
*/
enum class UIScenePageType {
	SCENE_PAGE_NULL = 0,

	/// ---  left controller insert here
	SCENE_PAGE_VIDEO_DIFFERENT_ROOM,  /// see name="tab_ctrls" page index
	SCENE_PAGE_VIDEO_SAME_ROOM,  /// see name="tab_ctrls" page index
	/// ---  left controller insert here

	SCENE_PAGE_LEFT,  /// not to change the position
	SCENE_PAGE_MAX,  /// this is the last one
};

/*
 * Description: Page event to outer
*/
enum class UIPageEvent {
	PAGE_EVENT_DISAPPEAR_INITIATIVE = 1000,  /// page disappear event from initiative
	PAGE_EVENT_SWITCH_LANGUAGE, /// page switch language event
	PAGE_EVENT_SWITCH_SCENE, /// page switch page event, eventParam see UISceneSwitchEvent
	PAGE_EVENT_MAX,  /// this is the last one
};

/*
 * Description: Page translate event to outer
*/
enum class UIPageTranslateLanguage {
	PAGE_TRANSLATE_ZH = 2000,   /// translate to Chinese
	PAGE_TRANSLATE_EN, /// translate to English
	PAGE_TRANSLATE_MAX,  /// this is the last one
};

class IUIBasePage;
typedef std::function<void (UIPageEvent event, void* eventParam, IUIBasePage* source) > UIPageEventHandleProc;

/*
 * Description: PAGE_SWITCH_SCENE event struct
*/
struct UISceneSwitchEvent {
	UIScenePageType _eFrom;
	UIScenePageType _eTo;
};
