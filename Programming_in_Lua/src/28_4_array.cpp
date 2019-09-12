/** lua程序设计2nd源代码
  * 面向对象的访问
  * 与28_2_array相比，只有测试lua代码不同
  
lua test code:
local metaarray = getmetatable(array.new(1))
metaarray.__index = array.get
metaarray.__newindex = array.set
metaarray.__len = array.size
a = array.new(1000)
a[10] = true
print(a[10])
print(#a)
  */

#include <stdio.h>
#include <string.h>
#include <stdarg.h>
extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include <limits.h>

namespace luabook_28_4 {
#define BITS_PER_WORD (CHAR_BIT*sizeof(unsigned int))
#define I_WORD(i) ((unsigned int)(i)/BITS_PER_WORD)
#define I_BIT(i) (1<<((unsigned int)(i)%BITS_PER_WORD))

#define checkarray(L) (NumArray*)luaL_checkudata(L, 1, "LuaBook.array")

typedef struct NumArray
{
	int size;
	unsigned int values[1];
} NumArray;

static unsigned int *getindex(lua_State *L, unsigned int *mask)
{
	NumArray *a = checkarray(L);
	int index = luaL_checkint(L, 2)-1;
	luaL_argcheck(L, 0<=index&&index<a->size, 2, "index out of range");

	*mask = I_BIT(index);
	return &a->values[I_WORD(index)];
}

static int newarray(lua_State *L)
{
	int i, n;
	size_t nbytes;
	NumArray *a;

	n = luaL_checkint(L, 1);
	luaL_argcheck(L, n>=1, 1, "invalid size");
	nbytes = sizeof(NumArray) + I_WORD(n-1)*sizeof(unsigned int);
	a = (NumArray*)lua_newuserdata(L, nbytes);

	a->size = n;
	for(i=0; i<=I_WORD(n-1); i++)
		a->values[i] = 0;

	luaL_getmetatable(L, "LuaBook.array");
	lua_setmetatable(L, -2);

	return 1;
}

static int setarray(lua_State *L)
{
	unsigned int mask;
	unsigned int *entry = getindex(L, &mask);
	luaL_checkany(L, 3);
	if(lua_toboolean(L, 3))
		*entry |= mask;
	else
		*entry &= ~mask;

	return 0;
}

static int getarray(lua_State *L)
{
	unsigned int mask;
	unsigned int *entry = getindex(L, &mask);
	lua_pushboolean(L, *entry&mask);
	return 1;
}

static int getsize(lua_State *L)
{
	NumArray *a = checkarray(L);
	lua_pushinteger(L, a->size);
	return 1;
}

int array2string(lua_State *L)
{
	NumArray *a = checkarray(L);
	lua_pushfstring(L, "array(%d)", a->size);
	return 1;
}

static const struct luaL_Reg arraylib_f[] = 
{
	{"new", newarray},
	{NULL, NULL},
};

static const struct luaL_Reg arraylib_m[] = 
{
	{"__tostring", array2string},
	{"set", setarray},
	{"get", getarray},
	{"size", getsize},
	{"__newindex", setarray},
	{"__index", getarray},
	{"__len", getsize},
	{NULL, NULL},
};

int luaopen_array(lua_State *L)
{
	luaL_newmetatable(L, "LuaBook.array");	// LuaBook.array
	lua_pushvalue(L, -1);					// LuaBook.array LuaBook.array
	lua_setfield(L, -2, "__index");			// LuaBook.array(__index) LuaBook.array

	luaL_register(L, NULL, arraylib_m);		// LuaBook.array(__index) LuaBook.array(arraylib_m)
	luaL_register(L, "array", arraylib_f);
	return 1;
}

/*
lua中设置metatable，需要用test28_2里面测试
28_4_1.lua
local metaarray = getmetatable(array.new(1))
metaarray.__index = array.get
metaarray.__newindex = array.set
metaarray.__len = array.size
a = array.new(1000)
a[10] = true
print(a[10])
print(#a)

c代码中设置
28_4_2.lua
a = array.new(1000)
a[10] = true
print(a[10])
print(#a)

*/


void test28_4(lua_State *L)
{
	luaopen_array(L);
	
	if(luaL_loadfile(L, "28_4_2.lua"))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
	
	if(lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
//	if(luaL_loadfile(L, "28_4_2.lua") || lua_pcall(L, 0, 0, 0))
//		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
}

}