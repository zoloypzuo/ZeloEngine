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

#ifndef DEMO_FRAMEWORK_LUA_SCRIPT_BINDINGS_H
#define DEMO_FRAMEWORK_LUA_SCRIPT_BINDINGS_H

struct lua_State;

/**
 * @summary Apply a three dimensional force in meters to the agent.
 * @param agent Agent to apply force on.
 * @param vector Representing force in meters.
 * @package Agent
 * @example force = Agent.ApplyForce(agent, Vector.new(1, 0, 0));
 */
int Lua_Script_AgentApplyForce(lua_State* luaVM);

/**
 * @summary Metamethod that determines if the agent is equal to the other
 *   variable.
 * @param agent Agent to compare.
 * @param variable Variable to compare against.
 * @return boolean True if the variable is equal to the agent.
 * @package Agent
 * @example comparison = agent == variable;
 */
int Lua_Script_AgentEquals(lua_State* luaVM);

/**
 * @summary Calculate a force vector to steer the agent into aligning with
 *   neighbor agents.
 * @param agent Agent to calculate a steering force for.
 * @param number Maximum distance to maintain with neighbors in meters.
 * @param number Maximum angle to maintain with neighbors in degrees.
 * @param table Table of agents indexed by number 1..n
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToAlign(agent, 1, 90, { agent2, agent3 });
 */
int Lua_Script_AgentForceToAlign(lua_State* luaVM);

/**
 * @summary Calculate a force to avoid all other agents within the sandbox.
 * @param agent Agent to calculate avoidance force for.
 * @param number Optional time in seconds to predict future movements, defaults
 *   to 0.1 seconds.
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToAvoidAgents(agent);
 * @example force = Agent.ForceToAvoidAgents(agent, 1);
 */
int Lua_Script_AgentForceToAvoidAgents(lua_State* luaVM);

/**
 * @summary Calculate a force to avoid all movable objects within the sandbox.
 * @param agent Agent to calculate avoidance force for.
 * @param number Optional time in seconds to predict future movements, defaults
 *   to 0.1 seconds.
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToAvoidObjects(agent);
 * @example force = Agent.ForceToAvoidObjects(agent, 1);
 */
int Lua_Script_AgentForceToAvoidObjects(lua_State* luaVM);

/**
 * @summary Calculate a force vector to steer the agent into moving toward a
 *   group of agents.
 * @param agent Agent to calculate a steering force for.
 * @param number Agents must be within this distance to be considered within the
 *   group.
 * @param number Agents must be within this degree of difference to be
 *   considered within the group.
 * @param table Table of agents indexed by number 1..n
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToCombine(agent, 1, 90, { agent2, agent3 });
 */
int Lua_Script_AgentForceToCombine(lua_State* luaVM);

/**
 * @summary Calculate a force vector to steer the agent away from the position.
 * @param agent Agent to calculate a steering force for.
 * @param vector Position to steering away from.
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToFleePosition(agent, vector.new(10, 0, 10));
 */
int Lua_Script_AgentForceToFleePosition(lua_State* luaVM);

/**
 * @summary Calculate a force vector to steer toward the Agent's current path.
 *   If the Agent doesn't have a path, returns the zero vector.
 * @param agent Agent to calculate following force for.
 * @param number Optional time in seconds to predict future movements, defaults
 *   to 0.1 seconds.
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToFollowPath(agent);
 * @example force = Agent.ForceToFollowPath(agent, 1);
 */
int Lua_Script_AgentForceToFollowPath(lua_State* luaVM);

/**
 * @summary Calculate a force vector to steer the Agent's toward a position.
 * @param agent Agent to calculate seeking force for.
 * @param vector Position to steer towards.
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToPosition(agent, Vector.new(10, 0, 10));
 */
int Lua_Script_AgentForceToPosition(lua_State* luaVM);

/**
 * @summary Calculate a force vector to steer away from a group of Agents.
 * @param agent Agent to calculate a separation force for.
 * @param number Agents must be within this distance to be considered within the
 *   group.
 * @param number Agents must be within this degree of difference to be
 *   considered within the group.
 * @param table Table of agents indexed by number 1..n
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToSeparate(agent, 1, 90, { agent2, agent3 });
 */
int Lua_Script_AgentForceToSeparate(lua_State* luaVM);

/**
 * @summary Calculate a force vector to steer toward the Agent toward the
 *   nearest path segment of their path.
 * @param agent Agent to calculate a separation force for.
 * @param number Optional time in seconds to predict future movements, defaults
 *   to 0.1 seconds.
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToStayOnPath(agent);
 * @example force = Agent.ForceToStayOnPath(agent, 1);
 */
int Lua_Script_AgentForceToStayOnPath(lua_State* luaVM);

/**
 * @summary Calculate a force vector to accelerate or decelerate the Agent to
 *   the specified speed.
 * @param agent Agent to calculate a speed adjustment force for.
 * @param number Speed in meters for the Agent to match.
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToTargetSpeed(agent, 3);
 */
int Lua_Script_AgentForceToTargetSpeed(lua_State* luaVM);

/**
 * @summary Calculate a force vector that randomly moves the agent in any
 *   direction.  The delta time in milliseconds controls the magnitude of the
 *   force vector.
 * @param agent Agent to calculate a force vector for.
 * @param number Delta time in milliseconds since the previous calling frame.
 * @return vector Force vector in meters.
 * @package Agent
 * @example force = Agent.ForceToWander(agent, deltaTimeInMillis);
 */
int Lua_Script_AgentForceToWander(lua_State* luaVM);

int Lua_Script_AgentGetDistanceAlongPath(lua_State* luaVM);

/**
 * @summary Returns the forward axis of the Agent.
 * @param agent Agent to return the forward axis to.
 * @return vector Normalized forward vector.
 * @package Agent
 * @example forward = Agent.GetForward(agent);
 */
int Lua_Script_AgentGetForward(lua_State* luaVM);

/**
 * @summary Returns the current health of the Agent.  Defaults to 100.
 * @param agent Agent to return the health of.
 * @return number Health of the Agent.
 * @package Agent
 * @example health = Agent.GetHealth(agent);
 */
int Lua_Script_AgentGetHealth(lua_State* luaVM);

/**
 * @summary Returns the current height of the Agent.  Defaults to 1.6 meters.
 * @param agent Agent to return the height of.
 * @return number Height in meters.
 * @package Agent
 * @example height = Agent.GetHeight(agent);
 */
int Lua_Script_AgentGetHeight(lua_State* luaVM);

/**
 * @summary Returns the unique id of the Agent.
 * @param agent Agent to return the id of.
 * @return number Unique id number.
 * @package Agent
 * @example id = Agent.GetId(agent);
 */
int Lua_Script_AgentGetId(lua_State* luaVM);

/**
 * @summary Returns the left axis of the Agent.
 * @param agent Agent to return the left axis to.
 * @return vector Normalized left vector.
 * @package Agent
 * @example left = Agent.GetLeft(agent);
 */
int Lua_Script_AgentGetLeft(lua_State* luaVM);

/**
 * @summary Returns the current mass of the Agent.  Defaults to 90.7 kilograms.
 * @param agent Agent to return the mass of.
 * @return number Mass of the Agent.
 * @package Agent
 * @example mass = Agent.GetMass(agent);
 */
int Lua_Script_AgentGetMass(lua_State* luaVM);

/**
 * @summary Returns the maximum number of newtons the Agent's force vector can
 *   reach.
 * @param agent Agent to return the maximum force of.
 * @return number Maximum force in number of newtons.
 * @package Agent
 * @example force = Agent.GetForce(agent);
 */
int Lua_Script_AgentGetMaxForce(lua_State* luaVM);

/**
 * @summary Returns the maximum speed in meters per second the Agent can reach.
 * @param agent Agent to return the maximum speed of.
 * @return number Speed in meters per seconds.
 * @package Agent
 * @example speed = Agent.GetMaxSpeed(agent);
 */
int Lua_Script_AgentGetMaxSpeed(lua_State* luaVM);

int Lua_Script_AgentGetNearestPointOnPath(lua_State* luaVM);

/**
 * @summary Returns a table of vectors representing the current path of the
 *   Agent.
 * @param agent Agent to return the path of.
 * @return table Table of vectors.  An empty table is returned if the Agent
 *   has no path.
 * @package Agent
 * @example path = Agent.GetPath(agent);
 */
int Lua_Script_AgentGetPath(lua_State* luaVM);

int Lua_Script_AgentGetPointOnPath(lua_State* luaVM);

/**
 * @summary Returns the Agent's current position.  This is the Agent's
 *   midpoint.
 * @param agent Agent to return the position of.
 * @return vector Position in meters.
 * @package Agent
 * @example position = Agent.GetPosition(agent);
 */
int Lua_Script_AgentGetPosition(lua_State* luaVM);

/**
 * @summary Returns the Agent's current radius.  This is the Agent's capsule
 *   radius used for avoidance and physics.
 * @param agent Agent to return the radius of.
 * @return number Radius in meters.
 * @package Agent
 * @example radius = Agent.GetRadius(agent);
 */
int Lua_Script_AgentGetRadius(lua_State* luaVM);

/**
 * @summary Returns the Sandbox instance the Agent belongs to.
 * @param agent Agent to return the Sandbox from.
 * @return sandbox Sandbox instance.
 * @package Agent
 * @example sandbox = Agent.GetSandbox(agent);
 */
int Lua_Script_AgentGetSandbox(lua_State* luaVM);

/**
 * @summary Returns the current speed of the agent as a scalar in meters per
 *   second.
 * @param agent Agent to return the current speed of.
 * @return number Speed in meters per second.
 * @package Agent
 * @example speed = Agent.GetSpeed(agent);
 */
int Lua_Script_AgentGetSpeed(lua_State* luaVM);

/**
 * @summary Returns the current target position of the agent in meters.
 * @param agent Agent to return the target of.
 * @return vector Position in meters.
 * @package Agent
 * @example target = Agent.GetTarget(agent);
 */
int Lua_Script_AgentGetTarget(lua_State* luaVM);

/**
 * @summary Returns the current target radius of the agent in meters.  The
 *   target radius is used to determine if the Agent is at the Agent's target
 *   position.
 * @param agent Agent to return the target radius of.
 * @return number Target radius in meters.
 * @package Agent
 * @example targetRadius = Agent.GetTargetRadius(agent);
 */
int Lua_Script_AgentGetTargetRadius(lua_State* luaVM);

/**
 * @summary Returns the current team name of the Agent, defaults to the empty
 *   string.
 * @param agent Agent to return the team for.
 * @return string Team name.
 * @package Agent
 * @example team = Agent.GetTeam(agent);
 */
int Lua_Script_AgentGetTeam(lua_State* luaVM);

/**
 * @summary Return the normalized up vector for the Agent.
 * @param agent Agent to return the up vector for.
 * @return vector Vector pointing in the up direction, normalized.
 * @package Agent
 * @example up = Agent.GetUp(agent);
 */
int Lua_Script_AgentGetUp(lua_State* luaVM);

/**
 * @summary Returns the current velocity vector of the Agent.  The velocity
 *   vector is the direction the Agent is moving and the magnitude of the vector
 *   is the current speed of the Agent.  Velocity is measured in meters per
 *   second.
 * @param agent Agent to return the velocity for.
 * @return vector Velocity vector in meters per second.
 * @package Agent
 * @example velocity = Agent.GetVelocity(agent);
 */
int Lua_Script_AgentGetVelocity(lua_State* luaVM);

int Lua_Script_AgentHasPath(lua_State* luaVM);

int Lua_Script_AgentIndex(lua_State* luaVM);

int Lua_Script_AgentIsAgent(lua_State* luaVM);

int Lua_Script_AgentPredictFuturePosition(lua_State* luaVM);

int Lua_Script_AgentRemovePath(lua_State* luaVM);

int Lua_Script_AgentRemovePhysics(lua_State* luaVM);

int Lua_Script_AgentSetForward(lua_State* luaVM);

int Lua_Script_AgentSetHealth(lua_State* luaVM);

int Lua_Script_AgentSetHeight(lua_State* luaVM);

int Lua_Script_AgentSetMass(lua_State* luaVM);

int Lua_Script_AgentSetPath(lua_State* luaVM);

int Lua_Script_AgentSetPosition(lua_State* luaVM);

int Lua_Script_AgentSetRadius(lua_State* luaVM);

int Lua_Script_AgentSetSpeed(lua_State* luaVM);

int Lua_Script_AgentSetMaxForce(lua_State* luaVM);

int Lua_Script_AgentSetMaxSpeed(lua_State* luaVM);

int Lua_Script_AgentSetTarget(lua_State* luaVM);

int Lua_Script_AgentSetTargetRadius(lua_State* luaVM);

int Lua_Script_AgentSetTeam(lua_State* luaVM);

int Lua_Script_AgentSetVelocity(lua_State* luaVM);

int Lua_Script_AgentToWatch(lua_State* luaVM);

int Lua_Script_AnimationAttachToBone(lua_State* luaVM);

int Lua_Script_AnimationGetAnimation(lua_State* luaVM);

int Lua_Script_AnimationGetBoneNames(lua_State* luaVM);

int Lua_Script_AnimationGetBonePosition(lua_State* luaVM);

int Lua_Script_AnimationGetBoneRotation(lua_State* luaVM);

int Lua_Script_AnimationGetLength(lua_State* luaVM);

int Lua_Script_AnimationGetName(lua_State* luaVM);

int Lua_Script_AnimationGetNormalizedTime(lua_State* luaVM);

int Lua_Script_AnimationGetTime(lua_State* luaVM);

int Lua_Script_AnimationGetWeight(lua_State* luaVM);

int Lua_Script_AnimationIsEnabled(lua_State* luaVM);

int Lua_Script_AnimationIsLooping(lua_State* luaVM);

int Lua_Script_AnimationReset(lua_State* luaVM);

int Lua_Script_AnimationSetDisplaySkeleton(lua_State* luaVM);

int Lua_Script_AnimationSetEnabled(lua_State* luaVM);

int Lua_Script_AnimationSetLooping(lua_State* luaVM);

int Lua_Script_AnimationSetNormalizedTime(lua_State* luaVM);

int Lua_Script_AnimationSetTime(lua_State* luaVM);

int Lua_Script_AnimationSetWeight(lua_State* luaVM);

int Lua_Script_AnimationStepAnimation(lua_State* luaVM);

int Lua_Script_AnimationToWatch(lua_State* luaVM);

int Lua_Script_CoreApplyForce(lua_State* luaVM);

int Lua_Script_CoreApplyImpulse(lua_State* luaVM);

int Lua_Script_CoreApplyAngularImpulse(lua_State* luaVM);

int Lua_Script_CoreCacheResource(lua_State* luaVM);

int Lua_Script_CoreCreateBox(lua_State* luaVM);

int Lua_Script_CoreCreateCapsule(lua_State* luaVM);

int Lua_Script_CoreCreateCircle(lua_State* luaVM);

int Lua_Script_CoreCreateCylinder(lua_State* luaVM);

int Lua_Script_CoreCreateDirectionalLight(lua_State* luaVM);

int Lua_Script_CoreCreateLine(lua_State* luaVM);

int Lua_Script_CoreCreateMesh(lua_State* luaVM);

int Lua_Script_CoreCreateParticle(lua_State* luaVM);

int Lua_Script_CoreCreatePlane(lua_State* luaVM);

int Lua_Script_CoreCreatePointLight(lua_State* luaVM);

int Lua_Script_CoreDrawLine(lua_State* luaVM);

int Lua_Script_CoreDrawCircle(lua_State* luaVM);

int Lua_Script_CoreDrawSphere(lua_State* luaVM);

int Lua_Script_CoreDrawSquare(lua_State* luaVM);

int Lua_Script_CoreGetMass(lua_State* luaVM);

int Lua_Script_CoreGetPosition(lua_State* luaVM);

int Lua_Script_CoreGetRadius(lua_State* luaVM);

int Lua_Script_CoreGetRotation(lua_State* luaVM);

int Lua_Script_CoreIsVisible(lua_State* luaVM);

int Lua_Script_CoreRemove(lua_State* luaVM);

int Lua_Script_CoreRequireLuaModule(lua_State* luaVM);

int Lua_Script_CoreResetParticle(lua_State* luaVM);

int Lua_Script_CoreSetAxis(lua_State* luaVM);

int Lua_Script_CoreSetGravity(lua_State* luaVM);

int Lua_Script_CoreSetLightDiffuse(lua_State* luaVM);

int Lua_Script_CoreSetLightRange(lua_State* luaVM);

int Lua_Script_CoreSetLightSpecular(lua_State* luaVM);

int Lua_Script_CoreSetLineStartEnd(lua_State* luaVM);

int Lua_Script_CoreSetMass(lua_State* luaVM);

int Lua_Script_CoreSetMaterial(lua_State* luaVM);

int Lua_Script_CoreSetParticleDirection(lua_State* luaVM);

int Lua_Script_CoreSetPosition(lua_State* luaVM);

int Lua_Script_CoreSetRotation(lua_State* luaVM);

int Lua_Script_CoreSetVisible(lua_State* luaVM);

int Lua_Script_CoreTypeToWatch(lua_State* luaVM);

int Lua_Script_SandboxAddCollisionCallback(lua_State* luaVM);

int Lua_Script_SandboxAddEvent(lua_State* luaVM);

int Lua_Script_SandboxAddEventCallback(lua_State* luaVM);

int Lua_Script_SandboxClearInfluenceMap(lua_State* luaVM);

int Lua_Script_SandboxCreateAgent(lua_State* luaVM);

int Lua_Script_SandboxCreateBox(lua_State* luaVM);

int Lua_Script_SandboxCreateCapsule(lua_State* luaVM);

int Lua_Script_SandboxCreateInfluenceMap(lua_State* luaVM);

int Lua_Script_SandboxCreateNavigationMesh(lua_State* luaVM);

int Lua_Script_SandboxCreateObject(lua_State* luaVM);

int Lua_Script_SandboxCreatePhysicsCapsule(lua_State* luaVM);

int Lua_Script_SandboxCreatePhysicsSphere(lua_State* luaVM);

int Lua_Script_SandboxCreatePlane(lua_State* luaVM);

int Lua_Script_SandboxCreateSkyBox(lua_State* luaVM);

int Lua_Script_SandboxCreateUIComponent(lua_State* luaVM);

int Lua_Script_SandboxCreateUIComponent3d(lua_State* luaVM);

int Lua_Script_SandboxDrawInfluenceMap(lua_State* luaVM);

int Lua_Script_SandboxFindClosestPoint(lua_State* luaVM);

int Lua_Script_SandboxFindPath(lua_State* luaVM);

int Lua_Script_SandboxGetAgents(lua_State* luaVM);

int Lua_Script_SandboxGetCameraForward(lua_State* luaVM);

int Lua_Script_SandboxGetCameraLeft(lua_State* luaVM);

int Lua_Script_SandboxGetCameraOrientation(lua_State* luaVM);

int Lua_Script_SandboxGetCameraPosition(lua_State* luaVM);

int Lua_Script_SandboxGetCameraUp(lua_State* luaVM);

int Lua_Script_SandboxGetDrawPhysicsWorld(lua_State* luaVM);

int Lua_Script_SandboxGetInertia(lua_State* luaVM);

int Lua_Script_SandboxGetMarkupColor(lua_State* luaVM);

int Lua_Script_SandboxGetObjects(lua_State* luaVM);

int Lua_Script_SandboxGetProfileRenderTime(lua_State* luaVM);

int Lua_Script_SandboxGetProfileSimTime(lua_State* luaVM);

int Lua_Script_SandboxGetProfileTotalSimTime(lua_State* luaVM);

int Lua_Script_SandboxGetScreenHeight(lua_State* luaVM);

int Lua_Script_SandboxGetScreenWidth(lua_State* luaVM);

int Lua_Script_SandboxGetTimeInMillis(lua_State* luaVM);

int Lua_Script_SandboxGetTimeInSeconds(lua_State* luaVM);

int Lua_Script_SandboxRandomPoint(lua_State* luaVM);

int Lua_Script_SandboxRayCastToObject(lua_State* luaVM);

int Lua_Script_SandboxRemoveObject(lua_State* luaVM);

int Lua_Script_SandboxSetAmbientLight(lua_State* luaVM);

int Lua_Script_SandboxSetCameraForward(lua_State* luaVM);

int Lua_Script_SandboxSetCameraOrientation(lua_State* luaVM);

int Lua_Script_SandboxSetCameraPosition(lua_State* luaVM);

int Lua_Script_SandboxSetDebugNavigationMesh(lua_State* luaVM);

int Lua_Script_SandboxSetDrawInfluenceMap(lua_State* luaVM);

int Lua_Script_SandboxSetDrawPhysicsWorld(lua_State* luaVM);

int Lua_Script_SandboxSetFalloff(lua_State* luaVM);

int Lua_Script_SandboxSetInertia(lua_State* luaVM);

int Lua_Script_SandboxSetInfluence(lua_State* luaVM);

int Lua_Script_SandboxSetMarkupColor(lua_State* luaVM);

int Lua_Script_SandboxSpreadInfluenceMap(lua_State* luaVM);

int Lua_Script_Vector3Add(lua_State* luaVM);

int Lua_Script_Vector3CrossProduct(lua_State* luaVM);

int Lua_Script_Vector3Distance(lua_State* luaVM);

int Lua_Script_Vector3DistanceSquared(lua_State* luaVM);

int Lua_Script_Vector3Divide(lua_State* luaVM);

int Lua_Script_Vector3DotProduct(lua_State* luaVM);

int Lua_Script_Vector3Equal(lua_State* luaVM);

int Lua_Script_Vector3Index(lua_State* luaVM);

int Lua_Script_Vector3Length(lua_State* luaVM);

int Lua_Script_Vector3LengthSquared(lua_State* luaVM);

int Lua_Script_Vector3Multiply(lua_State* luaVM);

int Lua_Script_Vector3Negation(lua_State* luaVM);

int Lua_Script_Vector3New(lua_State* luaVM);

int Lua_Script_Vector3NewIndex(lua_State* luaVM);

int Lua_Script_Vector3Normalize(lua_State* luaVM);

int Lua_Script_Vector3Rotate(lua_State* luaVM);

int Lua_Script_Vector3RotationTo(lua_State* luaVM);

int Lua_Script_Vector3Subtract(lua_State* luaVM);

int Lua_Script_Vector3ToString(lua_State* luaVM);

int Lua_Script_Vector3ToWatch(lua_State* luaVM);

int Lua_Script_UIComponentToWatch(lua_State* luaVM);

int Lua_Script_UICreateChild(lua_State* luaVM);

int Lua_Script_UIGetDimensions(lua_State* luaVM);

int Lua_Script_UIGetFont(lua_State* luaVM);

int Lua_Script_UIGetMarkupText(lua_State* luaVM);

int Lua_Script_UIGetOffsetPosition(lua_State* luaVM);

int Lua_Script_UIGetPosition(lua_State* luaVM);

int Lua_Script_UIGetScreenPosition(lua_State* luaVM);

int Lua_Script_UIGetText(lua_State* luaVM);

int Lua_Script_UIGetTextMargin(lua_State* luaVM);

int Lua_Script_UIIsVisible(lua_State* luaVM);

int Lua_Script_UISetBackgroundColor(lua_State* luaVM);

int Lua_Script_UISetDimensions(lua_State* luaVM);

int Lua_Script_UISetGradientColor(lua_State* luaVM);

int Lua_Script_UISetFont(lua_State* luaVM);

int Lua_Script_UISetFontColor(lua_State* luaVM);

int Lua_Script_UISetMarkupText(lua_State* luaVM);

int Lua_Script_UISetPosition(lua_State* luaVM);

int Lua_Script_UISetText(lua_State* luaVM);

int Lua_Script_UISetTextMargin(lua_State* luaVM);

int Lua_Script_UISetVisible(lua_State* luaVM);

int Lua_Script_UISetWorldPosition(lua_State* luaVM);

int Lua_Script_UISetWorldRotation(lua_State* luaVM);

#endif  // DEMO_FRAMEWORK_LUA_SCRIPT_BINDINGS_H
