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

#ifndef DEMO_FRAMEWORK_AGENT_PATH_H
#define DEMO_FRAMEWORK_AGENT_PATH_H

#include <vector>

#include "ogre3d/include/OgrePrerequisites.h"
#include "opensteer/include/Pathway.h"

namespace Ogre
{
    class Vector3;
}

class AgentPath : private OpenSteer::PolylinePathway
{
/**
 * Having Agent as a friend class to AgentPath allows for an Agent's OpenSteer
 * implementation to access the private OpenSteer PolylinePathway
 * implementation.
 */
friend class Agent;

public:
    const static size_t MAX_PATH_POINTS = 255;

    AgentPath();

    AgentPath(
        const std::vector<Ogre::Vector3>& points,
        const Ogre::Real radius,
        const bool cyclic);

    virtual ~AgentPath();

    AgentPath(const AgentPath& path);

    AgentPath& operator=(const AgentPath& path);

    size_t GetNumberOfPathPoints() const;

    Ogre::Real GetPathLength() const;

    void GetPathPoints(std::vector<Ogre::Vector3>& outPoints) const;

    Ogre::Real GetDistanceAlongPath(const Ogre::Vector3& position) const;

    Ogre::Vector3 GetNearestPointOnPath(const Ogre::Vector3& position) const;

    Ogre::Vector3 GetPointOnPath(const Ogre::Real distance) const;

    Ogre::Real GetRadius() const;

    unsigned int GetSegmentCount() const;
};

#endif  // DEMO_FRAMEWORK_AGENT_PATH_H
