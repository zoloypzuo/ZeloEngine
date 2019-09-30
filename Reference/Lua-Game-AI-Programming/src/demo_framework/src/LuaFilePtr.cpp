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
    if( resource.isNull() )
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
        ++(pInfo->useCount);
    }
}

LuaFilePtr& LuaFilePtr::operator=(const Ogre::ResourcePtr& resource)
{
    if(pRep == static_cast<LuaFile*>(resource.getPointer()))
        return *this;

    release();

    if(resource.isNull())
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
        ++(pInfo->useCount);
    }

    return *this;
}