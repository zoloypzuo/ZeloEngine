#ifndef DEMO_FRAMEWORK_BASE_APPLICATION_H
#define DEMO_FRAMEWORK_BASE_APPLICATION_H

#include <OGRE/OgreFrameListener.h>
#include <OGRE/Bites/OgreWindowEventUtilities.h>

#include <ois/OISKeyboard.h>
#include <ois/OISMouse.h>

class DebugDrawer;
class ObfuscatedZipFactory;

namespace Ogre
{
	class Camera;
	class RenderWindow;
	class Root;
	class SceneManager;
}

namespace OgreBites
{
	class SdkCameraMan;
}

namespace OIS
{
	class InputManager;
}

#define APPLICATION_LOG_DEBUG           "Sandbox_d.log"
#define APPLICATION_LOG_RELEASE         "Sandbox.log"
#define APPLICATION_CONFIG_DEBUG        "Sandbox_d.cfg"
#define APPLICATION_CONFIG_RELEASE      "Sandbox.cfg"
#define APPLICATION_RESOURCES_DEBUG     "SandboxResources_d.cfg"
#define APPLICATION_RESOURCES_RELEASE   "SandboxResources.cfg"

// 虚函数
// 继承了Ogre和OIS各两个类，把虚函数private地override了
// 初始化和关闭：Initialize和Cleanup
// 绘制和更新：Draw和Update
// 输入回调：HandleKeyRelease，HandleKeyRelease，HandleMouseMove，HandleMousePress，HandleMouseRelease
//
// 非虚函数
// SetShutdown
// GetCamera
// GetSceneManager
// GetRenderWindow
// Run
class BaseApplication :
	public Ogre::FrameListener,
	public Ogre::WindowEventListener,
	public OIS::KeyListener,
	public OIS::MouseListener
{
public:
	BaseApplication(const Ogre::String& applicationTitle = "");

	virtual ~BaseApplication();

	virtual void Cleanup();

	virtual void Draw();

	Ogre::Camera* GetCamera() const;

	Ogre::SceneManager* GetSceneManager() const;

	Ogre::RenderWindow* GetRenderWindow() const;

	virtual void HandleKeyPress(OIS::KeyCode keycode, unsigned int key);

	virtual void HandleKeyRelease(
		OIS::KeyCode keycode, unsigned int key);

	virtual void HandleMouseMove(int width, int height);

	virtual void HandleMousePress(
		int width, int height, OIS::MouseButtonID button);

	virtual void HandleMouseRelease(
		int width, int height, OIS::MouseButtonID button);

	virtual void Initialize();

	void Run();

	void SetShutdown(bool shutdown);

	virtual void Update();

private:
	DebugDrawer* debugDrawer_;
	ObfuscatedZipFactory* obfuscatedZipFactory_;

	Ogre::String applicationTitle_;
	Ogre::Root* root_;
	Ogre::Camera* camera_;
	Ogre::SceneManager* sceneManager_;
	Ogre::RenderWindow* renderWindow_;
	Ogre::String resourceConfig_;
	bool shutdown_;

	void ChooseSceneManager();
	bool Configure();
	void CreateCamera();
	void CreateFrameListener();
	static void CreateResourceListener();
	void CreateViewports() const;
	static void LoadResources();
	bool Setup();
	// 读取Resource.cfg，遍历加载资源map
	void SetupResources() const;
#pragma region override
	// Ogre::FrameListener
	bool frameEnded(const Ogre::FrameEvent& event) override;
	bool frameRenderingQueued(const Ogre::FrameEvent& event) override;
	bool frameStarted(const Ogre::FrameEvent& event) override;

	// OIS::KeyListener
	bool keyPressed(const OIS::KeyEvent& event) override;
	bool keyReleased(const OIS::KeyEvent& event) override;

	// OIS::MouseListener
	bool mouseMoved(const OIS::MouseEvent& event) override;
	bool mousePressed(
		const OIS::MouseEvent& event, OIS::MouseButtonID id) override;
	bool mouseReleased(
		const OIS::MouseEvent& event, OIS::MouseButtonID id) override;

	// Ogre::WindowEventListener
	void windowResized(Ogre::RenderWindow* renderWindow) override;
	void windowClosed(Ogre::RenderWindow* renderWindow) override;
#pragma endregion

	// OgreBites
	OgreBites::SdkCameraMan* cameraMan_; // basic camera controller

	//OIS Input devices
	OIS::InputManager* inputManager_;
	OIS::Mouse* mouse_;
	OIS::Keyboard* keyboard_;
}; // class BaseApplication

#endif  // DEMO_FRAMEWORK_BASE_APPLICATION_H
