// Demo1_Box.cpp
// created on 2019/8/27
// author @zoloypzuo

#include <cstdio>
#include <io.h>
#include <fcntl.h>
#include <windows.h>

#include "D3DApp.h"
#include "LuaUtil.h"
#include "Demo1_Box.h"

// TODO ignore OnResize temporarily

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
	//_CrtSetBreakAlloc(250);
	//_CrtSetBreakAlloc(351);
#endif

	//
	// initialize here
	//

	// try to open a console 
	if (AllocConsole())
	{
		// ReSharper disable once CppDeprecatedEntity
		freopen("CONOUT$", "w", stdout);
		// ReSharper disable once CppDeprecatedEntity
		freopen("CONOUT$", "w", stderr);
	}

	//
	// lua
	//
	L = lua_open(); // where is lua_open() ?
	luaL_openlibs(L);  // TODO this may raise error, put it in a pcall

	//
	// D3DApp
	//
	g_pApp = new Demo1_Box(
		hInstance,
		hPrevInstance,
		lpCmdLine,
		nShowCmd);

	if (g_pApp->Initialize())
	{
		assert(false && "");
		return -1;
	}

	// main loop
	int ret = g_pApp->Run();

	//
	// finalize here
	//
	stackDump(L);
	g_pApp->Finalize();
	delete g_pApp;
	lua_close(L);

	return ret;
}

Demo1_Box::Demo1_Box(HINSTANCE hInstance, HINSTANCE hPrevInstance, LPWSTR lpCmdLine, int nShowCmd)
	:D3DApp(hInstance, hPrevInstance, lpCmdLine, nShowCmd)
{
}

Demo1_Box::~Demo1_Box()
{
	D3DApp::~D3DApp();
}

int Demo1_Box::Initialize()
{
	if (D3DApp::Initialize())
	{
		assert(false);
		return -1;
	}

	BuildGeometryBuffers();
	BuildFx();
	BuildVertexLayout();
	return 0;
}

void Demo1_Box::Finalize()
{
	D3DApp::Finalize();
}

int Demo1_Box::Run()
{
	return D3DApp::Run();
}

LRESULT Demo1_Box::MsgProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam)
{
	return D3DApp::MsgProc(hWnd, message, wParam, lParam);
}

void Demo1_Box::Update(float dt)
{
	//float x = m_radius * 
	//XMVECTOR pos = XMVectorSet()
}

void Demo1_Box::Render()
{
}

void Demo1_Box::BuildGeometryBuffers()
{
}

void Demo1_Box::BuildFx()
{
}

void Demo1_Box::BuildVertexLayout()
{
}
