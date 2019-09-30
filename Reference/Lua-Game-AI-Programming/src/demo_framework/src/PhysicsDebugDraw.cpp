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

#include "demo_framework/include/DebugDrawer.h"
#include "demo_framework/include/PhysicsDebugDraw.h"

PhysicsDebugDraw::PhysicsDebugDraw()
    : btIDebugDraw(),
    debugMode_(0)
{
}

PhysicsDebugDraw::~PhysicsDebugDraw()
{
}

void PhysicsDebugDraw::draw3dText(
    const btVector3& location,const char* textString)
{
    (void)location;
    (void)textString;
}

void PhysicsDebugDraw::drawLine(
    const btVector3& from, const btVector3& to, const btVector3& color)
{
    DebugDrawer::getSingleton().drawLine(
        Ogre::Vector3(from.m_floats[0], from.m_floats[1], from.m_floats[2]),
        Ogre::Vector3(to.m_floats[0], to.m_floats[1], to.m_floats[2]),
        Ogre::ColourValue(
            color.m_floats[0], color.m_floats[1], color.m_floats[2]));
}

void PhysicsDebugDraw::drawContactPoint(
    const btVector3& pointOnB,
    const btVector3& normalOnB,
    btScalar distance,
    int lifeTime,
    const btVector3& color)
{
    (void)pointOnB;
    (void)normalOnB;
    (void)distance;
    (void)lifeTime;
    (void)color;
}

int PhysicsDebugDraw::getDebugMode() const
{
    return debugMode_;
}

void PhysicsDebugDraw::reportErrorWarning(const char* warningString)
{
    (void)warningString;
}

void PhysicsDebugDraw::setDebugMode(int debugMode)
{
    debugMode_ = debugMode;
}