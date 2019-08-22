// Lesson2_DirectX_Init.cpp
// created on 2019/8/22
// author @zoloypzuo

#include <windows.h>
#include <windowsx.h>
#include <tchar.h>
#include <cassert>

#define UNICODE
#define DXUT_AUTOLIB
#include "DXUT.h"

HRESULT hr{};  // used by V to check if a directx function succeeded

IDXGISwapChain* g_pSwapchain{};

ID3D11Device* g_pDev{};

ID3D11DeviceContext* g_pDevcon{};

ID3D11RenderTargetView* g_pRTV{};

void Initialize(HWND hWnd)
{
	//
	// create the swapchain
	//
	DXGI_SWAP_CHAIN_DESC scd{};
	scd.BufferCount = 1;  // use one back buffer
	scd.BufferDesc.Format = DXGI_FORMAT_R8G8B8A8_UNORM;  // use 32b color
	scd.BufferUsage = DXGI_USAGE_RENDER_TARGET_OUTPUT;
	scd.OutputWindow = hWnd;
	scd.SampleDesc.Count = 4;
	scd.Windowed = true;
	// ReSharper disable once CppJoinDeclarationAndAssignment
	V(D3D11CreateDeviceAndSwapChain(
		nullptr, D3D_DRIVER_TYPE_HARDWARE,
		nullptr, 0, nullptr, 0,
		D3D11_SDK_VERSION, &scd, &g_pSwapchain, &g_pDev, nullptr, &g_pDevcon));

	//
	// create the rtv
	//
	ID3D11Texture2D* pBackBuffer;
	// get the pointer to the backbuffer
	V(g_pSwapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), (LPVOID*)&pBackBuffer));
	// create a render target view from the backbuffer
	V(g_pDev->CreateRenderTargetView(pBackBuffer, nullptr, &g_pRTV));
	SAFE_RELEASE(pBackBuffer);
	// bind the view
	g_pDevcon->OMSetRenderTargets(1, &g_pRTV, nullptr);

	//
	// set the viewport
	//
	D3D11_VIEWPORT viewport{};
	viewport.TopLeftX = 0;
	viewport.TopLeftY = 0;
	viewport.Width = 500;  // TODO can be global const cfg
	viewport.Height = 400;
	g_pDevcon->RSSetViewports(1, &viewport);
}

void Finalize()
{
	SAFE_RELEASE(g_pSwapchain);
	SAFE_RELEASE(g_pDev);
	SAFE_RELEASE(g_pDevcon);
	SAFE_RELEASE(g_pRTV);
}


void RenderFrame()
{
	// clear the backbuffer
	const FLOAT color[4] = { 0.0f, 0.2f, 0.4f, 1.0f };
	g_pDevcon->ClearRenderTargetView(g_pRTV, color);

	// do render here

	// present the backbuffer
	V(g_pSwapchain->Present(0, 0));
}

LRESULT CALLBACK WindowProc(HWND hWnd,
	UINT message,
	WPARAM wParam,
	LPARAM lParam)
{
	switch (message) {
		// when the window is closed
	case WM_DESTROY:
		// close the app
		PostQuitMessage(0);
		return 0;
	case WM_PAINT:
		RenderFrame();
	default:
		break;
	}

	// default msg handle
	V_RETURN(DefWindowProc(hWnd, message, wParam, lParam));
};

int WINAPI wWinMain(
	_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPWSTR lpCmdLine,
	_In_ int nShowCmd
) {
	// create the window class
	WNDCLASSEX wc{};
	wc.cbSize = sizeof(WNDCLASSEX);
	wc.style = CS_HREDRAW | CS_VREDRAW;
	wc.lpfnWndProc = WindowProc;
	wc.hInstance = hInstance;
	wc.hCursor = LoadCursor(nullptr, IDC_ARROW);
	wc.hbrBackground = (HBRUSH)COLOR_WINDOW;
	wc.lpszClassName = _T("WIndowClass1");  // NOTE that spell mistake, this name is used for create the window

	RegisterClassEx(&wc);

	HWND hWnd;
	if (!(hWnd = CreateWindowEx(
		0,
		_T("WIndowClass1"),
		_T("lpWindowName"),
		WS_OVERLAPPEDWINDOW,
		300, 300,
		500, 400,
		nullptr,
		nullptr,
		hInstance,
		nullptr)))
		assert(false && "Creating window failed");

	// display the window
	ShowWindow(hWnd, nShowCmd);

	// do init here
	Initialize(hWnd);

	// wait for the next msg in the queue
	MSG msg{};
	while (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE)) {
		// translate msg into the right form
		TranslateMessage(&msg);
		// call WindowProc callback
		DispatchMessage(&msg);
	}

	// do cleanup here
	Finalize();

	// return WM_QUIT ???
	return msg.wParam;
}
