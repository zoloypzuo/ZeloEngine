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

#include "demo_framework/include/Collision.h"

Collision::Collision(
    const btRigidBody* objectA,
    const btVector3& pointA,
    const btRigidBody* objectB,
    const btVector3& pointB,
    const btVector3& normalOnB)
    : objectA_(objectA),
    pointA_(pointA.m_floats[0], pointA.m_floats[1], pointA.m_floats[2]),
    objectB_(objectB),
    pointB_(pointB.m_floats[0], pointB.m_floats[1], pointB.m_floats[2]),
    normalOnB_(normalOnB.m_floats[0], normalOnB.m_floats[1], normalOnB.m_floats[2])
{
}

Collision::Collision(const Collision& collision)
    : objectA_(collision.objectA_),
    pointA_(collision.pointA_),
    objectB_(collision.objectB_),
    pointB_(collision.pointB_),
    normalOnB_(collision.normalOnB_)
{
}

Collision& Collision::operator=(const Collision& collision)
{
    objectA_ = collision.objectA_;
    objectB_ = collision.objectB_;
    pointA_ = collision.pointA_;
    pointB_ = collision.pointB_;
    normalOnB_ = collision.normalOnB_;

    return *this;
}

Collision::~Collision()
{
}

const btRigidBody* Collision::GetObjectA() const
{
    return objectA_;
}

const btRigidBody* Collision::GetObjectB() const
{
    return objectB_;
}

const Ogre::Vector3& Collision::GetPointA() const
{
    return pointA_;
}

const Ogre::Vector3& Collision::GetPointB() const
{
    return pointB_;
}

const Ogre::Vector3& Collision::GetNormalOnB() const
{
    return normalOnB_;
}