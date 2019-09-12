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


void initState(lua_State *L)
{
}

void testRegistry(lua_State *L)
{
	static const char *regStart = "buck_reg_start";
	static const char *regKey = "buck_reg_key";

	// check start mark
	lua_pushstring(L, regStart);
	lua_rawget(L, LUA_REGISTRYINDEX);
	if(lua_isboolean(L, -1))
		return;
	
	// set start mark
	lua_pushstring(L, regStart);
	lua_newtable(L);
	lua_rawset(L, LUA_REGISTRYINDEX);
}

void testLightUserdata(lua_State *L)
{
	static char Key = 'k';
	static char *myStr = "My string";
	lua_pushlightuserdata(L, (void*)&Key);
	lua_pushstring(L, myStr);
	lua_settable(L, LUA_REGISTRYINDEX);

	lua_pushlightuserdata(L, (void*)&Key);
	lua_gettable(L, LUA_REGISTRYINDEX);
	const char *strOut = lua_tostring(L, -1);
	printf(strOut);
	printf("\n");
}

static int counter(lua_State *L);
int newCounter(lua_State *L)
{
	lua_pushinteger(L, 0);
	lua_pushcclosure(L, &counter, 1);
	return 1;
}

static int counter(lua_State *L)
{
	int val = lua_tointeger(L, lua_upvalueindex(1));
	val+=100;
	lua_pushinteger(L, ++val);	// 返回值
	val += 1000;
	lua_pushinteger(L, val);	// lua_upvalueindex(1)值
	//lua_pushvalue(L, -1);		// lua_upvalueindex(1)值
	lua_replace(L, lua_upvalueindex(1));
	return 1;
}

int t_tuple(lua_State *L)
{
	int op = luaL_optint(L, 1, 0);
	if(op==0)
	{
		int i;
		for(i=1; !lua_isnone(L, lua_upvalueindex(i)); i++)
			lua_pushvalue(L, lua_upvalueindex(i));
		return i-1;
	}
	else
	{
		luaL_argcheck(L, 0<op, 1, "index out of range");
		if(lua_isnone(L, lua_upvalueindex(op)))
			return 0;
		lua_pushvalue(L, lua_upvalueindex(op));
		return 1;
	}
}

int t_new(lua_State *L)
{
	lua_pushcclosure(L, t_tuple, lua_gettop(L));
	return 1;
}

static const struct luaL_Reg tuplelib[] = 
{
	{"new", t_new},
	{"newCounter", newCounter},
	{NULL, NULL}
};

int luaopen_tuple(lua_State *L)
{
	luaL_register(L, "tuple", tuplelib);
	return 1;
}

void testStateInC(lua_State *L)
{
	//testRegistry(L);
	//testLightUserdata(L);
	luaopen_tuple(L);
	
	if(luaL_loadfile(L, "part4\\27_3.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
}