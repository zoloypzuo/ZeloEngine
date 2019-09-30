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

#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/NavigationMesh.h"
#include "demo_framework/include/NavigationUtilities.h"

Ogre::NameGenerator NavigationMesh::debugNameGenerator("debugNavMesh");

NavigationMesh::NavigationMesh(
    rcConfig& config,
    const std::vector<SandboxObject*>& objects,
    Ogre::SceneManager* const manager)
{
    rcPolyMesh* polyMesh = NULL;
    rcPolyMeshDetail* polyMeshDetail = NULL;

    NavigationUtilities::CreatePolyMeshes(
        config, objects, polyMesh, polyMeshDetail);

    navMesh_ = NavigationUtilities::CreateNavMesh(
        config, *polyMesh, *polyMeshDetail);

    query_ = NavigationUtilities::CreateNavMeshQuery(*navMesh_);

    NavigationUtilities::DestroyPolyMesh(*polyMesh);
    NavigationUtilities::DestroyPolyMeshDetail(*polyMeshDetail);

    if (manager)
    {
        Ogre::ManualObject* const object =
            NavigationUtilities::CreateManualObject(*manager, *navMesh_);

        debugMesh_ = manager->getRootSceneNode()->createChildSceneNode();

        Ogre::MeshPtr mesh =
            object->convertToMesh(debugNameGenerator.generate());
        Ogre::Entity* const entity = manager->createEntity(mesh);
        entity->setCastShadows(false);

        debugMesh_->attachObject(entity);
        debugMesh_->setVisible(false);
        debugMesh_->_updateBounds();
    }
    else
    {
        debugMesh_ = NULL;
    }
}

NavigationMesh::~NavigationMesh()
{
    NavigationUtilities::DestroyNavMesh(*navMesh_);
    navMesh_= NULL;

    NavigationUtilities::DestroyNavMeshQuery(*query_);

    LuaScriptUtilities::DestroySceneNode(debugMesh_->getCreator(), debugMesh_);
}

Ogre::Vector3 NavigationMesh::FindClosestPoint(const Ogre::Vector3& point)
{
    return NavigationUtilities::FindClosestPoint(point, *query_);
}

void NavigationMesh::FindPath(
    const Ogre::Vector3& start,
    const Ogre::Vector3& end,
    std::vector<Ogre::Vector3>& outPath)
{
    NavigationUtilities::FindStraightPath(start, end, *query_, outPath);
}

Ogre::SceneNode* NavigationMesh::GetDebugMesh() const
{
    return debugMesh_;
}

Ogre::Vector3 NavigationMesh::RandomPoint()
{
    return NavigationUtilities::FindRandomPoint(*query_);
}

void NavigationMesh::SetNavmeshDebug(const bool debug)
{
    if (debugMesh_)
    {
        debugMesh_->setVisible(debug);
    }
}