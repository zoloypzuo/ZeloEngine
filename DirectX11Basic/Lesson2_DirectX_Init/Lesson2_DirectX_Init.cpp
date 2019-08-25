// Lesson2_DirectX_Init.cpp
// created on 2019/8/22
// author @zoloypzuo

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

HRESULT hr{}; // used by V to check if a directx function succeeded

class D3DApp;
D3DApp* g_pApp{};

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
	std::wstring m_mainWndCaption{ L"D3D11 App" }; // TODO string or wstring?
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
	D3D_DRIVER_TYPE m_driverType{ D3D_DRIVER_TYPE_HARDWARE };
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
		int nShowCmd)
	{
		m_winMainArgs.hInstance = hInstance;
		m_winMainArgs.hPrevInstance = hPrevInstance;
		m_winMainArgs.lpCmdLine = lpCmdLine;
		m_winMainArgs.nShowCmd = nShowCmd;
	}

	virtual ~D3DApp()
	{
		Finalize();
	}

	int Run()
	{
		// wait for the next msg in the queue
		MSG msg{};
		while (GetMessage(&msg, nullptr, 0, 0))
		{
			// translate msg into the right form
			TranslateMessage(&msg);
			// call WindowProc callback
			DispatchMessage(&msg);
		}

		// return WM_QUIT ???
		return msg.wParam;
	}

	int InitDirect3D()
	{
		HWND hWnd = m_hMainWnd;

		//
		// create the swapchain
		//
		DXGI_SWAP_CHAIN_DESC scd{};
		// fill the swap chain description struct
		scd.BufferCount = 1; // one back buffer
		scd.BufferDesc.Width = 500;
		scd.BufferDesc.Height = 400;
		scd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM; // use 32-bit color
		scd.BufferDesc.RefreshRate.Numerator = 60;
		scd.BufferDesc.RefreshRate.Denominator = 1;
		scd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT; // how swap chain is to be used
		scd.OutputWindow = hWnd; // the window to be used
		scd.SampleDesc.Count = 4; // how many multisamples
		scd.Windowed = true; // windowed/full-screen mode
		scd.Flags = DXGI_SWAP_CHAIN_FLAG_ALLOW_MODE_SWITCH; // allow full-screen switching

		const D3D_FEATURE_LEVEL FeatureLevels[] = {
			D3D_FEATURE_LEVEL_11_1,
			D3D_FEATURE_LEVEL_11_0,
			D3D_FEATURE_LEVEL_10_1,
			D3D_FEATURE_LEVEL_10_0,
			D3D_FEATURE_LEVEL_9_3,
			D3D_FEATURE_LEVEL_9_2,
			D3D_FEATURE_LEVEL_9_1
		};
		D3D_FEATURE_LEVEL FeatureLevelSupported;

		// ReSharper disable once CppJoinDeclarationAndAssignment
		V(D3D11CreateDeviceAndSwapChain(
			nullptr, D3D_DRIVER_TYPE_HARDWARE,
			nullptr, 0, FeatureLevels, _countof(FeatureLevels),
			D3D11_SDK_VERSION, &scd, &m_pSwapchain, &m_pDevice, &FeatureLevelSupported, &m_pDeviceContext));

		// fallback, not used currently, because V will throw error if failed
		if (hr == E_INVALIDARG)
		{
			//hr = D3D11CreateDeviceAndSwapChain(NULL,
			//	D3D_DRIVER_TYPE_HARDWARE,
			//	NULL,
			//	0,
			//	&FeatureLevelSupported,
			//	1,
			//	D3D11_SDK_VERSION,
			//	&scd,
			//	&g_pSwapchain,
			//	&g_pDev,
			//	NULL,
			//	&g_pDevcon);
		}

		//
		// create the rtv
		//
		ID3D11Texture2D* pBackBuffer; // or ComPtr<ID3D11Texture3D>
		// get the pointer to the backbuffer
		V(m_pSwapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), (LPVOID*)& pBackBuffer));
		// create a render target view from the backbuffer
		V(m_pDevice->CreateRenderTargetView(pBackBuffer, nullptr, &m_pRtv));
		SAFE_RELEASE(pBackBuffer);
		// bind the view
		m_pDeviceContext->OMSetRenderTargets(1, &m_pRtv, nullptr);


		//
		// set the viewport
		//
		D3D11_VIEWPORT viewport{};
		viewport.TopLeftX = 0;
		viewport.TopLeftY = 0;
		viewport.Width = 500; // TODO can be global const cfg
		viewport.Height = 400;
		m_pDeviceContext->RSSetViewports(1, &viewport);

		// TODO init pipeline

		// TODO init graphics
		return 0;
	}

	int Initialize()
	{
		if (InitMainWindow())
		{
			assert(false && "");
			return -1;
		}

		if (InitDirect3D())
		{
			assert(false && "");
			return -1;
		}

		return 0;
	}

	void Finalize()
	{
		SAFE_RELEASE(m_pSwapchain);
		SAFE_RELEASE(m_pDevice);
		SAFE_RELEASE(m_pDeviceContext);
		SAFE_RELEASE(m_pRtv);
	}


	void RenderFrame()
	{
		// clear the backbuffer
		const FLOAT color[4] = { 0.0f, 0.2f, 0.4f, 1.0f };
		m_pDeviceContext->ClearRenderTargetView(m_pRtv, color);

		// do render here

		// present the backbuffer
		V(m_pSwapchain->Present(0, 0));
	}

	static LRESULT CALLBACK WindowProc(HWND hWnd,
		UINT message,
		WPARAM wParam,
		LPARAM lParam)
	{
		switch (message)
		{
		case WM_CREATE:
			break;
		case WM_DESTROY: // when the window is closed
			// close the app here
			//DiscardGraphicResources();
			PostQuitMessage(0);
			return 0;
		case WM_SIZE:
			break;
		case WM_PAINT:
			//CreateGraphicsResources(hWnd);
			g_pApp->RenderFrame();
		default:
			break;
		}

		// default msg handle
		return DefWindowProc(hWnd, message, wParam, lParam);
	};

	int InitMainWindow()
	{
		// TODO a better implementation can be found at Introduction to 3D Game Programming with Direct3D
		HINSTANCE hInstance = m_winMainArgs.hInstance;

		// create the window class
		WNDCLASSEX wc{};
		wc.cbSize = sizeof(WNDCLASSEX);
		wc.style = CS_HREDRAW | CS_VREDRAW;
		wc.lpfnWndProc = WindowProc;
		wc.hInstance = hInstance;
		wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
		wc.hbrBackground = (HBRUSH)COLOR_WINDOW;
		wc.lpszClassName = _T("WIndowClass1"); // NOTE that spell mistake, this name is used for create the window

		if (!RegisterClassEx(&wc))
		{
			assert(false && "RegisterClassEx failed");
			return -1;
		}

		HWND hWnd;
		hWnd = CreateWindowEx(
			0,
			_T("WIndowClass1"),
			_T("lpWindowName"),
			WS_OVERLAPPEDWINDOW,
			300, 300,
			500, 400,
			nullptr,
			nullptr,
			hInstance,
			nullptr);
		if (!hWnd)
		{
			auto err = GetLastError();
			assert(false && "Creating window failed");
			return -1;
		}
		m_hMainWnd = hWnd;

		// display the window
		ShowWindow(hWnd, SW_SHOW);
		return 0;
	}
};

int WINAPI wWinMain(
	_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPWSTR lpCmdLine,
	_In_ int nShowCmd
)
{
#if _DEBUG
	_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
	// watch Visual Studio's output window for memory leak messages
	//
	// e.g.
	//Detected memory leaks!
	//	Dumping objects ->
	//{249} normal block at 0x013FAE08, 4 bytes long.
	//	Data: < > 00 00 00 00
	//	Object dump complete.
	//	The program '[18280] Lesson2_DirectX_Init.exe' has exited with code 0 (0x0).
	//
	// then set break point using _CrtSetBreakAlloc, NOTE that the "249" comes from the output message
	//_CrtSetBreakAlloc(249);
#endif
	g_pApp = new D3DApp(
		hInstance,
		hPrevInstance,
		lpCmdLine,
		nShowCmd);

	if (g_pApp->Initialize())
	{
		assert(false && "");
		return -1;
	}

	return g_pApp->Run();
}
