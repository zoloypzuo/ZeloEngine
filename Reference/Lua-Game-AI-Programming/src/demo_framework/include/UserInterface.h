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

#ifndef DEMO_FRAMEWORK_USER_INTERFACE_H
#define DEMO_FRAMEWORK_USER_INTERFACE_H

#define UI_LAYER_COUNT 16

class UserInterfaceComponent;

namespace Gorilla
{
class Layer;
class Screen;
}  // namespace Gorilla

namespace Ogre
{
class SceneNode;
class Viewport;
}

class UserInterface
{
public:
    UserInterface(Ogre::Viewport* const viewport);

    ~UserInterface();

    UserInterfaceComponent* Create3DComponent(Ogre::SceneNode& sceneNode);

    UserInterfaceComponent* CreateComponent(const size_t layerIndex);

    void DestroyComponent(UserInterfaceComponent* const component);

    Ogre::ColourValue GetMarkupColor(const int index) const;

    void SetMarkupColor(const int index, const Ogre::ColourValue& color);

private:
    Gorilla::Screen* screen_;
    Gorilla::Layer* layers_[UI_LAYER_COUNT];
};

#endif  // DEMO_FRAMEWORK_USER_INTERFACE_H