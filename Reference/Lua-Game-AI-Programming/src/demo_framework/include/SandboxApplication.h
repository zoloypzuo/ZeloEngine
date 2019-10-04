#ifndef DEMO_FRAMEWORK_SANDBOX_APPLICATION_H
#define DEMO_FRAMEWORK_SANDBOX_APPLICATION_H

#include "demo_framework/include/BaseApplication.h"
#include "ogre3d/include/OgreTimer.h"

class LuaFileManager;
class Sandbox;

class SandboxApplication : public BaseApplication
{
public:
	SandboxApplication(const Ogre::String& applicationTitle);

	virtual ~SandboxApplication();

	static void AddResourceLocation(const Ogre::String& location);

	void Cleanup() override;

	virtual void CreateSandbox(const Ogre::String& sandboxLuaScript);

	void Draw() override;

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
