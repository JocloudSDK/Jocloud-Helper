/*
 * File: string
 * Author: LanPZzzz
 * Date: 2020/06/02
 * Description: string convert
 */
#pragma once

#include "stdafx.h"

std::string ws2s(const std::wstring &ws);
std::wstring s2ws(const std::string &s);
std::string stringFormat(const char *pszFmt, ...);