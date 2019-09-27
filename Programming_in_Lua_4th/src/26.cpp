// 这里这有一个代码示例，就是lua如何调用c函数
// 这比c调用lua要困难一些，但是更多是模板性质的内容，也不难
// 要做两件事：写lua_CFunction，和把这个函数指针注册到lua层


#include <stdio.h>
#include <string.h>
#include <stdarg.h>
extern "C" {
#include <lua/lua.h>
#include <lua/lauxlib.h>
#include <lua/lualib.h>
}

#include <math.h>

static int l_sin(lua_State *L)
{
	// 获取参数
	double d = lua_tonumber(L, 1);

	// 计算
	double dsin = sin(d);
	
	// 压入结果
	// 注意这里不需要清空栈再压入返回值（试图这么做是为了保持栈调用前后一致）
	// 因为lua设计为这里直接压入，并且lua_CFunction要返回结果数量
	// 在lua源代码中，luaD_precall进行检查后调用c函数，并直接调用luaD_poscall返回，
	// 后者是按从后往前的顺序处理返回值的
	lua_pushnumber(L, dsin);
	
	// 结果数量，sin函数返回1个值
	return 1;

	// 书上的写法
	//double d = luaL_checknumber(L, 1);
	//lua_pushnumber(L, sin(d));
	//return 1;
}

static int l_dir(lua_State*L)
{
	return 1;
}

// 注册上面的l_sin函数
void initCFunc(lua_State *L)
{
	// 压入函数指针
	lua_pushcfunction(L, l_sin);
	// 作为全局变量
	lua_setglobal(L, "mysin");
	//没用
	//lua_pushcfunction(L, l_dir);
	//lua_setglobal(L, "mydir");
}

/*
local a=0.707
b = mysin(a)
*/
void testCFunc(lua_State *L)
{
	initCFunc(L);
	
	if(luaL_loadfile(L, "26.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));

	// 其实在lua层断言就可以了
	lua_getglobal(L, "b");
	if(!lua_isnumber(L, -1))
		printf("height should be a number\n");
	double b = lua_tonumber(L, -1);
	printf("sin func return:%f\n", b);
}

// main
int main()
{
	lua_State *L = luaL_newstate();
	luaL_openlibs(L);

	testCFunc(L);			// 26.1

	lua_close(L);
	return 0;
}
