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

#ifndef DEMO_FRAMEWORK_AGENT_H
#define DEMO_FRAMEWORK_AGENT_H

#include <vector>

#include "demo_framework/include/AgentPath.h"
#include "demo_framework/include/Object.h"
#include "ogre3d/include/OgrePrerequisites.h"
#include "opensteer/include/AbstractVehicle.h"
#include "opensteer/include/LocalSpace.h"
#include "opensteer/include/SteerLibrary.h"

struct lua_State;

class btRigidBody;
class Sandbox;
class SandboxObject;

namespace Ogre
{
class SceneNode;
class Vector3;
}

class Agent :
    public Object,
    private OpenSteer::SteerLibraryMixin<OpenSteer::AbstractVehicle>
{
friend class AgentGroup;

public:
    static const float DEFAULT_AGENT_HEALTH;
    static const float DEFAULT_AGENT_HEIGHT;
    static const float DEFAULT_AGENT_MASS;
    static const float DEFAULT_AGENT_MAX_FORCE;
    static const float DEFAULT_AGENT_MAX_SPEED;
    static const float DEFAULT_AGENT_RADIUS;
    static const float DEFAULT_AGENT_SPEED;
    static const float DEFAULT_AGENT_TARGET_RADIUS;
    static const float DEFAULT_AGENT_WALKABLE_CLIMB;
    static const float DEFAULT_AGENT_WALKABLE_SLOPE;
    static const Ogre::String DEFAULT_AGENT_TEAM;

    /**
     * Constructs a default Agent and uses the Ogre SceneNode for the Agent's
     * spatial position, and orientation.
     *
     * The Agent will update the SceneNode's position and orientation
     * throughout the Agent's lifetime. No other Ogre Entity should be attached
     * to this SceneNode.
     *
     * The Agent must be destroyed before the SceneManager destroys the
     * SceneNode.
     */
    Agent(
        const unsigned int agentId,
        Ogre::SceneNode* const sceneNode,
        btRigidBody* const rigidBody);

    virtual ~Agent();

    void Cleanup();

    void ClearPath();

    Ogre::Vector3 ForceToAlign(
        const Ogre::Real maxDistance,
        const Ogre::Degree maxAngle,
        const AgentGroup& group);

    Ogre::Vector3 ForceToAvoidAgents(
        const std::vector<Agent*>& agents, const float predictionTime = 2.0f);

    Ogre::Vector3 ForceToAvoidObjects(
        const std::map<unsigned int, SandboxObject*>& objects,
        const float predictionTime = 2.0f);

    Ogre::Vector3 ForceToCombine(
        const Ogre::Real maxDistance,
        const Ogre::Degree maxAngle,
        const AgentGroup& group);

    Ogre::Vector3 ForceToFleePosition(const Ogre::Vector3& position);

    Ogre::Vector3 ForceToFollowPath(const float predictionTime = 2.0f);

    Ogre::Vector3 ForceToFollowPath(
        AgentPath& path, const float predictionTime = 2.0f);

    Ogre::Vector3 ForceToPosition(const Ogre::Vector3& position);

    Ogre::Vector3 ForceToSeparate(
        const Ogre::Real maxDistance,
        const Ogre::Degree maxAngle,
        const AgentGroup& group);

    Ogre::Vector3 ForceToStayOnPath(const float predictionTime = 2.0f);

    Ogre::Vector3 ForceToStayOnPath(
        AgentPath& path, const float predictionTime = 2.0f);

    Ogre::Vector3 ForceToTargetSpeed(const Ogre::Real speed);

    Ogre::Vector3 ForceToWander(const Ogre::Real deltaMilliseconds);

    /**
     * Current forward unit vector of the agent.
     *
     * @remarks
     *      The Z-Axis is used as the forward axis.
     *      (x,y,z) = (0,0,1) would be the default forward unit vector.
     *      Agents use the right handed coordinate system.
     */
    Ogre::Vector3 GetForward() const;

    Ogre::Real GetHealth() const;

    Ogre::Real GetHeight() const;

    /**
     * Current left unit vector of the agent.
     *
     * @remarks
     *      The X Axis is used as the left axis.
     *      (x,y,z) = (1,0,0) would be the default left unit vector.
     *      Agents use the right handed coordinate system.
     */
    Ogre::Vector3 GetLeft() const;

    lua_State* GetLuaVM();

    /**
     * Current mass in kilograms.
     */
    Ogre::Real GetMass() const;

    /**
     * Max force in Newtons the agent can exert while steering.
     */
    Ogre::Real GetMaxForce() const;

    /**
     * Maximum speed an agent may travel.
     */
    Ogre::Real GetMaxSpeed() const;

    Ogre::Quaternion GetOrientation() const;

    AgentPath GetPath();

    const AgentPath& GetPath() const;

    /**
     * Local position of the agent.
     */
    Ogre::Vector3 GetPosition() const;

    /**
     * Current radius of the agent in meters.
     */
    Ogre::Real GetRadius() const;

    btRigidBody* GetRigidBody();

    Sandbox* GetSandbox();

    Ogre::SceneNode* GetSceneNode();

    /**
     * Current speed of the agent in meters per second.
     *
     * @remarks
     *      The magnitude of the velocity.
     */
    Ogre::Real GetSpeed() const;

    /**
     * Current target position of the agent.
     */
    Ogre::Vector3 GetTarget() const;

    /**
     * Radius distance to consider the agent has reached the target position.
     *
     * @remarks
     *      Radius is measured in meters.
     */
    Ogre::Real GetTargetRadius() const;

    const Ogre::String& GetTeam() const;

    Ogre::Vector3 GetUp() const;

    /**
     * Current velocity of the agent based on the agent's forward direction and
     * speed.
     *
     * @remarks
     *      Velocity is measured in meters per second(m/s).
     */
    Ogre::Vector3 GetVelocity() const;

    bool HasPath() const;

    void Initialize();

    void LoadScript(
        const char* const luaScript,
        const size_t bufferSize,
        const char* const fileName);

    /**
     * Predicted position of the agent based on a constant velocity.
     *
     * @param predictionTime Number of seconds to predict into the future.
     */
    Ogre::Vector3 PredictFuturePosition(const Ogre::Real predictionTime) const;

    bool ReloadScript(
        const char* const luaScript,
        const size_t bufferSize,
        const char* const fileName);

    void RemovePath();

    void SetForward(const Ogre::Vector3& forward);

    void SetForward(const Ogre::Quaternion& orientation);

    void SetHealth(const Ogre::Real health);

    void SetHeight(const Ogre::Real height);

    /**
     * Sets the mass of the Agent in kilograms.
     * Minimum value of 0, represents an immovable object.
     *
     * @remarks
     *      Mass is used to calculate the force of an agent.
     *      Force = Mass * Acceleration
     */
    void SetMass(const Ogre::Real mass);

    /**
     * Sets the max force the agent can exert while steering.
     * Minimum value of 0.
     *
     * @remarks
     *      Force measured in Newtons.
     *      kilograms * meters per second square, kg*m/s^2
     */
    void SetMaxForce(const Ogre::Real force);

    /**
     * Sets the max speed an agent may travel, negative moves the agent in the
     * opposite direction of the forward vector.
     *
     * @remarks
     *      Speed is measured in meters per second(m/s).
     */
    void SetMaxSpeed(const Ogre::Real speed);

    void SetPath(const AgentPath& path);

    /**
     * Sets the local position of the agent.
     */
    void SetPosition(const Ogre::Vector3 position);

    /**
     * Sets the radius of the Agent in meters.
     * Minimum value of 0.
     *
     * @remarks
     *      The Agent's radius is used for pathfinding, obstacle avoidance,
     *      and physics.
     */
    void SetRadius(const Ogre::Real radius);

    void SetRigidBody(btRigidBody* const rigidBody);

    void SetSandbox(Sandbox* const sandbox);

    /**
     * Sets the speed of the agent.
     *
     * @remarks
     *      Speed, measured in meters per second(m/s).
     */
    void SetSpeed(const Ogre::Real speed);

    /**
     * Sets the target position of the agent.  Typically used for movement.
     */
    void SetTarget(const Ogre::Vector3& target);

    /**
     * Sets the target radius to consider begin at the target location.
     *
     * @remarks
     *      Radius is measured in meters.
     */
    void SetTargetRadius(const Ogre::Real radius);

    void SetTeam(const Ogre::String& team);

    void SetVelocity(const Ogre::Vector3& velocity);

    void Update(const int deltaMilliseconds);

private:
    Sandbox* sandbox_;

    lua_State* luaVM_;
    Ogre::SceneNode* sceneNode_;
    btRigidBody* rigidBody_;

    AgentPath path_;
    bool hasPath_;

    Ogre::Real height_;
    Ogre::Real maxForce_;
    Ogre::Real maxSpeed_;
    Ogre::Real radius_;
    Ogre::Real speed_;
    Ogre::Real mass_;
    Ogre::Vector3 target_;
    Ogre::Real targetRadius_;
    Ogre::Real health_;
    Ogre::String team_;

    /**
     * Unimplemented copy constructor.
     */
    Agent(const Agent& agent);

    /**
     * Unimplemented assignment operator.
     */
    Agent& operator=(const Agent& agent);

    /**
     * Private implementation of OpenSteer AbstractVehicle.
     *
     * @remarks
     *      Implementing these functions are required to access OpenSteer
     *      functionality but public versions utilizing Ogre::Real's are
     *      preferred to interface between Ogre's math library and additional
     *      third party libraries.
     *
     * @see opensteer/include/AbstractVehicle.h
     */
    virtual OpenSteer::Vec3 forward() const;
    virtual OpenSteer::Vec3 globalizeDirection(const OpenSteer::Vec3&) const;
    virtual OpenSteer::Vec3 globalizePosition(const OpenSteer::Vec3&) const;
    virtual OpenSteer::Vec3 globalRotateForwardToSide(
        const OpenSteer::Vec3&) const;
    virtual OpenSteer::Vec3 localizeDirection(const OpenSteer::Vec3&) const;
    virtual OpenSteer::Vec3 localizePosition(const OpenSteer::Vec3&) const;
    virtual OpenSteer::Vec3 localRotateForwardToSide(
        const OpenSteer::Vec3&) const;
    virtual float mass() const;
    virtual float maxForce() const;
    virtual float maxSpeed() const;
    virtual OpenSteer::Vec3 position() const;
    virtual OpenSteer::Vec3 predictFuturePosition(const float) const;
    virtual float radius() const;
    virtual void regenerateOrthonormalBasisUF(const OpenSteer::Vec3&);
    virtual void regenerateOrthonormalBasis(const OpenSteer::Vec3&);
    virtual void regenerateOrthonormalBasis(
        const OpenSteer::Vec3&, const OpenSteer::Vec3&);
    virtual void resetLocalSpace();
    virtual bool rightHanded() const;
    virtual OpenSteer::Vec3 setForward(OpenSteer::Vec3);
    virtual float setMass(float);
    virtual float setMaxForce(float);
    virtual float setMaxSpeed(float);
    virtual OpenSteer::Vec3 setPosition(OpenSteer::Vec3);
    virtual float setRadius(float);
    virtual OpenSteer::Vec3 setSide(OpenSteer::Vec3);
    virtual float setSpeed(float speed);
    virtual void setUnitSideFromForwardAndUp();
    virtual OpenSteer::Vec3 setUp(OpenSteer::Vec3);
    virtual OpenSteer::Vec3 side() const;
    virtual float speed() const;
    virtual OpenSteer::Vec3 up() const;
    virtual void update(const float, const float);
    virtual OpenSteer::Vec3 velocity() const;
    /**
     * end of OpenSteer AbstractVehicle implementation.
     */
};

#endif  // DEMO_FRAMEWORK_AGENT_H
