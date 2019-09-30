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

#ifndef DEMO_FRAMEWORK_AGENT_UTILITIES_H
#define DEMO_FRAMEWORK_AGENT_UTILITIES_H

#include <vector>

#include "ogre3d/include/OgrePrerequisites.h"

class Agent;
class AgentGroup;
class AgentPath;

#define AGENT_CLEANUP_FUNC          "Agent_Cleanup"
#define AGENT_HANDLE_EVENT_FUNC     "Agent_HandleEvent"
#define AGENT_INITIALIZE_FUNC       "Agent_Initialize"
#define AGENT_LUA_VM_NAME           "AI Agent VM"
#define AGENT_UPDATE_FUNC           "Agent_Update"
#define LUA_AGENT_METATABLE         "AgentType"

class AgentUtilities
{
public:
    static void ApplyForce(Agent* const agent, const Ogre::Vector3 force);

    static void BindVMFunctions(lua_State* const luaVM);

    static int CallFunction(
        lua_State* const luaVM, const Ogre::String functionName);

    static void CallLuaAgentCleanup(Agent* const agent);

    static void CallLuaAgentHandleKeyboardEvent(
        Agent* const agent, const Ogre::String& key, const bool pressed);

    static void CallLuaAgentHandleMouseEvent(
        Agent* const agent,
        const int width,
        const int height,
        const Ogre::String button,
        const bool pressed);

    static void CallLuaAgentHandleMouseMoveEvent(
        Agent* const agent,
        const int width,
        const int height);

    static void CallLuaAgentInitialize(Agent* const agent);

    static void CallLuaAgentUpdate(
        Agent* const agent, const int deltaTimeInMillis);

    static void CreateRigidBodyCapsule(Agent* const agent);

    static Agent* GetAgent(lua_State* const luaVM, const int stackIndex);

    static Ogre::SceneNode* GetSceneNode(Agent* const agent);

    static bool IsAgent(lua_State* const luaVM, const int stackIndex);

    static bool IsEqual(
        const Agent* const leftAgent, const Agent* const rightAgent);

    static void LoadScript(
        Agent* const agent,
        const char* const luaScriptContents,
        const size_t bufferSize,
        const char* const fileName);

    static int PushAgent(lua_State* const luaVM, Agent* const agent);

    static int PushAgentAttribute(
        lua_State* const luaVM,
        Agent* const agent,
        const Ogre::String attributeName,
        const int tableIndex);

    static int PushAgentId(lua_State* const luaVM, Agent* const agent);

    static int PushAgentProperties(
        lua_State* const luaVM, const Agent* const agent);

    static int PushDistanceAlongPath(
        lua_State* const luaVM,
        const Agent* const agent,
        const Ogre::Vector3& position);

    static int PushForceToAlign(
        lua_State* const luaVM,
        Agent* const agent,
        const float maxDistance,
        const float maxAngle,
        const std::vector<Agent*>& group);

    static int PushForceToAvoidAgents(
        lua_State* const luaVM,
        Agent* const agent,
        const float predicitionTime = -1.0f);

    static int PushForceToAvoidObjects(
        lua_State* const luaVM,
        Agent* const agent,
        const float predicitionTime = -1.0f);

    static int PushForceToCombine(
        lua_State* const luaVM,
        Agent* const agent,
        const float maxDistance,
        const float maxAngle,
        const std::vector<Agent*>& group);

    static int PushForceToFleePosition(
        lua_State* const luaVM,
        Agent* const agent,
        const Ogre::Vector3& position);

    static int PushForceToFollowPath(
        lua_State* const luaVM,
        Agent* const agent,
        const float predicitionTime = -1.0f);

    static int PushForceToPosition(
        lua_State* const luaVM,
        Agent* const agent,
        const Ogre::Vector3& position);

    static int PushForceToSeparate(
        lua_State* const luaVM,
        Agent* const agent,
        const float maxDistance,
        const float maxAngle,
        const std::vector<Agent*>& group);

    static int PushForceToStayOnPath(
        lua_State* const luaVM,
        Agent* const agent,
        const float predicitionTime = -1.0f);

    static int PushForceToTargetSpeed(
        lua_State* const luaVM, Agent* const agent, const Ogre::Real speed);

    static int PushForceToWander(
        lua_State* const luaVM,
        Agent* const agent,
        const Ogre::Real deltaMilliseconds);

    static int PushForward(lua_State* const luaVM, Agent* const agent);

    static int PushFunction(
        lua_State* const luaVM, const Ogre::String functionName);

    static int PushHasPath(lua_State* const luaVM, const Agent* const agent);

    static int PushHealth(lua_State* const luaVM, const Agent* const agent);

    static int PushHeight(lua_State* const luaVM, const Agent* const agent);

    static int PushLeft(lua_State* const luaVM, Agent* const agent);

    static int PushMass(lua_State* const luaVM, const Agent* const agent);

    static int PushMaxForce(lua_State* const luaVM, const Agent* const agent);

    static int PushMaxSpeed(lua_State* const luaVM, const Agent* const agent);

    static int PushNearestPointOnPath(
        lua_State* const luaVM,
        const Agent* const agent,
        const Ogre::Vector3& position);

    static int PushPath(lua_State* const luaVM, const Agent* const agent);

    static int PushPathAttribute(
        lua_State* const luaVM,
        const Agent* const agent,
        const Ogre::String attributeName,
        const int tableIndex);

    static int PushPointOnPath(
        lua_State* const luaVM,
        const Agent* const agent,
        const Ogre::Real distance);

    static int PushPosition(lua_State* const luaVM, const Agent* const agent);

    static int PushPredictFuturePosition(
        lua_State* const luaVM,
        Agent* const agent,
        const Ogre::Real timeInSeconds);

    static int PushRadius(lua_State* const luaVM, const Agent* const agent);

    static int PushSandbox(lua_State* const luaVM, Agent* const agent);

    static int PushSpeed(lua_State* const luaVM, const Agent* const agent);

    static int PushTarget(lua_State* const luaVM, const Agent* const agent);

    static int PushTargetRadius(
        lua_State* const luaVM, const Agent* const agent);

    static int PushTeam(lua_State* const luaVM, const Agent* const agent);

    static int PushUp(lua_State* const luaVM, Agent* const agent);

    static int PushVelocity(lua_State* const luaVM, const Agent* const agent);

    static void RemovePath(Agent* const agent);

    static void RemovePhysics(Agent* const agent);

    static void SetForward(Agent* const agent, const Ogre::Vector3& forward);

    static void SetHealth(Agent* const agent, const Ogre::Real health);

    static void SetHeight(Agent* const agent, const Ogre::Real height);

    static void SetMass(Agent* const agent, const Ogre::Real mass);

    static void SetMaxForce(Agent* const agent, const Ogre::Real maxForce);

    static void SetMaxSpeed(Agent* const agent, const Ogre::Real maxSpeed);

    static void SetPath(
        Agent* const agent,
        const std::vector<Ogre::Vector3>& points,
        const bool cyclic);

    static void SetPosition(Agent* const agent, const Ogre::Vector3& vector);

    static void SetRadius(Agent* const agent, const Ogre::Real radius);

    static void SetSpeed(Agent* const agent, const Ogre::Real speed);

    static void SetTarget(Agent* const agent, const Ogre::Vector3& target);

    static void SetTargetRadius(Agent* const agent, const Ogre::Real radius);

    static void SetTeam(Agent* const agent, const Ogre::String& team);

    static void SetVelocity(Agent* const agent, const Ogre::Vector3& velocity);

    static void UpdateRigidBodyCapsule(Agent* const agent);

    static void UpdateWorldTransform(Agent* const agent);

private:
    AgentUtilities();
    ~AgentUtilities();
    AgentUtilities(const AgentUtilities&);
    AgentUtilities& operator=(const AgentUtilities&);
};  // class AgentUtilities

#endif  // DEMO_FRAMEWORK_AGENT_UTILITIES_H
