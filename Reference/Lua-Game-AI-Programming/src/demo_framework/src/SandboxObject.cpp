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

#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/PhysicsUtilities.h"
#include "demo_framework/include/SandboxUtilities.h"
#include "demo_framework/include/SandboxObject.h"

SandboxObject::SandboxObject(
    const unsigned int objectId,
    Ogre::SceneNode* const sceneNode,
    btRigidBody* const rigidBody)
    : Object(objectId, Object::SANDBOX_OBJECT),
    OpenSteer::SphericalObstacle(),
    sceneNode_(sceneNode),
    rigidBody_(rigidBody)
{
    assert(sceneNode);
    assert(rigidBody);
}

SandboxObject::~SandboxObject()
{
    LuaScriptUtilities::Remove(sceneNode_);
    PhysicsUtilities::DeleteRigidBody(rigidBody_);
}

void SandboxObject::Cleanup()
{
}

Ogre::Real SandboxObject::GetMass() const
{
    return PhysicsUtilities::GetRigidBodyMass(rigidBody_);
}

Ogre::Quaternion SandboxObject::GetOrientation() const
{
    const btQuaternion& rotation =
        rigidBody_->getCenterOfMassTransform().getRotation();

    return Ogre::Quaternion(
        rotation.w(), rotation.x(), rotation.y(), rotation.z());
}

OpenSteer::Vec3 SandboxObject::getPosition() const
{
    const btVector3& position = rigidBody_->getCenterOfMassPosition();

    return OpenSteer::Vec3(
        position.m_floats[0], position.m_floats[1], position.m_floats[2]);
}

Ogre::Vector3 SandboxObject::GetPosition() const
{
    const btVector3& position = rigidBody_->getCenterOfMassPosition();

    return Ogre::Vector3(
        position.m_floats[0], position.m_floats[1], position.m_floats[2]);
}

float SandboxObject::getRadius() const
{
    return GetRadius();
}

Ogre::Real SandboxObject::GetRadius() const
{
    return PhysicsUtilities::GetRigidBodyRadius(rigidBody_);
}

btRigidBody* SandboxObject::GetRigidBody()
{
    return rigidBody_;
}

const btRigidBody* SandboxObject::GetRigidBody() const
{
    return rigidBody_;
}

Ogre::SceneNode* SandboxObject::GetSceneNode()
{
    return sceneNode_;
}

const Ogre::SceneNode* SandboxObject::GetSceneNode() const
{
    return sceneNode_;
}

void SandboxObject::Initialize()
{
}

void SandboxObject::SetMass(const Ogre::Real mass)
{
    PhysicsUtilities::SetRigidBodyMass(rigidBody_, mass);
}

void SandboxObject::SetOrientation(const Ogre::Quaternion& quaternion)
{
    PhysicsUtilities::SetRigidBodyOrientation(
        rigidBody_,
        btQuaternion(quaternion.x, quaternion.y, quaternion.z, quaternion.w));

    SandboxUtilities::UpdateWorldTransform(this);
}

void SandboxObject::SetPosition(const Ogre::Vector3& position)
{
    PhysicsUtilities::SetRigidBodyPosition(
        rigidBody_, btVector3(position.x, position.y, position.z));

    SandboxUtilities::UpdateWorldTransform(this);
}

OpenSteer::Vec3 SandboxObject::steerToAvoid(
    const OpenSteer::AbstractVehicle& v, const float minTimeToCollision) const
{
    // minimum distance to obstacle before avoidance is required
    const float minDistanceToCollision = minTimeToCollision * v.speed();
    const float minDistanceToCenter = minDistanceToCollision + getRadius();

    // contact distance: sum of radii of obstacle and vehicle
    const float totalRadius = getRadius() + v.radius ();

    // obstacle center relative to vehicle position
    const OpenSteer::Vec3 localOffset = getPosition() - v.position ();

    // distance along vehicle's forward axis to obstacle's center
    const float forwardComponent = localOffset.dot(v.forward ());
    const OpenSteer::Vec3 forwardOffset = forwardComponent * v.forward();

    // offset from forward axis to obstacle's center
    const OpenSteer::Vec3 offForwardOffset = localOffset - forwardOffset;

    // test to see if sphere overlaps with obstacle-free corridor
    const bool inCylinder = offForwardOffset.length() < totalRadius;
    const bool nearby = forwardComponent < minDistanceToCenter;
    const bool inFront = forwardComponent > 0;

    // if all three conditions are met, steer away from sphere center
    if (inCylinder && nearby && inFront)
    {
        return offForwardOffset * -1;
    }
    else
    {
        return OpenSteer::Vec3::zero;
    }
}

void SandboxObject::Update(const int deltaMilliseconds)
{
    (void)deltaMilliseconds;

    SandboxUtilities::UpdateWorldTransform(this);
}