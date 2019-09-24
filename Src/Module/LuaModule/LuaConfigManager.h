// LuaConfigManager.h
// created on 2019/9/24
// author @zoloypzuo

#ifndef ZELOENGINE_LUACONFIGMANAGER_H
#define ZELOENGINE_LUACONFIGMANAGER_H
#include <string>


class LuaConfigManager {
public:
    template<typename T>
    T* LookupSymbol(const char* name);
};

template <typename T>
T* LuaConfigManager::LookupSymbol(const char* name)
{
	return T::LoadConfig();
}


#endif //ZELOENGINE_LUACONFIGMANAGER_H
