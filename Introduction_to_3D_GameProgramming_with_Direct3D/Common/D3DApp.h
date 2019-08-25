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

// dxut lib

//Severity	Code	Description	Project	File	Line	Suppression State
//Error	LNK2019	unresolved external symbol "long __stdcall DXUTTrace(char const *,unsigned long,long,wchar_t const *,bool)" (? DXUTTrace@@YGJPBDKJPB_W_N@Z) referenced in function "void __cdecl Initialize(struct HWND__ *)" (? Initialize@@YAXPAUHWND__@@@Z)	Lesson2_DirectX_Init	D : \ZeloEngine\build\Lesson2_DirectX_Init.obj	1
#pragma comment(lib, "DXUT.lib")
#pragma comment(lib, "DXUTOpt.lib")
//#pragma comment(lib, "comctl32.lib")
//#pragma comment(lib, "d3dcompiler.lib")
//#pragma comment(lib, "usp10.lib")
//#pragma comment(lib, "dxguid.lib")
//#pragma comment(lib, "winmm.lib")
//Severity	Code	Description	Project	File	Line	Suppression State
//Error	LNK2019	unresolved external symbol _D3D11CreateDeviceAndSwapChain@48 referenced in function "void __cdecl Initialize(struct HWND__ *)" (? Initialize@@YAXPAUHWND__@@@Z)	Lesson2_DirectX_Init	D : \ZeloEngine\build\Lesson2_DirectX_Init.obj	1
#pragma comment(lib, "D3D11.lib")

#define UNICODE
#define DXUT_AUTOLIB
#include "DXUT.h"
//#include "DXUTmisc.h"

// just for convenice, BAD practice
using namespace DirectX;
using namespace PackedVector;

extern HRESULT hr; // used by V to check if a directx function succeeded

class D3DApp;

extern D3DApp* g_pApp;

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

	//
	// some window configurations
	//
	std::wstring m_mainWndCaption{L"D3D11 App"}; // TODO string or wstring?
	int m_clientWidth{};
	int m_clientHeight{};

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

	//
	// some Direct3D configurations
	//
	D3D_DRIVER_TYPE m_driverType{D3D_DRIVER_TYPE_HARDWARE};
	bool m_enable4xMsaa{};
	UINT m_4xMsaaQuality{};

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

	int Run();

protected:
	int InitDirect3D();

	void Finalize();

	void RenderFrame();

	static LRESULT CALLBACK WindowProc(
		HWND hWnd,
		UINT message,
		WPARAM wParam,
		LPARAM lParam);

	int InitMainWindow();
};


#endif //ZELOENGINE_D3DAPP_H
