// Demo1_Box.cpp
// created on 2019/8/27
// author @zoloypzuo

#include <cstdio>
#include <io.h>  // freopen
#include <windows.h>

#include "LuaUtil.h"
#include "Demo1_Box.h"
#include "MathHelper.h"

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
	L = lua_open();
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
	m_theta = 1.5f * MathHelper::Pi;
	m_phi = 0.25f * MathHelper::Pi;
	m_radius = 5.0f;
	XMMATRIX I = XMMatrixIdentity();
	XMStoreFloat4x4(&m_world, I);
	XMStoreFloat4x4(&m_view, I);
	XMStoreFloat4x4(&m_proj, I);
}

Demo1_Box::~Demo1_Box()
{
	m_boxVB->Release();
	m_boxIB->Release();
	// NOTE do not call base destructor, because it is called automatically
	//D3DApp::~D3DApp();
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
	// Convert Spherical to Cartesian coordinates.
	float x = m_radius * sinf(m_phi) * cosf(m_theta);
	float z = m_radius * sinf(m_phi) * sinf(m_theta);
	float y = m_radius * cosf(m_phi);

	// Build the view matrix.
	FXMVECTOR pos = XMVectorSet(x, y, z, 1.0f);
	FXMVECTOR target = XMVectorZero();
	FXMVECTOR up = XMVectorSet(0.0f, 1.0f, 0.0f, 0.0f);

	XMMATRIX V = XMMatrixLookAtLH(pos, target, up);
	XMStoreFloat4x4(&m_view, V);
}

void Demo1_Box::Render()
{
	m_pDeviceContext->ClearRenderTargetView(m_pRtv, reinterpret_cast<const float*>(&Colors::LightSteelBlue));
	m_pDeviceContext->IASetInputLayout(m_inputLayout);
	m_pDeviceContext->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);
	UINT stride = sizeof(Vertex);
	UINT offset = 0;
	m_pDeviceContext->IASetVertexBuffers(0, 1, &m_boxVB, &stride, &offset);
	m_pDeviceContext->IASetIndexBuffer(m_boxIB, DXGI_FORMAT_R32_UINT, 0);

	// Set constants
	XMMATRIX world = XMLoadFloat4x4(&m_world);
	XMMATRIX view = XMLoadFloat4x4(&m_view);
	XMMATRIX proj = XMLoadFloat4x4(&m_proj);
	XMMATRIX worldViewProj = world * view * proj;

	//mfxWorldViewProj->SetMatrix(reinterpret_cast<float*>(&worldViewProj));

	D3DX11_TECHNIQUE_DESC techDesc{};
	m_tech->GetDesc(&techDesc);
	for (UINT p = 0; p < techDesc.Passes; ++p)
	{
		m_tech->GetPassByIndex(p)->Apply(0, m_pDeviceContext);

		// 36 indices for the box.
		m_pDeviceContext->DrawIndexed(36, 0, 0);
	}

	V(m_pSwapchain->Present(0, 0));

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
