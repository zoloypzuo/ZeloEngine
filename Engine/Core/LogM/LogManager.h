// LogManager.h
// created on 2021/12/23
// author @zoloypzuo
#pragma once

#include "ZeloPrerequisites.h"
#include "Foundation/ZeloSingleton.h"

namespace Zelo::Core::Log {

class LogManager : public Singleton<LogManager> {
public:
    LogManager();

    ~LogManager() = default;

    static LogManager *getSingletonPtr();

private:

};
}
