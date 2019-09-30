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

#ifndef DEMO_FRAMEWORK_LUA_FILE_SERIALIZER_H
#define DEMO_FRAMEWORK_LUA_FILE_SERIALIZER_H

#include "ogre3d/include/OgreSerializer.h"

class LuaFile;

class LuaFileSerializer : public Ogre::Serializer
{
public:
    LuaFileSerializer();

    virtual ~LuaFileSerializer();

    void ImportLuaFile(Ogre::DataStreamPtr& stream, LuaFile* const luaFile);

private:
    LuaFileSerializer(const LuaFileSerializer&);

    LuaFileSerializer& operator=(const LuaFileSerializer&);
};  // class LuaFileSerializer

#endif  // DEMO_FRAMEWORK_LUA_FILE_SERIALIZER_H
