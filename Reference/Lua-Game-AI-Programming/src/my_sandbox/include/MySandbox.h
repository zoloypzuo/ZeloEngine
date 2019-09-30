#include "demo_framework/include\SandboxApplication.h"

class MySandbox :public SandboxApplication{
public:
	MySandbox();
	virtual ~MySandbox();
	// 重载以加载lua脚本
	virtual void Initialize();
	// 重载Update和CleanUp等函数，必须先调用基类实现
};