#ifndef DEMO_FRAMEWORK_USER_INTERFACE_H
#define DEMO_FRAMEWORK_USER_INTERFACE_H

#define UI_LAYER_COUNT 16

class UserInterfaceComponent;

namespace Gorilla
{
	class Layer;
	class Screen;
} // namespace Gorilla

namespace Ogre
{
	class SceneNode;
	class Viewport;
}

class UserInterface
{
public:
	UserInterface(Ogre::Viewport* viewport);

	~UserInterface();

	static UserInterfaceComponent* Create3DComponent(Ogre::SceneNode& sceneNode);

	UserInterfaceComponent* CreateComponent(size_t layerIndex);

	static void DestroyComponent(UserInterfaceComponent* component);

	Ogre::ColourValue GetMarkupColor(int index) const;

	void SetMarkupColor(int index, const Ogre::ColourValue& color) const;

private:
	// screenºÍlayer
	Gorilla::Screen* screen_;
	Gorilla::Layer* layers_[UI_LAYER_COUNT];
};

#endif  // DEMO_FRAMEWORK_USER_INTERFACE_H
