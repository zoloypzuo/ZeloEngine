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

#include "demo_framework/include/LuaFile.h"
#include "demo_framework/include/LuaFilePtr.h"
#include "demo_framework/include/LuaFileManager.h"

template<> LuaFileManager *Ogre::Singleton<LuaFileManager>::msSingleton = 0;

LuaFileManager* LuaFileManager::getSingletonPtr()
{
    return msSingleton;
}

LuaFileManager& LuaFileManager::getSingleton()
{
    assert(msSingleton);
    return(*msSingleton);
}

LuaFileManager::LuaFileManager()
{
    mResourceType = "LuaFile";

    // low, because it will likely reference other resources
    mLoadOrder = 30.0f;

    Ogre::ResourceGroupManager::getSingleton()._registerResourceManager(
        mResourceType, this);
}

LuaFileManager::~LuaFileManager()
{
    Ogre::ResourceGroupManager::getSingleton()._unregisterResourceManager(
        mResourceType);
}

LuaFilePtr LuaFileManager::load(
    const Ogre::String &resourceName, const Ogre::String &group)
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

Ogre::Resource *LuaFileManager::createImpl(
    const Ogre::String &name,
    Ogre::ResourceHandle handle,
    const Ogre::String &group,
    bool isManual,
    Ogre::ManualResourceLoader *loader,
    const Ogre::NameValuePairList *createParams)
{
    (void)createParams;
    return new LuaFile(this, name, handle, group, isManual, loader);
}