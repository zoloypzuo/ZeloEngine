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

#ifndef DEMO_FRAMEWORK_PHYSICS_UTILITIES_H
#define DEMO_FRAMEWORK_PHYSICS_UTILITIES_H

#include "bullet_linearmath/include/LinearMath/btScalar.h"

class btConvexHullShape;
class btQuaternion;
class btVector3;
class Object;

namespace Ogre
{
	class Mesh;
} // namespace Ogre

class PhysicsUtilities
{
public:
	static void ApplyForce(
		btRigidBody* rigidBody, const btVector3& force);

	static void ApplyImpulse(
		btRigidBody* rigidBody, const btVector3& impulse);

	static void ApplyTorque(
		btRigidBody* rigidBody, const btVector3& torque);

	static void ApplyTorqueImpulse(
		btRigidBody* rigidBody, const btVector3& impulse);

	static Ogre::Vector3 BtVector3ToVector3(const btVector3& vector);

	static btRigidBody* CreateBox(
		btScalar width, btScalar height, btScalar length);

	static btRigidBody* CreateCapsule(
		btScalar height, btScalar radius);

	static btRigidBody* CreatePlane(
		const btVector3& normal, btScalar originOffset);

	static btRigidBody* CreateRigidBodyFromMesh(
		const Ogre::Mesh& mesh, const btVector3& position, btScalar mass);

	static btConvexHullShape* CreateSimplifiedConvexHull(
		const Ogre::Mesh& mesh);

	static btRigidBody* CreateSphere(btScalar radius);

	static void DeleteRigidBody(btRigidBody* rigidBody);

	static btScalar GetRigidBodyRadius(const btRigidBody* rigidBody);

	static btScalar GetRigidBodyMass(const btRigidBody* rigidBody);

	static bool IsPlane(const btRigidBody& rigidBody);

	static void SetRigidBodyGravity(
		btRigidBody* rigidBody, const btVector3& gravity);

	static void SetRigidBodyMass(
		btRigidBody* rigidBody, btScalar mass);

	static void SetRigidBodyOrientation(
		btRigidBody* rigidBody, const btQuaternion& orientation);

	static void SetRigidBodyPosition(
		btRigidBody* rigidBody, const btVector3& position);

	static void SetRigidBodyVelocity(
		btRigidBody* rigidBody, const btVector3& velocity);

	static Object* ToObject(
		const btRigidBody* rigidBody);

	static btVector3 Vector3ToBtVector3(const Ogre::Vector3& vector);

private:
	PhysicsUtilities();
	~PhysicsUtilities();
	PhysicsUtilities(const PhysicsUtilities&);
	PhysicsUtilities& operator=(const PhysicsUtilities&);
};

#endif  // DEMO_FRAMEWORK_PHYSICS_UTILITIES_H
