/**
 * Ogre Wiki Source Code Public Domain (Un)License
 * The source code on the Ogre Wiki is free and unencumbered
 * software released into the public domain.
 *
 * Anyone is free to copy, modify, publish, use, compile, sell, or
 * distribute this software, either in source code form or as a compiled
 * binary, for any purpose, commercial or non-commercial, and by any
 * means.
 *
 * In jurisdictions that recognize copyright laws, the author or authors
 * of this software dedicate any and all copyright interest in the
 * software to the public domain. We make this dedication for the benefit
 * of the public at large and to the detriment of our heirs and
 * successors. We intend this dedication to be an overt act of
 * relinquishment in perpetuity of all present and future rights to this
 * software under copyright law.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 * EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 * MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
 * IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
 * OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
 * ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
 * OTHER DEALINGS IN THE SOFTWARE.
 *
 * For more information, please refer to http://unlicense.org/
 */

/**
 * The source code in this file is attributed to the Ogre wiki article at
 * http://www.ogre3d.org/tikiwiki/tiki-index.php?page=Skeleton+Debugger&structure=Cookbook
 */

#ifndef DEMO_FRAMEWORK_SKELETON_DEBUG_H
#define DEMO_FRAMEWORK_SKELETON_DEBUG_H

#include "ogre3d/include/OgrePrerequisites.h"
#include "ogre3d/include/OgreString.h"

namespace Ogre
{
class Entity;
class SceneManager;
}

class SkeletonDebug
{
public:
    static Ogre::String axesName;
    static Ogre::String axesMeshName;
    static Ogre::String boneName;
    static Ogre::String boneMeshName;

    static bool HasSkeletonDebug(Ogre::Entity* entity);

    static void HideSkeletonDebug(Ogre::Entity* entity);

    static void ShowSkeletonDebug(Ogre::Entity* entity);

    static void SetSkeletonDebug(
        Ogre::Entity *entity,
        Ogre::SceneManager *sceneManager,
        const bool enable,
        Ogre::Real boneSize = 0.05f,
        Ogre::Real axisSize = 0.05f);

private:
    SkeletonDebug();
    ~SkeletonDebug();
    SkeletonDebug(const SkeletonDebug&);
    SkeletonDebug& operator=(const SkeletonDebug&);

    static Ogre::MaterialPtr GetAxesMaterial();
    static Ogre::ResourcePtr GetAxesMesh();

    static Ogre::MaterialPtr GetBoneMaterial();
    static Ogre::MeshPtr GetBoneMesh(const Ogre::Real boneSize);
};

#endif  // DEMO_FRAMEWORK_SKELETON_DEBUG_H
