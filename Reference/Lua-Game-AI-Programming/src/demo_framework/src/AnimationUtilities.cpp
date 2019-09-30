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

#include "demo_framework/include/AnimationUtilities.h"
#include "demo_framework/include/LuaScriptBindings.h"
#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/SkeletonDebug.h"

namespace
{
const luaL_Reg LuaAnimationFunctions[] =
{
    { "AttachToBone",               Lua_Script_AnimationAttachToBone },
    { "GetAnimation",               Lua_Script_AnimationGetAnimation },
    { "GetBoneNames",               Lua_Script_AnimationGetBoneNames },
    { "GetBonePosition",            Lua_Script_AnimationGetBonePosition },
    { "GetBoneRotation",            Lua_Script_AnimationGetBoneRotation },
    { "GetLength",                  Lua_Script_AnimationGetLength },
    { "GetName",                    Lua_Script_AnimationGetName },
    { "GetNormalizedTime",          Lua_Script_AnimationGetNormalizedTime },
    { "GetTime",                    Lua_Script_AnimationGetTime },
    { "GetWeight",                  Lua_Script_AnimationGetWeight },
    { "IsEnabled",                  Lua_Script_AnimationIsEnabled },
    { "IsLooping",                  Lua_Script_AnimationIsLooping },
    { "Reset",                      Lua_Script_AnimationReset },
    { "SetDisplaySkeleton",         Lua_Script_AnimationSetDisplaySkeleton },
    { "SetEnabled",                 Lua_Script_AnimationSetEnabled },
    { "SetLooping",                 Lua_Script_AnimationSetLooping },
    { "SetNormalizedTime",          Lua_Script_AnimationSetNormalizedTime },
    { "SetTime",                    Lua_Script_AnimationSetTime },
    { "SetWeight",                  Lua_Script_AnimationSetWeight },
    { "StepAnimation",              Lua_Script_AnimationStepAnimation },
    { NULL, NULL }
};

const luaL_Reg LuaAnimationMetatable[] =
{
    { "__towatch",                  Lua_Script_AnimationToWatch },
    { NULL, NULL }
};
}  // anonymous namespace

void AnimationUtilities::AttachToBone(
    Ogre::SceneNode& entityNode,
    const Ogre::String& boneName,
    Ogre::SceneNode& movableNode,
    const Ogre::Vector3& positionOffset,
    const Ogre::Quaternion& orientationOffset)
{
    Ogre::Entity* const entity = LuaScriptUtilities::GetEntity(entityNode);
    Ogre::Entity* const movableEntity =
        LuaScriptUtilities::GetEntity(movableNode);

    if (entity && movableEntity)
    {
        movableNode.detachObject(movableEntity);
        movableNode.getCreator()->destroySceneNode(&movableNode);

        AttachToBone(
            *entity,
            boneName,
            *movableEntity,
            positionOffset,
            orientationOffset);
    }
}

void AnimationUtilities::AttachToBone(
    Ogre::Entity& entity,
    const Ogre::String& boneName,
    Ogre::MovableObject& movable,
    const Ogre::Vector3& positionOffset,
    const Ogre::Quaternion& orientationOffset)
{
    entity.attachObjectToBone(
        boneName, &movable, orientationOffset, positionOffset);
}

void AnimationUtilities::BindVMFunctions(lua_State* const luaVM)
{
    luaL_newmetatable(luaVM, LUA_ANIMATION_METATABLE);
    luaL_register(luaVM, NULL, LuaAnimationMetatable);

    luaL_register(luaVM, "Animation", LuaAnimationFunctions);
}

Ogre::AnimationState* AnimationUtilities::GetAnimation(
    lua_State& luaVM, const int stackIndex)
{
    return *static_cast<Ogre::AnimationState**>(
        luaL_checkudata(&luaVM, stackIndex, LUA_ANIMATION_METATABLE));
}

bool AnimationUtilities::GetBoneOrientation(
    Ogre::SceneNode& node, const Ogre::String& boneName, Ogre::Quaternion& outOrientation)
{
    const unsigned short numAttachedObjects = node.numAttachedObjects();

    for (unsigned short index = 0; index < numAttachedObjects; ++index)
    {
        Ogre::MovableObject* const object = node.getAttachedObject(index);

        if (GetBoneOrientation(*object, boneName, outOrientation))
        {
            return true;
        }
    }

    return false;
}

bool AnimationUtilities::GetBoneOrientation(
    Ogre::MovableObject& object, const Ogre::String& boneName, Ogre::Quaternion& outOrientation)
{
    if (object.getMovableType() ==
            Ogre::EntityFactory::FACTORY_TYPE_NAME)
    {
        Ogre::Entity* const entity = static_cast<Ogre::Entity*>(&object);

        if (entity->hasSkeleton())
        {
            Ogre::Skeleton* const skeleton = entity->getSkeleton();
            if (skeleton->hasBone(boneName))
            {
                Ogre::SceneNode* node =
                    dynamic_cast<Ogre::SceneNode*>(entity->getParentNode());

                outOrientation = skeleton->getBone(boneName)->_getDerivedOrientation();

                if (node)
                {
                    outOrientation = node->convertLocalToWorldOrientation(outOrientation);
                }

                return true;
            }
        }

        Ogre::Entity::ChildObjectListIterator it =
            entity->getAttachedObjectIterator();

        while (it.hasMoreElements())
        {
            Ogre::MovableObject* const attachedObject = it.getNext();

            if (GetBoneOrientation(*attachedObject, boneName, outOrientation))
            {
                Ogre::Node* const parentNode = attachedObject->getParentNode();

                outOrientation = parentNode->convertLocalToWorldOrientation(outOrientation);

                return true;
            }
        }
    }

    return false;
}

bool AnimationUtilities::GetBonePosition(
    Ogre::SceneNode& node, const Ogre::String& boneName, Ogre::Vector3& outPosition)
{
    const unsigned short numAttachedObjects = node.numAttachedObjects();

    for (unsigned short index = 0; index < numAttachedObjects; ++index)
    {
        Ogre::MovableObject* const object = node.getAttachedObject(index);

        if (GetBonePosition(*object, boneName, outPosition))
        {
            return true;
        }
    }

    return false;
}

bool AnimationUtilities::GetBonePosition(
    Ogre::MovableObject& object,
    const Ogre::String& boneName,
    Ogre::Vector3& outPosition)
{
    if (object.getMovableType() ==
            Ogre::EntityFactory::FACTORY_TYPE_NAME)
    {
        Ogre::Entity* const entity = static_cast<Ogre::Entity*>(&object);

        if (entity->hasSkeleton())
        {
            Ogre::Skeleton* const skeleton = entity->getSkeleton();
            if (skeleton->hasBone(boneName))
            {
                Ogre::SceneNode* node =
                    dynamic_cast<Ogre::SceneNode*>(entity->getParentNode());

                outPosition = skeleton->getBone(boneName)->_getDerivedPosition();

                if (node)
                {
                    outPosition = node->_getDerivedPosition() +
                        (node->_getDerivedOrientation() * outPosition);
                }

                return true;
            }
        }

        Ogre::Entity::ChildObjectListIterator it =
            entity->getAttachedObjectIterator();

        while (it.hasMoreElements())
        {
            Ogre::MovableObject* const attachedObject = it.getNext();

            if (GetBonePosition(*attachedObject, boneName, outPosition))
            {
                Ogre::Node* const parentNode = attachedObject->getParentNode();

                outPosition = parentNode->_getDerivedPosition() +
                    (parentNode->_getDerivedOrientation() * outPosition);

                return true;
            }
        }
    }

    return false;
}

Ogre::Real AnimationUtilities::GetLength(
    const Ogre::AnimationState& animation)
{
    return animation.getLength();
}

Ogre::String AnimationUtilities::GetName(const Ogre::AnimationState& animation)
{
    return animation.getAnimationName();
}

Ogre::Real AnimationUtilities::GetNormalizedTime(
    const Ogre::AnimationState& animation)
{
    return AnimationUtilities::GetTime(animation)/
        AnimationUtilities::GetLength(animation);
}

Ogre::Real AnimationUtilities::GetTime(const Ogre::AnimationState& animation)
{
    return animation.getTimePosition();
}

Ogre::Real AnimationUtilities::GetWeight(const Ogre::AnimationState& animation)
{
    return animation.getWeight();
}

bool AnimationUtilities::IsEnabled(const Ogre::AnimationState& animation)
{
    return animation.getEnabled();
}

bool AnimationUtilities::IsLooping(const Ogre::AnimationState& animation)
{
    return animation.getLoop();
}

void AnimationUtilities::Reset(Ogre::AnimationState& animation)
{
    SetTime(animation, 0);
}

int AnimationUtilities::PushAnimation(
    lua_State& luaVM, Ogre::AnimationState& animation)
{
    const size_t animationSize = sizeof(animation);

    Ogre::AnimationState** const luaAnimation =
        static_cast<Ogre::AnimationState**>(
            lua_newuserdata(&luaVM, animationSize));

    *luaAnimation = &animation;

    luaL_getmetatable(&luaVM, LUA_ANIMATION_METATABLE);
    lua_setmetatable(&luaVM, -2);

    return 1;
}

int AnimationUtilities::PushAnimationProperties(
    lua_State& luaVM, Ogre::AnimationState& animation)
{
    lua_pushstring(&luaVM, "Animation");
    lua_newtable(&luaVM);
    const int tableIndex = lua_gettop(&luaVM);

    LuaScriptUtilities::PushBoolAttribute(
        &luaVM, IsEnabled(animation), "enabled", tableIndex);
    LuaScriptUtilities::PushRealAttribute(
        &luaVM, GetLength(animation), "length", tableIndex);
    LuaScriptUtilities::PushBoolAttribute(
        &luaVM, IsLooping(animation), "looping", tableIndex);
    LuaScriptUtilities::PushStringAttribute(
        &luaVM, GetName(animation), "name", tableIndex);
    LuaScriptUtilities::PushRealAttribute(
        &luaVM, GetNormalizedTime(animation), "normalizedTime", tableIndex);
    LuaScriptUtilities::PushRealAttribute(
        &luaVM, GetTime(animation), "time", tableIndex);
    LuaScriptUtilities::PushRealAttribute(
        &luaVM, GetWeight(animation), "weight", tableIndex);

    return 2;
}

int AnimationUtilities::PushBoneNames(
    lua_State& luaVM, Ogre::Entity& entity)
{
    Ogre::SkeletonInstance* const skeleton = entity.getSkeleton();

    lua_newtable(&luaVM);
    const int tableIndex = lua_gettop(&luaVM);

    if (skeleton)
    {
        const unsigned short numBones = skeleton->getNumBones();

        for (unsigned short index = 0; index < numBones; ++index)
        {
            lua_pushinteger(&luaVM, index);

            Ogre::Bone* const bone = skeleton->getBone(index);

            lua_pushstring(&luaVM, bone->getName().c_str());
            lua_settable(&luaVM, tableIndex);
        }
    }

    return 1;
}

void AnimationUtilities::SetDebugSkeleton(
    Ogre::Entity& entity, Ogre::SceneManager& manager, const bool enable)
{
    SkeletonDebug::SetSkeletonDebug(&entity, &manager, enable);
}

void AnimationUtilities::SetEnable(
    Ogre::AnimationState& animation, const bool enable)
{
    animation.setEnabled(enable);
}

void AnimationUtilities::SetLooping(
    Ogre::AnimationState& animation, const bool enable)
{
    animation.setLoop(enable);
}

void AnimationUtilities::SetNormalizedTime(
    Ogre::AnimationState& animation, const Ogre::Real normalizedTime)
{
    const Ogre::Real time =
        Ogre::Math::Clamp<Ogre::Real>(normalizedTime, 0, 1.0f) *
        AnimationUtilities::GetLength(animation);

    animation.setTimePosition(time);
}

void AnimationUtilities::SetTime(
    Ogre::AnimationState& animation, const Ogre::Real time)
{
    animation.setTimePosition(time);
}

void AnimationUtilities::SetWeight(
    Ogre::AnimationState& animation, const Ogre::Real weight)
{
    animation.setWeight(weight);
}

void AnimationUtilities::StepAnimation(
    Ogre::AnimationState& animation,
    const Ogre::Real deltaTimeInMillis)
{
    animation.addTime(deltaTimeInMillis / 1000.0f);
}