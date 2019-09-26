#ifndef ZELOENGINE_D3DAPPCONFIG_H
#define ZELOENGINE_D3DAPPCONFIG_H
#include "lua.hpp"
struct D3DAppConfig
{
	int clientHeight{};
	bool enable4xMsaa{};
	int driverType{};
	int clientWidth{};
	const char* engineDir{};
	const char* mainWndCaption{};
	const char* configDir{};
	int _4xMsaaQuality{};
	D3DAppConfig();
	friend class LuaConfigManager;
	private:
	static void LoadConfig(lua_State* L, D3DAppConfig* pConfig);
};
#endif //ZELOENGINE_D3DAPPCONFIG_H
