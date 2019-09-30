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
        const Ogre::String &resourceName, const Ogre::String& group);

    static LuaFileManager& getSingleton();

    static LuaFileManager* getSingletonPtr();

protected:
    // must implement this from ResourceManager's interface
    Ogre::Resource *createImpl(
        const Ogre::String &name,
        Ogre::ResourceHandle handle,
        const Ogre::String &group,
        bool isManual,
        Ogre::ManualResourceLoader *loader,
        const Ogre::NameValuePairList *createParams);

private:
};  // class LuaFileManager

#endif  // DEMO_FRAMEWORK_LUA_FILE_MANAGER_H
