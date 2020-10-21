#include "stdafx.h"
#include "utils.h"
#include <ShellAPI.h>

void openWebUrl(const std::wstring url) {
	ShellExecute(NULL, _T("open"), url.c_str(), NULL, NULL, SW_SHOWNORMAL);
}

int getBuildNumber() {
	int number = -1;
	FILE* fp = nullptr;
	fopen_s(&fp, "./number.txt", "r+");
	if (fp) {
		fseek(fp, 0, SEEK_END);
		int len = ftell(fp);
		fseek(fp, 0, SEEK_SET);
		if (len > 0 && len <= 10) {
			fscanf(fp, "%d", &number);
		}
		fclose(fp);
	}
	return number < 0 ? -1 : number;
}
