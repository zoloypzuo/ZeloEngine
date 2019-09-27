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

#include "header.h"

// main
int main()
{
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);

	//interpreteStdin(L);	// 24.1
	//stackTest(L);			// 24.2.3
	//testWHOnly(L);		// 25.1
	//testTable(L);			// 25.2
	//testCCallLuaFunc(L);	// 25.3
	//testcall_va(L);		// 25.4
	//testCFunc(L);			// 26.1
	//testMapFunc(L);		// 27.1
	//testSplitFunc(L);		// 27.2
	//testStateInC(L);		// 27.3
	//luabook_28_1::test28_1(L);
	//luabook_28_2::test28_2(L);
	//luabook_28_3::test28_3(L);
	//luabook_28_4::test28_4(L);
	//dumpState(L);
	//CommonTest(L);
	//luabook_29::luaDirTest(L);
	luabook_29::luaLxpTest(L);

	lua_close(L);
	return 0;
}
