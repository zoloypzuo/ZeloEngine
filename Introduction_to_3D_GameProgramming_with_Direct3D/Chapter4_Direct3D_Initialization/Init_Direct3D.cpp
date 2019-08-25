// Init_Direct3D.cpp
// created on 2019/8/25
// author @zoloypzuo

#include "D3DApp.h"
#include "Init_Direct3D.h"

int WINAPI wWinMain(
	_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPWSTR lpCmdLine,
	_In_ int nShowCmd
)
{
#if _DEBUG
	#define _CRTDBG_MAP_ALLOC
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
	//_CrtSetBreakAlloc(250);
	//_CrtSetBreakAlloc(251);
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

	int ret = g_pApp->Run();
	delete g_pApp;
	return ret;
}
