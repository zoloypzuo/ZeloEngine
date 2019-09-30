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

#ifndef DEMO_FRAMEWORK_PARTICLE_UTILITIES_H
#define DEMO_FRAMEWORK_PARTICLE_UTILITIES_H

#include "ogre3d/include/OgreCommon.h"
#include "ogre3d/include/OgreNameGenerator.h"
#include "ogre3d/include/OgrePrerequisites.h"

namespace Ogre
{
class SceneNode;
}

class ParticleUtilities
{
public:
    static Ogre::SceneNode* CreateParticle(
        Ogre::SceneNode* const parentNode,
        const Ogre::String& particleName);

    static Ogre::Real GetLength(Ogre::SceneNode* const node);

    static void Reset(Ogre::SceneNode* const node);

    static void SetDirection(
        Ogre::SceneNode* const node, const Ogre::Vector3 direction);

private:
    static Ogre::NameGenerator nameGenerator_;

    ParticleUtilities();
    ~ParticleUtilities();
    ParticleUtilities(const ParticleUtilities&);
    ParticleUtilities& operator=(const ParticleUtilities&);
};

#endif  // DEMO_FRAMEWORK_PARTICLE_UTILITIES_H
