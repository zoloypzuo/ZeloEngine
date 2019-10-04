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
	static void ApplyForce(Agent* agent, Ogre::Vector3 force);

	static void BindVMFunctions(lua_State* luaVM);

	static int CallFunction(
		lua_State* luaVM, Ogre::String functionName);

	static void CallLuaAgentCleanup(Agent* agent);

	static void CallLuaAgentHandleKeyboardEvent(
		Agent* agent, const Ogre::String& key, bool pressed);

	static void CallLuaAgentHandleMouseEvent(
		Agent* agent,
		int width,
		int height,
		Ogre::String button,
		bool pressed);

	static void CallLuaAgentHandleMouseMoveEvent(
		Agent* agent,
		int width,
		int height);

	static void CallLuaAgentInitialize(Agent* agent);

	static void CallLuaAgentUpdate(
		Agent* agent, int deltaTimeInMillis);

	static void CreateRigidBodyCapsule(Agent* agent);

	static Agent* GetAgent(lua_State* luaVM, int stackIndex);

	static Ogre::SceneNode* GetSceneNode(Agent* agent);

	static bool IsAgent(lua_State* luaVM, int stackIndex);

	static bool IsEqual(
		const Agent* leftAgent, const Agent* rightAgent);

	static void LoadScript(
		Agent* agent,
		const char* luaScriptContents,
		size_t bufferSize,
		const char* fileName);

	static int PushAgent(lua_State* luaVM, Agent* agent);

	static int PushAgentAttribute(
		lua_State* luaVM,
		Agent* agent,
		Ogre::String attributeName,
		int tableIndex);

	static int PushAgentId(lua_State* luaVM, Agent* agent);

	static int PushAgentProperties(
		lua_State* luaVM, const Agent* agent);

	static int PushDistanceAlongPath(
		lua_State* luaVM,
		const Agent* agent,
		const Ogre::Vector3& position);

	static int PushForceToAlign(
		lua_State* luaVM,
		Agent* agent,
		float maxDistance,
		float maxAngle,
		const std::vector<Agent*>& group);

	static int PushForceToAvoidAgents(
		lua_State* luaVM,
		Agent* agent,
		float predicitionTime = -1.0f);

	static int PushForceToAvoidObjects(
		lua_State* luaVM,
		Agent* agent,
		float predicitionTime = -1.0f);

	static int PushForceToCombine(
		lua_State* luaVM,
		Agent* agent,
		float maxDistance,
		float maxAngle,
		const std::vector<Agent*>& group);

	static int PushForceToFleePosition(
		lua_State* luaVM,
		Agent* agent,
		const Ogre::Vector3& position);

	static int PushForceToFollowPath(
		lua_State* luaVM,
		Agent* agent,
		float predicitionTime = -1.0f);

	static int PushForceToPosition(
		lua_State* luaVM,
		Agent* agent,
		const Ogre::Vector3& position);

	static int PushForceToSeparate(
		lua_State* luaVM,
		Agent* agent,
		float maxDistance,
		float maxAngle,
		const std::vector<Agent*>& group);

	static int PushForceToStayOnPath(
		lua_State* luaVM,
		Agent* agent,
		float predicitionTime = -1.0f);

	static int PushForceToTargetSpeed(
		lua_State* luaVM, Agent* agent, Ogre::Real speed);

	static int PushForceToWander(
		lua_State* luaVM,
		Agent* agent,
		Ogre::Real deltaMilliseconds);

	static int PushForward(lua_State* luaVM, Agent* agent);

	static int PushFunction(
		lua_State* luaVM, Ogre::String functionName);

	static int PushHasPath(lua_State* luaVM, const Agent* agent);

	static int PushHealth(lua_State* luaVM, const Agent* agent);

	static int PushHeight(lua_State* luaVM, const Agent* agent);

	static int PushLeft(lua_State* luaVM, Agent* agent);

	static int PushMass(lua_State* luaVM, const Agent* agent);

	static int PushMaxForce(lua_State* luaVM, const Agent* agent);

	static int PushMaxSpeed(lua_State* luaVM, const Agent* agent);

	static int PushNearestPointOnPath(
		lua_State* luaVM,
		const Agent* agent,
		const Ogre::Vector3& position);

	static int PushPath(lua_State* luaVM, const Agent* agent);

	static int PushPathAttribute(
		lua_State* luaVM,
		const Agent* agent,
		Ogre::String attributeName,
		int tableIndex);

	static int PushPointOnPath(
		lua_State* luaVM,
		const Agent* agent,
		Ogre::Real distance);

	static int PushPosition(lua_State* luaVM, const Agent* agent);

	static int PushPredictFuturePosition(
		lua_State* luaVM,
		Agent* agent,
		Ogre::Real timeInSeconds);

	static int PushRadius(lua_State* luaVM, const Agent* agent);

	static int PushSandbox(lua_State* luaVM, Agent* agent);

	static int PushSpeed(lua_State* luaVM, const Agent* agent);

	static int PushTarget(lua_State* luaVM, const Agent* agent);

	static int PushTargetRadius(
		lua_State* luaVM, const Agent* agent);

	static int PushTeam(lua_State* luaVM, const Agent* agent);

	static int PushUp(lua_State* luaVM, Agent* agent);

	static int PushVelocity(lua_State* luaVM, const Agent* agent);

	static void RemovePath(Agent* agent);

	static void RemovePhysics(Agent* agent);

	static void SetForward(Agent* agent, const Ogre::Vector3& forward);

	static void SetHealth(Agent* agent, Ogre::Real health);

	static void SetHeight(Agent* agent, Ogre::Real height);

	static void SetMass(Agent* agent, Ogre::Real mass);

	static void SetMaxForce(Agent* agent, Ogre::Real maxForce);

	static void SetMaxSpeed(Agent* agent, Ogre::Real maxSpeed);

	static void SetPath(
		Agent* agent,
		const std::vector<Ogre::Vector3>& points,
		bool cyclic);

	static void SetPosition(Agent* agent, const Ogre::Vector3& vector);

	static void SetRadius(Agent* agent, Ogre::Real radius);

	static void SetSpeed(Agent* agent, Ogre::Real speed);

	static void SetTarget(Agent* agent, const Ogre::Vector3& target);

	static void SetTargetRadius(Agent* agent, Ogre::Real radius);

	static void SetTeam(Agent* agent, const Ogre::String& team);

	static void SetVelocity(Agent* agent, const Ogre::Vector3& velocity);

	static void UpdateRigidBodyCapsule(Agent* agent);

	static void UpdateWorldTransform(Agent* agent);

private:
	AgentUtilities();
	~AgentUtilities();
	AgentUtilities(const AgentUtilities&);
	AgentUtilities& operator=(const AgentUtilities&);
}; // class AgentUtilities

#endif  // DEMO_FRAMEWORK_AGENT_UTILITIES_H
