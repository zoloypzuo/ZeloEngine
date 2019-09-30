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

#include "demo_framework/include/Agent.h"
#include "demo_framework/include/AgentGroup.h"

AgentGroup::AgentGroup() : OpenSteer::AVGroup()
{
}

AgentGroup::AgentGroup(const AgentGroup& group) : OpenSteer::AVGroup(group)
{
}

AgentGroup& AgentGroup::operator=(const AgentGroup& group)
{
    clear();

    insert(begin(), group.begin(), group.end());

    return *this;
}

AgentGroup::~AgentGroup()
{
}

void AgentGroup::AddAgent(Agent* const agent)
{
    if (!ContainsAgent(agent))
    {
        push_back(static_cast<OpenSteer::AbstractVehicle*>(agent));
    }
}

bool AgentGroup::ContainsAgent(const Agent* const agent) const
{
    std::vector<OpenSteer::AbstractVehicle*>::const_iterator it;

    for (it = begin(); it != end(); ++it)
    {
        if (*it == static_cast<const OpenSteer::AbstractVehicle*>(agent))
        {
            return true;
        }
    }

    return false;
}

bool AgentGroup::RemoveAgent(const Agent* const agent)
{
    std::vector<OpenSteer::AbstractVehicle*>::const_iterator it;

    for (it = begin(); it != end(); ++it)
    {
        if (*it == static_cast<const OpenSteer::AbstractVehicle*>(agent))
        {
            break;
        }
    }

    if (it != end())
    {
        erase(it);
        return true;
    }
    return false;
}

void AgentGroup::RemoveAgents()
{
    clear();
}

size_t AgentGroup::Size() const
{
    return size();
}