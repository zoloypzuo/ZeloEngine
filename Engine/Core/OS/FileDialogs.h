// FileDialogs.h
// created on 2021/4/2
// author @zoloypzuo

#ifndef ZELOENGINE_FILEDIALOGS_H
#define ZELOENGINE_FILEDIALOGS_H

#include "ZeloPrerequisites.h"

class FileDialogs {
public:
    // These return empty strings if cancelled
    std::wstring OpenFile(const wchar_t *filter, void *windowHandle);

    std::wstring SaveFile(const wchar_t *filter, void *windowHandle);
};


#endif //ZELOENGINE_FILEDIALOGS_H