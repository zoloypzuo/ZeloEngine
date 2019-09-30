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

#include "demo_framework/include/ParticleUtilities.h"

Ogre::NameGenerator ParticleUtilities::nameGenerator_("UnnamedParticle_");

Ogre::SceneNode* ParticleUtilities::CreateParticle(
    Ogre::SceneNode* const parentNode, const Ogre::String& particleName)
{
    assert(parentNode);

    Ogre::SceneNode* const particle = parentNode->createChildSceneNode();

    Ogre::ParticleSystem* const particleSystem =
        parentNode->getCreator()->createParticleSystem(
            nameGenerator_.generate(), particleName);

    particle->attachObject(particleSystem);

    return particle;
}

Ogre::Real ParticleUtilities::GetLength(Ogre::SceneNode* const node)
{
    Ogre::Real length = 0;

    const unsigned short numAttachedObjects = node->numAttachedObjects();

    for (unsigned short index = 0; index < numAttachedObjects; ++index)
    {
        Ogre::MovableObject* const object = node->getAttachedObject(index);

        if (object->getMovableType() ==
            Ogre::ParticleSystemFactory::FACTORY_TYPE_NAME)
        {
            Ogre::ParticleSystem* const particle =
                static_cast<Ogre::ParticleSystem*>(object);

            for(unsigned short i=0; i< particle->getNumEmitters(); i++)
            {
                Ogre::ParticleEmitter* const emitter =
                    particle->getEmitter(i);

                const Ogre::Real emitterLength =
                    emitter->getMaxTimeToLive() + emitter->getMaxDuration();

               if (emitterLength > length)
               {
                   length = emitterLength;
               }
            }
        }
    }

    return length;
}

void ParticleUtilities::Reset(Ogre::SceneNode* const node)
{
    const unsigned short numAttachedObjects = node->numAttachedObjects();

    for (unsigned short index = 0; index < numAttachedObjects; ++index)
    {
        Ogre::MovableObject* const object = node->getAttachedObject(index);

        if (object->getMovableType() ==
            Ogre::ParticleSystemFactory::FACTORY_TYPE_NAME)
        {
            Ogre::ParticleSystem* const particle =
                static_cast<Ogre::ParticleSystem*>(object);

            particle->setEmitting(true);

            for(unsigned short i=0; i< particle->getNumEmitters(); i++)
            {
                Ogre::ParticleEmitter* const emitter =
                    particle->getEmitter(i);

                emitter->setEnabled(false);
                //This resets the repeatDelay to 0
                emitter->setMinRepeatDelay(0);
                emitter->setEnabled(true);
            }
        }
    }
}

void ParticleUtilities::SetDirection(
    Ogre::SceneNode* const node, const Ogre::Vector3 direction)
{
    const unsigned short numAttachedObjects = node->numAttachedObjects();

    for (unsigned short index = 0; index < numAttachedObjects; ++index)
    {
        Ogre::MovableObject* const object = node->getAttachedObject(index);

        if (object->getMovableType() ==
            Ogre::ParticleSystemFactory::FACTORY_TYPE_NAME)
        {
            Ogre::ParticleSystem* const particle =
                static_cast<Ogre::ParticleSystem*>(object);

            particle->setEmitting(true);

            for(unsigned short i=0; i< particle->getNumEmitters(); i++)
            {
                Ogre::ParticleEmitter* const emitter = particle->getEmitter(i);
                emitter->setDirection(direction);
            }
        }
    }
}