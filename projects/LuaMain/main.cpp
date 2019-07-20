#include <lua/lua.hpp>

int pmain(lua_State* L) {
	luaL_openlibs(L);
	luaL_dostring(L,"print('hello world')");
	//luaL_dofile(L, "../scripts/hello.lua");
	return 1;
}

int main()
{
	lua_State* L = luaL_newstate();
	lua_pushcfunction(L, &pmain);  /* to call 'pmain' in protected mode */
	int status = lua_pcall(L, 0, 1, 0);  /* do the call */
	int result = lua_toboolean(L, -1);  /* get result */
	lua_close(L);
	return (result && status == LUA_OK) ? 0 : 1;
}