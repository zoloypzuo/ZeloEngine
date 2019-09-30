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

#ifndef DEMO_FRAMEWORK_ANIMATION_UTILITIES_H
#define DEMO_FRAMEWORK_ANIMATION_UTILITIES_H

#include "ogre3d/include/OgrePrerequisites.h"
#include "ogre3d/include/OgreQuaternion.h"
#include "ogre3d/include/OgreVector3.h"

#define LUA_ANIMATION_METATABLE "AnimationType"

struct lua_State;

namespace Ogre
{
class AnimationState;
}

class AnimationUtilities
{
public:
    static void AttachToBone(
        Ogre::SceneNode& entityNode,
        const Ogre::String& boneName,
        Ogre::SceneNode& movableNode,
        const Ogre::Vector3& positionOffset = Ogre::Vector3::ZERO,
        const Ogre::Quaternion& orientationOffset = Ogre::Quaternion::IDENTITY);

    static void AttachToBone(
        Ogre::Entity& entity,
        const Ogre::String& boneName,
        Ogre::MovableObject& movable,
        const Ogre::Vector3& positionOffset = Ogre::Vector3::ZERO,
        const Ogre::Quaternion& orientationOffset = Ogre::Quaternion::IDENTITY);

    static void BindVMFunctions(lua_State* const luaVM);

    static Ogre::AnimationState* GetAnimation(
        lua_State& luaVM, const int stackIndex);

    static bool GetBoneOrientation(
        Ogre::SceneNode& node,
        const Ogre::String& boneName,
        Ogre::Quaternion& outOrientation);

    static bool GetBoneOrientation(
        Ogre::MovableObject& object,
        const Ogre::String& boneName,
        Ogre::Quaternion& outOrientation);

    static bool GetBonePosition(
        Ogre::SceneNode& node,
        const Ogre::String& boneName,
        Ogre::Vector3& outPosition);

    static bool GetBonePosition(
        Ogre::MovableObject& object,
        const Ogre::String& boneName,
        Ogre::Vector3& outPosition);

    static Ogre::Real GetLength(const Ogre::AnimationState& animation);

    static Ogre::String GetName(const Ogre::AnimationState& animation);

    static Ogre::Real GetNormalizedTime(const Ogre::AnimationState& animation);

    static Ogre::Real GetTime(const Ogre::AnimationState& animation);

    static Ogre::Real GetWeight(const Ogre::AnimationState& animation);

    static bool IsEnabled(const Ogre::AnimationState& animation);

    static bool IsLooping(const Ogre::AnimationState& animation);

    static void Reset(Ogre::AnimationState& animation);

    static void SetDebugSkeleton(
        Ogre::Entity& entity, Ogre::SceneManager& manager, const bool enable);

    static int PushAnimation(
        lua_State& luaVM, Ogre::AnimationState& animation);

    static int PushAnimationProperties(
        lua_State& luaVM, Ogre::AnimationState& animation);

    static int PushBoneNames(
        lua_State& luaVM, Ogre::Entity& entity);

    static void SetEnable(
        Ogre::AnimationState& animation, const bool enable);

    static void SetLooping(
        Ogre::AnimationState& animation, const bool enable);

    static void SetNormalizedTime(
        Ogre::AnimationState& animation, const Ogre::Real normalizedTime);

    static void SetTime(
        Ogre::AnimationState& animation, const Ogre::Real time);

    static void SetWeight(
        Ogre::AnimationState& animation, const Ogre::Real weight);

    static void StepAnimation(
        Ogre::AnimationState& animation,
        const Ogre::Real deltaTimeInMillis);

private:
    AnimationUtilities();
    ~AnimationUtilities();
    AnimationUtilities(const AnimationUtilities&);
    AnimationUtilities& operator=(const AnimationUtilities&);
};

#endif  // DEMO_FRAMEWORK_ANIMATION_UTILITIES_H