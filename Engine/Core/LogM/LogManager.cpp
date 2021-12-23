// LogManager.cpp.cc
// created on 2021/12/23
// author @zoloypzuo
#include "ZeloPreCompiledHeader.h"
#include "LogManager.h"

template<> LogManager *Zelo::Singleton<LogManager>::msSingleton = nullptr;

namespace Zelo::Core::Log {
LogManager *LogManager::getSingletonPtr() {
    return msSingleton;
}
}
