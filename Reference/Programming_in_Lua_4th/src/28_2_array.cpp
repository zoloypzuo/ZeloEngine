/** lua程序设计2nd源代码
  * 为新建的array设置一个唯一的metatable，调用c函数的时候判断userdata的metatable是否正确
  
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
extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include <limits.h>

namespace luabook_28_2 {
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

static const struct luaL_Reg arraylib[] = 
{
	{"new", newarray},
	{"set", setarray},
	{"get", getarray},
	{"size", getsize},
	{NULL, NULL},
};

int luaopen_array(lua_State *L)
{
	luaL_newmetatable(L, "LuaBook.array");
	luaL_register(L, "array", arraylib);
	return 1;
}

/*
28_2.lua
与28_1.lua相同只是输出结果会报错
a = array.new(1000)
print(a)
print(array.size(a))
for i=1,1000 do
    array.set(a,i,i%5==0)
end
print(array.get(io.stdin,10))
print(array.get(a,11))
*/
void test28_2(lua_State *L)
{
	luaopen_array(L);
	
	if(luaL_loadfile(L, "28_4_1.lua") || lua_pcall(L, 0, 0, 0))	// "28_2.lua"
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
}
}