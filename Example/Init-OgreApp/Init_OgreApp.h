// Init_OgreApp.h
// created on 2019/10/9
// author @zoloypzuo

#ifndef ZELOENGINE_INIT_OGREAPP_H
#define ZELOENGINE_INIT_OGREAPP_H

#include "Bites/OgreApplicationContext.h"

class Init_OgreApp :OgreBites::ApplicationContext, public OgreBites::InputListener
{
public:
	Init_OgreApp():OgreBites::ApplicationContext()
	{
		
	}
	bool frameStarted(const Ogre::FrameEvent& evt) override;
	bool frameRenderingQueued(const Ogre::FrameEvent& evt) override;
	bool frameEnded(const Ogre::FrameEvent& evt) override;
	void setup() override;
	void createRoot() override;
	bool oneTimeConfig() override;
	void loadResources() override;
	void locateResources() override;
	void shutdown() override;
	void pollEvents() override;
	~Init_OgreApp() override;
	void frameRendered(const Ogre::FrameEvent& evt) override;
	bool keyPressed(const OgreBites::KeyboardEvent& evt) override;
	bool keyReleased(const OgreBites::KeyboardEvent& evt) override;
	bool touchMoved(const OgreBites::TouchFingerEvent& evt) override;
	bool touchPressed(const OgreBites::TouchFingerEvent& evt) override;
	bool touchReleased(const OgreBites::TouchFingerEvent& evt) override;
	bool mouseMoved(const OgreBites::MouseMotionEvent& evt) override;
	bool mouseWheelRolled(const OgreBites::MouseWheelEvent& evt) override;
	bool mousePressed(const OgreBites::MouseButtonEvent& evt) override;
	bool mouseReleased(const OgreBites::MouseButtonEvent& evt) override;
	void windowMoved(Ogre::RenderWindow* rw) override;
	void windowResized(Ogre::RenderWindow* rw) override;
	bool windowClosing(Ogre::RenderWindow* rw) override;
	void windowClosed(Ogre::RenderWindow* rw) override;
	void windowFocusChange(Ogre::RenderWindow* rw) override;
	void reconfigure(const Ogre::String& renderer, Ogre::NameValuePairList& options) override;
	void setWindowGrab(OgreBites::NativeWindowType* win, bool grab) override;
	void addInputListener(OgreBites::NativeWindowType* win, InputListener* lis) override;
	void removeInputListener(OgreBites::NativeWindowType* win, InputListener* lis) override;
	OgreBites::NativeWindowPair createWindow(const Ogre::String& name, uint32_t w, uint32_t h,
		Ogre::NameValuePairList miscParams) override;
};


#endif //ZELOENGINE_INIT_OGREAPP_H