// D3DAppConfig.h
// created on 2019/8/26
// author @zoloypzuo

#ifndef ZELOENGINE_D3DAPPCONFIG_H
#define ZELOENGINE_D3DAPPCONFIG_H
#include <string>
#include <d3dcommon.h>

#include "lua.hpp"

struct D3DAppConfig final
{
	//
	// some window configurations
	//
	std::string mainWndCaption{}; // TODO string or wstring?
	int clientWidth{};
	int clientHeight{};

	//
	// some Direct3D configurations
	//
	D3D_DRIVER_TYPE driverType{};
	bool enable4xMsaa{};
	UINT _4xMsaaQuality{};

	std::string engineDir{};
	std::string configDir{};

	D3DAppConfig();

	static int LoadConfig(lua_State* L, D3DAppConfig** ppConfig);

private:
	static int pLoadConfig(lua_State* L);
};


#endif //ZELOENGINE_D3DAPPCONFIG_H
