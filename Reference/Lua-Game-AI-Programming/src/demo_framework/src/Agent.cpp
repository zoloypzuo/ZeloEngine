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
#include "demo_framework/include/AgentUtilities.h"
#include "demo_framework/include/AnimationUtilities.h"
#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/PhysicsUtilities.h"
#include "demo_framework/include/SandboxObject.h"
#include "demo_framework/include/SandboxUtilities.h"

namespace
{
inline Ogre::Quaternion BtQuaterionToQuaternion(const btQuaternion& quaternion)
{
    return Ogre::Quaternion(
        quaternion.w(), quaternion.x(), quaternion.y(), quaternion.z());
}

inline btQuaternion QuaternionToBtQuaternion(
    const Ogre::Quaternion& quaternion)
{
    return btQuaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w);
}

inline OpenSteer::Vec3 Vector3ToVec3(const Ogre::Vector3& vector)
{
    return OpenSteer::Vec3(
        static_cast<float>(vector.x),
        static_cast<float>(vector.y),
        static_cast<float>(vector.z));
}

inline Ogre::Vector3 Vec3ToVector3(const OpenSteer::Vec3& vector)
{
    return Ogre::Vector3(
        Ogre::Real(vector.x), Ogre::Real(vector.y), Ogre::Real(vector.z));
}

inline btVector3 Vector3ToBtVector3(const Ogre::Vector3& vector)
{
    return btVector3(
        btScalar(vector.x), btScalar(vector.y), btScalar(vector.z));
}
}  // anonymous namespace

// Some default humanistic values.
const float Agent::DEFAULT_AGENT_HEALTH =           100.0f;
const float Agent::DEFAULT_AGENT_HEIGHT =           1.6f;  // meters (5.2 feet)
const float Agent::DEFAULT_AGENT_MASS =             90.7f;  // kilograms (200 lbs)
const float Agent::DEFAULT_AGENT_MAX_FORCE =        1000.0f;  // newtons (kg*m/s^2)
const float Agent::DEFAULT_AGENT_MAX_SPEED =        7.0f;  // m/s (23.0 ft/s)
const float Agent::DEFAULT_AGENT_RADIUS =           0.3f;  // meters (1.97 feet)
const float Agent::DEFAULT_AGENT_SPEED =            0.0f;  // m/s (0 ft/s)
const float Agent::DEFAULT_AGENT_TARGET_RADIUS =    0.5f;  // meters (1.64 feet)
const float Agent::DEFAULT_AGENT_WALKABLE_CLIMB =   DEFAULT_AGENT_RADIUS / 2.0f;
const float Agent::DEFAULT_AGENT_WALKABLE_SLOPE =   45.0f;
const Ogre::String Agent::DEFAULT_AGENT_TEAM =      "team1";

Agent::Agent(
    const unsigned int agentId,
    Ogre::SceneNode* const sceneNode,
    btRigidBody* const rigidBody)
    : Object(agentId, Object::AGENT),
    sandbox_(NULL),
    health_(DEFAULT_AGENT_HEALTH),
    height_(DEFAULT_AGENT_HEIGHT),
    hasPath_(false),
    sceneNode_(sceneNode),
    maxForce_(DEFAULT_AGENT_MAX_FORCE),
    maxSpeed_(DEFAULT_AGENT_MAX_SPEED),
    mass_(DEFAULT_AGENT_MASS),
    radius_(DEFAULT_AGENT_RADIUS),
    speed_(DEFAULT_AGENT_SPEED),
    rigidBody_(rigidBody),
    targetRadius_(DEFAULT_AGENT_TARGET_RADIUS),
    team_(DEFAULT_AGENT_TEAM),
    target_(Ogre::Vector3::ZERO)
{
    assert(sceneNode_);
    // SceneNode shouldn't have attached entities already.
    assert(!sceneNode_->numAttachedObjects());
    // SceneNode shouldn't have attached children.
    assert(!sceneNode_->numChildren());

    luaVM_ = LuaScriptUtilities::CreateVM();

    // Add general C functions.
    LuaScriptUtilities::BindVMFunctions(luaVM_);

    // Add Agent specific functions.
    AgentUtilities::BindVMFunctions(luaVM_);

    // Add Sandbox specific functions.
    SandboxUtilities::BindVMFunctions(luaVM_);

    // Add Animation specific functions.
    AnimationUtilities::BindVMFunctions(luaVM_);

    if (rigidBody_)
    {
        PhysicsUtilities::SetRigidBodyMass(rigidBody_, DEFAULT_AGENT_MASS);
        rigidBody->setUserPointer(this);
    }

    SetForward(Ogre::Vector3::UNIT_Z);
}

Agent::~Agent()
{
    sandbox_ = NULL;
    sceneNode_ = NULL;

    if (rigidBody_)
    {
        PhysicsUtilities::DeleteRigidBody(rigidBody_);
    }

    rigidBody_ = NULL;

    LuaScriptUtilities::DestroyVM(luaVM_);
}

void Agent::Cleanup()
{
    AgentUtilities::CallLuaAgentCleanup(this);
}

void Agent::ClearPath()
{
    hasPath_ = false;
}

Ogre::Vector3 Agent::ForceToAlign(
    const Ogre::Real maxDistance,
    const Ogre::Degree maxAngle,
    const AgentGroup& group)
{
    const float maxCosAngle = cosf(maxAngle.valueRadians());
    return Vec3ToVector3(steerForAlignment(maxDistance, maxCosAngle, group));
}

Ogre::Vector3 Agent::ForceToAvoidAgents(
    const std::vector<Agent*>& agents, const float predictionTime)
{
    const static float MIN_PREDICTION_TIME = 0.1f;

    OpenSteer::AVGroup group;
    std::vector<Agent*>::const_iterator it;

    // TODO(David Young): Avoid copying into the AVGroup.
    for (it = agents.begin(); it != agents.end(); ++it)
    {
        Agent* const agent = *it;
        group.push_back(agent);
    }

    return Vec3ToVector3(steerToAvoidNeighbors(
        std::max(MIN_PREDICTION_TIME, predictionTime), group));
}

Ogre::Vector3 Agent::ForceToAvoidObjects(
    const std::map<unsigned int, SandboxObject*>& objects,
    const float predictionTime)
{
    const static float MIN_PREDICTION_TIME = 0.1f;
    const float timeToCollision = std::max(MIN_PREDICTION_TIME, predictionTime);

    OpenSteer::ObstacleGroup group;
    std::map<unsigned int, SandboxObject*>::const_iterator it;

    OpenSteer::Vec3 avoidForce = OpenSteer::Vec3::zero;

    // TODO(David Young): Avoid copying into the ObstacleGroup.
    for (it = objects.begin(); it != objects.end(); ++it)
    {
        SandboxObject* const object = it->second;

        // Only avoid objects that aren't fixed.
        if (object->GetMass() > 0)
        {
            avoidForce += object->steerToAvoid(*this, timeToCollision);
        }
    }

    return Vec3ToVector3(avoidForce);
}

Ogre::Vector3 Agent::ForceToCombine(
    const Ogre::Real maxDistance,
    const Ogre::Degree maxAngle,
    const AgentGroup& group)
{
    const float maxCosAngle = cosf(maxAngle.valueRadians());
    return Vec3ToVector3(steerForCohesion(maxDistance, maxCosAngle, group));
}

Ogre::Vector3 Agent::ForceToFleePosition(const Ogre::Vector3& position)
{
    return Vec3ToVector3(steerForFlee(Vector3ToVec3(position)));
}

Ogre::Vector3 Agent::ForceToFollowPath(const float predicitionTime)
{
    return ForceToFollowPath(path_, predicitionTime);
}

Ogre::Vector3 Agent::ForceToFollowPath(
    AgentPath& path, const float predictionTime)
{
    const static int FORWARD_DIRECTION = 1;
    const static float MIN_PREDICTION_TIME = 0.1f;

    if (path.GetNumberOfPathPoints())
    {
        return Vec3ToVector3(steerToFollowPath(
            FORWARD_DIRECTION,
            std::max(MIN_PREDICTION_TIME, predictionTime),
            path));
    }
    return Ogre::Vector3(0.0f);
}

Ogre::Vector3 Agent::ForceToPosition(const Ogre::Vector3& position)
{
    return Vec3ToVector3(steerForSeek(Vector3ToVec3(position)));
}

Ogre::Vector3 Agent::ForceToStayOnPath(const float predictionTime)
{
    return ForceToStayOnPath(path_, predictionTime);
}

Ogre::Vector3 Agent::ForceToSeparate(
    const Ogre::Real maxDistance,
    const Ogre::Degree maxAngle,
    const AgentGroup& group)
{
    const float maxCosAngle = cosf(maxAngle.valueRadians());
    return Vec3ToVector3(steerForSeparation(maxDistance, maxCosAngle, group));
}

Ogre::Vector3 Agent::ForceToStayOnPath(
    AgentPath& path, const float predictionTime)
{
    const static float MIN_PREDICTION_TIME = 0.1f;

    if (path.GetNumberOfPathPoints())
    {
        return Vec3ToVector3(steerToStayOnPath(
        std::max(MIN_PREDICTION_TIME, predictionTime), path));
    }

    return Ogre::Vector3(0.0f);
}

Ogre::Vector3 Agent::ForceToTargetSpeed(const Ogre::Real speed)
{
    return Vec3ToVector3(steerForTargetSpeed(float(speed)));
}

Ogre::Vector3 Agent::ForceToWander(const Ogre::Real deltaMilliseconds)
{
    return Vec3ToVector3(steerForWander(deltaMilliseconds));
}

OpenSteer::Vec3 Agent::forward() const
{
    return Vector3ToVec3(GetForward());
}

Ogre::Vector3 Agent::GetForward() const
{
    if (rigidBody_)
    {
        const btQuaternion quaterion = rigidBody_->getOrientation();
        return Ogre::Quaternion(
            quaterion.w(), quaterion.x(), quaterion.y(), quaterion.z()).zAxis();
    }
    else if (sceneNode_)
    {
        return sceneNode_->getOrientation().zAxis();
    }

    return Ogre::Vector3::UNIT_Z;
}

Ogre::Real Agent::GetHealth() const
{
    return health_;
}

Ogre::Real Agent::GetHeight() const
{
    return height_;
}

Ogre::Vector3 Agent::GetLeft() const
{
    if (rigidBody_)
    {
        const btQuaternion quaterion = rigidBody_->getOrientation();
        return Ogre::Quaternion(
            quaterion.w(), quaterion.x(), quaterion.y(), quaterion.z()).xAxis();
    }
    else if (sceneNode_)
    {
        return sceneNode_->getOrientation().xAxis();
    }

    return Ogre::Vector3::UNIT_X;
}

lua_State* Agent::GetLuaVM()
{
    return luaVM_;
}

Ogre::Real Agent::GetMass() const
{
    if (rigidBody_)
    {
        return Ogre::Real(PhysicsUtilities::GetRigidBodyMass(rigidBody_));
    }
    else
    {
        return mass_;
    }
}

Ogre::Real Agent::GetMaxForce() const
{
    return maxForce_;
}

Ogre::Real Agent::GetMaxSpeed() const
{
    return maxSpeed_;
}

Ogre::Quaternion Agent::GetOrientation() const
{
    if (rigidBody_)
    {
        return BtQuaterionToQuaternion(rigidBody_->getOrientation());
    }
    else if (sceneNode_)
    {
        return sceneNode_->_getDerivedOrientation();
    }

    return Ogre::Quaternion::ZERO;
}

AgentPath Agent::GetPath()
{
    return path_;
}

const AgentPath& Agent::GetPath() const
{
    return path_;
}

Ogre::Vector3 Agent::GetPosition() const
{
    if (rigidBody_)
    {
        return PhysicsUtilities::BtVector3ToVector3(
            rigidBody_->getCenterOfMassPosition());
    }
    else if (sceneNode_)
    {
        return sceneNode_->_getDerivedPosition();
    }

    return Ogre::Vector3::ZERO;
}

Ogre::Real Agent::GetRadius() const
{
    return radius_;
}

btRigidBody* Agent::GetRigidBody()
{
    return rigidBody_;
}

Sandbox* Agent::GetSandbox()
{
    return sandbox_;
}

Ogre::SceneNode* Agent::GetSceneNode()
{
    return sceneNode_;
}

Ogre::Real Agent::GetSpeed() const
{
    if (rigidBody_)
    {
        const btVector3 velocity = rigidBody_->getLinearVelocity();
        // Ignore movement along the y axis.
        // Gravity does not contribute to the speed of the Agent.
        return Ogre::Real(
            Ogre::Vector3(velocity.x(), 0, velocity.z()).length());
    }
    else
    {
        return speed_;
    }
}

Ogre::Vector3 Agent::GetTarget() const
{
    return target_;
}

Ogre::Real Agent::GetTargetRadius() const
{
    return targetRadius_;
}

const Ogre::String& Agent::GetTeam() const
{
    return team_;
}

Ogre::Vector3 Agent::GetUp() const
{
    if (rigidBody_)
    {
        const btQuaternion quaterion = rigidBody_->getOrientation();
        return Ogre::Quaternion(
            quaterion.w(), quaterion.x(), quaterion.y(), quaterion.z()).yAxis();
    }
    else if (sceneNode_)
    {
        return sceneNode_->getOrientation().yAxis();
    }

    return Ogre::Vector3::UNIT_Y;
}

Ogre::Vector3 Agent::GetVelocity() const
{
    if (rigidBody_)
    {
        const btVector3 velocity = rigidBody_->getLinearVelocity();

        return Ogre::Vector3(velocity.x(), velocity.y(), velocity.z());
    }
    return GetForward() * speed_;
}

OpenSteer::Vec3 Agent::globalizeDirection(
    const OpenSteer::Vec3& localDirection) const
{
    (void)localDirection;
    // not implemented
    assert(false);

    return OpenSteer::Vec3();
}
OpenSteer::Vec3 Agent::globalizePosition(
    const OpenSteer::Vec3& localPosition) const
{
    (void)localPosition;
    // not implemented
    assert(false);

    return OpenSteer::Vec3();
}

OpenSteer::Vec3 Agent::globalRotateForwardToSide(
    const OpenSteer::Vec3& globalForward) const
{
    (void)globalForward;
    // not implemented
    assert(false);

    return OpenSteer::Vec3();
}

bool Agent::HasPath() const
{
    return hasPath_;
}

void Agent::Initialize()
{
    AgentUtilities::CreateRigidBodyCapsule(this);

    AgentUtilities::CallLuaAgentInitialize(this);
}

void Agent::LoadScript(
    const char* const luaScript,
    const size_t bufferSize,
    const char* const fileName)
{
    AgentUtilities::LoadScript(this, luaScript, bufferSize, fileName);
}

OpenSteer::Vec3 Agent::localizeDirection(
    const OpenSteer::Vec3& globalDirection) const
{
    // TODO(David Young): This is very slow, convert to native Ogre math.
    return OpenSteer::Vec3(
        globalDirection.dot(Vector3ToVec3(GetLeft())),
        globalDirection.dot(Vector3ToVec3(GetUp())),
        globalDirection.dot(Vector3ToVec3(GetForward())));
}

OpenSteer::Vec3 Agent::localizePosition(
    const OpenSteer::Vec3& globalPosition) const
{
    OpenSteer::Vec3 globalOffset =
        globalPosition - Vector3ToVec3(GetPosition());

    return localizeDirection (globalOffset);
}

OpenSteer::Vec3 Agent::localRotateForwardToSide(
    const OpenSteer::Vec3& side) const
{
    (void)side;
    // not implemented
    assert(false);

    return OpenSteer::Vec3();
}

float Agent::mass() const
{
    return static_cast<float>(GetMass());
}

float Agent::maxForce() const
{
    return static_cast<float>(GetMaxForce());
}

float Agent::maxSpeed() const
{
    return static_cast<float>(GetMaxSpeed());
}

OpenSteer::Vec3 Agent::position() const
{
    return Vector3ToVec3(GetPosition());
}

OpenSteer::Vec3 Agent::predictFuturePosition(
    const float predictionTime) const
{
    return Vector3ToVec3(PredictFuturePosition(Ogre::Real(predictionTime)));
}

Ogre::Vector3 Agent::PredictFuturePosition(
    const Ogre::Real predictionTime) const
{
    return GetPosition() + GetVelocity() * std::max(Ogre::Real(0), predictionTime);
}

float Agent::radius() const
{
    return static_cast<float>(GetRadius());
}

void Agent::regenerateOrthonormalBasisUF(
    const OpenSteer::Vec3& newUnitForward)
{
    (void)newUnitForward;
    // not implemented
    assert(false);
}

void Agent::regenerateOrthonormalBasis(const OpenSteer::Vec3& newForward)
{
    (void)newForward;
    // not implemented
    assert(false);
}

void Agent::regenerateOrthonormalBasis(
    const OpenSteer::Vec3& newForward, const OpenSteer::Vec3& newUp)
{
    (void)newForward;
    (void)newUp;
    // not implemented
    assert(false);
}

bool Agent::ReloadScript(
    const char* const luaScript,
    const size_t bufferSize,
    const char* const fileName)
{
    (void)luaScript;
    (void)bufferSize;
    (void)fileName;

    return false;
}

void Agent::RemovePath()
{
    hasPath_ = false;
}

void Agent::resetLocalSpace()
{
    // not implemented
    assert(false);
}

bool Agent::rightHanded() const
{
    return true;
}

void Agent::SetForward(const Ogre::Quaternion& orientation)
{
    if (rigidBody_)
    {
        PhysicsUtilities::SetRigidBodyOrientation(
            rigidBody_, QuaternionToBtQuaternion(orientation));
    }

    if (sceneNode_)
    {
        sceneNode_->setOrientation(orientation);
    }
}

void Agent::SetForward(const Ogre::Vector3& forward)
{
    Ogre::Vector3 up = Ogre::Vector3::UNIT_Y;

    const Ogre::Vector3 zAxis = forward.normalisedCopy();
    const Ogre::Vector3 xAxis = up.crossProduct(zAxis);
    const Ogre::Vector3 yAxis = zAxis.crossProduct(xAxis);

    Ogre::Quaternion orientation(xAxis, yAxis, zAxis);

    // Update both the rigid body and scene node.
    if (rigidBody_)
    {
        PhysicsUtilities::SetRigidBodyOrientation(
            rigidBody_, QuaternionToBtQuaternion(orientation));
    }

    if (sceneNode_)
    {
        sceneNode_->setOrientation(orientation);
    }
}

OpenSteer::Vec3 Agent::setForward(OpenSteer::Vec3 forward)
{
    (void)forward;
    // not implemented
    assert(false);

    return OpenSteer::Vec3();
}

void Agent::SetHealth(const Ogre::Real health)
{
    health_ = health;
}

void Agent::SetHeight(const Ogre::Real height)
{
    height_ = std::max(Ogre::Real(0), height);

    if (rigidBody_)
    {
        AgentUtilities::UpdateRigidBodyCapsule(this);
    }
}

float Agent::setMass(float mass)
{
    SetMass(Ogre::Real(mass));
    return this->mass();
}

void Agent::SetMass(const Ogre::Real mass)
{
    if (rigidBody_)
    {
        PhysicsUtilities::SetRigidBodyMass(
            rigidBody_, std::max(Ogre::Real(0), mass));
    }

    mass_ = mass;
}

float Agent::setMaxForce(float force)
{
    SetMaxForce(Ogre::Real(force));
    return maxForce();
}

void Agent::SetMaxForce(const Ogre::Real force)
{
    maxForce_ = std::max(Ogre::Real(0), force);
}

float Agent::setMaxSpeed(float speed)
{
    SetMaxSpeed(Ogre::Real(speed));
    return maxSpeed();
}

void Agent::SetMaxSpeed(const Ogre::Real speed)
{
    maxSpeed_ = std::max(Ogre::Real(0), speed);
}

void Agent::SetPath(const AgentPath& path)
{
    path_ = path;
    hasPath_ = true;
}

OpenSteer::Vec3 Agent::setPosition(OpenSteer::Vec3 position)
{
    SetPosition(Vec3ToVector3(position));
    return this->position();
}

void Agent::SetPosition(const Ogre::Vector3 position)
{
    if (rigidBody_)
    {
        PhysicsUtilities::SetRigidBodyPosition(
            rigidBody_, Vector3ToBtVector3(position));
    }

    if (sceneNode_)
    {
        sceneNode_->setPosition(position);
    }
}

float Agent::setRadius(float radius)
{
    SetRadius(Ogre::Real(radius));
    return this->radius();
}

void Agent::SetRadius(const Ogre::Real radius)
{
    if (sceneNode_)
    {
        radius_ = std::max(Ogre::Real(0), radius);
    }

    if (rigidBody_)
    {
        AgentUtilities::UpdateRigidBodyCapsule(this);
    }
}

void Agent::SetRigidBody(btRigidBody* const rigidBody)
{
    rigidBody_ = rigidBody;

    if (rigidBody_)
    {
        rigidBody_->setUserPointer(this);
    }
}

void Agent::SetSandbox(Sandbox* const sandbox)
{
    sandbox_ = sandbox;
}

OpenSteer::Vec3 Agent::setSide(OpenSteer::Vec3 side)
{
    (void)side;
    // not implemented
    assert(false);

    return OpenSteer::Vec3();
}

float Agent::setSpeed(float speed)
{
    SetSpeed(Ogre::Real(speed));
    return this->speed();
}

void Agent::SetSpeed(const Ogre::Real speed)
{
    // TODO(David Young): Need to update rigidbody's velocity based on input.
    speed_ = speed;
}

void Agent::SetTarget(const Ogre::Vector3& target)
{
    target_ = target;
}

void Agent::SetTargetRadius(const Ogre::Real radius)
{
    targetRadius_ = std::max(Ogre::Real(0), radius);
}

void Agent::SetTeam(const Ogre::String& team)
{
    team_ = team;
}

void Agent::setUnitSideFromForwardAndUp()
{
    // not implemented
    assert(false);
}

OpenSteer::Vec3 Agent::setUp(OpenSteer::Vec3 up)
{
    (void)up;
    // not implemented
    assert(false);

    return OpenSteer::Vec3();
}

void Agent::SetVelocity(const Ogre::Vector3& velocity)
{
    if (rigidBody_)
    {
        PhysicsUtilities::SetRigidBodyVelocity(
            rigidBody_, Vector3ToBtVector3(velocity));
    }

    SetSpeed(Ogre::Vector3(velocity.x, 0, velocity.z).length());
}

OpenSteer::Vec3 Agent::side() const
{
    return Vector3ToVec3(GetLeft());
}

float Agent::speed() const
{
    return static_cast<float>(GetSpeed());
}

OpenSteer::Vec3 Agent::up() const
{
    return Vector3ToVec3(GetUp());
}

void Agent::update(const float currentTime, const float elapsedTime)
{
    (void)currentTime;
    (void)elapsedTime;
    // not implemented
    assert(false);
}

void Agent::Update(const int deltaMilliseconds)
{
    AgentUtilities::CallLuaAgentUpdate(this, deltaMilliseconds);
    AgentUtilities::UpdateWorldTransform(this);

    if (rigidBody_)
    {
        const btVector3 velocity = rigidBody_->getLinearVelocity();
        SetSpeed(Ogre::Vector3(velocity.x(), 0, velocity.z()).length());
    }
}

OpenSteer::Vec3 Agent::velocity() const
{
    return Vector3ToVec3(GetVelocity());
}