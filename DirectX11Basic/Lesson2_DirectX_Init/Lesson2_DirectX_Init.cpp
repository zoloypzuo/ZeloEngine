// Lesson2_DirectX_Init.cpp
// created on 2019/8/22
// author @zoloypzuo

#include <windows.h>
#include <windowsx.h>
#include <tchar.h>
#include <cassert>
#include "DXUT.h"

HRESULT hr;  // used by V to check if a directx function succeeded

IDXGISwapChain* swapchain;

ID3D11Device* dev;

ID3D11DeviceContext* devcon;

ID3D11RenderTargetView* backbuffer;

void Initialize(HWND hWnd)
{
	// create the swapchain
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
		D3D11_SDK_VERSION, &scd, &swapchain, &dev, nullptr, &devcon));

	ID3D11Texture2D* pBackBuffer;
	// get pointer to backbuffer
	V(swapchain->GetBuffer(0, __uuidof(ID3D11Texture2D), (LPVOID*)&pBackBuffer));
	// create the render target view from the backbuffer
	V(dev->CreateRenderTargetView(pBackBuffer, nullptr, &backbuffer));
	SAFE_RELEASE(pBackBuffer);
	// set the backbuffer as the render target view of
	devcon->OMSetRenderTargets(1, &backbuffer, nullptr);

	// create and set the viewport
	D3D11_VIEWPORT viewport{};
	viewport.TopLeftX = 0;
	viewport.TopLeftY = 0;
	viewport.Width = 500;
	viewport.Height = 400;
	devcon->RSSetViewports(1, &viewport);
}

void Finalize()
{
	SAFE_RELEASE(swapchain);
	SAFE_RELEASE(dev);
	SAFE_RELEASE(devcon);
	SAFE_RELEASE(backbuffer);
}


void RenderFrame()
{
	// clear the backbuffer
	const FLOAT color[4] = { 0,0.2,0.4,1.0 };
	devcon->ClearRenderTargetView(backbuffer, color);

	// do render here

	// present the backbuffer
	V(swapchain->Present(0, 0));
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
