/*
 * File: uiNullPage
 * Author: LanPZzzz
 * Date: 2020/05/29
 * Description: Null page, no ui controller
 */
#pragma once

#include "stdafx.h"

class UINullPage : public IUIBasePage {
public:
	UINullPage();
	virtual ~UINullPage();

	virtual void init(SOUI::SWindow *pRoot) override;

	virtual void unInit() override;

	virtual void beforeAppear() override;

	virtual void beforeDisappear() override;

	void switchLanguage() override;

protected:
	EVENT_MAP_BEGIN()
		EVENT_CHECK_SENDER_ROOT(_pPageRoot)
	EVENT_MAP_BREAK()
};
