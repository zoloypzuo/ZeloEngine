#ifndef DEMO_FRAMEWORK_BASE_APPLICATION_H
#define DEMO_FRAMEWORK_BASE_APPLICATION_H

#include "ogre3d/include/OgreFrameListener.h"
#include "ogre3d/include/OgreWindowEventUtilities.h"
#include "ois/include/OISKeyboard.h"
#include "ois/include/OISMouse.h"

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

	// OgreBites
	OgreBites::SdkCameraMan* cameraMan_; // basic camera controller

	//OIS Input devices
	OIS::InputManager* inputManager_;
	OIS::Mouse* mouse_;
	OIS::Keyboard* keyboard_;
}; // class BaseApplication

#endif  // DEMO_FRAMEWORK_BASE_APPLICATION_H
