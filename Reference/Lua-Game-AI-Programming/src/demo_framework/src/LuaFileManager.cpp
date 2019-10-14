#include "PrecompiledHeaders.h"

#include "demo_framework/include/LuaFile.h"
#include "demo_framework/include/LuaFilePtr.h"
#include "demo_framework/include/LuaFileManager.h"

template <>
LuaFileManager* Ogre::Singleton<LuaFileManager>::msSingleton = nullptr;

LuaFileManager* LuaFileManager::getSingletonPtr()
{
	return msSingleton;
}

LuaFileManager& LuaFileManager::getSingleton()
{
	assert(msSingleton);
	return *msSingleton;
}

LuaFileManager::LuaFileManager()
{
	mResourceType = "LuaFile";

	// low, because it will likely reference other resources（低优先级，因为可能引用其他资源？没把，没道理啊）
	mLoadOrder = 30.0f;

	// 每一种资源都要写一个资源管理器
	// 资源管理要注册到管理器中
	// 注意到RAII，析构时解除注册
	Ogre::ResourceGroupManager::getSingleton()._registerResourceManager(
		mResourceType, this);
}

LuaFileManager::~LuaFileManager()
{
	Ogre::ResourceGroupManager::getSingleton()._unregisterResourceManager(
		mResourceType);
}

LuaFilePtr LuaFileManager::load(
	const Ogre::String& resourceName, const Ogre::String& group)
{
	LuaFilePtr luaFile(getResourceByName(resourceName));

	if (luaFile.isNull())
	{
		Ogre::LogManager::getSingletonPtr()->logMessage(
			"LuaFile: Loading " + resourceName, Ogre::LML_NORMAL);

		luaFile = createResource(resourceName, group);
	}

	luaFile->load();
	return luaFile;
}

Ogre::Resource* LuaFileManager::createImpl(
	const Ogre::String& name,
	Ogre::ResourceHandle handle,
	const Ogre::String& group,
	bool isManual,
	Ogre::ManualResourceLoader* loader,
	const Ogre::NameValuePairList* createParams)
{
	(void)createParams;
	return new LuaFile(this, name, handle, group, isManual, loader);
}
