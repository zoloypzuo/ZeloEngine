// LuaConfigManager.h
// created on 2019/9/24
// author @zoloypzuo

#ifndef ZELOENGINE_LUACONFIGMANAGER_H
#define ZELOENGINE_LUACONFIGMANAGER_H
#include <string>
#include "LuaUtil.h"
#include "GlobalConfig.h"

class LuaConfigManager {
public:
	/**
	 * \brief 加载配置文件（返回一个Lua表，代表一个配置对象），返回一个配置对象
	 */
	template<typename T>
	T* LoadConfig(const char* name);

	/**
	 * \brief 加载配置文件（返回一个Lua表，代表一个配置对象的列表），返回一个配置对象列表
	 */
	template<typename T>
	T** LoadConfigList(const char* name);
};

template <typename T>
T* LuaConfigManager::LoadConfig(const char* name)
{
	lua_pushcfunction(L, [](L)->int
	{
		if (luaL_dofile(L, (g_configFileDir + name).c_str()) != LUA_OK)
		{
			luaL_error("cannot run config file");
		}
		luaL_checktype(L, LUA_TOP, LUA_TTABLE);
		T* pConfig = new T();
		T::LoadConfig(L, pConfig);
		lua_pushlightuserdata(L, pConfig);
		return 1;
	});
	//lua_pushstring(L, name); c++ lambda可以闭包
	docall(L, 0);
	T* ret = lua_touserdata(L, LUA_TOP);
	// lua配置脚本最后一句是return一个表，加载完了要弹掉
	lua_pop(L, 1);
	return ret;
}

template <typename T>
T** LuaConfigManager::LoadConfigList(const char* name)
{
	lua_pushcfunction(L, [](L)->int
	{
		if (luaL_dofile(L, (g_configFileDir + name).c_str()) != LUA_OK)
		{
			luaL_error("cannot run config file");
		}
		luaL_checktype(L, LUA_TOP, LUA_TTABLE);
		lua_Integer len = luaL_len(L, LUA_TOP);
		T** pConfig = new T[len];
		for (size_t i = 0; i < len; i++)
		{
			lua_geti(L, LUA_TOP, i);
			T::LoadConfig(L, pConfig);
		}
		lua_pushlightuserdata(L, pConfig);
		return 1;
	});
	//lua_pushstring(L, name); c++ lambda可以闭包
	docall(L, 0);
	T** ret = lua_touserdata(L, LUA_TOP);
	// lua配置脚本最后一句是return一个表，加载完了要弹掉
	lua_pop(L, 1);
	return ret;
}


#endif //ZELOENGINE_LUACONFIGMANAGER_H
