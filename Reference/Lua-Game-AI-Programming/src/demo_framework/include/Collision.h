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

#ifndef DEMO_FRAMEWORK_COLLISION_H
#define DEMO_FRAMEWORK_COLLISION_H

#include "ogre3d/include/OgreVector3.h"

class btRigidBody;
class btVector3;

class Collision
{
public:
    Collision(
        const btRigidBody* objectA,
        const btVector3& pointA,
        const btRigidBody* objectB,
        const btVector3& pointB,
        const btVector3& normalOnB);

    Collision(const Collision& collision);

    Collision& operator=(const Collision& collision);

    ~Collision();

    const btRigidBody* GetObjectA() const;

    const btRigidBody* GetObjectB() const;

    const Ogre::Vector3& GetPointA() const;

    const Ogre::Vector3& GetPointB() const;

    const Ogre::Vector3& GetNormalOnB() const;

private:
    const btRigidBody* objectA_;
    const btRigidBody* objectB_;

    Ogre::Vector3 pointA_;
    Ogre::Vector3 pointB_;

    Ogre::Vector3 normalOnB_;
};

#endif  // DEMO_FRAMEWORK_COLLISION_H
