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
};

#endif //ZELOENGINE_DEMO1_BOX_H
