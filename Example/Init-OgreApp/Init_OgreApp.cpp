// Init_OgreApp.cpp
// created on 2019/10/9
// author @zoloypzuo

#include "Init_OgreApp.h"

bool Init_OgreApp::frameStarted(const Ogre::FrameEvent& evt)
{
	return false;
}

bool Init_OgreApp::frameRenderingQueued(const Ogre::FrameEvent& evt)
{
	return false;
}

bool Init_OgreApp::frameEnded(const Ogre::FrameEvent& evt)
{
	return false;
}

void Init_OgreApp::setup()
{
	// do not forget to call the base first
	OgreBites::ApplicationContext::setup();

	// register for input events
	addInputListener(this);
	// get a pointer to the already created root
	Ogre::Root* root = getRoot();
	Ogre::SceneManager* scnMgr = root->createSceneManager();
	// register our scene with the RTSS
	Ogre::RTShader::ShaderGenerator* shadergen = Ogre::RTShader::ShaderGenerator::getSingletonPtr();
	shadergen->addSceneManager(scnMgr);
	// without light we would just get a black screen    
	Ogre::Light* light = scnMgr->createLight("MainLight");
	Ogre::SceneNode* lightNode = scnMgr->getRootSceneNode()->createChildSceneNode();
	lightNode->setPosition(0, 10, 15);
	lightNode->attachObject(light);
	// also need to tell where we are
	Ogre::SceneNode* camNode = scnMgr->getRootSceneNode()->createChildSceneNode();
	camNode->setPosition(0, 0, 15);
	camNode->lookAt(Ogre::Vector3(0, 0, -1), Ogre::Node::TS_PARENT);
	// create the camera
	Ogre::Camera* cam = scnMgr->createCamera("myCam");
	cam->setNearClipDistance(5); // specific to this sample
	cam->setAutoAspectRatio(true);
	camNode->attachObject(cam);
	// and tell it to render into the main window
	getRenderWindow()->addViewport(cam);
	// finally something to render
	Ogre::Entity* ent = scnMgr->createEntity("Sinbad.mesh");
	Ogre::SceneNode* node = scnMgr->getRootSceneNode()->createChildSceneNode();
	node->attachObject(ent);
}

void Init_OgreApp::createRoot()
{
}

bool Init_OgreApp::oneTimeConfig()
{
	return false;
}

void Init_OgreApp::loadResources()
{
}

void Init_OgreApp::locateResources()
{
}

void Init_OgreApp::shutdown()
{
}

void Init_OgreApp::pollEvents()
{
}

Init_OgreApp::~Init_OgreApp()
{
}

void Init_OgreApp::frameRendered(const Ogre::FrameEvent& evt)
{
}

bool Init_OgreApp::keyPressed(const OgreBites::KeyboardEvent& evt)
{
	return false;

}

bool Init_OgreApp::keyReleased(const OgreBites::KeyboardEvent& evt)
{
	return false;

}

bool Init_OgreApp::touchMoved(const OgreBites::TouchFingerEvent& evt)
{
	return false;

}

bool Init_OgreApp::touchPressed(const OgreBites::TouchFingerEvent& evt)
{
	return false;

}

bool Init_OgreApp::touchReleased(const OgreBites::TouchFingerEvent& evt)
{
	return false;

}

bool Init_OgreApp::mouseMoved(const OgreBites::MouseMotionEvent& evt)
{
	return false;

}

bool Init_OgreApp::mouseWheelRolled(const OgreBites::MouseWheelEvent& evt)
{
	return false;

}

bool Init_OgreApp::mousePressed(const OgreBites::MouseButtonEvent& evt)
{
	return false;

}

bool Init_OgreApp::mouseReleased(const OgreBites::MouseButtonEvent& evt)
{
	return false;
}

void Init_OgreApp::windowMoved(Ogre::RenderWindow* rw)
{
}

void Init_OgreApp::windowResized(Ogre::RenderWindow* rw)
{
}

bool Init_OgreApp::windowClosing(Ogre::RenderWindow* rw)
{
	return false;
}

void Init_OgreApp::windowClosed(Ogre::RenderWindow* rw)
{
}

void Init_OgreApp::windowFocusChange(Ogre::RenderWindow* rw)
{
}

void Init_OgreApp::reconfigure(const Ogre::String& renderer, Ogre::NameValuePairList& options)
{
}

void Init_OgreApp::setWindowGrab(OgreBites::NativeWindowType* win, bool grab)
{
}

void Init_OgreApp::addInputListener(OgreBites::NativeWindowType* win, InputListener* lis)
{
}

void Init_OgreApp::removeInputListener(OgreBites::NativeWindowType* win, InputListener* lis)
{
}

OgreBites::NativeWindowPair Init_OgreApp::createWindow(const Ogre::String& name, uint32_t w, uint32_t h,
	Ogre::NameValuePairList miscParams)
{
	return {};
}

int main(size_t argc, char** argv)
{
	Init_OgreApp app;
	return 0;
}
