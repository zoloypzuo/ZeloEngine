// D3DApp.h
// created on 2019/8/25
// author @zoloypzuo

#ifndef ZELOENGINE_D3DAPP_H
#define ZELOENGINE_D3DAPP_H
#include <windows.h>
#include <windowsx.h>
#include <tchar.h>
#include <cassert>

#include <d3d11.h>
#include <d3d11_1.h>
#include <d3dcompiler.h>
#include <DirectXMath.h>
#include <DirectXColors.h>
#include <DirectXPackedVector.h>

#define UNICODE
#define DXUT_AUTOLIB
#include "DXUT.h"
//#include "DXUTmisc.h"
#include "lua.hpp"

#include "D3DAppConfig.h"


// just for convenice, BAD practice
using namespace DirectX;
using namespace PackedVector;

extern HRESULT hr; // used by V to check if a directx function succeeded

class D3DApp;

extern D3DApp* g_pApp;

extern lua_State* L;

class D3DApp
{
protected:
	//
	// some Direct3D objects
	//
	IDXGISwapChain* m_pSwapchain{};
	ID3D11Device* m_pDevice{};
	ID3D11DeviceContext* m_pDeviceContext{};
	ID3D11RenderTargetView* m_pRtv{};
	D3D11_VIEWPORT m_viewport{};

	/**
	 * \brief the args in wWinMain
	 */
	struct
	{
		HINSTANCE hInstance;
		HINSTANCE hPrevInstance;
		LPWSTR lpCmdLine;
		int nShowCmd;
	} m_winMainArgs{};

	/**
	 * \brief the window handle of the main window
	 */
	HWND m_hMainWnd{};

	D3DAppConfig* m_pConfig{};

public:
	/**
	 * \brief save wWinMain args
	 */
	D3DApp(
		HINSTANCE hInstance,
		HINSTANCE hPrevInstance,
		LPWSTR lpCmdLine,
		int nShowCmd);

	virtual ~D3DApp();

	int Initialize();

	void Finalize();

	int Run();

	LRESULT CALLBACK MsgProc(
		HWND hWnd,
		UINT message,
		WPARAM wParam,
		LPARAM lParam);

protected:
	int InitDirect3D();

	void RenderFrame();

	int InitMainWindow();
};


#endif //ZELOENGINE_D3DAPP_H
