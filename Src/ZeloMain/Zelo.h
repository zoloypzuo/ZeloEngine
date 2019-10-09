// Zelo.h
// created on 2019/9/27
// author @zoloypzuo
//
// 在这里include所有用zelo写的游戏app需要引用的引擎的头文件

#ifndef ZELOENGINE_ZELO_H
#define ZELOENGINE_ZELO_H


#include "d3dApp.h"
#include "LuaConfigManager.h"

extern D3DApp* g_pApp;
extern lua_State* L;
extern LuaConfigManager* g_pLuaConfigManager;

// 放在游戏应用的main的开头结尾
// 初始化管理器
inline int Initialize() {
	L = lua_open();
	g_pLuaConfigManager = new LuaConfigManager();
    return 0;
}

inline int Finalize() {
	lua_close(L);
	delete g_pLuaConfigManager;
	return 0;
}


#endif //ZELOENGINE_ZELO_H
