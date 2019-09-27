/**lua程序设计2nd源代码
lua test code:
a = array.new(1000)
print(a)
print(array.size(a))
for i=1,1000 do
	array.set(a, i, i%5==0)
end
print(array.get(a,10))
*/
#include <stdio.h>
#include <string.h>
#include <stdarg.h>

#include <Windows.h>

extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include <limits.h>
#include "header.h"

namespace luabook_29 {

static int dir_iter(lua_State *L);

static int l_dir(lua_State *L)
{
	HANDLE *h = (HANDLE*)lua_newuserdata(L, sizeof(HANDLE*));
	WIN32_FIND_DATA FindFileData;
	const char *path = luaL_checkstring(L, 1);
	char fname[MAX_PATH];
	sprintf(fname, "%s\\*", path);
	*h = FindFirstFile(fname, &FindFileData);

	if(*h==INVALID_HANDLE_VALUE)
		luaL_error(L, "cannot open %s", path);

	luaL_getmetatable(L, "LuaBook.dir");
	lua_setmetatable(L, -2);

	lua_pushcclosure(L, dir_iter, 1);
	return 1;
}

static int dir_iter(lua_State *L)
{
	HANDLE *h = (HANDLE*)lua_touserdata(L, lua_upvalueindex(1));
	if(*h==0 || *h==INVALID_HANDLE_VALUE)
		return 0;
	WIN32_FIND_DATA FindFileData;
	if (FindNextFile(*h, &FindFileData) != 0)
	{
		lua_pushstring(L, FindFileData.cFileName);
		return 1;
	}

	return 0;
}

static int dir_gc(lua_State *L)
{
	HANDLE *h = (HANDLE*)lua_touserdata(L, 1);
	if(*h==0 || *h==INVALID_HANDLE_VALUE)
		return 0;

	FindClose(*h);
	return 0;
}

int luaopen_dir(lua_State *L)
{
	luaL_newmetatable(L, "LuaBook.dir");
	lua_pushstring(L, "__gc");
	lua_pushcfunction(L, dir_gc);
	lua_settable(L, -3);

	lua_pushcfunction(L, l_dir);
	lua_setglobal(L, "dir");

	return 0;
}

// 用c++代码实现遍历当前目录
void ListFilesInDir()
{
	WIN32_FIND_DATA FindFileData;
	HANDLE hFind = INVALID_HANDLE_VALUE;
	DWORD dwError;
	LPTSTR DirSpec;
	size_t length_of_arg;
	INT retval;

	// Find the first file in the directory.
	hFind = FindFirstFile(".\\*", &FindFileData);

	if (hFind == INVALID_HANDLE_VALUE) 
	{
		printf("FindFirstFile error\n");
		return;
	} 
	else 
	{
		// List all the other files in the directory.
		while (FindNextFile(hFind, &FindFileData) != 0) 
		{
			printf("Next file name is: %s\n", FindFileData.cFileName);
		}

		dwError = GetLastError();
		FindClose(hFind);
	}
}

void luaDirTest(lua_State *L)
{
	//ListFilesInDir();
	//return;
	luaopen_dir(L);
	if(luaL_loadfile(L, "part4\\29_1.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));

}
}