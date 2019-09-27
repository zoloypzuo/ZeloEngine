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
	 * \brief ���������ļ�������һ��Lua������һ�����ö��󣩣�����һ�����ö���
	 */
	template<typename T>
	T* LoadConfig(const char* name);

	/**
	 * \brief ���������ļ�������һ��Lua������һ�����ö�����б�������һ�����ö����б�
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
	//lua_pushstring(L, name); c++ lambda���Ահ�
	docall(L, 0);
	T* ret = lua_touserdata(L, LUA_TOP);
	// lua���ýű����һ����returnһ������������Ҫ����
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
	//lua_pushstring(L, name); c++ lambda���Ահ�
	docall(L, 0);
	T** ret = lua_touserdata(L, LUA_TOP);
	// lua���ýű����һ����returnһ������������Ҫ����
	lua_pop(L, 1);
	return ret;
}


#endif //ZELOENGINE_LUACONFIGMANAGER_H
