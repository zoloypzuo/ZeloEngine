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

#ifndef DEMO_FRAMEWORK_NAVIGATION_MESH_H
#define DEMO_FRAMEWORK_NAVIGATION_MESH_H

#include <vector>

#include "ogre3d/include/OgreNameGenerator.h"

struct rcConfig;

class dtNavMesh;
class dtNavMeshQuery;
class SandboxObject;

namespace Ogre
{
class SceneManager;
class SceneNode;
class Vector3;
}

class NavigationMesh
{
public:
    NavigationMesh(
        rcConfig& config,
        const std::vector<SandboxObject*>& objects,
        Ogre::SceneManager* const manager = NULL);

    ~NavigationMesh();

    Ogre::Vector3 FindClosestPoint(const Ogre::Vector3& point);

    void FindPath(
        const Ogre::Vector3& start,
        const Ogre::Vector3& end,
        std::vector<Ogre::Vector3>& outPath);

    Ogre::SceneNode* GetDebugMesh() const;

    Ogre::Vector3 RandomPoint();

    void SetNavmeshDebug(const bool debug);

private:
    static Ogre::NameGenerator debugNameGenerator;

    dtNavMesh* navMesh_;
    dtNavMeshQuery* query_;
    Ogre::SceneNode* debugMesh_;
};

#endif  // DEMO_FRAMEWORK_NAVIGATION_MESH_H
