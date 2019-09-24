// D3DAppConfig.cpp
// created on 2019/8/26
// author @zoloypzuo


#include "D3DAppConfig.h"
#include "../../Module/LuaModule/LuaUtil.h"

D3DAppConfig::D3DAppConfig()
{
	// do nothing
}

void D3DAppConfig::LoadConfig(lua_State* L, D3DAppConfig* pConfig)
{
	// Õ»¶¥ÊÇluaÅäÖÃ¶ÔÏó
	luaL_checktype(L, LUA_TOP, LUA_TTABLE);

	pConfig->mainWndCaption = getFieldString(L, "mainWndCaption");
	pConfig->clientWidth = (int)getFieldInt(L, "clientWidth");
	pConfig->clientHeight = (int)getFieldInt(L, "clientHeight");
	pConfig->driverType = (D3D_DRIVER_TYPE)getFieldInt(L, "driverType");
	pConfig->enable4xMsaa = getFieldBool(L, "enable4xMsaa");
	pConfig->_4xMsaaQuality = (UINT)getFieldInt(L, "_4xMsaaQuality");
	pConfig->engineDir = getFieldString(L, "engineDir");
	pConfig->configDir = getFieldString(L, "configDir");

	lua_pop(L, 1); // pop D3DAppConfig
}
