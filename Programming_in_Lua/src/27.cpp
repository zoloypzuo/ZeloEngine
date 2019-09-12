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
#include <math.h>

//对一个数组中的所有元素应用一个给定函数
static int l_map(lua_State *L)
{
	int i, n;
	luaL_checktype(L, 1, LUA_TTABLE);
	luaL_checktype(L, 2, LUA_TFUNCTION);
	n = lua_objlen(L, 1);
	for(i=1; i<=n; ++i)
	{
		lua_pushvalue(L, 2);
		lua_rawgeti(L, 1, i);
		lua_call(L, 1, 1);
		lua_rawseti(L, 1, i);
	}
	return 0;
}


void initMapFunc(lua_State *L)
{
	lua_pushcfunction(L, l_map);
	lua_setglobal(L, "mymap");
}

/*
27_1.lua
a = {2, 3, 5, 7}

function func(a)
	local b = a*a
	return b
end


function testout()
	for i=1, #a do
		print(a[i])
	end
	mymap(a, func)
	for i=1, #a do
		print(a[i])
	end
end
*/
void testMapFunc(lua_State *L)
{
	initMapFunc(L);
	
	if(luaL_loadfile(L, "27_1.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));

	lua_getglobal(L, "testout");
	
	if(lua_pcall(L, 0, 0, 0)!=0)
		printf("error running function 'testMapFunc':%s", lua_tostring(L, -1));

}

static int lsplit(lua_State *L)
{
	const char *s = luaL_checkstring(L, 1);
	const char *sep = luaL_checkstring(L, 2);
	const char *e;
	int i = 1;

	lua_newtable(L);

	while((e=strchr(s, *sep))!=NULL)
	{
		lua_pushlstring(L, s, e-s);
		lua_rawseti(L, -2, i++);
		s = e + 1;
	}
	lua_pushstring(L, s);
	lua_rawseti(L, -2, i);
	return 1;
}

void initSplitFunc(lua_State *L)
{
	lua_pushcfunction(L, lsplit);
	lua_setglobal(L, "mysplit");
}

/*27_2.lua
res = mysplit("hi,ho,there", ",")
for i=1, #res do
	print(res[i])
end
*/
void testSplitFunc(lua_State *L)
{
	initSplitFunc(L);
	
	if(luaL_loadfile(L, "27_2.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
}