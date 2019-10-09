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

#include "Collision.h"
#include "PhysicsDebugDraw.h"
#include "PhysicsWorld.h"

PhysicsWorld::PhysicsWorld()
	: broadphase_(nullptr),
	  collisionConfiguration_(nullptr),
	  dispatcher_(nullptr),
	  solver_(nullptr),
	  dynamicsWorld_(nullptr),
	  debugDraw_(nullptr)
{
}

PhysicsWorld::~PhysicsWorld()
{
	Cleanup();
}

void PhysicsWorld::AddRigidBody(btRigidBody* const rigidBody) const
{
	dynamicsWorld_->addRigidBody(rigidBody);
}

void PhysicsWorld::Cleanup()
{
	if (dynamicsWorld_)
	{
		delete dynamicsWorld_;
		dynamicsWorld_ = nullptr;
	}

	if (solver_)
	{
		delete solver_;
		solver_ = nullptr;
	}

	if (dispatcher_)
	{
		delete dispatcher_;
		dispatcher_ = nullptr;
	}

	if (collisionConfiguration_)
	{
		delete collisionConfiguration_;
		collisionConfiguration_ = nullptr;
	}

	if (broadphase_)
	{
		delete broadphase_;
		broadphase_ = nullptr;
	}
}

void PhysicsWorld::DrawDebugWorld() const
{
	dynamicsWorld_->debugDrawWorld();
}

void PhysicsWorld::GetCollisions(std::vector<Collision>& collisions) const
{
	int numManifolds = dynamicsWorld_->getDispatcher()->getNumManifolds();

	for (int manifoldIndex = 0; manifoldIndex < numManifolds; manifoldIndex++)
	{
		btPersistentManifold* contactManifold =
			dynamicsWorld_->getDispatcher()->getManifoldByIndexInternal(manifoldIndex);
		const btRigidBody* objectA =
			dynamic_cast<const btRigidBody*>(contactManifold->getBody0());
		const btRigidBody* objectB =
			dynamic_cast<const btRigidBody*>(contactManifold->getBody1());

		if (objectA && objectB)
		{
			int numContacts = contactManifold->getNumContacts();

			for (int cpIndex = 0; cpIndex < numContacts; cpIndex++)
			{
				btManifoldPoint& point = contactManifold->getContactPoint(cpIndex);
				if (point.getDistance() < 0.0f)
				{
					collisions.push_back(
						Collision(
							objectA,
							point.m_positionWorldOnA,
							objectB,
							point.m_positionWorldOnB,
							point.m_normalWorldOnB));

					// Ignore additional per frame collisions.
					break;
				}
			}
		}
	}
}

btDiscreteDynamicsWorld* PhysicsWorld::GetDynamicsWorld() const
{
	return dynamicsWorld_;
}

void PhysicsWorld::Initialize()
{
	static const float gravity = -9.8f;

	broadphase_ = new btDbvtBroadphase();

	collisionConfiguration_ = new btDefaultCollisionConfiguration();

	dispatcher_ = new btCollisionDispatcher(collisionConfiguration_);

	solver_ = new btSequentialImpulseConstraintSolver();

	dynamicsWorld_ = new btDiscreteDynamicsWorld(
		dispatcher_, broadphase_, solver_, collisionConfiguration_);

	dynamicsWorld_->setGravity(btVector3(0, gravity, 0));

	debugDraw_ = new PhysicsDebugDraw();
	dynamicsWorld_->setDebugDrawer(debugDraw_);
	debugDraw_->setDebugMode(
		btIDebugDraw::DBG_DrawWireframe | btIDebugDraw::DBG_DrawAabb);
}

bool PhysicsWorld::RayCastToRigidBody(
	const btVector3& from,
	const btVector3& to,
	btVector3& hitPoint,
	const btRigidBody*& rigidBody) const
{
	btCollisionWorld::ClosestRayResultCallback rayResult(from, to);

	dynamicsWorld_->rayTest(from, to, rayResult);

	hitPoint = rayResult.m_hitPointWorld;
	rigidBody = dynamic_cast<const btRigidBody*>(rayResult.m_collisionObject);

	return rayResult.hasHit();
}

void PhysicsWorld::RemoveRigidBody(btRigidBody* const rigidBody) const
{
	dynamicsWorld_->removeRigidBody(rigidBody);
}

void PhysicsWorld::StepWorld() const
{
	dynamicsWorld_->stepSimulation(1.0f / 30.0f, 1, 1.0f / 30.0f);
}
