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

#ifndef DEMO_FRAMEWORK_PHYSICS_WORLD_H
#define DEMO_FRAMEWORK_PHYSICS_WORLD_H

#include <vector>

class btBroadphaseInterface;
class btCollisionDispatcher;
class btDefaultCollisionConfiguration;
class btDiscreteDynamicsWorld;
class btRigidBody;
class btSequentialImpulseConstraintSolver;
class Collision;
class PhysicsDebugDraw;

class PhysicsWorld
{
public:
    PhysicsWorld();

    ~PhysicsWorld();

    void AddRigidBody(btRigidBody* const rigidBody);

    void Cleanup();

    void DrawDebugWorld();

    void GetCollisions(std::vector<Collision>& collisions);

    btDiscreteDynamicsWorld* GetDynamicsWorld();

    void Initialize();

    bool RayCastToRigidBody(
        const btVector3& from,
        const btVector3& to,
        btVector3& hitPoint,
        const btRigidBody*& rigidBody) const;

    void RemoveRigidBody(btRigidBody* const rigidBody);

    void StepWorld();

private:
    PhysicsWorld(const PhysicsWorld&);
    PhysicsWorld& operator=(const PhysicsWorld&);

    btBroadphaseInterface* broadphase_;
    btDefaultCollisionConfiguration* collisionConfiguration_;
    btCollisionDispatcher* dispatcher_;
    btSequentialImpulseConstraintSolver* solver_;
    btDiscreteDynamicsWorld* dynamicsWorld_;
    PhysicsDebugDraw* debugDraw_;
};

#endif  // DEMO_FRAMEWORK_PHYSICS_WORLD_H
