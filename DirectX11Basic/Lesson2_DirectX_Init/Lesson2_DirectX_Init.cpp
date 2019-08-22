#include <windows.h>
#include <windowsx.h>
#include <tchar.h>
#include <assert.h>

#include <d3d11.h>
#pragma comment(lib,"d3d11.lib")

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
	default:
		break;
	}

	// default msg handle
	return DefWindowProc(hWnd, message, wParam, lParam);
};

IDXGISwapChain* swapchain;

ID3D11Device* dev;

ID3D11DeviceContext* devcon;

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
	HRESULT hr;
	if (!(hr = D3D11CreateDeviceAndSwapChain(
		nullptr, D3D_DRIVER_TYPE_HARDWARE,
		nullptr, 0, nullptr, 0,
		D3D11_SDK_VERSION, &scd, &swapchain, &dev, nullptr, &devcon)))
	{
		assert(false && hr && "D3D11CreateDeviceAndSwapChain failed");
	}
}

void Finalize()
{
	swapchain->Release();
	dev->Release();
	devcon->Release();
}

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
	while (true) {
		if (PeekMessage(&msg, nullptr, 0, 0, PM_REMOVE))
		{
			if(msg.message==WM_QUIT)
			{
				break;
			}

			// translate msg into the right form
			TranslateMessage(&msg);
			// call WindowProc callback
			DispatchMessage(&msg);
		}
		else
		{
			// run game code here
		}
	}

	// do cleanup here
	Finalize();

	// return WM_QUIT ???
	return msg.wParam;
}
