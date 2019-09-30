#ifndef DEMO_FRAMEWORK_SANDBOX_APPLICATION_H
#define DEMO_FRAMEWORK_SANDBOX_APPLICATION_H

#include "demo_framework/include/BaseApplication.h"
#include "ogre3d/include/OgreString.h"
#include "ogre3d/include/OgreTimer.h"

class LuaFileManager;
class Sandbox;

class SandboxApplication : public BaseApplication
{
public:
    SandboxApplication(const Ogre::String& applicationTitle);

    virtual ~SandboxApplication();

    void AddResourceLocation(const Ogre::String& location);

    virtual void Cleanup();

    virtual void CreateSandbox(const Ogre::String& sandboxLuaScript);

    virtual void Draw();

    int GenerateSandboxId();

    virtual Sandbox* GetSandbox();

    virtual void HandleKeyPress(const OIS::KeyCode keycode, unsigned int key);

    virtual void HandleKeyRelease(
        const OIS::KeyCode keycode, unsigned int key);

    virtual void HandleMouseMove(const int width, const int height);

    virtual void HandleMousePress(
        const int width, const int height, const OIS::MouseButtonID button);

    virtual void HandleMouseRelease(
        const int width, const int height, const OIS::MouseButtonID button);

    virtual void Initialize();

    virtual void Update();

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
