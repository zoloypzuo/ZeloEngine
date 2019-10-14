#include "PrecompiledHeaders.h"

#include "demo_framework/include/LuaFile.h"
#include "demo_framework/include/LuaFilePtr.h"

LuaFilePtr::LuaFilePtr()
	: Ogre::SharedPtr<LuaFile>()
{
}

LuaFilePtr::LuaFilePtr(LuaFile* const resource)
	: Ogre::SharedPtr<LuaFile>(resource)
{
}

LuaFilePtr::LuaFilePtr(const LuaFilePtr& resource)
	: Ogre::SharedPtr<LuaFile>(resource)
{
}

LuaFilePtr::LuaFilePtr(const Ogre::ResourcePtr& resource)
{
	if (resource.isNull())
	{
		return;
	}

	// lock & copy other mutex pointer
	OGRE_LOCK_MUTEX(*resource.OGRE_AUTO_MUTEX_NAME)
	OGRE_COPY_AUTO_SHARED_MUTEX(resource.OGRE_AUTO_MUTEX_NAME)

	pRep = static_cast<LuaFile*>(resource.getPointer());
	pInfo = resource.getPtrInfo();

	if (pInfo)
	{
		++pInfo->useCount;
	}
}

LuaFilePtr& LuaFilePtr::operator=(const Ogre::ResourcePtr& resource)
{
	if (pRep == static_cast<LuaFile*>(resource.getPointer()))
		return *this;

	release();

	if (resource.isNull())
	{
		// resource ptr is null, so the call to release above has done all we
		// need to do.
		return *this;
	}

	// lock & copy other mutex pointer
	OGRE_LOCK_MUTEX(*resource.OGRE_AUTO_MUTEX_NAME)
	OGRE_COPY_AUTO_SHARED_MUTEX(resource.OGRE_AUTO_MUTEX_NAME)
	pRep = static_cast<LuaFile*>(resource.getPointer());
	pInfo = resource.getPtrInfo();

	if (pInfo)
	{
		++pInfo->useCount;
	}

	return *this;
}
