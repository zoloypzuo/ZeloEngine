extern "C" {
#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
}
#include "header.h"

// 24.2.3≤‚ ‘¥Ú”°∂—’ª
void stackTest(lua_State *L)
{
	lua_pushboolean(L, 1);
	lua_pushnumber(L, 10);
	lua_pushnil(L);
	lua_pushstring(L, "hello");
	stackDump(L);
	//stackDump Begin ...
	//true
	//10
	//nil
	//'hello'
	//stackDump End ...

	lua_pushvalue(L, -4);
	stackDump(L);
	//stackDump Begin ...
	//index | value
	//-4    | true
	//-3    | 10
	//-2    | nil
	//-1    | 'hello'
	//true
	//stackDump End ...

	// stack[4] = stack.pop()
	lua_replace(L, 3);
	stackDump(L);
	//stackDump Begin ...
	//index | value
	//1 | true
	//2 | 10
	//3 | true
	//4 | 'hello'
	//stackDump End ...

	// ¿©»›£¨≤πnil
	lua_settop(L, 6);
	stackDump(L);

	// …æ≥˝stack[-3]
	lua_remove(L, -3);
	stackDump(L);

	// Àıºı’ª¥Û–°
	lua_settop(L, -5);
	stackDump(L);

}

int main()
{
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	stackTest(L);
	lua_close(L);
	return 0;
}

