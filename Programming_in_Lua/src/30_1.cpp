/**lua程序设计2nd源代码
*/
#include <stdio.h>
#include <string.h>
#include <stdarg.h>


extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include <Windows.h>

#include <limits.h>
#include "header.h"

namespace luabook_30 {

void luaTestThread(lua_State *L)
{
	lua_State *L1 = lua_newthread(L);

	/*
	printf("%d\n", lua_gettop(L1));
	printf("%d\n", lua_gettop(L));
	printf("%s\n\n", luaL_typename(L, -1));
	*/
	
	if(luaL_loadfile(L, "part4\\30_1.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));

	/*
	lua_getglobal(L1, "f");
	lua_pushinteger(L1, 5);
	lua_call(L1, 1, 1);
	lua_xmove(L1, L, 1);
	printf("%d\n", lua_tointeger(L, -1));
	*/

	lua_getglobal(L1, "foo1");
	lua_pushinteger(L1, 20);
	stackDump(L1);
	int r = lua_resume(L1, 1);
	stackDump(L1);
	lua_resume(L1, 0);
	stackDump(L1);
}

}