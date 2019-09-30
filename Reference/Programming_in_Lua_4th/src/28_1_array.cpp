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
extern "C" {
#include "lua.h"
#include "lauxlib.h"
#include "lualib.h"
}

#include <limits.h>

namespace luabook_28_1 {
#define BITS_PER_WORD (CHAR_BIT*sizeof(unsigned int))
#define I_WORD(i) ((unsigned int)(i)/BITS_PER_WORD)
#define I_BIT(i) (1<<((unsigned int)(i)%BITS_PER_WORD))

typedef struct NumArray
{
	int size;
	unsigned int values[1];
} NumArray;

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

	return 1;
}

static int setarray(lua_State *L)
{
	NumArray *a = (NumArray*)lua_touserdata(L, 1);
	int index = luaL_checkint(L, 2)-1;
	luaL_checkany(L, 3);

	luaL_argcheck(L, a!=NULL, 1, "'array' expected");
	luaL_argcheck(L, 0<=index && index<a->size, 2, "index out of range");

	if(lua_toboolean(L, 3))
		a->values[I_WORD(index)] |= I_BIT(index);
	else
		a->values[I_WORD(index)] &= ~I_BIT(index);
	return 0;
}

static int getarray(lua_State *L)
{
	NumArray *a = (NumArray*)lua_touserdata(L, 1);
	int index = luaL_checkint(L, 2)-1;
	luaL_argcheck(L, a!=NULL, 1, "'array' expected");
	luaL_argcheck(L, 0<=index &&index<a->size, 2, "index out of range");
	lua_pushboolean(L, a->values[I_WORD(index)] & I_BIT(index));
	return 1;
}

static int getsize(lua_State *L)
{
	NumArray *a = (NumArray*)lua_touserdata(L, 1);
	luaL_argcheck(L, a!=NULL, 1, "'array' expected");
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
	luaL_register(L, "array", arraylib);
	return 1;
}

/*
28_1.lua
a = array.new(1000)
print(a)
print(array.size(a))
for i=1,1000 do
    array.set(a,i,i%5==0)
end
print(array.get(io.stdin,10))
print(array.get(a,11))
*/
void test28_1(lua_State *L)
{
	luaopen_array(L);
	
	if(luaL_loadfile(L, "1.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));
}
}