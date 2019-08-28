// Demo1_Box.h
// created on 2019/8/27
// author @zoloypzuo

#ifndef ZELOENGINE_DEMO1_BOX_H
#define ZELOENGINE_DEMO1_BOX_H

class Demo1_Box :public D3DApp
{
public:
	Demo1_Box(
		HINSTANCE hInstance,
		HINSTANCE hPrevInstance,
		LPWSTR lpCmdLine,
		int nShowCmd);
	~Demo1_Box() override;
	int Initialize() override;
	void Finalize() override;
	int Run() override;
	LRESULT __stdcall MsgProc(HWND hWnd, UINT message, WPARAM wParam, LPARAM lParam) override;
	void Update(float dt) override;
	void Render()override;

private:
	void BuildGeometryBuffers();
	void BuildFx();
	void BuildVertexLayout();

private:
	ID3D11Buffer* m_boxVB;
	ID3D11Buffer* m_boxIB;
	
	//ID3DX11Effect* mFx;
	//ID3DX11EffectTechnique* m_tech;

	ID3D11InputLayout* m_inputLayout;

	XMFLOAT4X4 m_world;
	XMFLOAT4X4 m_view;
	XMFLOAT4X4 m_proj;

	float m_theta;
	float m_phi;
	float m_radius;

	POINT m_lastMousePos;
};

#endif //ZELOENGINE_DEMO1_BOX_H
