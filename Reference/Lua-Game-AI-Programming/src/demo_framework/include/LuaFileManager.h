#ifndef DEMO_FRAMEWORK_LUA_FILE_MANAGER_H
#define DEMO_FRAMEWORK_LUA_FILE_MANAGER_H

#include "ogre3d/include/OgreResourceManager.h"
#include "ogre3d/include/OgreSingleton.h"

class LuaFilePtr;

class LuaFileManager
	: public Ogre::ResourceManager,
	  public Ogre::Singleton<LuaFileManager>
{
public:
	LuaFileManager();
	virtual ~LuaFileManager();

	virtual LuaFilePtr load(
		const Ogre::String& resourceName, const Ogre::String& group);

	static LuaFileManager& getSingleton();

	static LuaFileManager* getSingletonPtr();

protected:
	// must implement this from ResourceManager's interface
	Ogre::Resource* createImpl(
		const Ogre::String& name,
		Ogre::ResourceHandle handle,
		const Ogre::String& group,
		bool isManual,
		Ogre::ManualResourceLoader* loader,
		const Ogre::NameValuePairList* createParams) override;

private:
}; // class LuaFileManager

#endif  // DEMO_FRAMEWORK_LUA_FILE_MANAGER_H
