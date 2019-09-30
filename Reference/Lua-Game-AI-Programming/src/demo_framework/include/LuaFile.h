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

#ifndef DEMO_FRAMEWORK_LUA_FILE_H
#define DEMO_FRAMEWORK_LUA_FILE_H

#include "ogre3d/include/OgreResource.h"

class LuaFile : public Ogre::Resource
{
public:
    LuaFile(
        Ogre::ResourceManager* const creator,
        const Ogre::String& resourceName,
        Ogre::ResourceHandle handle,
        const Ogre::String& group,
        const bool isManual = false,
        Ogre::ManualResourceLoader* const loader = NULL);

    virtual ~LuaFile();

    const char* GetData() const;

    size_t GetDataLength() const;

    void SetData(const char* const data, const size_t dataLength);

protected:
    virtual size_t calculateSize() const;

    virtual void loadImpl();

    virtual void unloadImpl();

private:
    const char* binaryData_;
    size_t dataLength_;

    /**
     * Unimplemented copy constructor.
     */
    LuaFile(const LuaFile&);

    /**
     * Unimplemented assignment operator.
     */
    LuaFile& operator=(const LuaFile&);
};  // class LuaFile

#endif  // DEMO_FRAMEWORK_LUA_FILE_H
