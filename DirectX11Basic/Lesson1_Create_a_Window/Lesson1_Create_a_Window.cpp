#include <windows.h>
#include <windowsx.h>
#include <tchar.h>

WNDPROC WindowProc = [](HWND hWnd, UINT msg, WPARAM wParam, LPARAM lParam)->LRESULT {
	switch (msg) {
	// when the window is closed
	case WM_DESTROY:
		// close the app
		PostQuitMessage(0);
		return 0;
	default:
		break;
	}

	// default msg handle
	return DefWindowProc(hWnd, msg, wParam, lParam);
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
	wc.lpszClassName = _T("WIndowClass1");

	RegisterClassEx(&wc);

	// create the window
	HWND hWnd;
	//CreateWindowExA(
	//	_In_ DWORD dwExStyle,
	//	_In_opt_ LPCSTR lpClassName,
	//	_In_opt_ LPCSTR lpWindowName,
	//	_In_ DWORD dwStyle,
	//	_In_ int X,
	//	_In_ int Y,
	//	_In_ int nWidth,
	//	_In_ int nHeight,
	//	_In_opt_ HWND hWndParent,
	//	_In_opt_ HMENU hMenu,
	//	_In_opt_ HINSTANCE hInstance,
	//	_In_opt_ LPVOID lpParam);
	hWnd = CreateWindowEx(
		0,
		_T("lpClassName"),
		_T("lpWindowName"),
		WS_OVERLAPPEDWINDOW,
		300, 300,
		500, 400,
		nullptr,
		nullptr,
		hInstance,
		nullptr);

	// display the window
	ShowWindow(hWnd, nShowCmd);

	// wait for the next msg in the queue
	MSG msg{};
	while (GetMessage(&msg, nullptr, 0, 0)) {
		// translate msg into the right form
		TranslateMessage(&msg);
		// call WindowProc callback
		DispatchMessage(&msg);
	}

	// return WM_QUIT ???
	return msg.wParam;
}
