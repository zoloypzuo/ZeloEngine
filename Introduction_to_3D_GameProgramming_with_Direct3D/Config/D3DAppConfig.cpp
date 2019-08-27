// D3DAppConfig.cpp
// created on 2019/8/26
// author @zoloypzuo



#define UNICODE
#include "DXUT.h"

#include "D3DAppConfig.h"
#include "../Common/LuaUtil.h"

D3DAppConfig::D3DAppConfig()
{
	// do nothing
}

int D3DAppConfig::LoadConfig(lua_State* L, D3DAppConfig** ppConfig)
{
	lua_pushcfunction(L, traceback);
	lua_pushcfunction(L, &pLoadConfig);
	if (lua_pcall(L, 0, 1, 1))
	{
		fprintf(stderr, "%s", lua_tostring(L, LUA_TOP));
		lua_pop(L, 1);
	}
	else
	{
		stackDump(L);
		if(!lua_isuserdata(L,LUA_TOP))
		{
			error(L, "is not ud");
			return -1;
		}
		*ppConfig = (D3DAppConfig*)lua_touserdata(L, LUA_TOP);
	}
	return 0;
}

// D3DAppConfig LoadConfig()
int D3DAppConfig::pLoadConfig(lua_State* L)
{
	stackDump(L);
	HRESULT hr;  // used for V
	int err;  // used for lua

	// read file to buffer
	ID3DBlob* pContent{};
	V(D3DReadFileToBlob(L"../Config/D3DAppConfig.lua", &pContent));

	// dostring
	auto buffer = pContent->GetBufferPointer();
	auto size = pContent->GetBufferSize();
	err = luaL_loadbuffer(L, (char*)buffer, size, "") | lua_pcall(L, 0, 0, 1);
	if (err)
	{
		// get err msg from stack top
		error(L, "cannot run config file: %s", lua_tostring(L, LUA_TOP));
	}

	D3DAppConfig* pConfig = new D3DAppConfig();
	lua_pushlightuserdata(L, pConfig);

	lua_getglobal(L, "D3DAppConfig");

	if (!lua_istable(L, LUA_TOP))
	{
		error(L, "D3DAppConfig is not a table");
	}
	pConfig->mainWndCaption = getFieldString(L, "mainWndCaption");
	pConfig->clientWidth = getFieldInt(L, "clientWidth");
	pConfig->clientHeight = getFieldInt(L, "clientHeight");
	pConfig->driverType = (D3D_DRIVER_TYPE)getFieldInt(L, "driverType");
	pConfig->enable4xMsaa = getFieldBool(L, "enable4xMsaa");
	pConfig->_4xMsaaQuality = getFieldInt(L, "_4xMsaaQuality");

	lua_pop(L, 1);  // pop D3DAppConfig

	lua_pushnil(L);
	lua_setglobal(L, "D3DAppConfig");
	if (lua_getglobal(L, "D3DAppConfig") != LUA_TNIL)
	{
		error(L, "D3DAppConfig is not set to nil");
	}
	lua_pop(L, 1);
	stackDump(L);
	return 1;
}