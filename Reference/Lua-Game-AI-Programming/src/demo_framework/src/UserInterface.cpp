#include "PrecompiledHeaders.h"

#include "demo_framework/include/UserInterface.h"
#include "demo_framework/include/UserInterfaceComponent.h"

#define DEFAULT_ATLAS "fonts/dejavu/dejavu"

UserInterface::UserInterface(Ogre::Viewport* const viewport)
{
	// 拿到管理器单例、
	// 创建screen和layer
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
	// RAII析构
	for (size_t index = 0; index < UI_LAYER_COUNT; ++index)
	{
		screen_->destroy(layers_[index]);
		layers_[index] = nullptr;
	}

	Gorilla::Silverback* const mSilverback =
		Gorilla::Silverback::getSingletonPtr();

	mSilverback->destroyScreen(screen_);
	screen_ = nullptr;
}

//
// 剩下的函数有点迷，不了解这个库
// 大概地，就是screen，layer，uicomponent，atlas，markupcolor
//

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

	return nullptr;
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
	const int index, const Ogre::ColourValue& color) const
{
	for (size_t layerIndex = 0; layerIndex < UI_LAYER_COUNT; ++layerIndex)
	{
		layers_[layerIndex]->_getAtlas()->setMarkupColour(index, color);
	}
}
