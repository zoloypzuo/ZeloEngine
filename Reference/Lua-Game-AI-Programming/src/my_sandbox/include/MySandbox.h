#include "demo_framework/include\SandboxApplication.h"

class MySandbox :public SandboxApplication{
public:
	MySandbox();
	virtual ~MySandbox();
	// �����Լ���lua�ű�
	virtual void Initialize();
	// ����Update��CleanUp�Ⱥ����������ȵ��û���ʵ��
};