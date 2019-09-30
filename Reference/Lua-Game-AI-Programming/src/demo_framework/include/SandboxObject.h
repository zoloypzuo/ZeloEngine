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

#ifndef DEMO_FRAMEWORK_GAME_OBJECT_H
#define DEMO_FRAMEWORK_GAME_OBJECT_H

#include "demo_framework/include/Object.h"
#include "opensteer/include/Obstacle.h"

class Agent;
class btRigidBody;
class Sandbox;

namespace Ogre
{
class SceneNode;
}

class SandboxObject :
    public Object,
    private OpenSteer::SphericalObstacle
{
friend class Agent;

public:
    SandboxObject(
        const unsigned int objectId,
        Ogre::SceneNode* const sceneNode,
        btRigidBody* const rigidBody);

    virtual ~SandboxObject();

    virtual void Cleanup();

    Ogre::Real GetMass() const;

    Ogre::Quaternion GetOrientation() const;

    Ogre::Vector3 GetPosition() const;

    Ogre::Real GetRadius() const;

    btRigidBody* GetRigidBody();

    const btRigidBody* GetRigidBody() const;

    Ogre::SceneNode* GetSceneNode();

    const Ogre::SceneNode* GetSceneNode() const;

    virtual void Initialize();

    void SetMass(const Ogre::Real mass);

    void SetOrientation(const Ogre::Quaternion& quaternion);

    void SetPosition(const Ogre::Vector3& position);

    virtual void Update(const int deltaMilliseconds);

private:
    Ogre::SceneNode* const sceneNode_;
    btRigidBody* const rigidBody_;

    SandboxObject(const SandboxObject& gameObject);
    SandboxObject& operator=(const SandboxObject& gameObject);

    OpenSteer::Vec3 getPosition() const;

    // Overloading the SphericalObstacle's radius implementation.
    virtual float getRadius() const;

    virtual OpenSteer::Vec3 steerToAvoid(
        const OpenSteer::AbstractVehicle& vehicle,
        const float minTimeToCollision) const;
};

#endif  // DEMO_FRAMEWORK_GAME_OBJECT_H
