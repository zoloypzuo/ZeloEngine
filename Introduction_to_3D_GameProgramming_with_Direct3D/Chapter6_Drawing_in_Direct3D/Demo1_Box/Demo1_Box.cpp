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

	// try to open a console 
	if (AllocConsole())
	{
		// ReSharper disable once CppDeprecatedEntity
		freopen("CONOUT$", "w", stdout);
		// ReSharper disable once CppDeprecatedEntity
		freopen("CONOUT$", "w", stderr);
	}
#endif

	//
	// initialize here
	//

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
	m_fx->Release();
	m_inputLayout->Release();
	// NOTE do not call base destructor, because it is called automatically
	//D3DApp::~D3DApp();
}

float Demo1_Box::AspectRatio()
{
	return static_cast<float>(m_pConfig->clientWidth / m_pConfig->clientHeight);
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

	// The window resized, so update the aspect ratio and recompute the projection matrix.
	XMMATRIX P = XMMatrixPerspectiveFovLH(0.25f*MathHelper::Pi, AspectRatio(), 1.0f, 1000.0f);
	XMStoreFloat4x4(&m_proj, P);

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
	FXMVECTOR eyePos = XMVectorSet(x, y, z, 1.0f);
	FXMVECTOR target = XMVectorZero();
	FXMVECTOR up = XMVectorSet(0.0f, 1.0f, 0.0f, 0.0f);

	XMMATRIX V = XMMatrixLookAtLH(eyePos, target, up);
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

	m_fxWorldViewProj->SetMatrix(reinterpret_cast<float*>(&worldViewProj));

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
	// Create vertex buffer
	Vertex vertices[8] =
	{
		{ XMFLOAT3(-1.0f, -1.0f, -1.0f), XMFLOAT4((const float*)&Colors::White)  },
		{ XMFLOAT3(-1.0f, +1.0f, -1.0f), XMFLOAT4((const float*)&Colors::Black) },
		{ XMFLOAT3(+1.0f, +1.0f, -1.0f), XMFLOAT4((const float*)&Colors::Red)},
		{ XMFLOAT3(+1.0f, -1.0f, -1.0f), XMFLOAT4((const float*)&Colors::Green)},
		{ XMFLOAT3(-1.0f, -1.0f, +1.0f), XMFLOAT4((const float*)&Colors::Blue)  },
		{ XMFLOAT3(-1.0f, +1.0f, +1.0f), XMFLOAT4((const float*)&Colors::Yellow) },
		{ XMFLOAT3(+1.0f, +1.0f, +1.0f), XMFLOAT4((const float*)&Colors::Cyan)},
		{ XMFLOAT3(+1.0f, -1.0f, +1.0f), XMFLOAT4((const float*)&Colors::Magenta)}
	};

	D3D11_BUFFER_DESC vbd;
	vbd.Usage = D3D11_USAGE_IMMUTABLE;
	vbd.ByteWidth = sizeof(Vertex) * 8;
	vbd.BindFlags = D3D11_BIND_VERTEX_BUFFER;
	vbd.CPUAccessFlags = 0;
	vbd.MiscFlags = 0;
	vbd.StructureByteStride = 0;
	D3D11_SUBRESOURCE_DATA vinitData;
	vinitData.pSysMem = vertices;
	V(m_pDevice->CreateBuffer(&vbd, &vinitData, &m_boxVB));


	// Create the index buffer

	UINT indices[] = {
		// front face
		0, 1, 2,
		0, 2, 3,

		// back face
		4, 6, 5,
		4, 7, 6,

		// left face
		4, 5, 1,
		4, 1, 0,

		// right face
		3, 2, 6,
		3, 6, 7,

		// top face
		1, 5, 6,
		1, 6, 2,

		// bottom face
		4, 0, 3,
		4, 3, 7
	};

	D3D11_BUFFER_DESC ibd;
	ibd.Usage = D3D11_USAGE_IMMUTABLE;
	ibd.ByteWidth = sizeof(UINT) * 36;
	ibd.BindFlags = D3D11_BIND_INDEX_BUFFER;
	ibd.CPUAccessFlags = 0;
	ibd.MiscFlags = 0;
	ibd.StructureByteStride = 0;
	D3D11_SUBRESOURCE_DATA iinitData;
	iinitData.pSysMem = indices;
	V(m_pDevice->CreateBuffer(&ibd, &iinitData, &m_boxIB));
}

void Demo1_Box::BuildFx()
{
	DWORD shaderFlags = 0;
#if defined( DEBUG ) || defined( _DEBUG )
	shaderFlags |= D3D10_SHADER_DEBUG;
	shaderFlags |= D3D10_SHADER_SKIP_OPTIMIZATION;
#endif

	ID3D10Blob* compiledShader = 0;
	ID3D10Blob* compilationMsgs = 0;

	V(D3DCompileFromFile(L"color.fx", 0, 0, 0, "fx_5_0", shaderFlags, 0, &compiledShader, &compilationMsgs));

	// compilationMsgs can store errors or warnings.
#if 0
	if (compilationMsgs != 0)
	{
		MessageBoxA(0, (char*)compilationMsgs->GetBufferPointer(), 0, 0);
		SAFE_RELEASE(compilationMsgs);
}
#endif

	V(D3DX11CreateEffectFromMemory(compiledShader->GetBufferPointer(), compiledShader->GetBufferSize(),
		0, m_pDevice, &m_fx));

	// Done with compiled shader.
	compiledShader->Release();

	m_tech = m_fx->GetTechniqueByName("ColorTech");
	m_fxWorldViewProj = m_fx->GetVariableByName("gWorldViewProj")->AsMatrix();
}

void Demo1_Box::BuildVertexLayout()
{
	// Create the vertex input layout.
	D3D11_INPUT_ELEMENT_DESC vertexDesc[] =
	{
		{"POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D11_INPUT_PER_VERTEX_DATA, 0},
		{"COLOR",    0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 12, D3D11_INPUT_PER_VERTEX_DATA, 0}
	};

	// Create the input layout
	D3DX11_PASS_DESC passDesc;
	m_tech->GetPassByIndex(0)->GetDesc(&passDesc);
	V(m_pDevice->CreateInputLayout(vertexDesc, 2, passDesc.pIAInputSignature,
		passDesc.IAInputSignatureSize, &m_inputLayout));
}
