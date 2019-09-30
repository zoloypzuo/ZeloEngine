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
// 24.1 简单的lua解释器，从命令行读入执行
void interpreteStdin(lua_State *L)
{
	int a = _MSC_VER;
	char buff[256];
	int error;
	while (fgets(buff, sizeof(buff), stdin) != NULL)
	{
		error = luaL_loadbuffer(L, buff, strlen(buff), "line") || lua_pcall(L, 0, 0, 0);
		if (error)
		{
			fprintf(stderr, "%s", lua_tostring(L, -1));
			lua_pop(L, 1);
		}
	}
}

int main()
{
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);
	interpreteStdin(L);	// 24.1
	lua_close(L);
	return 0;
}
