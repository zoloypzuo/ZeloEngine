#include "D3DAppConfig.hpp"
#include "../../Module/LuaModule/LuaUtil.h"
D3DAppConfig::D3DAppConfig()
{
}
void D3DAppConfig::LoadConfig(lua_State* L, D3DAppConfig* pConfig)
{
	luaL_checktype(L, LUA_TOP, LUA_TTABLE);
	pConfig->clientHeight = getFieldInt(L, "clientHeight");
	pConfig->enable4xMsaa = getFieldBool(L, "enable4xMsaa");
	pConfig->driverType = getFieldInt(L, "driverType");
	pConfig->clientWidth = getFieldInt(L, "clientWidth");
	pConfig->engineDir = getFieldString(L, "engineDir");
	pConfig->mainWndCaption = getFieldString(L, "mainWndCaption");
	pConfig->configDir = getFieldString(L, "configDir");
	pConfig->_4xMsaaQuality = getFieldInt(L, "_4xMsaaQuality");
	lua_pop(L, 1);
}
