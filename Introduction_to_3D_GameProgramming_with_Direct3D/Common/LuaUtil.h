// LuaUtil.h
// created on 2019/8/27
// author @zoloypzuo

#ifndef ZELOENGINE_LUAUTIL_H
#define ZELOENGINE_LUAUTIL_H
#include <cstdarg>
#include <cstdio>
#include <cstdlib>

#include "lua.hpp"
#include <csignal>


class LuaUtil
{
};

const int LUA_TOP = -1;

/**
 * \brief the table is at -1 when calling a lua_getfield
 */
const int LUA_TABLE_INDEX = -1;


static lua_State *globalL = NULL;

static void lstop(lua_State *L, lua_Debug *ar) {
	(void)ar;  /* unused arg. */
	lua_sethook(L, NULL, 0, 0);
	luaL_error(L, "interrupted!");
}


inline void laction(int i) {
	signal(i, SIG_DFL); /* if another SIGINT happens before lstop,
								terminate process (default action) */
	lua_sethook(globalL, lstop, LUA_MASKCALL | LUA_MASKRET | LUA_MASKCOUNT, 1);
}

inline int traceback(lua_State *L) {
	if (!lua_isstring(L, 1))  /* 'message' not a string? */
		return 1;  /* keep it intact */
	lua_getglobal(L, "debug");
	if (!lua_istable(L, -1)) {
		lua_pop(L, 1);
		return 1;
	}
	lua_getfield(L, -1, "traceback");
	if (!lua_isfunction(L, -1)) {
		lua_pop(L, 2);
		return 1;
	}
	lua_pushvalue(L, 1);  /* pass error message */
	lua_pushinteger(L, 2);  /* skip this function and traceback */
	lua_call(L, 2, 1);  /* call debug.traceback */
	return 1;
}

inline int docall(lua_State *L, int narg, int clear) {
	int status;
	int base = lua_gettop(L) - narg;  /* function index */
	lua_pushcfunction(L, traceback);  /* push traceback function */
	lua_insert(L, base);  /* put it under chunk and args */
	signal(SIGINT, laction);
	status = lua_pcall(L, narg, (clear ? 0 : LUA_MULTRET), base);
	signal(SIGINT, SIG_DFL);
	lua_remove(L, base);  /* remove traceback function */
	/* force a complete garbage collection in case of errors */
	if (status != 0) lua_gc(L, LUA_GCCOLLECT, 0);
	return status;
}

inline void stackDump(lua_State* L)
{
	printf("====stackDump Begin ...\n");
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
	printf("====stackDump End ...\n");
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
