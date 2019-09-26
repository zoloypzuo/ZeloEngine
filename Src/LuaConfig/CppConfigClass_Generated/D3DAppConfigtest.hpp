#ifndef ZELOENGINE_D3DAPPCONFIG_H
#define ZELOENGINE_D3DAPPCONFIG_H
#include "lua.hpp"
struct D3DAppConfig
{
	const char* configDir{};
	int clientWidth{};
	int _4xMsaaQuality{};
	const char* mainWndCaption{};
	int driverType{};
	bool enable4xMsaa{};
	int clientHeight{};
	const char* engineDir{};
	D3DAppConfig();
	friend class LuaConfigManager;
	private:
	static void LoadConfig(lua_State* L, D3DAppConfig* pConfig);
};
#endif //ZELOENGINE_D3DAPPCONFIG_H
