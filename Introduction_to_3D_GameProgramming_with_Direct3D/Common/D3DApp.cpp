// D3DApp.cpp
// created on 2019/8/25
// author @zoloypzuo

#include "lua.hpp"

#include "D3DApp.h"

HRESULT hr{};

D3DApp* g_pApp{};

lua_State* L{};

static LRESULT CALLBACK MainWndProc(
	HWND hWnd,
	UINT message,
	WPARAM wParam,
	LPARAM lParam)
{
	return g_pApp->MsgProc(hWnd, message, wParam, lParam);
}

D3DApp::D3DApp(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nShowCmd)
{
	m_winMainArgs.hInstance = hInstance;
	m_winMainArgs.hPrevInstance = hPrevInstance;
	m_winMainArgs.lpCmdLine = lpCmdLine;
	m_winMainArgs.nShowCmd = nShowCmd;
}

D3DApp::~D3DApp()
{
}

int D3DApp::Initialize()
{
	if (D3DAppConfig::LoadConfig(L, &m_pConfig))
	{
		assert(false);
		return -1;
	}

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

int D3DApp::Run()
{
	// wait for the next msg in the queue
	MSG msg{};
	while (msg.message != WM_QUIT)
	{
		if (PeekMessage(&msg, 0, 0, 0, PM_REMOVE))
		{
			// translate msg into the right form
			TranslateMessage(&msg);
			// call WindowProc callback
			DispatchMessage(&msg);
		}
		else
		{
			m_timer.Tick();
			Update(m_timer.DeltaTime());
			Render();
		}
	}

	return msg.wParam;
}

int D3DApp::InitDirect3D()
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
	viewport.Width = static_cast<FLOAT>(m_pConfig->clientWidth);
	viewport.Height = static_cast<FLOAT>(m_pConfig->clientHeight);
	m_pDeviceContext->RSSetViewports(1, &viewport);

	// TODO init pipeline

	// TODO init graphics
	return 0;
}


void D3DApp::Finalize()
{
	SAFE_RELEASE(m_pSwapchain);
	SAFE_RELEASE(m_pDevice);
	SAFE_RELEASE(m_pDeviceContext);
	SAFE_RELEASE(m_pRtv);

	m_pConfig->~D3DAppConfig();
}


void D3DApp::RenderFrame()
{
	// clear the backbuffer
	const FLOAT color[4] = { 0.0f, 0.2f, 0.4f, 1.0f };
	m_pDeviceContext->ClearRenderTargetView(m_pRtv, color);

	// do render here

	// present the backbuffer
	V(m_pSwapchain->Present(0, 0));
}

LRESULT D3DApp::MsgProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
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
	case WM_SIZE:  // when the user resizes the window
		m_pConfig->clientWidth = LOWORD(lParam);
		m_pConfig->clientHeight = HIWORD(lParam);
		if (!m_pDevice)
		{
			break;
		}
		assert(false && "resize handle not implemented");
		break;
	case WM_PAINT:
		// do not use it
		break;
	case WM_GETMINMAXINFO:  // set min size of the window to prevent the window from being too small
	{
		//auto minmaxInfo = (MINMAXINFO*)lParam;
		//minmaxInfo->ptMinTrackSize.x = 640;
		//minmaxInfo->ptMinTrackSize.y = 480;
		break;
	}
	case WM_LBUTTONDOWN:
		break;
	case WM_MBUTTONDOWN:
		break;
	case WM_RBUTTONDBLCLK:
		break;
	case WM_RBUTTONUP:
		break;
	case WM_MOUSEMOVE:
		break;
	default:
		break;
	}

	// default msg handle
	return DefWindowProc(hWnd, message, wParam, lParam);
};

int D3DApp::InitMainWindow()
{
	// TODO a better implementation can be found at Introduction to 3D Game Programming with Direct3D
	HINSTANCE hInstance = m_winMainArgs.hInstance;

	// create the window class
	WNDCLASSEX wc{};
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.style = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc = MainWndProc;
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
		m_pConfig->mainWndCaption.c_str(),
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
