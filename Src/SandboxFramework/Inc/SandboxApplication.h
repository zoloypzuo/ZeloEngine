#ifndef DEMO_FRAMEWORK_SANDBOX_APPLICATION_H
#define DEMO_FRAMEWORK_SANDBOX_APPLICATION_H

#include "BaseApplication.h"
#include <OGRE/OgreTimer.h>

class LuaFileManager;
class Sandbox;

// 虚函数
// GetSandbox
// CreateSandbox
//
// 非虚函数
// GenerateSandboxId
// AddResourceLocation（静态）
class SandboxApplication : public BaseApplication
{
public:
	SandboxApplication(const Ogre::String& applicationTitle);

	virtual ~SandboxApplication();

	// ogre添加资源搜索路径
	static void AddResourceLocation(const Ogre::String& location);

	void Cleanup() override;

	virtual void CreateSandbox(const Ogre::String& sandboxLuaScript);

	void Draw() override;

	// 使用一个简单的递增id生成
	int GenerateSandboxId();

	virtual Sandbox* GetSandbox();

	void HandleKeyPress(OIS::KeyCode keycode, unsigned int key) override;

	void HandleKeyRelease(
		OIS::KeyCode keycode, unsigned int key) override;

	void HandleMouseMove(int width, int height) override;

	void HandleMousePress(
		int width, int height, OIS::MouseButtonID button) override;

	void HandleMouseRelease(
		int width, int height, OIS::MouseButtonID button) override;

	void Initialize() override;

	void Update() override;

private:
	long long lastUpdateTimeInMicro_;
	long long lastUpdateCallTime_;

	LuaFileManager* luaFileManager_;

	Sandbox* sandbox_;
	Ogre::Timer timer_;

	int lastSandboxId_;

	SandboxApplication(const SandboxApplication&);
	SandboxApplication& operator=(const SandboxApplication&);
};

#endif  // DEMO_FRAMEWORK_SANDBOX_APPLICATION_H
