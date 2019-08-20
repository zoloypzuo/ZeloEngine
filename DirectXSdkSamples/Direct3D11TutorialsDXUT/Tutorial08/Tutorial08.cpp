// Tutorial08.cpp
// created on 2019/8/19
// author @zoloypzuo

#pragma region stdafx.h

#define WIN32_LEAN_AND_MEAN             // Exclude rarely-used stuff from Windows headers

// windows header
#define NOMINMAX
#include <windows.h>
#include <windowsx.h>

#include <crtdbg.h>

#include <tchar.h>
#include <cstdint>


// directx header

#define DXUT_AUTOLIB  // #define DXUT_AUTOLIB to automatically include the libs needed for DXUT
#define UNICODE

#include "DXUT.h"

#define GCC_NEW new
#define GCC_ASSERT(o) (void)0
#define GCC_ERROR(o) (void)0
#define GCC_LOG(o) (void)0

#pragma endregion

// dxut lib
#pragma comment(lib, "DXUT.lib")
#pragma comment(lib, "DXUTOpt.lib")
#pragma comment(lib, "comctl32.lib")
#pragma comment(lib, "d3dcompiler.lib")
#pragma comment(lib, "usp10.lib")
#pragma comment(lib, "dxguid.lib")
#pragma comment(lib, "winmm.lib")

#include "SDKmisc.h"

#include "Tutorial08.h"


struct SimpleVertex
{
	DirectX::XMFLOAT3 Pos;
	DirectX::XMFLOAT2 Tex;
};

struct CBChangesEveryFrame
{
	DirectX::XMFLOAT4X4 mWorldViewProj;
	DirectX::XMFLOAT4X4 mWorld;
	DirectX::XMFLOAT4 vMeshColor;
};

ID3D11VertexShader* g_pVertexShader{};
ID3D11PixelShader* g_pPixelShader{};
// TODO more global var

// IsD3D11DeviceAcceptable return true to accept any devices

// ModifyDeviceSettings called right before creating a d3d device, allowing the app to modify the device settings as needed

// OnD3D11CreateDevice create any d3d resources that are not dependent on the back buffer

// OnD3D11ResizedSwapChain create any d3d resources that are dependent on the back buffer

// OnFrameMove handle updates to the scene

// OnD3D11FrameRender render the scene using the d3d device

// OnD3D11ReleasingSwapChain release resources created in OnD3D11ResizedSwapChain

// OnD3D11DestroyDevice release resources created in OnD3D11CreateDevice

// MsgProc handle msg to the app

// OnKeyboard handle key presses

// OnDeviceRemoved called when device was moved, return true to find a new device, or false to quit

DirectX::XMMATRIX g_world;
DirectX::XMFLOAT4 g_vMeshColor{ 0.7f,0.7f,0.7f,1.0f };

LPDXUTCALLBACKFRAMEMOVE OnFrameMove = [](_In_ double fTime, _In_ float fElapsedTime, _In_opt_ void* pUserContext)
{
	const float time = static_cast<float>(fTime);

	// rotate the cube around the origin
	g_world = DirectX::XMMatrixRotationY(60.0f * DirectX::XMConvertToRadians(time));

	// modify the color
	g_vMeshColor.x = sinf((time*1.0f + 1.0f)*0.5f);
	g_vMeshColor.y = cosf((time * 3.0f + 1.0f)*0.5f);
	g_vMeshColor.y = sinf((time*5.0f) + 1.0f*0.5f);
};

LPDXUTCALLBACKKEYBOARD OnKeyboard = [](_In_ UINT nChar, _In_ bool bKeyDown, _In_ bool bAltDown, _In_opt_ void* pUserContext)
{
	if (bKeyDown)
	{
		switch (nChar)
		{
		case VK_F1:
			break;
		default:
			break;
		}
	}
};

LPDXUTCALLBACKMSGPROC MsgProc = [](_In_ HWND hWnd, _In_ UINT uMsg, _In_ WPARAM wParam, _In_ LPARAM lParam,
	_Out_ bool* pbNoFurtherProcessing, _In_opt_ void* pUserContext)->LRESULT
{
	// do nothing
	return 0;
};

LPDXUTCALLBACKMODIFYDEVICESETTINGS ModifyDeviceSettings = [](_In_ DXUTDeviceSettings* pDeviceSettings, _In_opt_ void* pUserContext)->bool
{
	// do nothing
	return true;
};

LPDXUTCALLBACKDEVICEREMOVED OnDeivceRemoved = [](_In_opt_ void* pUserContext)->bool
{
	// do nothing
	return true;
};

LPDXUTCALLBACKISD3D11DEVICEACCEPTABLE IsD3D11DeviceAcceptable = [](_In_ const CD3D11EnumAdapterInfo *AdapterInfo, _In_ UINT Output, _In_ const CD3D11EnumDeviceInfo *DeviceInfo,
	_In_ DXGI_FORMAT BackBufferFormat, _In_ bool bWindowed, _In_opt_ void* pUserContext)->bool
{
	// do nothing
	return true;
};

ID3D11InputLayout* g_pVertexLayout;
ID3D11Buffer* g_pVertexBuffer;
ID3D11Buffer* g_pIndexBuffer;
ID3D11Buffer* g_pCBChangesEveryFrame;
ID3D11SamplerState* g_pSamplerLinear;
DirectX::XMMATRIX g_View;
ID3D11ShaderResourceView* g_pTextureRV;
LPDXUTCALLBACKD3D11DEVICECREATED OnD3D11CreateDevice = [](_In_ ID3D11Device* pd3dDevice, _In_ const DXGI_SURFACE_DESC* pBackBufferSurfaceDesc, _In_opt_ void* pUserContext)->HRESULT
{
	HRESULT hr = S_OK;
	auto pd3dImmediateContext = DXUTGetD3D11DeviceContext();
	DWORD dwShaderFlags = D3DCOMPILE_ENABLE_STRICTNESS;
#ifdef _DEBUG
	// embed debug info in the shader, and disable optimizations
	dwShaderFlags |= D3DCOMPILE_DEBUG | D3DCOMPILE_SKIP_OPTIMIZATION;
#endif

	{
		// compile the vertex shader
		ID3DBlob* pVSBlob{};
		V_RETURN(DXUTCompileFromFile(L"Tutorial08.fx", nullptr, "VS", "vs_4_0", dwShaderFlags, 0, &pVSBlob));

		auto bufferPointer = pVSBlob->GetBufferPointer();
		auto bufferSize = pVSBlob->GetBufferSize();

		// create the vertex shader
		hr = pd3dDevice->CreateVertexShader(bufferPointer, bufferSize, nullptr, &g_pVertexShader);
		if (FAILED(hr))
		{
			SAFE_RELEASE(pVSBlob);
			return hr;
		}

		// define the input layout
		// TODO ???
		D3D11_INPUT_ELEMENT_DESC layout[] = {
			{"POSITION",0,DXGI_FORMAT_R32G32B32_FLOAT,0,0,D3D11_INPUT_PER_VERTEX_DATA,0},
			{"TEXCOORD",0,DXGI_FORMAT_R32G32_FLOAT,0,12,D3D11_INPUT_PER_VERTEX_DATA,0}
		};
		UINT numElements = ARRAYSIZE(layout);

		// create the input layout
		hr = pd3dDevice->CreateInputLayout(layout, numElements, bufferPointer, bufferSize, &g_pVertexLayout);
		SAFE_RELEASE(pVSBlob);
		if (FAILED(hr))
		{
			return hr;
		}

		// set the input layout
		pd3dImmediateContext->IASetInputLayout(g_pVertexLayout);
	}

	{
		ID3DBlob* pPSBlob{};
		V_RETURN(DXUTCompileFromFile(L"Tutorial08.fx", nullptr, "PS", "ps_4_0", dwShaderFlags, 0, &pPSBlob));

		auto bufferPointer = pPSBlob->GetBufferPointer();
		auto bufferSize = pPSBlob->GetBufferSize();

		hr = pd3dDevice->CreatePixelShader(bufferPointer, bufferSize, nullptr, &g_pPixelShader);
		SAFE_RELEASE(pPSBlob);
		if (FAILED(hr))
		{
			return hr;
		}
	}

	// TODO ???
	typedef DirectX::XMFLOAT2 XMFLOAT2;
	typedef DirectX::XMFLOAT3 XMFLOAT3;

	SimpleVertex vertices[] = {
				{ XMFLOAT3(-1.0f, 1.0f, -1.0f), XMFLOAT2(1.0f, 0.0f) },
		{ XMFLOAT3(1.0f, 1.0f, -1.0f), XMFLOAT2(0.0f, 0.0f) },
		{ XMFLOAT3(1.0f, 1.0f, 1.0f), XMFLOAT2(0.0f, 1.0f) },
		{ XMFLOAT3(-1.0f, 1.0f, 1.0f), XMFLOAT2(1.0f, 1.0f) },

		{ XMFLOAT3(-1.0f, -1.0f, -1.0f), XMFLOAT2(0.0f, 0.0f) },
		{ XMFLOAT3(1.0f, -1.0f, -1.0f), XMFLOAT2(1.0f, 0.0f) },
		{ XMFLOAT3(1.0f, -1.0f, 1.0f), XMFLOAT2(1.0f, 1.0f) },
		{ XMFLOAT3(-1.0f, -1.0f, 1.0f), XMFLOAT2(0.0f, 1.0f) },

		{ XMFLOAT3(-1.0f, -1.0f, 1.0f), XMFLOAT2(0.0f, 1.0f) },
		{ XMFLOAT3(-1.0f, -1.0f, -1.0f), XMFLOAT2(1.0f, 1.0f) },
		{ XMFLOAT3(-1.0f, 1.0f, -1.0f), XMFLOAT2(1.0f, 0.0f) },
		{ XMFLOAT3(-1.0f, 1.0f, 1.0f), XMFLOAT2(0.0f, 0.0f) },

		{ XMFLOAT3(1.0f, -1.0f, 1.0f), XMFLOAT2(1.0f, 1.0f) },
		{ XMFLOAT3(1.0f, -1.0f, -1.0f), XMFLOAT2(0.0f, 1.0f) },
		{ XMFLOAT3(1.0f, 1.0f, -1.0f), XMFLOAT2(0.0f, 0.0f) },
		{ XMFLOAT3(1.0f, 1.0f, 1.0f), XMFLOAT2(1.0f, 0.0f) },

		{ XMFLOAT3(-1.0f, -1.0f, -1.0f), XMFLOAT2(0.0f, 1.0f) },
		{ XMFLOAT3(1.0f, -1.0f, -1.0f), XMFLOAT2(1.0f, 1.0f) },
		{ XMFLOAT3(1.0f, 1.0f, -1.0f), XMFLOAT2(1.0f, 0.0f) },
		{ XMFLOAT3(-1.0f, 1.0f, -1.0f), XMFLOAT2(0.0f, 0.0f) },

		{ XMFLOAT3(-1.0f, -1.0f, 1.0f), XMFLOAT2(1.0f, 1.0f) },
		{ XMFLOAT3(1.0f, -1.0f, 1.0f), XMFLOAT2(0.0f, 1.0f) },
		{ XMFLOAT3(1.0f, 1.0f, 1.0f), XMFLOAT2(0.0f, 0.0f) },
		{ XMFLOAT3(-1.0f, 1.0f, 1.0f), XMFLOAT2(1.0f, 0.0f) },
	};

	D3D11_BUFFER_DESC bd{};
	bd.Usage = D3D11_USAGE_DEFAULT;
	bd.ByteWidth = sizeof(SimpleVertex) * 24;
	bd.BindFlags = D3D11_BIND_VERTEX_BUFFER;
	bd.CPUAccessFlags = 0;

	D3D11_SUBRESOURCE_DATA Initdata{};
	Initdata.pSysMem = vertices;
	V_RETURN(pd3dDevice->CreateBuffer(&bd, &Initdata, &g_pVertexBuffer));

	UINT stride = sizeof(SimpleVertex);
	UINT offset = 0;
	pd3dImmediateContext->IASetVertexBuffers(0, 1, &g_pVertexBuffer, &stride, &offset);

	DWORD indices[] = {
		3,1,0,
		2,1,3,

		6,4,5,
		7,4,6,

		11,9,8,
		10,9,11,

		14,12,13,
		15,12,14,

		19,17,16,
		18,17,19,

		22,20,21,
		23,20,22
	};

	bd.Usage = D3D11_USAGE_DEFAULT;
	bd.ByteWidth = sizeof(DWORD) * 36;
	bd.BindFlags = D3D11_BIND_INDEX_BUFFER;
	bd.CPUAccessFlags = 0;
	bd.MiscFlags = 0;
	Initdata.pSysMem = indices;
	V_RETURN(pd3dDevice->CreateBuffer(&bd, &Initdata, &g_pIndexBuffer));

	pd3dImmediateContext->IASetIndexBuffer(g_pIndexBuffer, DXGI_FORMAT_R32_UINT, 0);
	pd3dImmediateContext->IASetPrimitiveTopology(D3D11_PRIMITIVE_TOPOLOGY_TRIANGLELIST);

	bd.Usage = D3D11_USAGE_DYNAMIC;
	bd.BindFlags = D3D11_BIND_CONSTANT_BUFFER;
	bd.CPUAccessFlags = D3D11_CPU_ACCESS_WRITE;
	bd.ByteWidth = sizeof(CBChangesEveryFrame);
	V_RETURN(pd3dDevice->CreateBuffer(&bd, nullptr, &g_pCBChangesEveryFrame));

	g_world = DirectX::XMMatrixIdentity();
	static const DirectX::XMVECTORF32 s_Eye = { 0.0f, 3.0f, -6.0f, 0.f };
	static const DirectX::XMVECTORF32 s_At = { 0.0f, 1.0f, 0.0f, 0.f };
	static const DirectX::XMVECTORF32 s_Up = { 0.0f, 1.0f, 0.0f, 0.f };
	g_View = DirectX::XMMatrixLookAtLH(s_Eye, s_At, s_Up);

	V_RETURN(DXUTCreateShaderResourceViewFromFile(pd3dDevice, L"misc\\seafloor.dds", &g_pTextureRV));

	D3D11_SAMPLER_DESC sampDesc{};
	sampDesc.Filter = D3D11_FILTER_MIN_MAG_MIP_LINEAR;
	sampDesc.AddressU = D3D11_TEXTURE_ADDRESS_WRAP;
	sampDesc.AddressV = D3D11_TEXTURE_ADDRESS_WRAP;
	sampDesc.AddressW = D3D11_TEXTURE_ADDRESS_WRAP;
	sampDesc.ComparisonFunc = D3D11_COMPARISON_NEVER;
	sampDesc.MinLOD = 0;
	sampDesc.MaxLOD = D3D11_FLOAT32_MAX;
	V_RETURN(pd3dDevice->CreateSamplerState(&sampDesc, &g_pSamplerLinear));
	return S_OK;
};

DirectX::XMMATRIX g_Projection;
LPDXUTCALLBACKD3D11SWAPCHAINRESIZED OnD3D11ResizedSwapChain = [](_In_ ID3D11Device* pd3dDevice, _In_ IDXGISwapChain *pSwapChain, _In_ const DXGI_SURFACE_DESC* pBackBufferSurfaceDesc, _In_opt_ void* pUserContext)->HRESULT
{
	// setup the projection parameters
	float fAspect = static_cast<float>(pBackBufferSurfaceDesc->Width) / static_cast<float>(pBackBufferSurfaceDesc->Height);
	g_Projection = DirectX::XMMatrixPerspectiveFovLH(DirectX::XM_PI*0.25f, fAspect, 0.1f, 100.0f);
	return S_OK;
};

LPDXUTCALLBACKD3D11FRAMERENDER OnD3D11FrameRender = [](_In_ ID3D11Device* pd3dDevice, _In_ ID3D11DeviceContext* pd3dImmediateContext, _In_ double fTime, _In_ float fElapsedTime, _In_opt_ void* pUserContext)
{
	// clear the back buffer
	auto pRTV = DXUTGetD3D11RenderTargetView();
	pd3dImmediateContext->ClearRenderTargetView(pRTV, DirectX::Colors::MidnightBlue);

	// clear the depth stencil
	auto pDSV = DXUTGetD3D11DepthStencilView();
	pd3dImmediateContext->ClearDepthStencilView(pDSV, D3D11_CLEAR_DEPTH, 1.0, 0);

	DirectX::XMMATRIX mWorldViewProjection = g_world * g_View * g_Projection;

	// update constant buffer that changes once per frame
	HRESULT hr;
	D3D11_MAPPED_SUBRESOURCE MappedResource;
	pd3dImmediateContext->Map(g_pCBChangesEveryFrame, 0, D3D11_MAP_WRITE_DISCARD, 0, &MappedResource);
	auto pCB = reinterpret_cast<CBChangesEveryFrame*>(MappedResource.pData);
	DirectX::XMStoreFloat4x4(&pCB->mWorldViewProj, DirectX::XMMatrixTranspose(mWorldViewProjection));
	DirectX::XMStoreFloat4x4(&pCB->mWorld, DirectX::XMMatrixTranspose(mWorldViewProjection));
	pCB->vMeshColor = g_vMeshColor;
	pd3dImmediateContext->Unmap(g_pCBChangesEveryFrame, 0);

	// render the cube
	pd3dImmediateContext->VSSetShader(g_pVertexShader, nullptr, 0);
	pd3dImmediateContext->VSSetConstantBuffers(0, 1, &g_pCBChangesEveryFrame);
	pd3dImmediateContext->PSSetShader(g_pPixelShader, nullptr, 0);
	pd3dImmediateContext->PSSetConstantBuffers(0, 1, &g_pCBChangesEveryFrame);
	pd3dImmediateContext->PSSetShaderResources(0, 1, &g_pTextureRV);
	pd3dImmediateContext->PSSetSamplers(0, 1, &g_pSamplerLinear);
	pd3dImmediateContext->DrawIndexed(36, 0, 0);
};

LPDXUTCALLBACKD3D11SWAPCHAINRELEASING OnD3D11ReleasingSwapChain = [](_In_opt_ void* pUserContext)
{
	// do nothing
};

LPDXUTCALLBACKD3D11DEVICEDESTROYED OnD3D11DestroyDevice = [](_In_opt_ void* pUserContext)
{
	SAFE_RELEASE(g_pVertexShader);
	SAFE_RELEASE(g_pVertexBuffer);
	SAFE_RELEASE(g_pVertexLayout);
	SAFE_RELEASE(g_pIndexBuffer);
	SAFE_RELEASE(g_pTextureRV);
	SAFE_RELEASE(g_pPixelShader);
	SAFE_RELEASE(g_pCBChangesEveryFrame);
	SAFE_RELEASE(g_pSamplerLinear);
};

int WINAPI wWinMain(_In_ HINSTANCE hInstance,
	_In_opt_ HINSTANCE hPrevInstance,
	_In_ LPWSTR lpCmdLine,
	_In_ int nCmdSHow)
{
	// enable runtime memory leak check for debug build
#ifdef _DEBUG
	_CrtSetDbgFlag(_CRTDBG_ALLOC_MEM_DF | _CRTDBG_LEAK_CHECK_DF);
#endif

	// dxut will create and use the best device depending on following callbacks

	// set general dxut callbacks
	DXUTSetCallbackFrameMove(OnFrameMove);
	DXUTSetCallbackKeyboard(OnKeyboard);
	DXUTSetCallbackMsgProc(MsgProc);
	DXUTSetCallbackDeviceChanging(ModifyDeviceSettings);
	DXUTSetCallbackDeviceRemoved(OnDeivceRemoved);

	// set d3d11 dxut callbacks, remove these sets if the app does not support d3d11
	DXUTSetCallbackD3D11DeviceAcceptable(IsD3D11DeviceAcceptable);
	DXUTSetCallbackD3D11DeviceCreated(OnD3D11CreateDevice);
	DXUTSetCallbackD3D11SwapChainResized(OnD3D11ResizedSwapChain);
	DXUTSetCallbackD3D11FrameRender(OnD3D11FrameRender);
	DXUTSetCallbackD3D11SwapChainReleasing(OnD3D11ReleasingSwapChain);
	DXUTSetCallbackD3D11DeviceDestroyed(OnD3D11DestroyDevice);

	// perform app initialization here
	DXUTInit(); // parse cmd args, show msgbox on error, no extra args
	DXUTSetCursorSettings(); // hide the cursor

	DXUTCreateDevice(D3D_FEATURE_LEVEL_10_0, true, 800, 600); // require 10-level hardware or later
	DXUTMainLoop();

	// perform app cleanup here

	return DXUTGetExitCode();
}
