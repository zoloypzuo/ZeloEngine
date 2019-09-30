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

#include "demo_framework/include/UserInterface.h"
#include "demo_framework/include/UserInterfaceComponent.h"

#define DEFAULT_ATLAS "fonts/dejavu/dejavu"

UserInterface::UserInterface(Ogre::Viewport* const viewport)
{
    Gorilla::Silverback* const silverback =
        Gorilla::Silverback::getSingletonPtr();
    silverback->loadAtlas(DEFAULT_ATLAS);

    screen_ = silverback->createScreen(viewport, DEFAULT_ATLAS);

    for (int index = 0; index < UI_LAYER_COUNT; ++index)
    {
        layers_[index] = screen_->createLayer(index);
    }
}

UserInterface::~UserInterface()
{
    for (size_t index = 0; index < UI_LAYER_COUNT; ++index)
    {
        screen_->destroy(layers_[index]);
        layers_[index] = NULL;
    }

    Gorilla::Silverback* const mSilverback =
        Gorilla::Silverback::getSingletonPtr();

    mSilverback->destroyScreen(screen_);
    screen_ = NULL;
}

UserInterfaceComponent* UserInterface::Create3DComponent(
    Ogre::SceneNode& sceneNode)
{
    Gorilla::Silverback* const silverback =
        Gorilla::Silverback::getSingletonPtr();

    return new UserInterfaceComponent(
        sceneNode,
        silverback->createScreenRenderable(Ogre::Vector2::ZERO, DEFAULT_ATLAS));
}

UserInterfaceComponent* UserInterface::CreateComponent(const size_t layerIndex)
{
    if (layerIndex < UI_LAYER_COUNT)
    {
        return new UserInterfaceComponent(layers_[layerIndex]);
    }

    return NULL;
}

void UserInterface::DestroyComponent(UserInterfaceComponent* const component)
{
    delete component;
}

Ogre::ColourValue UserInterface::GetMarkupColor(const int index) const
{
    return layers_[0]->_getAtlas()->getMarkupColour(index);
}

void UserInterface::SetMarkupColor(
    const int index, const Ogre::ColourValue& color)
{
    for (size_t layerIndex = 0; layerIndex < UI_LAYER_COUNT; ++layerIndex)
    {
        layers_[layerIndex]->_getAtlas()->setMarkupColour(index, color);
    }
}
