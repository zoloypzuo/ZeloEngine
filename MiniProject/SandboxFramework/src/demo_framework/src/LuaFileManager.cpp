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

	// low, because it will likely reference other resources�������ȼ�����Ϊ��������������Դ��û�ѣ�û������
	mLoadOrder = 30.0f;

	// ÿһ����Դ��Ҫдһ����Դ������
	// ��Դ����Ҫע�ᵽ��������
	// ע�⵽RAII������ʱ���ע��
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
