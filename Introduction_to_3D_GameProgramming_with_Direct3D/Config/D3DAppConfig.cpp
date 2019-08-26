// D3DAppConfig.cpp
// created on 2019/8/26
// author @zoloypzuo

#define UNICODE
#include "DXUT.h"

#include "D3DAppConfig.h"

D3DAppConfig::D3DAppConfig(lua_State* L)
{
	HRESULT hr; // used for V
	// read file to buffer
	ID3DBlob* pContent{};
	V(D3DReadFileToBlob(L"../Config/D3DAppConfig.lua", &pContent));

	// dostring
	auto buffer = pContent->GetBufferPointer();
	auto size = pContent->GetBufferSize();
	int err = luaL_loadbuffer(L, (char*)buffer, size, "") | lua_pcall(L, 0, 0, 0);
	if (err)
	{
		fprintf(stderr, "%s", lua_tostring(L, -1));
		lua_pop(L, 1);
	}
	lua_getglobal(L, "D3DAppConfig"); // TODO handle error
	luaL_checktype(L, 1, LUA_TTABLE);
	lua_getfield(L, 1, "mainWndCaption");
	size_t* len{};
	auto s = lua_tostring(L, -1);
	mainWndCaption = s;
	//lua_pop(L, -1);
	lua_getfield(L, 1, "clientWidth");
	clientWidth = lua_tointeger(L, -1);
	//lua_pop(L,-1);
	lua_getfield(L, 1, "clientHeight");
	clientHeight = lua_tointeger(L, -1);
	//lua_pop(L, -1);
	lua_getfield(L, 1, "driverType");
	driverType = (D3D_DRIVER_TYPE)lua_tointeger(L, -1);
	//lua_pop(L, -1);
	lua_getfield(L, 1, "enable4xMsaa");
	enable4xMsaa = lua_toboolean(L, -1);
	//lua_pop(L, -1);
	lua_getfield(L, 1, "_4xMsaaQuality");
	_4xMsaaQuality = lua_tointeger(L, -1);
	//lua_pop(L, -1);
}
