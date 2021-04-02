// FileDialogs.h
// created on 2021/4/2
// author @zoloypzuo

#ifndef ZELOENGINE_FILEDIALOGS_H
#define ZELOENGINE_FILEDIALOGS_H

#include "ZeloPrerequisites.h"
#include <optional>

class FileDialogs {
public:
    // These return empty strings if cancelled
    static std::optional<std::string> OpenFile(const char *filter);

    static std::optional<std::string> SaveFile(const char *filter);
};


#endif //ZELOENGINE_FILEDIALOGS_H