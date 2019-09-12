// ��������һ������ʾ��������lua��ε���c����
// ���c����luaҪ����һЩ�����Ǹ�����ģ�����ʵ����ݣ�Ҳ����
// Ҫ�������£�дlua_CFunction���Ͱ��������ָ��ע�ᵽlua��


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
	// ��ȡ����
	double d = lua_tonumber(L, 1);

	// ����
	double dsin = sin(d);
	
	// ѹ����
	// ע�����ﲻ��Ҫ���ջ��ѹ�뷵��ֵ����ͼ��ô����Ϊ�˱���ջ����ǰ��һ�£�
	// ��Ϊlua���Ϊ����ֱ��ѹ�룬����lua_CFunctionҪ���ؽ������
	// ��luaԴ�����У�luaD_precall���м������c��������ֱ�ӵ���luaD_poscall���أ�
	// �����ǰ��Ӻ���ǰ��˳������ֵ��
	lua_pushnumber(L, dsin);
	
	// ���������sin��������1��ֵ
	return 1;

	// ���ϵ�д��
	//double d = luaL_checknumber(L, 1);
	//lua_pushnumber(L, sin(d));
	//return 1;
}

static int l_dir(lua_State*L)
{
	return 1;
}

// ע�������l_sin����
void initCFunc(lua_State *L)
{
	// ѹ�뺯��ָ��
	lua_pushcfunction(L, l_sin);
	// ��Ϊȫ�ֱ���
	lua_setglobal(L, "mysin");
	//û��
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

	// ��ʵ��lua����ԾͿ�����
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
