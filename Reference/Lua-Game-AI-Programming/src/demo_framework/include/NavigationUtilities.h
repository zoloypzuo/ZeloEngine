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

#ifndef DEMO_FRAMEWORK_NAVIGATION_UTILITIES_H
#define DEMO_FRAMEWORK_NAVIGATION_UTILITIES_H

#include <stddef.h>

struct lua_State;
struct rcCompactHeightfield;
struct rcConfig;
struct rcContourSet;
struct rcHeightfield;
struct rcPolyMesh;
struct rcPolyMeshDetail;
struct RawMesh;

class dtNavMesh;
class dtNavMeshQuery;
class rcContext;

namespace Ogre
{
class SceneManager;
}

struct MeshMetadata
{
    unsigned char* const dataBuffer;
    const size_t dataBufferSize;

    MeshMetadata(
        unsigned char* const dataBuffer,
        const size_t dataBufferSize);
    MeshMetadata(const MeshMetadata& data);

private:
    MeshMetadata& operator=(const MeshMetadata&);
};

class NavigationUtilities
{
public:
    static void BuildDistanceField(
        rcContext& context,
        const rcConfig& config,
        rcCompactHeightfield& heightfield);

    static void BuildRegions(
        rcContext& context,
        const rcConfig& config,
        rcCompactHeightfield& heightfield);

    static rcCompactHeightfield* CreateCompactHeightfield(
        rcContext& context, const rcConfig& config, rcHeightfield& heightfield);

    static rcContourSet* CreateContourSet(
        rcContext& context,
        const rcConfig& config,
        rcCompactHeightfield& heightfield);

    static rcHeightfield* CreateHeightfield(
        rcContext& context, const rcConfig& config);

    static Ogre::ManualObject* CreateManualObject(
        Ogre::SceneManager& sceneManager, const dtNavMesh& navMesh);

    static Ogre::ManualObject* CreateManualObject(
        Ogre::SceneManager& sceneManager, const rcHeightfield& heightfield);

    static Ogre::ManualObject* CreateManualObject(
        Ogre::SceneManager& sceneManager, const rcPolyMesh& polyMesh);

    static Ogre::ManualObject* CreateManualObject(
        Ogre::SceneManager& sceneManager, const rcPolyMeshDetail& polyMesh);

    static dtNavMesh* CreateNavMesh(
        const rcConfig& config,
        rcPolyMesh& polyMesh,
        rcPolyMeshDetail& polyMeshDetail);

    static dtNavMeshQuery* CreateNavMeshQuery(const dtNavMesh& navMesh);

    static rcPolyMesh* CreatePolyMesh(
        rcContext& context,
        const rcConfig& config,
        rcContourSet& contourSet);

    static void CreatePolyMeshes(
        rcConfig& config,
        const std::vector<SandboxObject*>& objects,
        rcPolyMesh*& polyMesh,
        rcPolyMeshDetail*& polyMeshDetail);

    static rcPolyMeshDetail* CreatePolyMeshDetail(
        rcContext& context,
        const rcConfig& config,
        rcCompactHeightfield& compactHeightfield,
        rcPolyMesh& polyMesh);

    static void DefaultConfig(rcConfig& config);

    static void DestroyCompactHeightfield(rcCompactHeightfield& heightfield);

    static void DestroyContourSet(rcContourSet& countourSet);

    static void DestroyHeightfield(rcHeightfield& heightfield);

    static void DestroyNavMesh(dtNavMesh& navMesh);

    static void DestroyNavMeshQuery(dtNavMeshQuery& navMeshQuery);

    static void DestroyPolyMesh(rcPolyMesh& polyMesh);

    static void DestroyPolyMeshDetail(rcPolyMeshDetail& polyMeshDetail);

    static void ErodeWalkableArea(
        rcContext& context,
        const rcConfig& config,
        rcCompactHeightfield& heightfield);

    static void FilterWalkableSurfaces(
        rcContext& context,
        const rcConfig& config,
        rcHeightfield& heightfield);

    static Ogre::Vector3 FindClosestPoint(
        const Ogre::Vector3& point, const dtNavMeshQuery& query);

    static Ogre::Vector3 FindRandomPoint(const dtNavMeshQuery& query);

    static void FindStraightPath(
        const Ogre::Vector3& start,
        const Ogre::Vector3& end,
        const dtNavMeshQuery& query,
        std::vector<Ogre::Vector3>& outPath);

    static rcConfig GetNavigationMeshConfig(lua_State* luaVM, int stackIndex);

    static void RasterizeMesh(
        rcContext& context,
        const rcConfig& config,
        const RawMesh& mesh,
        const MeshMetadata& metadata,
        rcHeightfield& heightfield);

    static void RasterizeSandboxObjects(
        rcContext& context,
        const rcConfig& config,
        const std::vector<SandboxObject*>& objects,
        rcHeightfield& heightfield);

    static void SetBounds(
        rcConfig& config,
        const std::vector<SandboxObject*>& objects);

private:
    NavigationUtilities();
    ~NavigationUtilities();
    NavigationUtilities(const NavigationUtilities&);
    NavigationUtilities& operator=(const NavigationUtilities&);
};

#endif  // DEMO_FRAMEWORK_NAVIGATION_UTILITIES_H
