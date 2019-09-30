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
#include "demo_framework/include/AgentPath.h"
#include "demo_framework/include/AgentUtilities.h"
#include "demo_framework/include/LuaScriptBindings.h"
#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/PhysicsUtilities.h"
#include "demo_framework/include/PhysicsWorld.h"
#include "demo_framework/include/Sandbox.h"

namespace {
const luaL_Reg AgentFunctions[] =
{
    { "ApplyForce",                 Lua_Script_AgentApplyForce },
    { "ForceToAlign",               Lua_Script_AgentForceToAlign },
    { "ForceToAvoidAgents",         Lua_Script_AgentForceToAvoidAgents },
    { "ForceToAvoidObjects",        Lua_Script_AgentForceToAvoidObjects },
    { "ForceToCombine",             Lua_Script_AgentForceToCombine },
    { "ForceToFleePosition",        Lua_Script_AgentForceToFleePosition },
    { "ForceToFollowPath",          Lua_Script_AgentForceToFollowPath },
    { "ForceToPosition",            Lua_Script_AgentForceToPosition },
    { "ForceToSeparate",            Lua_Script_AgentForceToSeparate },
    { "ForceToStayOnPath",          Lua_Script_AgentForceToStayOnPath },
    { "ForceToTargetSpeed",         Lua_Script_AgentForceToTargetSpeed },
    { "ForceToWander",              Lua_Script_AgentForceToWander },
    { "GetDistanceAlongPath",       Lua_Script_AgentGetDistanceAlongPath },
    { "GetForward",                 Lua_Script_AgentGetForward },
    { "GetHealth",                  Lua_Script_AgentGetHealth },
    { "GetHeight",                  Lua_Script_AgentGetHeight },
    { "GetId",                      Lua_Script_AgentGetId },
    { "GetLeft",                    Lua_Script_AgentGetLeft },
    { "GetMass",                    Lua_Script_AgentGetMass },
    { "GetMaxForce",                Lua_Script_AgentGetMaxForce },
    { "GetMaxSpeed",                Lua_Script_AgentGetMaxSpeed },
    { "GetNearestPointOnPath",      Lua_Script_AgentGetNearestPointOnPath },
    { "GetPath",                    Lua_Script_AgentGetPath },
    { "GetPointOnPath",             Lua_Script_AgentGetPointOnPath },
    { "GetPosition",                Lua_Script_AgentGetPosition },
    { "GetRadius",                  Lua_Script_AgentGetRadius },
    { "GetSandbox",                 Lua_Script_AgentGetSandbox },
    { "GetSpeed",                   Lua_Script_AgentGetSpeed },
    { "GetTarget",                  Lua_Script_AgentGetTarget },
    { "GetTargetRadius",            Lua_Script_AgentGetTargetRadius },
    { "GetTeam",                    Lua_Script_AgentGetTeam },
    { "GetUp",                      Lua_Script_AgentGetUp },
    { "GetVelocity",                Lua_Script_AgentGetVelocity },
    { "HasPath",                    Lua_Script_AgentHasPath },
    { "IsAgent",                    Lua_Script_AgentIsAgent },
    { "PredictFuturePosition",      Lua_Script_AgentPredictFuturePosition },
    { "RemovePath",                 Lua_Script_AgentRemovePath },
    { "RemovePhysics",              Lua_Script_AgentRemovePhysics },
    { "SetForward",                 Lua_Script_AgentSetForward },
    { "SetHealth",                  Lua_Script_AgentSetHealth },
    { "SetHeight",                  Lua_Script_AgentSetHeight },
    { "SetMass",                    Lua_Script_AgentSetMass },
    { "SetMaxForce",                Lua_Script_AgentSetMaxForce },
    { "SetMaxSpeed",                Lua_Script_AgentSetMaxSpeed },
    { "SetPath",                    Lua_Script_AgentSetPath },
    { "SetPosition",                Lua_Script_AgentSetPosition },
    { "SetRadius",                  Lua_Script_AgentSetRadius },
    { "SetSpeed",                   Lua_Script_AgentSetSpeed },
    { "SetTarget",                  Lua_Script_AgentSetTarget },
    { "SetTargetRadius",            Lua_Script_AgentSetTargetRadius },
    { "SetTeam",                    Lua_Script_AgentSetTeam },
    { "SetVelocity",                Lua_Script_AgentSetVelocity },
    { NULL, NULL }
};

const luaL_Reg AgentMetaFunctions[] =
{
    { "__eq",                       Lua_Script_AgentEquals },
    { "__index",                    Lua_Script_AgentIndex },
    { "__towatch",                  Lua_Script_AgentToWatch },
    { NULL, NULL }
};
}  // anonymous namespace

void AgentUtilities::ApplyForce(Agent* const agent, const Ogre::Vector3 force)
{
    PhysicsUtilities::ApplyForce(
        agent->GetRigidBody(), btVector3(force.x, force.y, force.z));
}

void AgentUtilities::BindVMFunctions(lua_State* const luaVM)
{
    luaL_newmetatable(luaVM, LUA_AGENT_METATABLE);
    luaL_register(luaVM, NULL, AgentMetaFunctions);

    luaL_register(luaVM, "Agent", AgentFunctions);
}

int AgentUtilities::CallFunction(
    lua_State* const luaVM, const Ogre::String functionName)
{
    size_t index = 0;
    luaL_Reg function;

    do
    {
        function = AgentFunctions[index++];

        if (functionName == function.name)
        {
            return function.func(luaVM);
        }
    }
    while (function.func && function.name);

    return 0;
}

void AgentUtilities::CallLuaAgentCleanup(Agent* const agent)
{
    lua_State* const luaVM = agent->GetLuaVM();

    lua_getglobal(luaVM, AGENT_CLEANUP_FUNC);
    PushAgent(luaVM, agent);

    if (lua_pcall(luaVM, 1, 0, 0) != 0)
    {
        Ogre::LogManager::getSingletonPtr()->logMessage(
            Ogre::String(lua_tostring(luaVM, -1)), Ogre::LML_CRITICAL);
        assert(false);
    }
}

void AgentUtilities::CallLuaAgentHandleKeyboardEvent(
    Agent* const agent, const Ogre::String& key, const bool pressed)
{
    lua_State* const luaVM = agent->GetLuaVM();

    lua_getglobal(luaVM, AGENT_HANDLE_EVENT_FUNC);

    if (lua_isfunction(luaVM, -1))
    {
        AgentUtilities::PushAgent(luaVM, agent);
        LuaScriptUtilities::PushKeyboardEvent(luaVM, key, pressed);

        if (lua_pcall(luaVM, 2, 0, 0) != 0)
        {
            Ogre::LogManager::getSingletonPtr()->logMessage(
                Ogre::String(lua_tostring(luaVM, -1)), Ogre::LML_CRITICAL);
            assert(false);
        }
    }
    else
    {
        lua_pop(luaVM, 1);
    }
}

void AgentUtilities::CallLuaAgentHandleMouseEvent(
    Agent* const agent,
    const int width,
    const int height,
    const Ogre::String button,
    const bool pressed)
{
    lua_State* const luaVM = agent->GetLuaVM();

    lua_getglobal(luaVM, AGENT_HANDLE_EVENT_FUNC);

    if (lua_isfunction(luaVM, -1))
    {
        AgentUtilities::PushAgent(luaVM, agent);
        LuaScriptUtilities::PushMouseEvent(
            luaVM, width, height, button, pressed);

        if (lua_pcall(luaVM, 2, 0, 0) != 0)
        {
            Ogre::LogManager::getSingletonPtr()->logMessage(
                Ogre::String(lua_tostring(luaVM, -1)), Ogre::LML_CRITICAL);
            assert(false);
        }
    }
    else
    {
        lua_pop(luaVM, 1);
    }
}

void AgentUtilities::CallLuaAgentHandleMouseMoveEvent(
    Agent* const agent,
    const int width,
    const int height)
{
    lua_State* const luaVM = agent->GetLuaVM();

    lua_getglobal(luaVM, AGENT_HANDLE_EVENT_FUNC);

    if (lua_isfunction(luaVM, -1))
    {
        AgentUtilities::PushAgent(luaVM, agent);
        LuaScriptUtilities::PushMouseMoveEvent(luaVM, width, height);

        if (lua_pcall(luaVM, 2, 0, 0) != 0)
        {
            Ogre::LogManager::getSingletonPtr()->logMessage(
                Ogre::String(lua_tostring(luaVM, -1)), Ogre::LML_CRITICAL);
            assert(false);
        }
    }
    else
    {
        lua_pop(luaVM, 1);
    }
}

void AgentUtilities::CallLuaAgentInitialize(Agent* const agent)
{
    lua_State* luaVM = agent->GetLuaVM();

    lua_getglobal(luaVM, AGENT_INITIALIZE_FUNC);
    PushAgent(luaVM, agent);

    if (lua_pcall(luaVM, 1, 0, 0) != 0)
    {
        Ogre::LogManager::getSingletonPtr()->logMessage(
            Ogre::String(lua_tostring(luaVM, -1)), Ogre::LML_CRITICAL);
        assert(false);
    }
}

void AgentUtilities::CallLuaAgentUpdate(
    Agent* const agent, const int deltaTimeInMillis)
{
    lua_State* luaVM = agent->GetLuaVM();

    lua_getglobal(luaVM, AGENT_UPDATE_FUNC);
    PushAgent(luaVM, agent);
    LuaScriptUtilities::PushInt(luaVM, deltaTimeInMillis);

    if (lua_pcall(luaVM, 2, 0, 0) != 0)
    {
        Ogre::LogManager::getSingletonPtr()->logMessage(
            Ogre::String(lua_tostring(luaVM, -1)), Ogre::LML_CRITICAL);
        assert(false);
    }
}

void AgentUtilities::CreateRigidBodyCapsule(Agent* const agent)
{
    assert(!agent->GetRigidBody());

    btRigidBody* const rigidBody =
        PhysicsUtilities::CreateCapsule(agent->GetHeight(), agent->GetRadius());

    rigidBody->setAngularFactor(btVector3(0, 0.0f, 0));

    const Ogre::Vector3 position = agent->GetPosition();
    const Ogre::Quaternion rot = agent->GetOrientation();

    PhysicsUtilities::SetRigidBodyMass(rigidBody, btScalar(agent->GetMass()));
    PhysicsUtilities::SetRigidBodyPosition(
        rigidBody, btVector3(position.x, position.y, position.z));
    PhysicsUtilities::SetRigidBodyOrientation(
        rigidBody, btQuaternion(rot.x, rot.y, rot.z, rot.w));

    agent->SetRigidBody(rigidBody);

    agent->GetSandbox()->GetPhysicsWorld()->AddRigidBody(rigidBody);
}

Agent* AgentUtilities::GetAgent(lua_State* const luaVM, const int stackIndex)
{
    Agent** const agentPointer =
        static_cast<Agent**>(lua_touserdata(luaVM, stackIndex));

    if (agentPointer != NULL) {
        if (lua_getmetatable(luaVM, stackIndex)) {
            lua_getfield(luaVM, LUA_REGISTRYINDEX, LUA_AGENT_METATABLE);
            if (lua_rawequal(luaVM, -1, -2)) {
                lua_pop(luaVM, 2);
                return *agentPointer;
            }
            lua_pop(luaVM, 2);
        }
    }

    return NULL;
}

Ogre::SceneNode* AgentUtilities::GetSceneNode(Agent* const agent)
{
    return agent->GetSceneNode();
}

bool AgentUtilities::IsAgent(lua_State* const luaVM, const int stackIndex)
{
    return LuaScriptUtilities::IsUserdataType(
        luaVM, stackIndex, LUA_AGENT_METATABLE);
}

bool AgentUtilities::IsEqual(
    const Agent* const leftAgent, const Agent* const rightAgent)
{
    assert(leftAgent);
    assert(rightAgent);

    return leftAgent->GetId() == rightAgent->GetId();
}

void AgentUtilities::LoadScript(
    Agent* const agent,
    const char* const luaScriptContents,
    const size_t bufferSize,
    const char* const fileName)
{
    char agentVMName[1024];
    sprintf_s(
        agentVMName,
        sizeof(agentVMName),
        "%s - \"%s\"",
        AGENT_LUA_VM_NAME,
        fileName);

    lua_State* const luaVM = agent->GetLuaVM();
    LuaScriptUtilities::NameVM(luaVM, agentVMName);
    LuaScriptUtilities::LoadScript(
        luaVM, luaScriptContents, bufferSize, fileName);
}

int AgentUtilities::PushAgent(lua_State* const luaVM, Agent* const agent)
{
    const size_t pointerSize = sizeof(intptr_t);

    Agent** const agentType =
        static_cast<Agent**>(lua_newuserdata(luaVM, pointerSize));

    *agentType = agent;

    luaL_getmetatable(luaVM, LUA_AGENT_METATABLE);
    lua_setmetatable(luaVM, -2);
    return 1;
}

int AgentUtilities::PushAgentAttribute(
    lua_State* const luaVM,
    Agent* const agent,
    const Ogre::String attributeName,
    const int tableIndex)
{
    LuaScriptUtilities::PushString(luaVM, attributeName);
    PushAgent(luaVM, agent);
    lua_settable(luaVM, tableIndex);
    return 1;
}

int AgentUtilities::PushAgentId(lua_State* const luaVM, Agent* const agent)
{
    return LuaScriptUtilities::PushReal(luaVM, Ogre::Real(agent->GetId()));
}

int AgentUtilities::PushAgentProperties(
    lua_State* const luaVM, const Agent* const agent)
{
    lua_pushstring(luaVM, "Agent");
    lua_newtable(luaVM);
    const int propertiesTableIndex = lua_gettop(luaVM);

    LuaScriptUtilities::PushIntAttribute(
        luaVM, agent->GetId(), "agentId", propertiesTableIndex);
    LuaScriptUtilities::PushVector3Attribute(
        luaVM, agent->GetForward(), "forward", propertiesTableIndex);
    LuaScriptUtilities::PushBoolAttribute(
        luaVM, agent->HasPath(), "hasPath", propertiesTableIndex);
    LuaScriptUtilities::PushRealAttribute(
        luaVM, agent->GetMass(), "mass", propertiesTableIndex);
    LuaScriptUtilities::PushRealAttribute(
        luaVM, agent->GetMaxForce(), "maxForce", propertiesTableIndex);
    LuaScriptUtilities::PushRealAttribute(
        luaVM, agent->GetMaxSpeed(), "maxSpeed", propertiesTableIndex);
    PushPathAttribute(luaVM, agent, "path", propertiesTableIndex);
    LuaScriptUtilities::PushVector3Attribute(
        luaVM, agent->GetPosition(), "position", propertiesTableIndex);
    LuaScriptUtilities::PushRealAttribute(
        luaVM, agent->GetRadius(), "radius", propertiesTableIndex);
    LuaScriptUtilities::PushRealAttribute(
        luaVM, agent->GetSpeed(), "speed", propertiesTableIndex);
    LuaScriptUtilities::PushVector3Attribute(
        luaVM, agent->GetTarget(), "target", propertiesTableIndex);
    LuaScriptUtilities::PushRealAttribute(
        luaVM, agent->GetTargetRadius(), "targetRadius", propertiesTableIndex);
    LuaScriptUtilities::PushVector3Attribute(
        luaVM, agent->GetVelocity(), "velocity", propertiesTableIndex);

    return 2;
}

int AgentUtilities::PushDistanceAlongPath(
    lua_State* const luaVM,
    const Agent* const agent,
    const Ogre::Vector3& position)
{
    if (agent->HasPath())
    {
        return LuaScriptUtilities::PushReal(
            luaVM,
            agent->GetPath().GetDistanceAlongPath(position));
    }

    return 0;
}

int AgentUtilities::PushForceToAlign(
    lua_State* const luaVM,
    Agent* const agent,
    const float maxDistance,
    const float maxAngle,
    const std::vector<Agent*>& group)
{
    AgentGroup agentGroup;

    std::vector<Agent*>::const_iterator it;

    for (it = group.begin(); it != group.end(); ++it)
    {
        agentGroup.AddAgent(*it);
    }

    return LuaScriptUtilities::PushVector3(
        luaVM,
        agent->ForceToAlign(maxDistance, Ogre::Degree(maxAngle), agentGroup));
}

int AgentUtilities::PushForceToAvoidAgents(
    lua_State* const luaVM,
    Agent* const agent,
    const float predicitionTime)
{
    Sandbox* const sandbox = agent->GetSandbox();

    if (sandbox)
    {
        std::vector<Agent*>& agents = sandbox->GetAgents();
        std::vector<Agent*> aliveAgents;

        std::vector<Agent*>::iterator it;

        for (it = agents.begin(); it != agents.end(); ++it)
        {
            if ((*it)->GetHealth() > 0)
            {
                aliveAgents.push_back(*it);
            }
        }

        return LuaScriptUtilities::PushVector3(
            luaVM,
            agent->ForceToAvoidAgents(aliveAgents, predicitionTime));
    }

    return 0;
}

int AgentUtilities::PushForceToAvoidObjects(
    lua_State* const luaVM,
    Agent* const agent,
    const float predicitionTime)
{
    Sandbox* const sandbox = agent->GetSandbox();

    if (sandbox)
    {
        return LuaScriptUtilities::PushVector3(
            luaVM,
            agent->ForceToAvoidObjects(sandbox->GetObjects(), predicitionTime));
    }

    return 0;
}

int AgentUtilities::PushForceToCombine(
    lua_State* const luaVM,
    Agent* const agent,
    const float maxDistance,
    const float maxAngle,
    const std::vector<Agent*>& group)
{
    AgentGroup agentGroup;

    std::vector<Agent*>::const_iterator it;

    for (it = group.begin(); it != group.end(); ++it)
    {
        agentGroup.AddAgent(*it);
    }

    return LuaScriptUtilities::PushVector3(
        luaVM,
        agent->ForceToCombine(maxDistance, Ogre::Degree(maxAngle), agentGroup));
}

int AgentUtilities::PushForceToFleePosition(
    lua_State* const luaVM, Agent* const agent, const Ogre::Vector3& position)
{
    return LuaScriptUtilities::PushVector3(
        luaVM, agent->ForceToFleePosition(position));
}

int AgentUtilities::PushForceToFollowPath(
    lua_State* const luaVM, Agent* const agent, const float predicitionTime)
{
    return LuaScriptUtilities::PushVector3(
        luaVM, agent->ForceToFollowPath(predicitionTime));
}

int AgentUtilities::PushForceToPosition(
    lua_State* const luaVM, Agent* const agent, const Ogre::Vector3& position)
{
    return LuaScriptUtilities::PushVector3(
        luaVM, agent->ForceToPosition(position));
}

int AgentUtilities::PushForceToSeparate(
    lua_State* const luaVM,
    Agent* const agent,
    const float maxDistance,
    const float maxAngle,
    const std::vector<Agent*>& group)
{
    AgentGroup agentGroup;

    std::vector<Agent*>::const_iterator it;

    for (it = group.begin(); it != group.end(); ++it)
    {
        agentGroup.AddAgent(*it);
    }

    return LuaScriptUtilities::PushVector3(
        luaVM,
        agent->ForceToSeparate(maxDistance, Ogre::Degree(maxAngle), agentGroup));
}

int AgentUtilities::PushForceToStayOnPath(
    lua_State* const luaVM, Agent* const agent, const float predicitionTime)
{
    return LuaScriptUtilities::PushVector3(
        luaVM, agent->ForceToStayOnPath(predicitionTime));
}

int AgentUtilities::PushForceToTargetSpeed(
    lua_State* const luaVM, Agent* const agent,const Ogre::Real speed)
{
    return LuaScriptUtilities::PushVector3(
        luaVM, agent->ForceToTargetSpeed(speed));
}

int AgentUtilities::PushForceToWander(
    lua_State* const luaVM,
    Agent* const agent,
    const Ogre::Real deltaMilliseconds)
{
    return LuaScriptUtilities::PushVector3(
        luaVM, agent->ForceToWander(deltaMilliseconds));
}

int AgentUtilities::PushForward(lua_State* const luaVM, Agent* const agent)
{
    return LuaScriptUtilities::PushVector3(luaVM, agent->GetForward());
}

int AgentUtilities::PushFunction(
    lua_State* const luaVM, const Ogre::String functionName)
{
    size_t index = 0;
    luaL_Reg function = AgentFunctions[index++];

    // TODO(David Young): Convert into a hash lookup.
    while (function.func && function.name)
    {
        if (functionName == function.name)
        {
            lua_pushcfunction(luaVM, function.func);
            return 1;
        }

        function = AgentFunctions[index++];
    }

    return 0;
}

int AgentUtilities::PushHasPath(
    lua_State* const luaVM, const Agent* const agent)
{
    lua_pushboolean(luaVM, agent->HasPath());
    return 1;
}

int AgentUtilities::PushHealth(lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushReal(luaVM, agent->GetHealth());
}

int AgentUtilities::PushHeight(lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushReal(luaVM, agent->GetHeight());
}

int AgentUtilities::PushLeft(lua_State* const luaVM, Agent* const agent)
{
    return LuaScriptUtilities::PushVector3(luaVM, agent->GetLeft());
}

int AgentUtilities::PushMass(lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushReal(luaVM, agent->GetMass());
}

int AgentUtilities::PushMaxForce(
    lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushReal(luaVM, agent->GetMaxForce());
}

int AgentUtilities::PushMaxSpeed(
    lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushReal(luaVM, agent->GetMaxSpeed());
}

int AgentUtilities::PushNearestPointOnPath(
    lua_State* const luaVM,
    const Agent* const agent,
    const Ogre::Vector3& position)
{
    if (agent->HasPath())
    {
        return LuaScriptUtilities::PushVector3(
            luaVM,
            agent->GetPath().GetNearestPointOnPath(position));
    }

    return 0;
}

int AgentUtilities::PushPath(lua_State* const luaVM, const Agent* const agent)
{
    lua_newtable(luaVM);
    const int tableIndex = lua_gettop(luaVM);

    if (!agent->HasPath())
    {
        return 1;
    }

    const AgentPath pathway = agent->GetPath();

    std::vector<Ogre::Vector3> points;
    pathway.GetPathPoints(points);

    std::vector<Ogre::Vector3>::iterator it;

    size_t count = 1;

    for (it = points.begin(); it != points.end(); ++it)
    {
        lua_pushinteger(luaVM, count);
        LuaScriptUtilities::PushVector3(luaVM, *it);
        lua_settable(luaVM, tableIndex);

        ++count;
    }

    return 1;
}

int AgentUtilities::PushPathAttribute(
    lua_State* const luaVM,
    const Agent* const agent,
    const Ogre::String attributeName,
    const int tableIndex)
{
    lua_pushstring(luaVM, attributeName.c_str());
    PushPath(luaVM, agent);
    lua_settable(luaVM, tableIndex);

    return 1;
}

int AgentUtilities::PushPointOnPath(
    lua_State* const luaVM,
    const Agent* const agent,
    const Ogre::Real distance)
{
    if (agent->HasPath())
    {
        return LuaScriptUtilities::PushVector3(
            luaVM,
            agent->GetPath().GetPointOnPath(distance));
    }

    return 0;
}

int AgentUtilities::PushPosition(
    lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushVector3(luaVM, agent->GetPosition());
}

int AgentUtilities::PushPredictFuturePosition(
    lua_State* const luaVM,
    Agent* const agent,
    const Ogre::Real timeInSeconds)
{
    return LuaScriptUtilities::PushVector3(
        luaVM, agent->PredictFuturePosition(timeInSeconds));
}

int AgentUtilities::PushRadius(lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushReal(luaVM, agent->GetRadius());
}

int AgentUtilities::PushSandbox(lua_State* const luaVM, Agent* const agent)
{
    return LuaScriptUtilities::PushDataType(
        luaVM, agent->GetSandbox(), SCRIPT_SANDBOX);
}

int AgentUtilities::PushSpeed(lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushReal(luaVM, agent->GetSpeed());
}

int AgentUtilities::PushTarget(lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushVector3(luaVM, agent->GetTarget());
}

int AgentUtilities::PushTargetRadius(
    lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushReal(luaVM, agent->GetTargetRadius());
}

int AgentUtilities::PushTeam(lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushString(luaVM, agent->GetTeam());
}

int AgentUtilities::PushUp(lua_State* const luaVM, Agent* const agent)
{
    return LuaScriptUtilities::PushVector3(luaVM, agent->GetUp());
}

int AgentUtilities::PushVelocity(
    lua_State* const luaVM, const Agent* const agent)
{
    return LuaScriptUtilities::PushVector3(luaVM, agent->GetVelocity());
}

void AgentUtilities::RemovePath(Agent* const agent)
{
    assert(agent);

    agent->RemovePath();
}

void AgentUtilities::RemovePhysics(Agent* const agent)
{
    if (agent->GetRigidBody())
    {
        agent->GetSandbox()->GetPhysicsWorld()->RemoveRigidBody(
            agent->GetRigidBody());

        PhysicsUtilities::DeleteRigidBody(agent->GetRigidBody());

        agent->SetRigidBody(NULL);
    }
}

void AgentUtilities::SetForward(
    Agent* const agent, const Ogre::Vector3& forward)
{
    agent->SetForward(forward);
}

void AgentUtilities::SetHealth(Agent* const agent, const Ogre::Real health)
{
    agent->SetHealth(health);
}

void AgentUtilities::SetHeight(Agent* const agent, const Ogre::Real height)
{
    agent->SetHeight(height);
}

void AgentUtilities::SetMass(Agent* const agent, const Ogre::Real mass)
{
    agent->SetMass(mass);
}

void AgentUtilities::SetMaxForce(Agent* const agent, const Ogre::Real maxForce)
{
    agent->SetMaxForce(maxForce);
}

void AgentUtilities::SetMaxSpeed(Agent* const agent, const Ogre::Real maxSpeed)
{
    agent->SetMaxSpeed(maxSpeed);
}

void AgentUtilities::SetPath(
    Agent* const agent,
    const std::vector<Ogre::Vector3>& points,
    const bool cyclic)
{
    AgentPath path(points, agent->GetRadius(), cyclic);

    agent->SetPath(path);
}

void AgentUtilities::SetPosition(
    Agent* const agent, const Ogre::Vector3& vector)
{
    agent->SetPosition(vector);
}

void AgentUtilities::SetRadius(Agent* const agent, const Ogre::Real radius)
{
    agent->SetRadius(radius);
}

void AgentUtilities::SetSpeed(Agent* const agent, const Ogre::Real speed)
{
    agent->SetSpeed(speed);
}

void AgentUtilities::SetTarget(Agent* const agent, const Ogre::Vector3& target)
{
    agent->SetTarget(target);
}

void AgentUtilities::SetTargetRadius(
    Agent* const agent, const Ogre::Real radius)
{
    agent->SetTargetRadius(radius);
}

void AgentUtilities::SetTeam(Agent* const agent, const Ogre::String& team)
{
    agent->SetTeam(team);
}

void AgentUtilities::SetVelocity(Agent* const agent, const Ogre::Vector3& velocity)
{
    agent->SetVelocity(velocity);
}

void AgentUtilities::UpdateRigidBodyCapsule(Agent* const agent)
{
    agent->GetSandbox()->GetPhysicsWorld()->RemoveRigidBody(
        agent->GetRigidBody());

    PhysicsUtilities::DeleteRigidBody(agent->GetRigidBody());

    agent->SetRigidBody(NULL);

    CreateRigidBodyCapsule(agent);
}

void AgentUtilities::UpdateWorldTransform(Agent* const agent)
{
    btRigidBody* const rigidBody = agent->GetRigidBody();

    if (rigidBody)
    {
        Ogre::SceneNode* const sceneNode = agent->GetSceneNode();

        const btVector3& rigidBodyPosition =
            rigidBody->getWorldTransform().getOrigin();

        sceneNode->_setDerivedPosition(Ogre::Vector3(
            rigidBodyPosition.m_floats[0],
            rigidBodyPosition.m_floats[1],
            rigidBodyPosition.m_floats[2]));

        const btQuaternion rigidBodyOrientation =
            rigidBody->getWorldTransform().getRotation();

        sceneNode->_setDerivedOrientation(Ogre::Quaternion(
            rigidBodyOrientation.w(),
            rigidBodyOrientation.x(),
            rigidBodyOrientation.y(),
            rigidBodyOrientation.z()));
    }
}