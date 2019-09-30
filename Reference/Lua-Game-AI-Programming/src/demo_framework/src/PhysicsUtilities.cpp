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

#include "demo_framework/include/Object.h"
#include "demo_framework/include/PhysicsUtilities.h"

namespace
{
void getMeshInformation(
    const Ogre::Mesh* const mesh,
    size_t &vertex_count,
    Ogre::Vector3* &vertices,
    size_t &index_count,
    unsigned long* &indices,
    const Ogre::Vector3 &position = Ogre::Vector3::ZERO,
    const Ogre::Quaternion &orient = Ogre::Quaternion::IDENTITY,
    const Ogre::Vector3 &scale = Ogre::Vector3::UNIT_SCALE)
{
    bool added_shared = false;
    size_t current_offset = 0;
    size_t shared_offset = 0;
    size_t next_offset = 0;
    size_t index_offset = 0;

    vertex_count = index_count = 0;

    // Calculate how many vertices and indices we're going to need
    for ( unsigned short i = 0; i < mesh->getNumSubMeshes(); ++i)
    {
        Ogre::SubMesh* submesh = mesh->getSubMesh(i);
        // We only need to add the shared vertices once
        if(submesh->useSharedVertices)
        {
            if(!added_shared)
            {
                vertex_count += mesh->sharedVertexData->vertexCount;
                added_shared = true;
            }
        }
        else
        {
            vertex_count += submesh->vertexData->vertexCount;
        }
        // Add the indices
        index_count += submesh->indexData->indexCount;
    }

    // Allocate space for the vertices and indices
    vertices = new Ogre::Vector3[vertex_count];
    indices = new unsigned long[index_count];

    added_shared = false;

    // Run through the submeshes again, adding the data into the arrays
    for (unsigned short i = 0; i < mesh->getNumSubMeshes(); ++i)
    {
        Ogre::SubMesh* submesh = mesh->getSubMesh(i);

        Ogre::VertexData* vertex_data = submesh->useSharedVertices ?
            mesh->sharedVertexData : submesh->vertexData;

        if ((!submesh->useSharedVertices) ||
            (submesh->useSharedVertices && !added_shared))
        {
            if(submesh->useSharedVertices)
            {
                added_shared = true;
                shared_offset = current_offset;
            }

            const Ogre::VertexElement* posElem =
                vertex_data->vertexDeclaration->findElementBySemantic(
                    Ogre::VES_POSITION);

            Ogre::HardwareVertexBufferSharedPtr vbuf =
                vertex_data->vertexBufferBinding->getBuffer(
                    posElem->getSource());

            unsigned char* vertex =
                static_cast<unsigned char*>(vbuf->lock(
                    Ogre::HardwareBuffer::HBL_READ_ONLY));

            // There is _no_ baseVertexPointerToElement() which takes an
            // Ogre::Real or a double as second argument. So make it float, to
            // avoid trouble when Ogre::Real will be comiled/typedefed as
            // double:

            // Ogre::Real* pReal;
            float* pReal;

            for(size_t j = 0; j < vertex_data->vertexCount; ++j,
                vertex += vbuf->getVertexSize())
            {
                posElem->baseVertexPointerToElement(vertex, &pReal);

                Ogre::Vector3 pt(pReal[0], pReal[1], pReal[2]);
                vertices[current_offset + j] =
                    (orient * (pt * scale)) + position;
            }

            vbuf->unlock();
            next_offset += vertex_data->vertexCount;
        }

        Ogre::IndexData* index_data = submesh->indexData;
        size_t numTris = index_data->indexCount / 3;
        Ogre::HardwareIndexBufferSharedPtr ibuf = index_data->indexBuffer;

        bool use32bitindexes =
            ibuf->getType() == Ogre::HardwareIndexBuffer::IT_32BIT;

        unsigned long* pLong = static_cast<unsigned long*>(
            ibuf->lock(Ogre::HardwareBuffer::HBL_READ_ONLY));
        unsigned short* pShort = reinterpret_cast<unsigned short*>(pLong);

        size_t offset = (submesh->useSharedVertices) ?
            shared_offset : current_offset;

        if (use32bitindexes)
        {
            for (size_t k = 0; k < numTris*3; ++k)
            {
                indices[index_offset++] =
                    pLong[k] + static_cast<unsigned long>(offset);
            }
        }
        else
        {
            for (size_t k = 0; k < numTris*3; ++k)
            {
                indices[index_offset++] =
                    static_cast<unsigned long>(pShort[k]) +
                    static_cast<unsigned long>(offset);
            }
        }

        ibuf->unlock();
        current_offset = next_offset;
    }
}
}  // anonymous namespace

void PhysicsUtilities::ApplyForce(
    btRigidBody* const rigidBody, const btVector3& force)
{
    rigidBody->applyCentralForce(force);
    rigidBody->activate(true);
}

void PhysicsUtilities::ApplyImpulse(
    btRigidBody* const rigidBody, const btVector3& impulse)
{
    rigidBody->applyCentralForce(impulse);
    rigidBody->activate(true);
}

void PhysicsUtilities::ApplyTorque(
    btRigidBody* const rigidBody, const btVector3& torque)
{
    rigidBody->applyTorque(torque);
    rigidBody->activate(true);
}

void PhysicsUtilities::ApplyTorqueImpulse(
    btRigidBody* const rigidBody, const btVector3& impulse)
{
    rigidBody->applyTorqueImpulse(impulse);
    rigidBody->activate(true);
}

Ogre::Vector3 PhysicsUtilities::BtVector3ToVector3(const btVector3& vector)
{
    return Ogre::Vector3(
        vector.m_floats[0], vector.m_floats[1], vector.m_floats[2]);
}

btRigidBody* PhysicsUtilities::CreateBox(
    const btScalar width, const btScalar height, const btScalar length)
{
    btBoxShape* const boxShape =
        new btBoxShape(btVector3(width/2, height/2, length/2));

    btDefaultMotionState* const boxMotionState = new btDefaultMotionState();

    btVector3 localInertia(0,0,0);
    boxShape->calculateLocalInertia(1.0f, localInertia);

    btRigidBody::btRigidBodyConstructionInfo
        boxRigidBodyCI(1.0f, boxMotionState, boxShape, localInertia);

    btRigidBody* const rigidBody = new btRigidBody(boxRigidBodyCI);

    rigidBody->setCcdMotionThreshold(0.5f);
    rigidBody->setCcdSweptSphereRadius(width / 2.0f);

    return rigidBody;
}

btRigidBody* PhysicsUtilities::CreateCapsule(
    const btScalar height, const btScalar radius)
{
    // Since the height of
    btCapsuleShape* const capsuleShape = new btCapsuleShape(
        radius, height - radius * 2);

    btDefaultMotionState* const capsuleMotionState = new btDefaultMotionState();

    btVector3 localInertia(0,0,0);
    capsuleShape->calculateLocalInertia(1.0f, localInertia);

    btRigidBody::btRigidBodyConstructionInfo
        capsuleRigidBodyCI(
            1.0f, capsuleMotionState, capsuleShape, localInertia);

    // Prevent rolling forever.
    capsuleRigidBodyCI.m_rollingFriction = 0.2f;

    btRigidBody* const rigidBody = new btRigidBody(capsuleRigidBodyCI);

    rigidBody->setCcdMotionThreshold(0.5f);
    rigidBody->setCcdSweptSphereRadius(radius);

    return rigidBody;
}

btRigidBody* PhysicsUtilities::CreatePlane(
    const btVector3& normal, const btScalar originOffset)
{
    btCollisionShape* const groundShape =
        new btStaticPlaneShape(normal, originOffset);

    btDefaultMotionState* const groundMotionState = new btDefaultMotionState();

    btRigidBody::btRigidBodyConstructionInfo
        groundRigidBodyCI(
            0, groundMotionState, groundShape, btVector3(0, 0, 0));

    groundRigidBodyCI.m_rollingFriction = 0.1f;

    return new btRigidBody(groundRigidBodyCI);
}

btRigidBody* PhysicsUtilities::CreateRigidBodyFromMesh(
    const Ogre::Mesh& mesh, const btVector3& position, const btScalar mass)
{
    btConvexHullShape* hullShape = CreateSimplifiedConvexHull(mesh);

    btVector3 aabbMin;
    btVector3 aabbMax;

    hullShape->getAabb(
        btTransform(btQuaternion::getIdentity()), aabbMin, aabbMax);

    // Set the center of mass of the rigid body to the center of the mesh.
    // This works well for objects that are symmetrical but will have odd
    // results for asymmetrical objects.
    const btVector3 centerOfMass = (aabbMax + aabbMin) / 2.0f;

    btCompoundShape* compoundShape = new btCompoundShape();

    // TODO(David Young): To fix the center of mass issue this introduces a
    // graphical offset problem that needs to be fixed.
    /*
    compoundShape->addChildShape(
        btTransform(btQuaternion::getIdentity(), -centerOfMass),
        hullShape);
    */

    compoundShape->addChildShape(
        btTransform(btQuaternion::getIdentity()), hullShape);

    btDefaultMotionState* const motionState = new btDefaultMotionState(
        btTransform(btQuaternion::getIdentity(), position));

    btVector3 localInertia(0,0,0);
    compoundShape->calculateLocalInertia(mass, localInertia);

    btRigidBody::btRigidBodyConstructionInfo
        rigidBodyCI(mass, motionState, compoundShape, localInertia);

    rigidBodyCI.m_linearSleepingThreshold = 0.3f;

    btRigidBody* const rigidBody = new btRigidBody(rigidBodyCI);

    rigidBody->setCcdMotionThreshold(0.5f);
    rigidBody->setCcdSweptSphereRadius(aabbMax.length() / 2.0f);

    return rigidBody;
}

btConvexHullShape* PhysicsUtilities::CreateSimplifiedConvexHull(
    const Ogre::Mesh& mesh)
{
    btConvexHullShape* const shape = new btConvexHullShape();
    shape->setMargin(0.01f);
    shape->setSafeMargin(0.01f);

    size_t vertex_count, index_count;
    Ogre::Vector3* vertices;
    unsigned long* indices;

    getMeshInformation(&mesh, vertex_count, vertices, index_count, indices);

    for (size_t index = 0; index < vertex_count; ++index)
    {
        shape->addPoint(
            btVector3(vertices[index].x, vertices[index].y, vertices[index].z));
    }

    delete [] vertices;
    delete [] indices;

    vertices = NULL;
    indices = NULL;

    btShapeHull* const hull = new btShapeHull(shape);

    hull->buildHull(shape->getMargin());

    btConvexHullShape* const simplifiedConvexShape = new btConvexHullShape();

    const btVector3* const btVertices = hull->getVertexPointer();
    const int numVertices = hull->numVertices();

    for (int index = 0; index < numVertices; ++index)
    {
        simplifiedConvexShape->addPoint(btVertices[index]);
    }

    simplifiedConvexShape->setMargin(0.01f);

    delete hull;
    delete shape;

    return simplifiedConvexShape;
}

btRigidBody* PhysicsUtilities::CreateSphere(const btScalar radius)
{
    btCollisionShape* const sphereShape = new btSphereShape(radius);
    btDefaultMotionState* const sphereMotionState = new btDefaultMotionState();

    btVector3 localInertia(0,0,0);
    sphereShape->calculateLocalInertia(1.0f, localInertia);

    btRigidBody::btRigidBodyConstructionInfo
        sphereRigidBodyCI(
            1.0f, sphereMotionState, sphereShape, localInertia);

    sphereRigidBodyCI.m_rollingFriction = 0.1f;

    btRigidBody* const rigidBody = new btRigidBody(sphereRigidBodyCI);

    rigidBody->setCcdMotionThreshold(0.5f);
    rigidBody->setCcdSweptSphereRadius(radius);

    return rigidBody;
}

void PhysicsUtilities::DeleteRigidBody(btRigidBody* const rigidBody)
{
    delete rigidBody->getMotionState();
    delete rigidBody->getCollisionShape();
    delete rigidBody;
}

btScalar PhysicsUtilities::GetRigidBodyRadius(
    const btRigidBody* const rigidBody)
{
    btVector3 aabbMin;
    btVector3 aabbMax;

    rigidBody->getAabb(aabbMin, aabbMax);

    return aabbMax.distance(aabbMin) / 2.0f;
}

btScalar PhysicsUtilities::GetRigidBodyMass(const btRigidBody* const rigidBody)
{
    btScalar inverseMass = rigidBody->getInvMass();

    if (inverseMass == 0)
        return 0;

    return 1.0f / inverseMass;
}

bool PhysicsUtilities::IsPlane(const btRigidBody& rigidBody)
{
    assert(rigidBody.getCollisionShape());

    const btCollisionShape* const shape = rigidBody.getCollisionShape();

    return shape->getShapeType() == STATIC_PLANE_PROXYTYPE;
}

void PhysicsUtilities::SetRigidBodyGravity(
    btRigidBody* const rigidBody, const btVector3& gravity)
{
    rigidBody->setGravity(gravity);
    rigidBody->activate(true);
}

void PhysicsUtilities::SetRigidBodyMass(btRigidBody* rigidBody, btScalar mass)
{
    btVector3 localInertia(0,0,0);
    rigidBody->getCollisionShape()->calculateLocalInertia(mass, localInertia);
    rigidBody->setMassProps(mass, localInertia);
    rigidBody->updateInertiaTensor();
    rigidBody->activate(true);
}

void PhysicsUtilities::SetRigidBodyOrientation(
    btRigidBody* const rigidBody, const btQuaternion& orientation)
{
    btTransform transform = rigidBody->getWorldTransform();
    transform.setRotation(orientation);

    rigidBody->setWorldTransform(transform);
    rigidBody->activate(true);
}

void PhysicsUtilities::SetRigidBodyPosition(
    btRigidBody* const rigidBody, const btVector3& position)
{
    btTransform transform = rigidBody->getWorldTransform();
    transform.setOrigin(position);

    rigidBody->setWorldTransform(transform);
    rigidBody->activate(true);
}

void PhysicsUtilities::SetRigidBodyVelocity(
    btRigidBody* const rigidBody, const btVector3& velocity)
{
    rigidBody->setLinearVelocity(velocity);
    rigidBody->activate(true);
}

Object* PhysicsUtilities::ToObject(
    const btRigidBody* const rigidBody)
{
    Object* const object =
        static_cast<Object*>(rigidBody->getUserPointer());

    return object;
}

btVector3 PhysicsUtilities::Vector3ToBtVector3(const Ogre::Vector3& vector)
{
    return btVector3(vector.x, vector.y, vector.z);
}