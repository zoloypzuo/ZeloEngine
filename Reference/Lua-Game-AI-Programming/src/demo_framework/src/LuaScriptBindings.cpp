#include "PrecompiledHeaders.h"

#include "demo_framework/include/AgentUtilities.h"
#include "demo_framework/include/AnimationUtilities.h"
#include "demo_framework/include/DebugDrawer.h"
#include "demo_framework/include/Event.h"
#include "demo_framework/include/InfluenceMap.h"
#include "demo_framework/include/InfluenceMapUtilities.h"
#include "demo_framework/include/LuaScriptBindings.h"
#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/NavigationUtilities.h"
#include "demo_framework/include/ParticleUtilities.h"
#include "demo_framework/include/PhysicsUtilities.h"
// TODO(David Young): Bindings shouldn't include Sandbox.
#include "demo_framework/include/Sandbox.h"
// end of TODO
// TODO(David Young): Bindings shouldn't include SandboxObject.
#include "demo_framework/include/SandboxObject.h"
// end of TODO
#include "demo_framework/include/SandboxUtilities.h"
#include "demo_framework/include/UserInterfaceUtilities.h"

/**
 * @remarks
 *      The script bindings should never need to reach inside an Agent class
 *      directly.
 *      All manipulation of an Agent from lua should be done through the
 *      AgentUtilities utility class.  This prevents unwanted coupling.
 */
#ifdef DEMO_FRAMEWORK_AGENT_H
#error LuaScriptBindings.cpp tried to include Agent.h which will create \
undesirable coupling if any lua binding function needs to know about an \
Agent's internals.
#endif
#ifdef DEMO_FRAMEWORK_AGENT_GROUP_H
#error LuaScriptBindings.cpp tried to include AgentGroup.h which will \
create undesirable coupling if any lua binding function needs to know \
about an AgentGroup's internals.
#endif
#ifdef DEMO_FRAMEWORK_AGENT_PATH_H
#error LuaScriptBindings.cpp tried to include AgentPath.h which will \
create undesirable coupling if any lua binding function needs to know \
about an AgentPath's internals.
#endif

namespace
{
	Ogre::SceneNode* GetSceneNodeFromIndex(lua_State* luaVM, int index)
	{
		Ogre::SceneNode* sceneNode = nullptr;

		if (LuaScriptUtilities::IsUserdataType(
			luaVM, index, LUA_SCRIPT_TYPE_METATABLE))
		{
			LuaScriptType* const type =
				LuaScriptUtilities::GetDataType(luaVM, index);

			switch (type->type)
			{
			case SCRIPT_SANDBOX:
				sceneNode =
					static_cast<Sandbox*>(type->rawPointer)->GetRootNode();
				break;
			case SCRIPT_SANDBOX_OBJECT:
				sceneNode =
					static_cast<SandboxObject*>(type->rawPointer)->GetSceneNode();
				break;
			case SCRIPT_SCENENODE:
				sceneNode = static_cast<Ogre::SceneNode*>(type->rawPointer);
				break;
			default:
				break;
			}
		}
		else if (LuaScriptUtilities::IsUserdataType(
			luaVM, index, LUA_AGENT_METATABLE))
		{
			Agent* const agent = AgentUtilities::GetAgent(luaVM, index);

			if (agent)
			{
				sceneNode = AgentUtilities::GetSceneNode(agent);
			}
		}

		return sceneNode;
	}
} // anonymous namespace

int Lua_Script_AgentApplyForce(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Vector3* const force =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		AgentUtilities::ApplyForce(agent, *force);
	}
	return 0;
}

int Lua_Script_AgentEquals(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		const Agent* const agentLeft = AgentUtilities::GetAgent(luaVM, 1);
		const Agent* const agentRight = AgentUtilities::GetAgent(luaVM, 2);

		lua_pushboolean(luaVM, AgentUtilities::IsEqual(agentLeft, agentRight));

		return 1;
	}
	return 0;
}

int Lua_Script_AgentGetDistanceAlongPath(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);
		const Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, 2);

		return AgentUtilities::PushDistanceAlongPath(luaVM, agent, *position);
	}
	return 0;
}

int Lua_Script_AgentGetForward(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushForward(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetHealth(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushHealth(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetHeight(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushHeight(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetId(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushAgentId(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetLeft(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushLeft(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetMass(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushMass(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetMaxForce(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushMaxForce(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetMaxSpeed(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushMaxSpeed(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetNearestPointOnPath(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);
		const Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, 2);

		return AgentUtilities::PushNearestPointOnPath(luaVM, agent, *position);
	}
	return 0;
}

int Lua_Script_AgentGetPath(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushPath(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetPointOnPath(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);
		const Ogre::Real distance = LuaScriptUtilities::GetReal(luaVM, 2);

		return AgentUtilities::PushPointOnPath(luaVM, agent, distance);
	}
	return 0;
}

int Lua_Script_AgentGetPosition(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushPosition(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetRadius(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushRadius(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetSandbox(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushSandbox(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetSpeed(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushSpeed(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetTarget(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushTarget(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetTargetRadius(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushTargetRadius(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetTeam(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushTeam(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetUp(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushUp(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentGetVelocity(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushVelocity(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentHasPath(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		return AgentUtilities::PushHasPath(luaVM, agent);
	}
	return 0;
}

int Lua_Script_AgentForceToAlign(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 4)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);
		const Ogre::Real maxDistance = LuaScriptUtilities::GetReal(luaVM, 2);
		const Ogre::Real maxAngle = LuaScriptUtilities::GetReal(luaVM, 3);
		std::vector<Agent*> agents;

		agents.push_back(agent);

		lua_pushnil(luaVM);
		while (lua_next(luaVM, -2))
		{
			Agent* const groupAgent =
				AgentUtilities::GetAgent(luaVM, -1);

			agents.push_back(groupAgent);
			lua_pop(luaVM, 1);
		}
		lua_pop(luaVM, 1);

		return AgentUtilities::PushForceToAlign(
			luaVM, agent, maxDistance, maxAngle, agents);
	}
	return 0;
}

int Lua_Script_AgentForceToAvoidAgents(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -1);

		return AgentUtilities::PushForceToAvoidAgents(luaVM, agent);
	}
	else if (lua_gettop(luaVM) == 2)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real prediction = LuaScriptUtilities::GetReal(luaVM, -1);

		return AgentUtilities::PushForceToAvoidAgents(
			luaVM, agent, prediction);
	}
	return 0;
}

int Lua_Script_AgentForceToAvoidObjects(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -1);

		return AgentUtilities::PushForceToAvoidObjects(luaVM, agent);
	}
	else if (lua_gettop(luaVM) == 2)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real prediction = LuaScriptUtilities::GetReal(luaVM, -1);

		return AgentUtilities::PushForceToAvoidObjects(
			luaVM, agent, prediction);
	}
	return 0;
}

int Lua_Script_AgentForceToCombine(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 4)
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);
		const Ogre::Real maxDistance = LuaScriptUtilities::GetReal(luaVM, 2);
		const Ogre::Real maxAngle = LuaScriptUtilities::GetReal(luaVM, 3);
		std::vector<Agent*> agents;

		agents.push_back(agent);

		lua_pushnil(luaVM);
		while (lua_next(luaVM, -2))
		{
			Agent* const groupAgent =
				AgentUtilities::GetAgent(luaVM, -1);

			agents.push_back(groupAgent);
			lua_pop(luaVM, 1);
		}
		lua_pop(luaVM, 1);

		return AgentUtilities::PushForceToCombine(
			luaVM, agent, maxDistance, maxAngle, agents);
	}
	return 0;
}

int Lua_Script_AgentForceToFleePosition(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);
		const Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, 2);

		return AgentUtilities::PushForceToFleePosition(
			luaVM, agent, *position);
	}
	return 0;
}

int Lua_Script_AgentForceToFollowPath(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		if (lua_gettop(luaVM) == 1)
		{
			return AgentUtilities::PushForceToFollowPath(luaVM, agent);
		}
		else
		{
			const Ogre::Real predicition = LuaScriptUtilities::GetReal(luaVM, 2);

			return AgentUtilities::PushForceToFollowPath(
				luaVM, agent, predicition);
		}
	}

	return 0;
}

int Lua_Script_AgentForceToPosition(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);
		const Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, 2);

		return AgentUtilities::PushForceToPosition(luaVM, agent, *position);
	}
	return 0;
}

int Lua_Script_AgentForceToSeparate(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 4))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);
		const Ogre::Real maxDistance = LuaScriptUtilities::GetReal(luaVM, 2);
		const Ogre::Real maxAngle = LuaScriptUtilities::GetReal(luaVM, 3);
		std::vector<Agent*> agents;

		agents.push_back(agent);

		lua_pushnil(luaVM);
		while (lua_next(luaVM, -2))
		{
			Agent* const groupAgent = AgentUtilities::GetAgent(luaVM, -1);

			agents.push_back(groupAgent);
			lua_pop(luaVM, 1);
		}
		lua_pop(luaVM, 1);

		return AgentUtilities::PushForceToSeparate(
			luaVM, agent, maxDistance, maxAngle, agents);
	}

	return 0;
}

int Lua_Script_AgentForceToStayOnPath(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		if (lua_gettop(luaVM) == 1)
		{
			return AgentUtilities::PushForceToStayOnPath(luaVM, agent);
		}
		else
		{
			const Ogre::Real predicition = LuaScriptUtilities::GetReal(luaVM, 2);

			return AgentUtilities::PushForceToStayOnPath(
				luaVM, agent, predicition);
		}
	}

	return 0;
}

int Lua_Script_AgentForceToTargetSpeed(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real speed = LuaScriptUtilities::GetReal(luaVM, -1);

		return AgentUtilities::PushForceToTargetSpeed(luaVM, agent, speed);
	}
	return 0;
}

int Lua_Script_AgentForceToWander(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real deltaInMillis = LuaScriptUtilities::GetReal(luaVM, -1);

		return AgentUtilities::PushForceToWander(luaVM, agent, deltaInMillis);
	}
	return 0;
}

int Lua_Script_AgentIndex(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		assert(
			LuaScriptUtilities::IsUserdataType(luaVM, 1, LUA_AGENT_METATABLE));
		const Ogre::String function(luaL_checkstring(luaVM, 2));

		return AgentUtilities::PushFunction(luaVM, function);
	}

	return 0;
}

int Lua_Script_AgentIsAgent(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		lua_pushboolean(luaVM, agent != nullptr);
		return 1;
	}

	return 0;
}

int Lua_Script_AgentPredictFuturePosition(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);
		const Ogre::Real seconds = LuaScriptUtilities::GetReal(luaVM, 2);

		return AgentUtilities::PushPredictFuturePosition(luaVM, agent, seconds);
	}
	return 0;
}

int Lua_Script_AgentRemovePath(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		AgentUtilities::RemovePath(agent);
	}
	return 0;
}

int Lua_Script_AgentRemovePhysics(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		AgentUtilities::RemovePhysics(agent);
	}
	return 0;
}

int Lua_Script_AgentSetForward(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Vector3* const forward =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		AgentUtilities::SetForward(agent, *forward);
	}
	return 0;
}

int Lua_Script_AgentSetHealth(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real health = LuaScriptUtilities::GetReal(luaVM, -1);

		AgentUtilities::SetHealth(agent, health);
	}
	return 0;
}

int Lua_Script_AgentSetHeight(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real height = LuaScriptUtilities::GetReal(luaVM, -1);

		AgentUtilities::SetHeight(agent, height);
	}
	return 0;
}

int Lua_Script_AgentSetMass(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real mass = LuaScriptUtilities::GetReal(luaVM, -1);

		AgentUtilities::SetMass(agent, mass);
	}
	return 0;
}

int Lua_Script_AgentSetMaxForce(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real maxForce = LuaScriptUtilities::GetReal(luaVM, -1);

		AgentUtilities::SetMaxForce(agent, maxForce);
	}
	return 0;
}

int Lua_Script_AgentSetMaxSpeed(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real maxSpeed = LuaScriptUtilities::GetReal(luaVM, -1);

		AgentUtilities::SetMaxSpeed(agent, maxSpeed);
	}
	return 0;
}

int Lua_Script_AgentSetPath(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2, 1))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, 1);

		std::vector<Ogre::Vector3> points;

		lua_pushnil(luaVM);
		while (lua_next(luaVM, 2))
		{
			if (LuaScriptUtilities::IsVector3(luaVM, -1))
			{
				Ogre::Vector3* point =
					LuaScriptUtilities::GetVector3(luaVM, -1);

				points.push_back(*point);
			}
			lua_pop(luaVM, 1);
		}

		bool cyclic = false;

		if (lua_gettop(luaVM) == 3)
		{
			cyclic = lua_toboolean(luaVM, 3) == 1;
		}

		AgentUtilities::SetPath(agent, points, cyclic);
	}
	return 0;
}

int Lua_Script_AgentSetPosition(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		AgentUtilities::SetPosition(agent, *position);
	}
	return 0;
}

int Lua_Script_AgentSetRadius(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, -1);

		AgentUtilities::SetRadius(agent, radius);
	}
	return 0;
}

int Lua_Script_AgentSetSpeed(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real speed = LuaScriptUtilities::GetReal(luaVM, -1);

		AgentUtilities::SetSpeed(agent, speed);
	}
	return 0;
}

int Lua_Script_AgentSetTarget(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Vector3* const target =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		AgentUtilities::SetTarget(agent, *target);
	}
	return 0;
}

int Lua_Script_AgentSetTargetRadius(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, -1);

		AgentUtilities::SetTargetRadius(agent, radius);
	}
	return 0;
}

int Lua_Script_AgentSetTeam(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::String team = LuaScriptUtilities::GetString(luaVM, -1);

		AgentUtilities::SetTeam(agent, team);
	}
	return 0;
}

int Lua_Script_AgentSetVelocity(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Agent* const agent = AgentUtilities::GetAgent(luaVM, -2);
		const Ogre::Vector3* velocity = LuaScriptUtilities::GetVector3(luaVM, -1);

		AgentUtilities::SetVelocity(agent, *velocity);
	}
	return 0;
}

int Lua_Script_AgentToWatch(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1))
	{
		const Agent* const agent = AgentUtilities::GetAgent(luaVM, -1);
		return AgentUtilities::PushAgentProperties(luaVM, agent);
	}

	return 0;
}

int Lua_Script_AnimationAttachToBone(lua_State* luaVM)
{
	// TODO(David Young): Currently does not support SandboxObject.

	if (lua_gettop(luaVM) >= 3)
	{
		LuaScriptType* const type = LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::String boneName = lua_tostring(luaVM, 2);
		LuaScriptType* const type2 = LuaScriptUtilities::GetDataType(luaVM, 3);

		Ogre::SceneNode* const node1 = LuaScriptUtilities::GetSceneNode(*type);
		Ogre::SceneNode* const node2 = LuaScriptUtilities::GetSceneNode(*type2);

		if (lua_gettop(luaVM) == 3)
		{
			AnimationUtilities::AttachToBone(*node1, boneName, *node2);
		}
		else if (lua_gettop(luaVM) == 4)
		{
			Ogre::Vector3* const positionOffset =
				LuaScriptUtilities::GetVector3(luaVM, 4);

			AnimationUtilities::AttachToBone(
				*node1, boneName, *node2, *positionOffset);
		}
		else if (lua_gettop(luaVM) == 5)
		{
			Ogre::Vector3* const positionOffset =
				LuaScriptUtilities::GetVector3(luaVM, 4);
			Ogre::Vector3* const rotationOffset =
				LuaScriptUtilities::GetVector3(luaVM, 5);

			const Ogre::Quaternion rotation =
				LuaScriptUtilities::QuaternionFromRotationDegrees(
					*rotationOffset);

			AnimationUtilities::AttachToBone(
				*node1, boneName, *node2, *positionOffset, rotation);
		}
		else
		{
			return 0;
		}
	}

	return 0;
}

int Lua_Script_AnimationGetAnimation(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::String animationName(luaL_checkstring(luaVM, 2));

		Ogre::SceneNode* const node = LuaScriptUtilities::GetSceneNode(*type);

		if (node)
		{
			Ogre::Entity* const movableEntity =
				LuaScriptUtilities::GetEntity(*node);

			if (movableEntity)
			{
				Ogre::AnimationState* const animation =
					movableEntity->getAnimationState(animationName);

				if (animation)
				{
					return AnimationUtilities::PushAnimation(
						*luaVM, *animation);
				}
			}
		}
	}

	return 0;
}

int Lua_Script_AnimationGetBoneNames(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type = LuaScriptUtilities::GetDataType(luaVM, 1);

		Ogre::SceneNode* const node = LuaScriptUtilities::GetSceneNode(*type);

		if (node)
		{
			Ogre::Entity* const movableEntity =
				LuaScriptUtilities::GetEntity(*node);

			if (movableEntity)
			{
				return AnimationUtilities::PushBoneNames(
					*luaVM, *movableEntity);
			}
		}
	}

	return 0;
}

int Lua_Script_AnimationGetBonePosition(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::String boneName(luaL_checkstring(luaVM, 2));

		Ogre::SceneNode* const node = LuaScriptUtilities::GetSceneNode(*type);

		if (node)
		{
			Ogre::Vector3 position;
			if (AnimationUtilities::GetBonePosition(*node, boneName, position))
			{
				return LuaScriptUtilities::PushVector3(luaVM, position);
			}
		}
	}

	return 0;
}

int Lua_Script_AnimationGetBoneRotation(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::String boneName(luaL_checkstring(luaVM, 2));

		Ogre::SceneNode* const node = LuaScriptUtilities::GetSceneNode(*type);

		if (node)
		{
			Ogre::Quaternion orientation;
			if (AnimationUtilities::GetBoneOrientation(*node, boneName, orientation))
			{
				return LuaScriptUtilities::PushVector3(
					luaVM,
					LuaScriptUtilities::QuaternionToRotationDegrees(orientation));
			}
		}
	}

	return 0;
}

int Lua_Script_AnimationGetLength(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);

		return LuaScriptUtilities::PushReal(
			luaVM, AnimationUtilities::GetLength(*animation));
	}

	return 0;
}

int Lua_Script_AnimationGetName(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);

		return LuaScriptUtilities::PushString(
			luaVM, AnimationUtilities::GetName(*animation));
	}

	return 0;
}

int Lua_Script_AnimationGetNormalizedTime(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);

		return LuaScriptUtilities::PushReal(
			luaVM, AnimationUtilities::GetNormalizedTime(*animation));
	}

	return 0;
}

int Lua_Script_AnimationGetTime(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);

		return LuaScriptUtilities::PushReal(
			luaVM, AnimationUtilities::GetTime(*animation));
	}

	return 0;
}

int Lua_Script_AnimationGetWeight(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);

		return LuaScriptUtilities::PushReal(
			luaVM, AnimationUtilities::GetWeight(*animation));
	}

	return 0;
}

int Lua_Script_AnimationIsEnabled(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);

		lua_pushboolean(luaVM, AnimationUtilities::IsEnabled(*animation));

		return 1;
	}

	return 0;
}

int Lua_Script_AnimationIsLooping(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);

		lua_pushboolean(luaVM, AnimationUtilities::IsLooping(*animation));

		return 1;
	}

	return 0;
}

int Lua_Script_AnimationReset(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);

		AnimationUtilities::Reset(*animation);
	}

	return 0;
}

int Lua_Script_AnimationSetDisplaySkeleton(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		const bool enable = lua_toboolean(luaVM, 2) == 1;

		Ogre::SceneNode* const node = LuaScriptUtilities::GetSceneNode(*type);

		if (node)
		{
			Ogre::Entity* const entity = LuaScriptUtilities::GetEntity(*node);

			if (entity)
			{
				AnimationUtilities::SetDebugSkeleton(
					*entity, *node->getCreator(), enable);
			}
		}
	}

	return 0;
}

int Lua_Script_AnimationSetEnabled(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, -2);
		const bool enable = lua_toboolean(luaVM, -1) == 1;

		AnimationUtilities::SetEnable(*animation, enable);
	}

	return 0;
}

int Lua_Script_AnimationSetLooping(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, -2);
		const bool enable = lua_toboolean(luaVM, -1) == 1;

		AnimationUtilities::SetLooping(*animation, enable);
	}

	return 0;
}

int Lua_Script_AnimationSetNormalizedTime(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);
		const Ogre::Real normalizedTime =
			LuaScriptUtilities::GetReal(luaVM, 2);

		AnimationUtilities::SetNormalizedTime(*animation, normalizedTime);
	}

	return 0;
}

int Lua_Script_AnimationSetTime(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);
		const Ogre::Real time = LuaScriptUtilities::GetReal(luaVM, 2);

		AnimationUtilities::SetTime(*animation, time);
	}

	return 0;
}

int Lua_Script_AnimationSetWeight(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);
		const Ogre::Real weight = LuaScriptUtilities::GetReal(luaVM, 2);

		AnimationUtilities::SetWeight(*animation, weight);
	}

	return 0;
}

int Lua_Script_AnimationStepAnimation(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);
		const Ogre::Real deltaTimeInMillis =
			LuaScriptUtilities::GetReal(luaVM, 2);

		AnimationUtilities::StepAnimation(*animation, deltaTimeInMillis);
	}

	return 0;
}

int Lua_Script_AnimationToWatch(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::AnimationState* const animation =
			AnimationUtilities::GetAnimation(*luaVM, 1);

		return AnimationUtilities::PushAnimationProperties(*luaVM, *animation);
	}

	return 0;
}

// ɱ������rbӦ��һ����
int Lua_Script_CoreApplyForce(lua_State* luaVM)
{
    if (lua_gettop(luaVM) == 2) {
        LuaScriptType* const type =
                LuaScriptUtilities::GetDataType(luaVM, -2);
        const Ogre::Vector3* const force =
                LuaScriptUtilities::GetVector3(luaVM, -1);

        if (type && type->type == SCRIPT_SANDBOX_OBJECT) {
            SandboxObject* const object =
                    static_cast<SandboxObject*>(type->rawPointer);
            PhysicsUtilities::ApplyForce(
                    object->GetRigidBody(),
                    btVector3(force->x, force->y, force->z));
        }
    }

    return 0;
}

int Lua_Script_CoreApplyImpulse(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -2);
		const Ogre::Vector3* const impulse =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX_OBJECT)
		{
			SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);
			PhysicsUtilities::ApplyImpulse(
				object->GetRigidBody(),
				btVector3(impulse->x, impulse->y, impulse->z));
		}
	}

	return 0;
}

int Lua_Script_CoreApplyAngularImpulse(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -2);
		const Ogre::Vector3* const impulse =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX_OBJECT)
		{
			SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);
			PhysicsUtilities::ApplyTorqueImpulse(
				object->GetRigidBody(),
				btVector3(impulse->x, impulse->y, impulse->z));
		}
	}

	return 0;
}

int Lua_Script_CoreCacheResource(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		const Ogre::String resourceFileName(luaL_checkstring(luaVM, -1));

		LuaScriptUtilities::CacheResource(resourceFileName);
	}

	return 0;
}

int Lua_Script_CoreCreateBox(lua_State* luaVM)
{
	if (lua_gettop(luaVM) >= 4)
	{
		Ogre::SceneNode* sceneNode = GetSceneNodeFromIndex(luaVM, 1);
		const Ogre::Real width = LuaScriptUtilities::GetReal(luaVM, 2);
		const Ogre::Real height = LuaScriptUtilities::GetReal(luaVM, 3);
		const Ogre::Real length = LuaScriptUtilities::GetReal(luaVM, 4);
		Ogre::Real uTile = 1.0f;
		Ogre::Real vTile = 1.0f;

		if (lua_gettop(luaVM) >= 6)
		{
			uTile = LuaScriptUtilities::GetReal(luaVM, 5);
			vTile = LuaScriptUtilities::GetReal(luaVM, 6);
		}

		if (sceneNode)
		{
			Ogre::SceneNode* const box = LuaScriptUtilities::CreateBox(
				sceneNode, width, height, length, uTile, vTile);

			return LuaScriptUtilities::PushDataType(
				luaVM, box, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreCreateCapsule(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		Ogre::SceneNode* sceneNode = GetSceneNodeFromIndex(luaVM, -3);
		const Ogre::Real height = LuaScriptUtilities::GetReal(luaVM, -2);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, -1);

		if (sceneNode)
		{
			Ogre::SceneNode* const capsule = LuaScriptUtilities::CreateCapsule(
				sceneNode, height, radius);

			return LuaScriptUtilities::PushDataType(
				luaVM, capsule, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreCreateCircle(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::SceneNode* sceneNode = GetSceneNodeFromIndex(luaVM, -2);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, -1);

		if (sceneNode)
		{
			Ogre::SceneNode* const circle = LuaScriptUtilities::CreateCircle(
				sceneNode, radius);

			return LuaScriptUtilities::PushDataType(
				luaVM, circle, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreCreateCylinder(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		Ogre::SceneNode* sceneNode = GetSceneNodeFromIndex(luaVM, -3);
		const Ogre::Real height = LuaScriptUtilities::GetReal(luaVM, -2);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, -1);

		if (sceneNode)
		{
			Ogre::SceneNode* const capsule = LuaScriptUtilities::CreateCylinder(
				sceneNode, height, radius);

			return LuaScriptUtilities::PushDataType(
				luaVM, capsule, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreCreateDirectionalLight(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::SceneNode* const sceneNode = GetSceneNodeFromIndex(luaVM, -2);
		const Ogre::Vector3* const direction =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		if (sceneNode && direction)
		{
			Ogre::SceneNode* const light = sceneNode->createChildSceneNode();

			Ogre::Light* const lightEntity =
				sceneNode->getCreator()->createLight();

			lightEntity->setCastShadows(true);
			lightEntity->setType(Ogre::Light::LT_DIRECTIONAL);

			lightEntity->setDiffuseColour(1.0f, 1.0f, 1.0f);
			lightEntity->setSpecularColour(0, 0, 0);
			lightEntity->setDirection(*direction);

			light->attachObject(lightEntity);

			return LuaScriptUtilities::PushDataType(
				luaVM, light, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreCreateLine(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		Ogre::SceneNode* sceneNode = GetSceneNodeFromIndex(luaVM, -3);
		const Ogre::Vector3* start = LuaScriptUtilities::GetVector3(luaVM, -2);
		const Ogre::Vector3* end = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (sceneNode && start && end)
		{
			Ogre::SceneNode* const line = LuaScriptUtilities::CreateLine(
				sceneNode, *start, *end);

			return LuaScriptUtilities::PushDataType(
				luaVM, line, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreCreateMesh(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::SceneNode* const sceneNode = GetSceneNodeFromIndex(luaVM, -2);
		const Ogre::String meshFileName(luaL_checkstring(luaVM, -1));

		if (sceneNode)
		{
			Ogre::SceneNode* const mesh = LuaScriptUtilities::CreateMesh(
				sceneNode, meshFileName);

			return LuaScriptUtilities::PushDataType(
				luaVM, mesh, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreCreateParticle(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::SceneNode* const sceneNode = GetSceneNodeFromIndex(luaVM, 1);
		const Ogre::String partileName(luaL_checkstring(luaVM, 2));

		if (sceneNode)
		{
			Ogre::SceneNode* const particle = ParticleUtilities::CreateParticle(
				sceneNode, partileName);

			return LuaScriptUtilities::PushDataType(
				luaVM, particle, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreCreatePlane(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		Ogre::SceneNode* sceneNode = GetSceneNodeFromIndex(luaVM, -3);
		const Ogre::Real length = LuaScriptUtilities::GetReal(luaVM, -2);
		const Ogre::Real width = LuaScriptUtilities::GetReal(luaVM, -1);

		if (sceneNode)
		{
			Ogre::SceneNode* const plane = LuaScriptUtilities::CreatePlane(
				sceneNode, length, width);

			return LuaScriptUtilities::PushDataType(
				luaVM, plane, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreCreatePointLight(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::SceneNode* sceneNode = GetSceneNodeFromIndex(luaVM, -2);
		const Ogre::Vector3* position =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		if (sceneNode && position)
		{
			Ogre::SceneNode* const light = sceneNode->createChildSceneNode();
			light->setPosition(*position);

			Ogre::Light* const lightEntity =
				sceneNode->getCreator()->createLight();

			lightEntity->setCastShadows(true);
			lightEntity->setType(Ogre::Light::LT_POINT);

			lightEntity->setDiffuseColour(1.0f, 1.0f, 1.0f);
			lightEntity->setSpecularColour(0, 0, 0);

			const Ogre::Real range = 30;

			LuaScriptUtilities::SetLightRange(lightEntity, range);

			light->attachObject(lightEntity);

			return LuaScriptUtilities::PushDataType(
				luaVM, light, SCRIPT_SCENENODE);
		}
	}

	return 0;
}

int Lua_Script_CoreDrawCircle(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		const Ogre::Vector3* start = LuaScriptUtilities::GetVector3(luaVM, 1);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, 2);
		const Ogre::Vector3* color = LuaScriptUtilities::GetVector3(luaVM, 3);

		if (start && radius > 0 && color)
		{
			DebugDrawer::getSingleton().drawCircle(
				*start, radius, 10, Ogre::ColourValue(color->x, color->y, color->z));
		}
	}

	return 0;
}

int Lua_Script_CoreDrawLine(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		const Ogre::Vector3* start = LuaScriptUtilities::GetVector3(luaVM, 1);
		const Ogre::Vector3* end = LuaScriptUtilities::GetVector3(luaVM, 2);
		const Ogre::Vector3* color = LuaScriptUtilities::GetVector3(luaVM, 3);

		if (start && end && color)
		{
			DebugDrawer::getSingleton().drawLine(
				*start, *end, Ogre::ColourValue(color->x, color->y, color->z));
		}
	}

	return 0;
}

int Lua_Script_CoreDrawSphere(lua_State* luaVM)
{
	bool filled = false;

	if (lua_gettop(luaVM) == 4)
	{
		filled = lua_toboolean(luaVM, 4) == 1;
	}

	if (lua_gettop(luaVM) >= 3)
	{
		const Ogre::Vector3* position =
			LuaScriptUtilities::GetVector3(luaVM, 1);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, 2);
		const Ogre::Vector3* color = LuaScriptUtilities::GetVector3(luaVM, 3);

		if (position && color)
		{
			DebugDrawer::getSingleton().drawSphere(
				*position,
				radius,
				Ogre::ColourValue(color->x, color->y, color->z),
				filled);
		}
	}

	return 0;
}

int Lua_Script_CoreDrawSquare(lua_State* luaVM)
{
	bool filled = false;

	if (lua_gettop(luaVM) == 4)
	{
		filled = lua_toboolean(luaVM, 4) == 1;
	}

	if (lua_gettop(luaVM) >= 3)
	{
		const Ogre::Vector3* position =
			LuaScriptUtilities::GetVector3(luaVM, 1);
		const Ogre::Real length = LuaScriptUtilities::GetReal(luaVM, 2);
		const Ogre::Vector3* color = LuaScriptUtilities::GetVector3(luaVM, 3);

		if (position && color)
		{
			const float halfLength = length / 2.0f;

			Ogre::Vector3 square[4];

			square[0].x = (*position).x + halfLength;
			square[0].y = (*position).y;
			square[0].z = (*position).z + halfLength;

			square[1].x = (*position).x - halfLength;
			square[1].y = (*position).y;
			square[1].z = (*position).z + halfLength;

			square[2].x = (*position).x - halfLength;
			square[2].y = (*position).y;
			square[2].z = (*position).z - halfLength;

			square[3].x = (*position).x + halfLength;
			square[3].y = (*position).y;
			square[3].z = (*position).z - halfLength;

			DebugDrawer::getSingleton().drawQuad(
				square, Ogre::ColourValue(color->x, color->y, color->z), filled);
		}
	}

	return 0;
}

int Lua_Script_CoreGetMass(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX_OBJECT)
		{
			SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);

			Ogre::Real mass(
				PhysicsUtilities::GetRigidBodyMass(object->GetRigidBody()));

			return LuaScriptUtilities::PushReal(luaVM, mass);
		}
	}

	return 0;
}

int Lua_Script_CoreGetPosition(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type->type == SCRIPT_SCENENODE)
		{
			Ogre::SceneNode* const node =
				static_cast<Ogre::SceneNode*>(type->rawPointer);
			return LuaScriptUtilities::PushVector3(luaVM, node->getPosition());
		}
		else if (type->type == SCRIPT_SANDBOX_OBJECT)
		{
			SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);
			return LuaScriptUtilities::PushVector3(
				luaVM, object->GetPosition());
		}
	}

	return 0;
}

int Lua_Script_CoreGetRadius(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type->type == SCRIPT_SCENENODE)
		{
			Ogre::SceneNode* const node =
				static_cast<Ogre::SceneNode*>(type->rawPointer);

			return LuaScriptUtilities::PushReal(
				luaVM, LuaScriptUtilities::GetRadius(node));
		}
		else if (type->type == SCRIPT_SANDBOX_OBJECT)
		{
			SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);

			return LuaScriptUtilities::PushReal(
				luaVM,
				Ogre::Real(PhysicsUtilities::GetRigidBodyRadius(
					object->GetRigidBody())));
		}
	}

	return 0;
}

int Lua_Script_CoreGetRotation(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX_OBJECT)
		{
			SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);

			btQuaternion orientation = object->GetRigidBody()->getOrientation();
			Ogre::Quaternion rotation(
				orientation.w(),
				orientation.x(),
				orientation.y(),
				orientation.z());

			return LuaScriptUtilities::PushVector3(
				luaVM,
				Ogre::Vector3(
					rotation.getPitch().valueDegrees(),
					rotation.getYaw().valueDegrees(),
					rotation.getRoll().valueDegrees()));
		}
	}

	return 0;
}

int Lua_Script_CoreIsVisible(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::SceneNode* const node = LuaScriptUtilities::GetSceneNode(luaVM, 1);

		if (node)
		{
			lua_pushboolean(luaVM, LuaScriptUtilities::IsVisisble(node));
			return 1;
		}
	}

	return 0;
}

int Lua_Script_CoreRemove(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::SceneNode* const node = LuaScriptUtilities::GetSceneNode(luaVM, 1);

		if (node)
		{
			LuaScriptUtilities::Remove(node);
		}
	}

	return 0;
}

int Lua_Script_CoreRequireLuaModule(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		const Ogre::String moduleName(luaL_checkstring(luaVM, -1));

		lua_getglobal(luaVM, "package");
		assert(lua_istable(luaVM, -1));

		const int packageTableIndex = lua_gettop(luaVM);
		lua_pushstring(luaVM, "loaded");
		lua_gettable(luaVM, packageTableIndex);
		assert(lua_istable(luaVM, -1));

		const int loadedTableIndex = lua_gettop(luaVM);

		lua_pushstring(luaVM, moduleName.c_str());
		lua_gettable(luaVM, loadedTableIndex);

		if (lua_isnil(luaVM, -1))
		{
			// Module hasn't been loaded yet.
			LuaScriptUtilities::RequireLuaModule(luaVM, moduleName + ".lua");

			// Mark that the Module is loaded.
			LuaScriptUtilities::PushBoolAttribute(
				luaVM, true, moduleName, loadedTableIndex);
		}
	}

	return 0;
}

int Lua_Script_CoreResetParticle(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::SceneNode* sceneNode = GetSceneNodeFromIndex(luaVM, 1);
		ParticleUtilities::Reset(sceneNode);
	}

	return 0;
}

int Lua_Script_CoreSetAxis(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 4)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::Vector3* const xAxis =
			LuaScriptUtilities::GetVector3(luaVM, 2);
		const Ogre::Vector3* const yAxis =
			LuaScriptUtilities::GetVector3(luaVM, 3);
		const Ogre::Vector3* const zAxis =
			LuaScriptUtilities::GetVector3(luaVM, 4);

		Ogre::Quaternion rotation(*xAxis, *yAxis, *zAxis);

		if (!type)
		{
			return 0;
		}

		if (type->type == SCRIPT_SCENENODE)
		{
			Ogre::SceneNode* const node =
				static_cast<Ogre::SceneNode*>(type->rawPointer);
			node->setOrientation(rotation);
		}
		else if (type->type == SCRIPT_SANDBOX_OBJECT)
		{
			SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);
			object->SetOrientation(rotation);
		}

		return 1;
	}

	return 0;
}

int Lua_Script_CoreSetGravity(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		SandboxObject* const object =
			LuaScriptUtilities::GetSandboxObject(luaVM, -2);
		Ogre::Vector3* const gravity = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (object)
		{
			PhysicsUtilities::SetRigidBodyGravity(
				object->GetRigidBody(),
				btVector3(gravity->x, gravity->y, gravity->z));
		}
	}

	return 0;
}

int Lua_Script_CoreSetLightDiffuse(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::Light* const light = LuaScriptUtilities::GetLight(luaVM, -2);
		Ogre::Vector3* const vector = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (light)
		{
			light->setDiffuseColour(vector->x, vector->y, vector->z);
		}
	}

	return 0;
}

int Lua_Script_CoreSetLightRange(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::Light* const light = LuaScriptUtilities::GetLight(luaVM, -2);
		Ogre::Real const range = LuaScriptUtilities::GetReal(luaVM, -1);

		if (light)
		{
			LuaScriptUtilities::SetLightRange(light, range);
		}
	}

	return 0;
}

int Lua_Script_CoreSetLightSpecular(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::Light* const light = LuaScriptUtilities::GetLight(luaVM, -2);
		Ogre::Vector3* const vector = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (light)
		{
			light->setSpecularColour(vector->x, vector->y, vector->z);
		}
	}

	return 0;
}

int Lua_Script_CoreSetLineStartEnd(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		Ogre::SceneNode* sceneNode = GetSceneNodeFromIndex(luaVM, -3);
		const Ogre::Vector3* start = LuaScriptUtilities::GetVector3(luaVM, -2);
		const Ogre::Vector3* end = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (sceneNode)
		{
			LuaScriptUtilities::SetLineStartEnd(sceneNode, *start, *end);
		}
	}

	return 0;
}

int Lua_Script_CoreSetMass(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		SandboxObject* const object =
			LuaScriptUtilities::GetSandboxObject(luaVM, -2);
		const Ogre::Real mass = LuaScriptUtilities::GetReal(luaVM, -1);

		if (object)
		{
			PhysicsUtilities::SetRigidBodyMass(object->GetRigidBody(), mass);
		}
	}

	return 0;
}

int Lua_Script_CoreSetMaterial(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -2);
		const Ogre::String materialName(luaL_checkstring(luaVM, -1));

		if (type)
		{
			Ogre::SceneNode* node = LuaScriptUtilities::GetSceneNode(luaVM, -2);

			if (!node)
			{
				return 0;
			}

			Ogre::SceneNode::ObjectIterator it =
				node->getAttachedObjectIterator();

			while (it.hasMoreElements())
			{
				const Ogre::String movableType =
					it.current()->second->getMovableType();

				if (movableType == Ogre::EntityFactory::FACTORY_TYPE_NAME)
				{
					Ogre::Entity* const entity =
						static_cast<Ogre::Entity*>(it.current()->second);
					entity->setMaterialName(materialName);
				}
				else if (movableType ==
					Ogre::ManualObjectFactory::FACTORY_TYPE_NAME)
				{
					Ogre::ManualObject* const entity =
						static_cast<Ogre::ManualObject*>(it.current()->second);
					unsigned int sections = entity->getNumSections();

					for (unsigned int id = 0; id < sections; ++id)
					{
						entity->setMaterialName(id, materialName);
					}
				}

				it.getNext();
			}
		}
	}

	return 0;
}

int Lua_Script_CoreSetParticleDirection(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -2);
		const Ogre::Vector3* const direction =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		if (type && type->type == SCRIPT_SCENENODE)
		{
			Ogre::SceneNode* const particle =
				static_cast<Ogre::SceneNode*>(type->rawPointer);
			ParticleUtilities::SetDirection(particle, *direction);
		}
	}

	return 0;
}

int Lua_Script_CoreSetPosition(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -2);
		const Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		if (type && type->type == SCRIPT_SCENENODE)
		{
			Ogre::SceneNode* const node =
				static_cast<Ogre::SceneNode*>(type->rawPointer);
			node->setPosition(*position);
		}
		else if (type && type->type == SCRIPT_SANDBOX_OBJECT)
		{
			SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);
			object->SetPosition(*position);
		}
	}

	return 0;
}

int Lua_Script_CoreSetRotation(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -2);
		const Ogre::Vector3* const angles =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		const Ogre::Quaternion rotation =
			LuaScriptUtilities::QuaternionFromRotationDegrees(
				angles->x, angles->y, angles->z);

		if (!type)
		{
			return 0;
		}

		if (type->type == SCRIPT_SCENENODE)
		{
			Ogre::SceneNode* const node =
				static_cast<Ogre::SceneNode*>(type->rawPointer);
			node->setOrientation(rotation);
		}
		else if (type->type == SCRIPT_SANDBOX_OBJECT)
		{
			SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);
			object->SetOrientation(rotation);
		}
	}

	return 0;
}

int Lua_Script_CoreSetVisible(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::SceneNode* const node = LuaScriptUtilities::GetSceneNode(luaVM, 1);
		const bool visible = lua_toboolean(luaVM, 2) == 1;

		if (node)
		{
			node->setVisible(visible);
		}
	}

	return 0;
}

int Lua_Script_CoreTypeToWatch(lua_State* luaVM)
{
	assert(lua_gettop(luaVM) == 1);
	const LuaScriptType* const type =
		LuaScriptUtilities::GetDataType(luaVM, -1);

	Ogre::Vector3 position;

	switch (type->type)
	{
	case SCRIPT_SANDBOX:
		{
			const Sandbox* const sandbox =
				static_cast<Sandbox*>(type->rawPointer);
			position = sandbox->GetRootNode()->getPosition();
			lua_pushstring(luaVM, "Sandbox");
			break;
		}
	case SCRIPT_SCENENODE:
		{
			position =
				static_cast<Ogre::SceneNode*>(type->rawPointer)->getPosition();
			lua_pushstring(luaVM, "SceneNode");
			break;
		}
	case SCRIPT_SANDBOX_OBJECT:
		{
			position =
				static_cast<SandboxObject*>(type->rawPointer)->GetPosition();
			lua_pushstring(luaVM, "SandboxObject");
			break;
		}
	default:
		assert(false);
		return 0;
		break;
	}

	lua_newtable(luaVM);
	const int properties = lua_gettop(luaVM);

	LuaScriptUtilities::PushVector3Attribute(
		luaVM, position, "position", properties);

	switch (type->type)
	{
	case SCRIPT_SANDBOX_OBJECT:
		{
			const SandboxObject* const object =
				static_cast<SandboxObject*>(type->rawPointer);

			LuaScriptUtilities::PushRealAttribute(
				luaVM, object->GetMass(), "mass", properties);

			break;
		}
	default:
		break;
	}

	return 2;
}

int Lua_Script_SandboxAddCollisionCallback(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		LuaScriptType* const sandboxType =
			LuaScriptUtilities::GetDataType(luaVM, 1);

		LuaScriptType* const objectType =
			LuaScriptUtilities::GetDataType(luaVM, 2);

		const int functionIndex = luaL_ref(luaVM, LUA_REGISTRYINDEX);

		if (sandboxType &&
			objectType &&
			sandboxType->type == SCRIPT_SANDBOX &&
			objectType->type == SCRIPT_SANDBOX_OBJECT)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(
				sandboxType->rawPointer);
			SandboxObject* const sandboxObject = static_cast<SandboxObject*>(
				objectType->rawPointer);

			SandboxUtilities::AddCollisionCallback(
				sandbox, sandboxObject, luaVM, functionIndex);
		}
	}

	return 0;
}

int Lua_Script_SandboxAddEvent(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		Ogre::String eventType = LuaScriptUtilities::GetString(luaVM, 2);

		Event event(eventType);
		SandboxUtilities::GetEvent(luaVM, 3, event);

		SandboxUtilities::AddEvent(sandbox, event);
	}

	return 0;
}

int Lua_Script_SandboxAddEventCallback(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		Object* const object = LuaScriptUtilities::GetObject(luaVM, 2);

		const int functionIndex = luaL_ref(luaVM, LUA_REGISTRYINDEX);

		if (sandbox)
		{
			if (object)
			{
				SandboxUtilities::AddEventCallback(
					sandbox, object, luaVM, functionIndex);
			}
		}
	}

	return 0;
}

int Lua_Script_SandboxClearInfluenceMap(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const size_t layer =
			static_cast<size_t>(LuaScriptUtilities::GetReal(luaVM, 2));

		SandboxUtilities::ClearInfluenceMap(sandbox, layer);
	}

	return 0;
}

int Lua_Script_SandboxCreateAgent(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type = LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::String scriptFileName(luaL_checkstring(luaVM, 2));

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);
			Agent* const agent =
				SandboxUtilities::CreateAgent(sandbox, scriptFileName);

			return AgentUtilities::PushAgent(luaVM, agent);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreateBox(lua_State* luaVM)
{
	if (lua_gettop(luaVM) >= 4)
	{
		LuaScriptType* const type = LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::Real width = LuaScriptUtilities::GetReal(luaVM, 2);
		const Ogre::Real height = LuaScriptUtilities::GetReal(luaVM, 3);
		const Ogre::Real length = LuaScriptUtilities::GetReal(luaVM, 4);
		Ogre::Real uTile = 1.0f;
		Ogre::Real vTile = 1.0f;

		if (lua_gettop(luaVM) >= 6)
		{
			uTile = LuaScriptUtilities::GetReal(luaVM, 5);
			vTile = LuaScriptUtilities::GetReal(luaVM, 6);
		}

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);
			SandboxObject* const object =
				SandboxUtilities::CreateSandboxBox(
					sandbox, width, height, length, uTile, vTile);

			return LuaScriptUtilities::PushDataType(
				luaVM, object, SCRIPT_SANDBOX_OBJECT);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreateCapsule(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		LuaScriptType* const type = LuaScriptUtilities::GetDataType(luaVM, -3);
		const Ogre::Real height = LuaScriptUtilities::GetReal(luaVM, -2);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);
			SandboxObject* const object =
				SandboxUtilities::CreateSandboxCapsule(sandbox, height, radius);

			return LuaScriptUtilities::PushDataType(
				luaVM, object, SCRIPT_SANDBOX_OBJECT);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreateInfluenceMap(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2, 1))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const Ogre::String name = LuaScriptUtilities::GetString(luaVM, 2);
		InfluenceMapConfig config =
			InfluenceMapUtilities::GetInfluenceMapConfig(luaVM, 3);

		if (sandbox)
		{
			SandboxUtilities::CreateInfluenceMap(sandbox, config, name);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreateNavigationMesh(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2, 1))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const Ogre::String name = LuaScriptUtilities::GetString(luaVM, 2);
		rcConfig config =
			NavigationUtilities::GetNavigationMeshConfig(luaVM, 3);

		if (sandbox)
		{
			SandboxUtilities::CreateNavigationMesh(sandbox, config, name);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreateObject(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type = LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::String meshFileName(luaL_checkstring(luaVM, 2));

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			SandboxObject* const object =
				SandboxUtilities::CreateSandboxObject(sandbox, meshFileName);

			return LuaScriptUtilities::PushDataType(
				luaVM, object, SCRIPT_SANDBOX_OBJECT);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreatePhysicsCapsule(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		LuaScriptType* const type = LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::Real height = LuaScriptUtilities::GetReal(luaVM, 2);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, 3);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			SandboxObject* const object =
				SandboxUtilities::CreatePhysicsCapsule(sandbox, height, radius);

			return LuaScriptUtilities::PushDataType(
				luaVM, object, SCRIPT_SANDBOX_OBJECT);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreatePhysicsSphere(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type = LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::Real radius = LuaScriptUtilities::GetReal(luaVM, 2);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			SandboxObject* const object =
				SandboxUtilities::CreatePhysicsSphere(sandbox, radius);

			return LuaScriptUtilities::PushDataType(
				luaVM, object, SCRIPT_SANDBOX_OBJECT);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreatePlane(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 3)
	{
		LuaScriptType* const type = LuaScriptUtilities::GetDataType(luaVM, -3);
		const Ogre::Real length = LuaScriptUtilities::GetReal(luaVM, -2);
		const Ogre::Real width = LuaScriptUtilities::GetReal(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			SandboxObject* const object =
				SandboxUtilities::CreateSandboxPlane(sandbox, length, width);

			return LuaScriptUtilities::PushDataType(
				luaVM, object, SCRIPT_SANDBOX_OBJECT);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreateSkyBox(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::String materialName(luaL_checkstring(luaVM, 2));

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);
			SandboxUtilities::CreateSkyBox(sandbox, materialName);
		}
	}
	else if (lua_gettop(luaVM) == 3)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		const Ogre::String materialName(luaL_checkstring(luaVM, 2));
		const Ogre::Vector3* const rotation =
			LuaScriptUtilities::GetVector3(luaVM, 3);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			const Ogre::Quaternion orientation =
				LuaScriptUtilities::QuaternionFromRotationDegrees(
					rotation->x, rotation->y, rotation->z);

			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);
			SandboxUtilities::CreateSkyBox(
				sandbox, materialName, orientation);
		}
	}

	return 0;
}

int Lua_Script_SandboxCreateUIComponent(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const size_t uiLayer =
			static_cast<size_t>(LuaScriptUtilities::GetReal(luaVM, 2));

		UserInterfaceComponent* const component =
			SandboxUtilities::CreateUIComponent(sandbox, uiLayer);

		return UserInterfaceUtilities::PushUserInterfaceComponent(
			*luaVM, *component);
	}

	return 0;
}

int Lua_Script_SandboxCreateUIComponent3d(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, 2);

		UserInterfaceComponent* const component =
			SandboxUtilities::CreateUIComponent3d(sandbox, *position);

		return UserInterfaceUtilities::PushUserInterfaceComponent(
			*luaVM, *component);
	}

	return 0;
}

int Lua_Script_SandboxDrawInfluenceMap(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 5))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const size_t influenceLayer =
			static_cast<size_t>(LuaScriptUtilities::GetReal(luaVM, 2));
		Ogre::ColourValue positiveColor = LuaScriptUtilities::GetColourValue(luaVM, 3);
		Ogre::ColourValue neutralColor = LuaScriptUtilities::GetColourValue(luaVM, 4);
		Ogre::ColourValue negativeColor = LuaScriptUtilities::GetColourValue(luaVM, 5);

		if (sandbox)
		{
			sandbox->DrawInfluenceMap(
				influenceLayer, positiveColor, neutralColor, negativeColor);
		}
	}

	return 0;
}

int Lua_Script_SandboxFindClosestPoint(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const Ogre::String name = LuaScriptUtilities::GetString(luaVM, 2);
		Ogre::Vector3* const point = LuaScriptUtilities::GetVector3(luaVM, 3);

		if (sandbox && point)
		{
			Ogre::Vector3 closestPoint =
				SandboxUtilities::FindClosestPoint(sandbox, name, *point);

			return LuaScriptUtilities::PushVector3(luaVM, closestPoint);
		}
	}

	return 0;
}

int Lua_Script_SandboxFindPath(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 4))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const Ogre::String name = LuaScriptUtilities::GetString(luaVM, 2);
		Ogre::Vector3* startPoint = LuaScriptUtilities::GetVector3(luaVM, 3);
		Ogre::Vector3* endPoint = LuaScriptUtilities::GetVector3(luaVM, 4);

		if (sandbox && startPoint && endPoint)
		{
			std::vector<Ogre::Vector3> path;

			SandboxUtilities::FindPath(
				sandbox, name, *startPoint, *endPoint, path);

			return SandboxUtilities::PushPath(luaVM, path);
		}
	}

	return 0;
}

int Lua_Script_SandboxGetAgents(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			std::vector<Agent*> agents = sandbox->GetAgents();

			lua_newtable(luaVM);
			const int tableIndex = lua_gettop(luaVM);

			std::vector<Agent*>::iterator it;
			size_t count = 1;

			for (it = agents.begin(); it != agents.end(); ++it)
			{
				lua_pushinteger(luaVM, count);
				AgentUtilities::PushAgent(luaVM, *it);
				lua_settable(luaVM, tableIndex);

				++count;
			}

			return 1;
		}
	}

	return 0;
}

int Lua_Script_SandboxGetCameraForward(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			return LuaScriptUtilities::PushVector3(
				luaVM, sandbox->GetCameraForward());
		}
	}

	return 0;
}

int Lua_Script_SandboxGetCameraLeft(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			return LuaScriptUtilities::PushVector3(
				luaVM, sandbox->GetCameraLeft());
		}
	}

	return 0;
}

int Lua_Script_SandboxGetCameraOrientation(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			Ogre::Quaternion rotation = sandbox->GetCameraOrientation();
			return LuaScriptUtilities::PushVector3(
				luaVM, LuaScriptUtilities::QuaternionToRotationDegrees(rotation));
		}
	}

	return 0;
}

int Lua_Script_SandboxGetCameraPosition(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			return LuaScriptUtilities::PushVector3(
				luaVM, sandbox->GetCameraPosition());
		}
	}

	return 0;
}

int Lua_Script_SandboxGetCameraUp(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			return LuaScriptUtilities::PushVector3(
				luaVM, sandbox->GetCameraUp());
		}
	}

	return 0;
}

int Lua_Script_SandboxGetDrawPhysicsWorld(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			lua_pushboolean(
				luaVM, SandboxUtilities::GetDrawPhysicsWorld(sandbox));

			return 1;
		}
	}

	return 0;
}

int Lua_Script_SandboxGetInertia(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const size_t layer =
			static_cast<size_t>(LuaScriptUtilities::GetReal(luaVM, 2));
		Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, 3);

		return LuaScriptUtilities::PushReal(
			luaVM, SandboxUtilities::GetInertia(sandbox, layer, *position));
	}

	return 0;
}

int Lua_Script_SandboxGetObjects(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			std::map<unsigned int, SandboxObject*> objects =
				sandbox->GetObjects();

			std::map<unsigned int, SandboxObject*>::iterator it;

			lua_newtable(luaVM);
			const int tableIndex = lua_gettop(luaVM);

			size_t count = 1;

			for (it = objects.begin(); it != objects.end(); ++it)
			{
				lua_pushinteger(luaVM, count);
				LuaScriptUtilities::PushDataType(
					luaVM, it->second, SCRIPT_SANDBOX_OBJECT);

				lua_settable(luaVM, tableIndex);

				++count;
			}

			return 1;
		}
	}

	return 0;
}

int Lua_Script_SandboxGetProfileRenderTime(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);

		if (sandbox)
		{
			const Ogre::Real time = static_cast<Ogre::Real>(
				SandboxUtilities::GetProfileRenderTime(sandbox));

			return LuaScriptUtilities::PushReal(luaVM, time);
		}
	}

	return 0;
}

int Lua_Script_SandboxGetProfileSimTime(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);

		if (sandbox)
		{
			const Ogre::Real time = static_cast<Ogre::Real>(
				SandboxUtilities::GetProfileSimTime(sandbox));

			return LuaScriptUtilities::PushReal(luaVM, time);
		}
	}

	return 0;
}

int Lua_Script_SandboxGetProfileTotalSimTime(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);

		if (sandbox)
		{
			const Ogre::Real time = static_cast<Ogre::Real>(
				SandboxUtilities::GetProfileTotalSimTime(sandbox));

			return LuaScriptUtilities::PushReal(luaVM, time);
		}
	}

	return 0;
}

int Lua_Script_SandboxGetMarkupColor(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const int index = static_cast<int>(
			LuaScriptUtilities::GetReal(luaVM, 2));

		return SandboxUtilities::PushMarkupColor(
			luaVM, sandbox, index);
	}

	return 0;
}

int Lua_Script_SandboxGetScreenHeight(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);

		return SandboxUtilities::PushScreenHeight(luaVM, sandbox);
	}

	return 0;
}

int Lua_Script_SandboxGetScreenWidth(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 1))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);

		return SandboxUtilities::PushScreenWidth(luaVM, sandbox);
	}

	return 0;
}

int Lua_Script_SandboxGetTimeInMillis(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			return LuaScriptUtilities::PushReal(
				luaVM, SandboxUtilities::GetTimeInMillis(sandbox));
		}
	}

	return 0;
}

int Lua_Script_SandboxGetTimeInSeconds(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			return LuaScriptUtilities::PushReal(
				luaVM, SandboxUtilities::GetTimeInSeconds(sandbox));
		}
	}

	return 0;
}

int Lua_Script_SandboxRandomPoint(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const Ogre::String name = LuaScriptUtilities::GetString(luaVM, 2);

		if (sandbox)
		{
			return LuaScriptUtilities::PushVector3(
				luaVM, SandboxUtilities::RandomPoint(sandbox, name));
		}
	}

	return 0;
}

int Lua_Script_SandboxRayCastToObject(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		Ogre::Vector3* const from = LuaScriptUtilities::GetVector3(luaVM, 2);
		Ogre::Vector3* const to = LuaScriptUtilities::GetVector3(luaVM, 3);
		Ogre::Vector3 hitPoint;
		Object* object;

		const bool result = SandboxUtilities::RayCastToObject(
			sandbox, *from, *to, hitPoint, object);

		lua_newtable(luaVM);
		const int tableIndex = lua_gettop(luaVM);
		LuaScriptUtilities::PushBoolAttribute(luaVM, result, "result", tableIndex);

		if (result)
		{
			LuaScriptUtilities::PushVector3Attribute(
				luaVM, hitPoint, "hitPoint", tableIndex);
			SandboxUtilities::PushObjectAttribute(
				luaVM, object, "object", tableIndex);
		}

		return 1;
	}

	return 0;
}

int Lua_Script_SandboxRemoveObject(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		LuaScriptType* const object =
			LuaScriptUtilities::GetDataType(luaVM, 2);

		if (type &&
			object &&
			type->type == SCRIPT_SANDBOX &&
			object->type == SCRIPT_SANDBOX_OBJECT)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);
			SandboxObject* const sandboxObject =
				static_cast<SandboxObject*>(object->rawPointer);

			SandboxUtilities::RemoveSandboxObject(sandbox, sandboxObject);
		}
	}

	return 0;
}

int Lua_Script_SandboxSetAmbientLight(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -2);
		Ogre::Vector3* const light = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			SandboxUtilities::SetAmbientLight(sandbox, *light);
		}
	}

	return 0;
}

int Lua_Script_SandboxSetCameraForward(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		Ogre::Vector3* const forward =
			LuaScriptUtilities::GetVector3(luaVM, 2);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			SandboxUtilities::SetCameraForward(sandbox, *forward);
		}
	}

	return 0;
}

int Lua_Script_SandboxSetCameraOrientation(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, -2);
		const Ogre::Vector3* const angles =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		const Ogre::Quaternion rotation =
			LuaScriptUtilities::QuaternionFromRotationDegrees(
				angles->x, angles->y, angles->z);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			SandboxUtilities::SetCameraOrientation(sandbox, rotation);
		}
	}

	return 0;
}

int Lua_Script_SandboxSetCameraPosition(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		LuaScriptType* const type =
			LuaScriptUtilities::GetDataType(luaVM, 1);
		Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, 2);

		if (type && type->type == SCRIPT_SANDBOX)
		{
			Sandbox* const sandbox = static_cast<Sandbox*>(type->rawPointer);

			SandboxUtilities::SetCameraPosition(sandbox, *position);
		}
	}

	return 0;
}

int Lua_Script_SandboxSetDebugNavigationMesh(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const Ogre::String name = LuaScriptUtilities::GetString(luaVM, 2);
		const bool debugNavMesh = lua_toboolean(luaVM, 3) == 1;

		if (sandbox)
		{
			SandboxUtilities::SetDebugNavigationMesh(
				sandbox, name, debugNavMesh);
		}
	}

	return 0;
}

int Lua_Script_SandboxSetDrawInfluenceMap(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const bool drawInfluenceMap = lua_toboolean(luaVM, 2) == 1;

		SandboxUtilities::SetDrawInfluenceMap(sandbox, drawInfluenceMap);
	}

	return 0;
}

int Lua_Script_SandboxSetDrawPhysicsWorld(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const bool drawPhysicsWorld = lua_toboolean(luaVM, 2) == 1;

		SandboxUtilities::SetDrawPhysicsWorld(sandbox, drawPhysicsWorld);
	}

	return 0;
}

int Lua_Script_SandboxSetFalloff(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const size_t layer =
			static_cast<size_t>(LuaScriptUtilities::GetReal(luaVM, 2));
		const Ogre::Real value = LuaScriptUtilities::GetReal(luaVM, 3);

		SandboxUtilities::SetFalloff(sandbox, layer, value);
	}

	return 0;
}

int Lua_Script_SandboxSetInertia(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const size_t layer =
			static_cast<size_t>(LuaScriptUtilities::GetReal(luaVM, 2));
		const Ogre::Real value = LuaScriptUtilities::GetReal(luaVM, 3);

		SandboxUtilities::SetInertia(sandbox, layer, value);
	}

	return 0;
}

int Lua_Script_SandboxSetInfluence(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 4))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const size_t layer =
			static_cast<size_t>(LuaScriptUtilities::GetReal(luaVM, 2));
		const Ogre::Vector3* const position =
			LuaScriptUtilities::GetVector3(luaVM, 3);
		const Ogre::Real value = LuaScriptUtilities::GetReal(luaVM, 4);

		SandboxUtilities::SetInfluence(sandbox, layer, *position, value);
	}

	return 0;
}

int Lua_Script_SandboxSetMarkupColor(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 5, 6))
	{
		Ogre::Real alpha = 1.0f;

		if (lua_gettop(luaVM) == 6)
		{
			alpha = LuaScriptUtilities::GetReal(luaVM, 6);
		}

		SandboxUtilities::SetMarkupColor(
			LuaScriptUtilities::GetSandbox(luaVM, 1),
			static_cast<int>(LuaScriptUtilities::GetReal(luaVM, 2)),
			LuaScriptUtilities::GetReal(luaVM, 3),
			LuaScriptUtilities::GetReal(luaVM, 4),
			LuaScriptUtilities::GetReal(luaVM, 5),
			alpha);
	}

	return 0;
}

int Lua_Script_SandboxSpreadInfluenceMap(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Sandbox* const sandbox = LuaScriptUtilities::GetSandbox(luaVM, 1);
		const size_t layer =
			static_cast<size_t>(LuaScriptUtilities::GetReal(luaVM, 2));

		SandboxUtilities::SpreadInfluenceMap(sandbox, layer);
	}

	return 0;
}

int Lua_Script_Vector3Add(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		if (LuaScriptUtilities::IsUserdataType(luaVM, 1, LUA_VECTOR3_METATABLE))
		{
			// Left value is a Vector3.
			Ogre::Vector3* left = LuaScriptUtilities::GetVector3(luaVM, 1);

			if (lua_isnumber(luaVM, 2))
			{
				// Right value is a Real.
				Ogre::Real right = LuaScriptUtilities::GetReal(luaVM, 2);
				return LuaScriptUtilities::PushVector3(luaVM, *left + right);
			}
			else if (LuaScriptUtilities::IsVector3(luaVM, 2))
			{
				// Right value is a Vector3.
				Ogre::Vector3* right = LuaScriptUtilities::GetVector3(luaVM, 2);
				return LuaScriptUtilities::PushVector3(luaVM, *left + *right);
			}
		}
	}
	return 0;
}

int Lua_Script_Vector3CrossProduct(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::Vector3* const left = LuaScriptUtilities::GetVector3(luaVM, -2);
		Ogre::Vector3* const right = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (left && right)
		{
			return LuaScriptUtilities::PushVector3(
				luaVM, left->crossProduct(*right));
		}
	}
	return 0;
}

int Lua_Script_Vector3Distance(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::Vector3* const left = LuaScriptUtilities::GetVector3(luaVM, -2);
		Ogre::Vector3* const right = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (left && right)
		{
			return LuaScriptUtilities::PushReal(
				luaVM, left->distance(*right));
		}
	}
	return 0;
}

int Lua_Script_Vector3DistanceSquared(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::Vector3* const left = LuaScriptUtilities::GetVector3(luaVM, -2);
		Ogre::Vector3* const right = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (left && right)
		{
			return LuaScriptUtilities::PushReal(
				luaVM, left->squaredDistance(*right));
		}
	}
	return 0;
}

int Lua_Script_Vector3Divide(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		if (LuaScriptUtilities::IsUserdataType(luaVM, 1, LUA_VECTOR3_METATABLE))
		{
			// Left value is a Vector3.
			Ogre::Vector3* left = LuaScriptUtilities::GetVector3(luaVM, 1);

			if (lua_isnumber(luaVM, 2))
			{
				// Right value is a Real.
				Ogre::Real right = LuaScriptUtilities::GetReal(luaVM, 2);
				return LuaScriptUtilities::PushVector3(luaVM, *left / right);
			}
			else if (LuaScriptUtilities::IsVector3(luaVM, 2))
			{
				// Right value is a Vector3.
				Ogre::Vector3* right = LuaScriptUtilities::GetVector3(luaVM, 2);
				return LuaScriptUtilities::PushVector3(luaVM, *left / *right);
			}
		}
	}
	return 0;
}

int Lua_Script_Vector3DotProduct(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		const Ogre::Vector3* const left = LuaScriptUtilities::GetVector3(luaVM, 1);
		const Ogre::Vector3* const right = LuaScriptUtilities::GetVector3(luaVM, 2);

		return LuaScriptUtilities::PushReal(luaVM, (*left).dotProduct(*right));
	}
	return 0;
}

int Lua_Script_Vector3Equal(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		Ogre::Vector3* left = LuaScriptUtilities::GetVector3(luaVM, 1);
		Ogre::Vector3* right = LuaScriptUtilities::GetVector3(luaVM, 2);

		if (*left == *right)
		{
			lua_pushboolean(luaVM, true);
			return 1;
		}
	}
	lua_pushboolean(luaVM, false);
	return 1;
}

int Lua_Script_Vector3Index(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		const Ogre::Vector3* const vector =
			LuaScriptUtilities::GetVector3(luaVM, -2);
		const Ogre::String key(luaL_checkstring(luaVM, -1));

		if (key.length() == 1)
		{
			switch (key[0])
			{
			case 'x':
				LuaScriptUtilities::PushReal(luaVM, vector->x);
				break;
			case 'y':
				LuaScriptUtilities::PushReal(luaVM, vector->y);
				break;
			case 'z':
				LuaScriptUtilities::PushReal(luaVM, vector->z);
				break;
			default:
				lua_pushnil(luaVM);
			}
		}
		else
		{
			lua_pushnil(luaVM);
		}
	}
	else
	{
		lua_pushnil(luaVM);
	}

	return 1;
}

int Lua_Script_Vector3Length(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		if (LuaScriptUtilities::IsUserdataType(luaVM, 1, LUA_VECTOR3_METATABLE))
		{
			Ogre::Vector3* const vector =
				LuaScriptUtilities::GetVector3(luaVM, 1);
			return LuaScriptUtilities::PushReal(luaVM, vector->length());
		}
	}
	return 0;
}

int Lua_Script_Vector3LengthSquared(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		if (LuaScriptUtilities::IsUserdataType(luaVM, 1, LUA_VECTOR3_METATABLE))
		{
			Ogre::Vector3* const vector =
				LuaScriptUtilities::GetVector3(luaVM, 1);
			return LuaScriptUtilities::PushReal(luaVM, vector->squaredLength());
		}
	}
	return 0;
}

int Lua_Script_Vector3Multiply(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		if (LuaScriptUtilities::IsUserdataType(luaVM, 1, LUA_VECTOR3_METATABLE))
		{
			// Left value is a Vector3.
			Ogre::Vector3* left = LuaScriptUtilities::GetVector3(luaVM, 1);

			if (lua_isnumber(luaVM, 2))
			{
				// Right value is a Real.
				Ogre::Real right = LuaScriptUtilities::GetReal(luaVM, 2);
				return LuaScriptUtilities::PushVector3(luaVM, *left * right);
			}
			else if (LuaScriptUtilities::IsVector3(luaVM, 2))
			{
				// Right value is a Vector3.
				Ogre::Vector3* right = LuaScriptUtilities::GetVector3(luaVM, 2);
				return LuaScriptUtilities::PushVector3(luaVM, *left * *right);
			}
		}
	}
	return 0;
}

int Lua_Script_Vector3Negation(lua_State* luaVM)
{
	/**
	 * @remarks
	 *      Even though negation is a unary operation lua passes the same value
	 *      twice for negation.
	 */
	if (lua_gettop(luaVM) == 2 && LuaScriptUtilities::IsVector3(luaVM, -1))
	{
		Ogre::Vector3* vector = LuaScriptUtilities::GetVector3(luaVM, -1);
		return LuaScriptUtilities::PushVector3(luaVM, -*vector);
	}
	return 0;
}

int Lua_Script_Vector3New(lua_State* luaVM)
{
	const int stackSize = lua_gettop(luaVM);

	switch (stackSize)
	{
	case 0:
		// Create a vector3 initialized to (0, 0, 0).
		return LuaScriptUtilities::PushVector3(luaVM, Ogre::Vector3(0.0f));
		break;
	case 1:
		{
			if (LuaScriptUtilities::IsUserdataType(
				luaVM, 1, LUA_VECTOR3_METATABLE))
			{
				// Create a vector3 initialized to the passed in vector.
				return LuaScriptUtilities::PushVector3(
					luaVM, *LuaScriptUtilities::GetVector3(luaVM, 1));
			}
			else if (lua_isnumber(luaVM, 1))
			{
				// Create a vector3 initialized to (value, value, value).
				return LuaScriptUtilities::PushVector3(
					luaVM,
					Ogre::Vector3(LuaScriptUtilities::GetReal(luaVM, 1)));
			}
		}
		break;
	case 3:
		if (lua_isnumber(luaVM, 1) &&
			lua_isnumber(luaVM, 2) &&
			lua_isnumber(luaVM, 3))
		{
			// Create a vector3 initialized to (value1, value2, value3).
			return LuaScriptUtilities::PushVector3(
				luaVM, Ogre::Vector3(
					LuaScriptUtilities::GetReal(luaVM, 1),
					LuaScriptUtilities::GetReal(luaVM, 2),
					LuaScriptUtilities::GetReal(luaVM, 3)));
		}
	default:
		break;
	}
	lua_pushnil(luaVM);
	return 1;
}

int Lua_Script_Vector3NewIndex(lua_State* luaVM)
{
	Ogre::Vector3* const vector =
		LuaScriptUtilities::GetVector3(luaVM, -3);
	const Ogre::String key(luaL_checkstring(luaVM, -2));
	const Ogre::Real value = LuaScriptUtilities::GetReal(luaVM, -1);

	if (key.length() == 1)
	{
		switch (key[0])
		{
		case 'x':
			vector->x = value;
			break;
		case 'y':
			vector->y = value;
			break;
		case 'z':
			vector->z = value;
			break;
		default:
			break;
		}
	}

	return 0;
}

int Lua_Script_Vector3Normalize(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		Ogre::Vector3* const vector = LuaScriptUtilities::GetVector3(luaVM, -1);

		if (vector)
		{
			return LuaScriptUtilities::PushVector3(
				luaVM, vector->normalisedCopy());
		}
	}
	return 0;
}

int Lua_Script_Vector3Rotate(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		const Ogre::Vector3* const vector = LuaScriptUtilities::GetVector3(luaVM, 1);
		const Ogre::Vector3* const angles = LuaScriptUtilities::GetVector3(luaVM, 2);

		const Ogre::Quaternion rotation =
			LuaScriptUtilities::QuaternionFromRotationDegrees(
				angles->x, angles->y, angles->z);

		return LuaScriptUtilities::PushVector3(luaVM, rotation * *vector);
	}
	return 0;
}

int Lua_Script_Vector3RotationTo(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		const Ogre::Vector3* const begin = LuaScriptUtilities::GetVector3(luaVM, 1);
		const Ogre::Vector3* const end = LuaScriptUtilities::GetVector3(luaVM, 2);

		const Ogre::Quaternion rotation = begin->getRotationTo(*end);

		return LuaScriptUtilities::PushVector3(
			luaVM, LuaScriptUtilities::QuaternionToRotationDegrees(rotation));
	}
	return 0;
}

int Lua_Script_Vector3Subtract(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 2)
	{
		if (LuaScriptUtilities::IsUserdataType(luaVM, 1, LUA_VECTOR3_METATABLE))
		{
			// Left value is a Vector3.
			Ogre::Vector3* left = LuaScriptUtilities::GetVector3(luaVM, 1);

			if (lua_isnumber(luaVM, 2))
			{
				// Right value is a Real.
				Ogre::Real right = LuaScriptUtilities::GetReal(luaVM, 2);
				return LuaScriptUtilities::PushVector3(luaVM, *left - right);
			}
			else if (LuaScriptUtilities::IsVector3(luaVM, 2))
			{
				// Right value is a Vector3.
				Ogre::Vector3* right = LuaScriptUtilities::GetVector3(luaVM, 2);
				return LuaScriptUtilities::PushVector3(luaVM, *left - *right);
			}
		}
	}
	return 0;
}

int Lua_Script_Vector3ToString(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		char buffer[1024];

		const Ogre::Vector3* const vector =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		sprintf_s(
			buffer,
			sizeof buffer,
			"{ x=%f, y=%f, z=%f }",
			vector->x,
			vector->y,
			vector->z);

		lua_pushstring(luaVM, buffer);
		return 1;
	}
	return 0;
}

int Lua_Script_Vector3ToWatch(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		const Ogre::Vector3* const vector =
			LuaScriptUtilities::GetVector3(luaVM, -1);

		lua_pushstring(luaVM, "Vector3");
		lua_newtable(luaVM);

		const int properties = lua_gettop(luaVM);

		LuaScriptUtilities::PushRealAttribute(
			luaVM, vector->x, "x", properties);
		LuaScriptUtilities::PushRealAttribute(
			luaVM, vector->y, "y", properties);
		LuaScriptUtilities::PushRealAttribute(
			luaVM, vector->z, "z", properties);

		return 2;
	}
	return 0;
}

int Lua_Script_UIComponentToWatch(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushUserInterfaceComponentProperties(
			*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UICreateChild(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushCreatedChildComponent(
			*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UIGetDimensions(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushDimensions(*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UIGetFont(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushFont(*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UIGetMarkupText(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushMarkupText(*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UIGetOffsetPosition(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushOffsetPosition(*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UIGetPosition(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushPosition(*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UIGetScreenPosition(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushScreenPosition(*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UIGetText(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushText(*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UIGetTextMargin(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushTextMargin(*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UIIsVisible(lua_State* luaVM)
{
	if (lua_gettop(luaVM) == 1)
	{
		UserInterfaceComponent* const component =
			UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1);

		return UserInterfaceUtilities::PushVisible(*luaVM, *component);
	}

	return 0;
}

int Lua_Script_UISetBackgroundColor(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 4, 5))
	{
		Ogre::Real alpha = 1.0f;

		if (lua_gettop(luaVM) == 5)
		{
			alpha = LuaScriptUtilities::GetReal(luaVM, 5);
		}

		UserInterfaceUtilities::SetBackgroundColor(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			LuaScriptUtilities::GetReal(luaVM, 2),
			LuaScriptUtilities::GetReal(luaVM, 3),
			LuaScriptUtilities::GetReal(luaVM, 4),
			alpha);
	}

	return 0;
}

int Lua_Script_UISetDimensions(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		UserInterfaceUtilities::SetDimension(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			LuaScriptUtilities::GetReal(luaVM, 2),
			LuaScriptUtilities::GetReal(luaVM, 3));
	}

	return 0;
}

int Lua_Script_UISetGradientColor(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 10))
	{
		UserInterfaceUtilities::SetGradientColor(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			LuaScriptUtilities::GetString(luaVM, 2),
			LuaScriptUtilities::GetReal(luaVM, 3),
			LuaScriptUtilities::GetReal(luaVM, 4),
			LuaScriptUtilities::GetReal(luaVM, 5),
			LuaScriptUtilities::GetReal(luaVM, 6),
			LuaScriptUtilities::GetReal(luaVM, 7),
			LuaScriptUtilities::GetReal(luaVM, 8),
			LuaScriptUtilities::GetReal(luaVM, 9),
			LuaScriptUtilities::GetReal(luaVM, 10));
	}

	return 0;
}

int Lua_Script_UISetFont(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		UserInterfaceUtilities::SetFont(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			LuaScriptUtilities::GetString(luaVM, 2));
	}

	return 0;
}

int Lua_Script_UISetFontColor(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 4, 5))
	{
		Ogre::Real alpha = 1.0f;

		if (lua_gettop(luaVM) == 5)
		{
			alpha = LuaScriptUtilities::GetReal(luaVM, 5);
		}

		UserInterfaceUtilities::SetFontColor(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			LuaScriptUtilities::GetReal(luaVM, 2),
			LuaScriptUtilities::GetReal(luaVM, 3),
			LuaScriptUtilities::GetReal(luaVM, 4),
			alpha);
	}

	return 0;
}

int Lua_Script_UISetMarkupText(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		UserInterfaceUtilities::SetMarkupText(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			LuaScriptUtilities::GetString(luaVM, 2));
	}

	return 0;
}

int Lua_Script_UISetPosition(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		UserInterfaceUtilities::SetPosition(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			LuaScriptUtilities::GetReal(luaVM, 2),
			LuaScriptUtilities::GetReal(luaVM, 3));
	}

	return 0;
}

int Lua_Script_UISetText(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		UserInterfaceUtilities::SetText(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			LuaScriptUtilities::GetString(luaVM, 2));
	}

	return 0;
}

int Lua_Script_UISetTextMargin(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 3))
	{
		UserInterfaceUtilities::SetTextMargin(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			LuaScriptUtilities::GetReal(luaVM, 2),
			LuaScriptUtilities::GetReal(luaVM, 3));
	}

	return 0;
}

int Lua_Script_UISetVisible(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		const bool visible = lua_toboolean(luaVM, 2) == 1;

		UserInterfaceUtilities::SetVisible(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			visible);
	}

	return 0;
}

int Lua_Script_UISetWorldPosition(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		UserInterfaceUtilities::SetWorldPosition(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			*LuaScriptUtilities::GetVector3(luaVM, 2));
	}

	return 0;
}

int Lua_Script_UISetWorldRotation(lua_State* luaVM)
{
	if (LuaScriptUtilities::CheckArgumentCountOrDie(luaVM, 2))
	{
		Ogre::Vector3* const angles =
			LuaScriptUtilities::GetVector3(luaVM, 2);

		const Ogre::Quaternion rotation =
			LuaScriptUtilities::QuaternionFromRotationDegrees(*angles);

		UserInterfaceUtilities::SetWorldRotation(
			*UserInterfaceUtilities::GetUserInterfaceComponent(*luaVM, 1),
			rotation);
	}

	return 0;
}
