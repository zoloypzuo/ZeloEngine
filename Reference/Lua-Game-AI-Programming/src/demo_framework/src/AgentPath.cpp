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

#include "demo_framework/include/AgentPath.h"

AgentPath::AgentPath() : PolylinePathway()
{
}

AgentPath::AgentPath(
    const std::vector<Ogre::Vector3>& points,
    const Ogre::Real radius,
    const bool cyclic)
{
    OpenSteer::Vec3 vec3Point[MAX_PATH_POINTS];

    assert(points.size() < MAX_PATH_POINTS);

    std::vector<Ogre::Vector3>::const_iterator it;
    int count = 0;

    for (it = points.begin(); it != points.end(); ++it)
    {
        const Ogre::Vector3& vec = *it;

        vec3Point[count].x = vec.x;
        vec3Point[count].y = vec.y;
        vec3Point[count].z = vec.z;

        ++count;
    }

    initialize(count, vec3Point, static_cast<float>(radius), cyclic);
}

AgentPath::~AgentPath()
{
}

AgentPath::AgentPath(const AgentPath& path)
{
    initialize(path.pointCount, path.points, path.radius, path.cyclic);
}

AgentPath& AgentPath::operator=(const AgentPath& path)
{
    initialize(path.pointCount, path.points, path.radius, path.cyclic);
    return *this;
}

Ogre::Real AgentPath::GetDistanceAlongPath(const Ogre::Vector3& position) const
{
    const OpenSteer::Vec3 vec3(position.x, position.y, position.z);

    return const_cast<AgentPath*>(this)->mapPointToPathDistance(vec3);
}

Ogre::Vector3 AgentPath::GetNearestPointOnPath(
    const Ogre::Vector3& position) const
{
    const OpenSteer::Vec3 vec3(position.x, position.y, position.z);
    OpenSteer::Vec3 tangent;
    float outside;

    const OpenSteer::Vec3 pointOnPath =
        const_cast<AgentPath*>(this)->mapPointToPath(vec3, tangent, outside);

    return Ogre::Vector3(pointOnPath.x, pointOnPath.y, pointOnPath.z);
}

size_t AgentPath::GetNumberOfPathPoints() const
{
    return pointCount;
}

Ogre::Real AgentPath::GetPathLength() const
{
    // XXX(8-22-13) - This variable may become private in the future.
    return Ogre::Real(totalPathLength);
}

void AgentPath::GetPathPoints(std::vector<Ogre::Vector3>& outPoints) const
{
    outPoints.clear();

    const size_t pathPoints = GetNumberOfPathPoints();

    for (size_t index = 0; index < pathPoints; ++index)
    {
        const OpenSteer::Vec3& vec3 = points[index];
        outPoints.push_back(Ogre::Vector3(vec3.x, vec3.y, vec3.z));
    }
}

Ogre::Vector3 AgentPath::GetPointOnPath(const Ogre::Real distance) const
{
    const OpenSteer::Vec3 pointOnPath =
        const_cast<AgentPath*>(this)->mapPathDistanceToPoint(distance);

    return Ogre::Vector3(pointOnPath.x, pointOnPath.y, pointOnPath.z);
}

Ogre::Real AgentPath::GetRadius() const
{
    return radius;
}

unsigned int AgentPath::GetSegmentCount() const
{
    return static_cast<unsigned int>(pointCount) - 1;
}
