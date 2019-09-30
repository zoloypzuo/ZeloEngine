/**lua程序设计2nd源代码
注意点：
1.XML解析器的userdata为lxp_userdata，xml解析过程中从中去除lua_State调用相应lua函数
2.通过调用lua_setfenv将lua中的解析函数保存为环境，在解析过程中取出使用

注册完结果：
REGISTRY:"Expat" = { {"parse", lxp_parse},
	{"close", lxp_close},
	{"__gc", lxp_close}, }

_G["lxp"] = { {"new", lxp_make_parser}, }

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
#include "header.h"
#include "expat.h"

namespace luabook_29 {
typedef struct lxp_userdata{
	lua_State *L;
	XML_Parser parser;
} lxp_userdata;

static void f_StartElement (void *ud, const char *name, const char **atts);
static void f_CharData (void *ud, const char *s, int len);
static void f_EndElement (void *ud, const char *name);

/*
in: callbacks = { StartElement = ..., EndElement = ..., }
*/
static int lxp_make_parser (lua_State *L)
{
	// table
	XML_Parser p;
	lxp_userdata *xpu;
	
	xpu = (lxp_userdata*)lua_newuserdata(L, sizeof(lxp_userdata));	// table userdata
	xpu->parser = NULL;

	luaL_getmetatable(L, "Expat");
	lua_setmetatable(L, -2);
	
	p = xpu->parser = XML_ParserCreate(NULL);
	if (!p)
		luaL_error(L, "XML_ParserCreate failed");

	luaL_checktype(L, 1, LUA_TTABLE);
	lua_pushvalue(L, 1);		// table userdata table
	lua_setfenv(L, -2);			// table userdata

	XML_SetUserData(p, xpu);
	XML_SetElementHandler(p, f_StartElement, f_EndElement);
	XML_SetCharacterDataHandler(p, f_CharData);
	
	return 1;
}

static int lxp_parse (lua_State *L)
{
	int status;
	size_t len;
	const char *s;
	lxp_userdata *xpu;

	// userdata stringtoparse
	xpu = (lxp_userdata *)luaL_checkudata(L, 1, "Expat");
	s = luaL_optlstring(L, 2, NULL, &len);
	
	lua_settop(L, 2);
	lua_getfenv(L, 1);	// userdata stringtoparse table
	xpu->L = L;
	
	status = XML_Parse(xpu->parser, s, (int)len, s==NULL);

	lua_pushboolean(L, status);
	return 1;
}

static void f_CharData (void *ud, const char *s, int len)
{
	lxp_userdata *xpu = (lxp_userdata*)ud;
	lua_State *L = xpu->L;

	lua_getfield(L, 3, "CharacterData");
	if (lua_isnil(L, -1))
	{
		lua_pop(L, 1);
		return;
	}

	lua_pushvalue(L, 1);
	lua_pushlstring(L, s, len);
	lua_call(L, 2, 0);
}

static void f_EndElement (void *ud, const char *name)
{
	lxp_userdata *xpu = (lxp_userdata*)ud;
	lua_State *L = xpu->L;
	lua_getfield(L, 3, "EndElement");
	if (lua_isnil(L, -1))
	{
		lua_pop(L, 1);
		return;
	}

	lua_pushvalue(L, 1);
	lua_pushstring(L, name);
	lua_call(L, 2, 0);
}

static void f_StartElement (void *ud, const char *name, const char **atts)
{
	lxp_userdata *xpu = (lxp_userdata*)ud;
	lua_State *L = xpu->L;
	
	// userdata stringtoparse table
	lua_getfield(L, 3, "StartElement");
	if (lua_isnil(L, -1))
	{
		lua_pop(L, 1);
		return;
	}

	lua_pushvalue(L, 1);		// userdata stringtoparse table function userdata
	lua_pushstring(L, name);	// userdata stringtoparse table function userdata string(name)

	lua_newtable(L);
	for (; *atts; atts+=2)
	{
		lua_pushstring(L, *(atts+1));
		lua_setfield(L, -2, *atts);
	}
	
	lua_call(L, 3, 0);
}

static int lxp_close (lua_State *L)
{
	lxp_userdata *xpu = (lxp_userdata*)luaL_checkudata(L, 1, "Expat");

	if (xpu->parser)
		XML_ParserFree(xpu->parser);
	xpu->parser = NULL;
	return 0;
}

static const struct luaL_Reg lxp_meths[] = {
	{"parse", lxp_parse},
	{"close", lxp_close},
	{"__gc", lxp_close},
	{NULL, NULL},
};

static const struct luaL_Reg lxp_funcs[] = {
	{"new", lxp_make_parser},
	{NULL, NULL},
};

int luaopen_lxp (lua_State *L) {
	luaL_newmetatable(L, "Expat");
	lua_pushvalue(L, -1);
	lua_setfield(L, -2, "__index");

	luaL_register(L, NULL, lxp_meths);

	luaL_register(L, "lxp", lxp_funcs);
	
	return 1;
}

void luaLxpTest (lua_State *L)
{
	luaopen_lxp(L);
	if(luaL_loadfile(L, "part4\\29_2.lua") || lua_pcall(L, 0, 0, 0))
		printf("cannot run config. file:%s\n", lua_tostring(L, -1));

}
}