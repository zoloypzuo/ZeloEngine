/**
 * Copyright (c) 2013 David Young dayoung@goliathdesigns.com
 *
 * This software is provided 'as-is', without any express or implied
 * warranty. In no event will the authors be held liable for any damages
 * arising from the use of this software.
 *
 * Permission is granted to anyone to use this software for any purpose,
 * including commercial applications, and to alter it and redistribute it
 * freely, subject to the following restrictions:
 *
 *  1. The origin of this software must not be misrepresented; you must not
 *  claim that you wrote the original software. If you use this software
 *  in a product, an acknowledgment in the product documentation would be
 *  appreciated but is not required.
 *
 *  2. Altered source versions must be plainly marked as such, and must not be
 *  misrepresented as being the original software.
 *
 *  3. This notice may not be removed or altered from any source
 *  distribution.
 */

#include "PrecompiledHeaders.h"

#include "BaseApplication.h"
#include "DebugDrawer.h"
#include "ObfuscatedZip.h"

BaseApplication::BaseApplication(const Ogre::String& applicationTitle)
	: debugDrawer_(nullptr),
	  applicationTitle_(applicationTitle),
	  root_(nullptr),
	  camera_(nullptr),
	  sceneManager_(nullptr),
	  renderWindow_(nullptr),
	  resourceConfig_(Ogre::StringUtil::BLANK),
	  shutdown_(false),
	  cameraMan_(nullptr),
	  inputManager_(nullptr),
	  mouse_(nullptr),
	  keyboard_(nullptr)
{
}

BaseApplication::~BaseApplication()
{
	delete debugDrawer_;

	if (cameraMan_)
	{
		delete cameraMan_;
	}

	//Remove ourself as a Window listener
	Ogre::WindowEventUtilities::removeWindowEventListener(renderWindow_, this);

	windowClosed(renderWindow_);

	delete root_;

	if (obfuscatedZipFactory_ != nullptr)
	{
		delete obfuscatedZipFactory_;
		obfuscatedZipFactory_ = nullptr;
	}
}

// 创建通用场景和debug gizmoz drawer
void BaseApplication::ChooseSceneManager()
{
	// The sandbox is only built with the generic scene manager.
	sceneManager_ = root_->createSceneManager(Ogre::ST_EXTERIOR_CLOSE);

	debugDrawer_ = new DebugDrawer(sceneManager_, 0.5f);
}

// do nothing here
void BaseApplication::Cleanup()
{
}

bool BaseApplication::Configure()
{
	// Show the configuration dialog and initialise the system
	// You can skip this and use root.restoreConfig() to load configuration
	// settings if you were sure there are valid ones saved in ogre.cfg
	if (root_->restoreConfig() || root_->showConfigDialog())
	{
		// If returned true, user clicked OK so initialise
		// Here we choose to let the system create a default rendering window by passing 'true'
		renderWindow_ = root_->initialise(true, applicationTitle_);

		return true;
	}
	else
	{
		return false;
	}
}

// 创建主相机
void BaseApplication::CreateCamera()
{
	camera_ = sceneManager_->createCamera("PlayerCamera");

	camera_->setPosition(Ogre::Vector3(0, 1.0f, 0));

	// Look back along -Z
	camera_->lookAt(Ogre::Vector3(0, 0, -1.0f));
	camera_->setNearClipDistance(0.001f);

	camera_->setAutoAspectRatio(true);

	cameraMan_ = new OgreBites::SdkCameraMan(camera_);
	cameraMan_->setTopSpeed(5.0f);
}

// 创建IOS输入管理
void BaseApplication::CreateFrameListener()
{
	// log
	Ogre::LogManager::getSingletonPtr()->logMessage("*** Initializing OIS ***");
	OIS::ParamList pl;
	size_t windowHnd = 0;
	std::ostringstream windowHndStr;

	renderWindow_->getCustomAttribute("WINDOW", &windowHnd);
	windowHndStr << windowHnd;
	pl.insert(std::make_pair(std::string("WINDOW"), windowHndStr.str()));
#if defined OIS_WIN32_PLATFORM
	pl.insert(std::make_pair(std::string("w32_mouse"), std::string("DISCL_FOREGROUND")));
	pl.insert(std::make_pair(std::string("w32_mouse"), std::string("DISCL_NONEXCLUSIVE")));
	pl.insert(std::make_pair(std::string("w32_keyboard"), std::string("DISCL_FOREGROUND")));
	pl.insert(std::make_pair(std::string("w32_keyboard"), std::string("DISCL_NONEXCLUSIVE")));
#elif defined OIS_LINUX_PLATFORM
    pl.insert(std::make_pair(std::string("x11_mouse_grab"), std::string("false")));
    pl.insert(std::make_pair(std::string("x11_mouse_hide"), std::string("false")));
    pl.insert(std::make_pair(std::string("x11_keyboard_grab"), std::string("false")));
    pl.insert(std::make_pair(std::string("XAutoRepeatOn"), std::string("true")));
#endif

	inputManager_ = OIS::InputManager::createInputSystem(pl);

	keyboard_ = static_cast<OIS::Keyboard*>(
		inputManager_->createInputObject(OIS::OISKeyboard, true));
	mouse_ = static_cast<OIS::Mouse*>(
		inputManager_->createInputObject(OIS::OISMouse, true));

	mouse_->setEventCallback(this);
	keyboard_->setEventCallback(this);

	//Set initial mouse clipping size
	windowResized(renderWindow_);

	//Register as a Window listener
	Ogre::WindowEventUtilities::addWindowEventListener(renderWindow_, this);

	root_->addFrameListener(this);
}

void BaseApplication::CreateResourceListener()
{
}

// 根据相机创建视口
void BaseApplication::CreateViewports() const
{
	// Create one viewport, entire window
	Ogre::Viewport* vp = renderWindow_->addViewport(camera_);
	vp->setBackgroundColour(Ogre::ColourValue(0.0f, 0.0f, 0.0f));

	// Alter the camera aspect ratio to match the viewport
	camera_->setAspectRatio(
		Ogre::Real(vp->getActualWidth()) / Ogre::Real(vp->getActualHeight()));
}

void BaseApplication::Draw()
{
}

bool BaseApplication::frameEnded(const Ogre::FrameEvent& event)
{
	(void)event;

	return true;
}

bool BaseApplication::frameRenderingQueued(const Ogre::FrameEvent& event)
{
	if (shutdown_ || renderWindow_->isClosed())
		return false;

	//Need to capture/update each device
	keyboard_->capture();
	mouse_->capture();

	Update();

	cameraMan_->frameRenderingQueued(event);

	return true;
}

bool BaseApplication::frameStarted(const Ogre::FrameEvent& event)
{
	(void)event;

	Draw();

	return true;
}

Ogre::Camera* BaseApplication::GetCamera() const
{
	return camera_;
}

Ogre::RenderWindow* BaseApplication::GetRenderWindow() const
{
	return renderWindow_;
}

Ogre::SceneManager* BaseApplication::GetSceneManager() const
{
	return sceneManager_;
}

void BaseApplication::HandleKeyPress(
	const OIS::KeyCode keycode, unsigned int key)
{
	(void)keycode;
	(void)key;
}

void BaseApplication::HandleKeyRelease(
	const OIS::KeyCode keycode, unsigned int key)
{
	(void)keycode;
	(void)key;
}

void BaseApplication::HandleMouseMove(const int width, const int height)
{
	(void)width;
	(void)height;
}

void BaseApplication::HandleMousePress(
	const int width, const int height, const OIS::MouseButtonID button)
{
	(void)width;
	(void)height;
	(void)button;
}

void BaseApplication::HandleMouseRelease(
	const int width, const int height, const OIS::MouseButtonID button)
{
	(void)width;
	(void)height;
	(void)button;
}

void BaseApplication::Initialize()
{
}

bool BaseApplication::keyPressed(const OIS::KeyEvent& event)
{
	if (event.key == OIS::KC_R) // cycle polygon rendering mode
	{
		Ogre::String newVal;
		Ogre::PolygonMode pm;

		switch (camera_->getPolygonMode())
		{
		case Ogre::PM_SOLID:
			newVal = "Wireframe";
			pm = Ogre::PM_WIREFRAME;
			break;
		case Ogre::PM_WIREFRAME:
			newVal = "Points";
			pm = Ogre::PM_POINTS;
			break;
		default:
			newVal = "Solid";
			pm = Ogre::PM_SOLID;
		}

		camera_->setPolygonMode(pm);
	}
	else if (event.key == OIS::KC_F12) // refresh all textures
	{
		Ogre::TextureManager::getSingleton().reloadAll();
	}
	else if (event.key == OIS::KC_SYSRQ) // take a screenshot
	{
		renderWindow_->writeContentsToTimestampedFile("screenshot", ".bmp");
	}
	else if (event.key == OIS::KC_ESCAPE)
	{
		shutdown_ = true;
	}

	cameraMan_->injectKeyDown(event);

	HandleKeyPress(event.key, event.text);
	return true;
}

bool BaseApplication::keyReleased(const OIS::KeyEvent& event)
{
	cameraMan_->injectKeyUp(event);

	HandleKeyRelease(event.key, event.text);
	return true;
}

void BaseApplication::LoadResources(void)
{
	Ogre::ResourceGroupManager::getSingleton().initialiseAllResourceGroups();
}

bool BaseApplication::mouseMoved(const OIS::MouseEvent& event)
{
	if (event.state.buttonDown(OIS::MB_Right))
	{
		cameraMan_->injectMouseMove(event);
	}

	GetRenderWindow()->setActive(true);

	HandleMouseMove(event.state.width, event.state.height);
	return true;
}

bool BaseApplication::mousePressed(
	const OIS::MouseEvent& event, OIS::MouseButtonID id)
{
	cameraMan_->injectMouseDown(event, id);

	if (id == OIS::MB_Right)
	{
		const OIS::MouseState& ms = mouse_->getMouseState();
		(void)ms;
	}

	HandleMousePress(event.state.width, event.state.height, id);
	return true;
}

bool BaseApplication::mouseReleased(
	const OIS::MouseEvent& event, OIS::MouseButtonID id)
{
	cameraMan_->injectMouseUp(event, id);

	HandleMouseRelease(event.state.width, event.state.height, id);
	return true;
}

void BaseApplication::Run()
{
#ifdef _DEBUG
	resourceConfig_ = APPLICATION_RESOURCES_DEBUG;
#else
    resourceConfig_ = APPLICATION_RESOURCES_RELEASE;
#endif

	if (!Setup())
	{
		return;
	}

	root_->startRendering();

	Cleanup();
}

void BaseApplication::SetShutdown(const bool shutdown)
{
	shutdown_ = shutdown;
}

bool BaseApplication::Setup(void)
{
#ifdef _DEBUG
	root_ = new Ogre::Root("", APPLICATION_CONFIG_DEBUG, APPLICATION_LOG_DEBUG);
#else
    root_ = new Ogre::Root("", APPLICATION_CONFIG_RELEASE, APPLICATION_LOG_RELEASE);
#endif
	root_->installPlugin(new Ogre::D3D9Plugin());
	root_->installPlugin(new Ogre::ParticleFXPlugin());

	obfuscatedZipFactory_ = new ObfuscatedZipFactory();
	Ogre::ArchiveManager::getSingleton().addArchiveFactory(obfuscatedZipFactory_);

	SetupResources();

	bool carryOn = Configure();
	if (!carryOn)
	{
		return false;
	}

	ChooseSceneManager();
	CreateCamera();
	CreateViewports();

	// Set default mipmap level (NB some APIs ignore this)（设置默认mipmap数量）
	Ogre::TextureManager::getSingleton().setDefaultNumMipmaps(5);

	// Create any resource listeners (for loading screens)（创建资源监听）
	// do nothing here（目前啥也不做）
	CreateResourceListener();

	// Load resources
	// load ogre resource
	LoadResources();

	// do nothing here
	Initialize();

	CreateFrameListener();

	return true;
}

void BaseApplication::SetupResources() const
{
	// Load resource paths from config file
	Ogre::ConfigFile cf;
	cf.load(resourceConfig_);

	// Go through all sections & settings in the file
	Ogre::ConfigFile::SectionIterator seci = cf.getSectionIterator();

	Ogre::String secName, typeName, archName;
	while (seci.hasMoreElements())
	{
		secName = seci.peekNextKey();
		Ogre::ConfigFile::SettingsMultiMap* settings = seci.getNext();
		Ogre::ConfigFile::SettingsMultiMap::iterator i;
		for (i = settings->begin(); i != settings->end(); ++i)
		{
			typeName = i->first;
			archName = i->second;
			Ogre::ResourceGroupManager::getSingleton().addResourceLocation(
				archName, typeName, secName, true);
		}
	}
}

void BaseApplication::Update()
{
}

void BaseApplication::windowResized(Ogre::RenderWindow* renderWindow)
{
	unsigned int width, height, depth;
	int left, top;
	renderWindow->getMetrics(width, height, depth, left, top);

	const OIS::MouseState& ms = mouse_->getMouseState();
	ms.width = width;
	ms.height = height;
}

void BaseApplication::windowClosed(Ogre::RenderWindow* renderWindow)
{
	//Only close for window that created OIS (the main window in these demos)
	if (renderWindow == renderWindow_)
	{
		if (inputManager_)
		{
			inputManager_->destroyInputObject(mouse_);
			inputManager_->destroyInputObject(keyboard_);

			OIS::InputManager::destroyInputSystem(inputManager_);
			inputManager_ = nullptr;
		}
	}
}
