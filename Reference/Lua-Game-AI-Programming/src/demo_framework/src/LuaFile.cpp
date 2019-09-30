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
#include "demo_framework/include/LuaFileSerializer.h"

LuaFile::LuaFile(
    Ogre::ResourceManager* const creator,
    const Ogre::String& resourceName,
    Ogre::ResourceHandle handle,
    const Ogre::String& group,
    const bool isManual,
    Ogre::ManualResourceLoader* const loader)
    : Ogre::Resource(creator, resourceName, handle, group, isManual, loader),
    binaryData_(NULL),
    dataLength_(0)
{
    createParamDictionary("LuaFile");
}

LuaFile::~LuaFile()
{
    unload();
}

size_t LuaFile::calculateSize() const
{
    return dataLength_;
}

const char* LuaFile::GetData() const
{
    return binaryData_;
}

size_t LuaFile::GetDataLength() const
{
    return dataLength_;
}

void LuaFile::loadImpl()
{
    LuaFileSerializer serializer;

    Ogre::DataStreamPtr stream =
        Ogre::ResourceGroupManager::getSingleton().openResource(
            mName, mGroup, true, this);

    serializer.ImportLuaFile(stream, this);
}

void LuaFile::SetData(const char* const data, const size_t dataLength)
{
    binaryData_ = data;
    dataLength_ = dataLength;
}

void LuaFile::unloadImpl()
{
    if (binaryData_)
    {
        delete binaryData_;
        binaryData_ = NULL;
        dataLength_ = 0;
    }
}