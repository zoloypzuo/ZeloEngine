// LuaUtil.h
// created on 2019/8/27
// author @zoloypzuo

#ifndef ZELOENGINE_LUAUTIL_H
#define ZELOENGINE_LUAUTIL_H
#include <cstdarg>
#include <cstdio>
#include <cstdlib>

#include "lua.hpp"


class LuaUtil
{
};

const int LUA_TOP = -1;

/**
 * \brief the table is at -1 when calling a lua_getfield
 */
const int LUA_TABLE_INDEX = -1;

inline int traceback(lua_State* L)
{
	const char* msg = lua_tostring(L, LUA_TOP);
	if (msg)
	{
		luaL_traceback(L, L, msg, 1);
		return -1;
	}
	lua_pushliteral(L, "no message");
	return 0;
}

inline void stackDump(lua_State* L)
{
	printf("stackDump Begin ...\n");
	int i;
	int top = lua_gettop(L);
	for (i = 1; i <= top; i++)
	{
		int t = lua_type(L, i);
		switch (t)
		{
		case LUA_TSTRING:
			{
				printf("'%s'", lua_tostring(L, i));
				break;
			}
		case LUA_TBOOLEAN:
			{
				printf(lua_toboolean(L, i) ? "true" : "false");
				break;
			}
		case LUA_TNUMBER:
			{
				printf("%g", lua_tonumber(L, i));
				break;
			}
		default:
			{
				printf("%s", lua_typename(L, t));
				break;
			}
			printf(" ");
		}
		printf("\n");
	}
	printf("stackDump End ...\n");
	printf("\n");
}

inline lua_Integer getFieldInt(lua_State* L, const char* k)
{
	stackDump(L);
	lua_Integer res{};
	int isInt{};

	lua_getfield(L, LUA_TABLE_INDEX, k);
	res = lua_tointegerx(L, LUA_TOP, &isInt);
	if (!isInt)
	{
		luaL_error(L, "invalid value for %s", k);
	}
	lua_pop(L, 1);
	stackDump(L);
	return res;
}

inline const char* getFieldString(lua_State* L, const char* k)
{
	stackDump(L);
	const char* res{};
	lua_getfield(L, LUA_TABLE_INDEX, k);
	if (!lua_isstring(L, LUA_TOP))
	{
		luaL_error(L, "invalid value for %s", k);
	}
	res = lua_tostring(L, LUA_TOP);
	lua_pop(L, 1);
	stackDump(L);
	return res;
}

inline bool getFieldBool(lua_State* L, const char* k)
{
	stackDump(L);
	bool res{};
	lua_getfield(L, LUA_TABLE_INDEX, k);
	if (!lua_isboolean(L, LUA_TOP))
	{
		luaL_error(L, "invalid value for %s", k);
	}
	res = lua_toboolean(L, LUA_TOP);
	lua_pop(L, 1);
	stackDump(L);
	return res;
}

/**
 * \brief lua 5.2 removes lua_open, but I think it is paired with lua_close()
 */
#define lua_open() luaL_newstate()

#endif //ZELOENGINE_LUAUTIL_H
