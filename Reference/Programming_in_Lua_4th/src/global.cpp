/**lua程序设计2nd源代码
*/
#include <stdio.h>
#include <string.h>
#include <stdarg.h>
extern "C" {
#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
}

#include "header.h"


int luaopen_cjson_safe(lua_State *l)
{
    /* Return cjson.safe table */
    return 1;
}

void dumpState(lua_State *L)
{
	
    lua_getglobal(L, "package");
    lua_getfield(L, -1, "preload");

       lua_pushcfunction(L, luaopen_cjson_safe);
      lua_setfield(L, -2, "testf");


	if(luaL_loadfile(L, "1.lua") || lua_pcall(L, 0, 0, 0))
		printf("run func.lua error:%s", lua_tostring(L, -1));
}

// 24.2.2打印堆栈
void stackDump(lua_State *L)
{
	printf("stackDump Begin ...\n");
	int i;
	int top = lua_gettop(L);
	for (i=1; i<=top; i++)
	{
		int t = lua_type(L, i);
		switch(t)
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


void CommonTest(lua_State *L)
{
	if(luaL_loadfile(L, "test.lua"))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
	
	if(lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
}