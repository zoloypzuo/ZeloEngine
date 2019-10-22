#ifndef DEMO_FRAMEWORK_USER_INTERFACE_COMPONENT_H
#define DEMO_FRAMEWORK_USER_INTERFACE_COMPONENT_H


// include核心：gorilla
#include <vector>

#include "ogre3d/include/OgreColourValue.h"
#include "ogre3d/include/OgreVector2.h"
#include "ogre3d_gorilla/include/Gorilla.h"

class UserInterfaceLineList;

namespace Gorilla
{
	class Caption;
	class Layer;
	class LineList;
	class MarkupText;
	class Rectangle;
	class ScreenRenderable;
}

namespace Ogre
{
	class SceneNode;
}

class UserInterfaceComponent
{
public:
	enum Font
	{
		SMALL = 9,
		SMALL_MONO = 91,
		MEDIUM = 14,
		MEDIUM_MONO = 141,
		LARGE = 24,
		LARGE_MONO = 241,
		UNKNOWN_FONT = -1
	};

	enum GradientDirection
	{
		DIAGONAL = Gorilla::Gradient_Diagonal,
		NORTH_SOUTH = Gorilla::Gradient_NorthSouth,
		WEST_EAST = Gorilla::Gradient_WestEast,
		UNKNOWN_GRADIENT = -1
	};

	enum HorizontalTextAlignment
	{
		ALIGN_CENTER = Gorilla::TextAlign_Centre,
		ALIGN_LEFT = Gorilla::TextAlign_Left,
		ALIGN_RIGHT = Gorilla::TextAlign_Right
	};

	enum VerticalTextAlignment
	{
		ALIGN_BOTTOM = Gorilla::VerticalAlign_Bottom,
		ALIGN_MIDDLE = Gorilla::VerticalAlign_Middle,
		ALIGN_TOP = Gorilla::VerticalAlign_Top
	};

	static Ogre::String FontToString(Font);

	static Font StringToFont(const Ogre::String& string);

	static Ogre::String GradientToString(GradientDirection gradient);

	static GradientDirection StringToGradient(const Ogre::String& string);

	/**
	 * @summary Create a 2D user interface component that draws based on the
	 *   global UI layer ordering.（创建一个2D UI组件，基于全局UI层次）
	 * @param layer Layer which owns this UI component, determines draw order.（层次决定了UI绘制顺序）
	 */
	UserInterfaceComponent(Gorilla::Layer* layer);

	UserInterfaceComponent(
		Ogre::SceneNode& sceneNode,
		Gorilla::ScreenRenderable* screenRenderable);

	~UserInterfaceComponent();

	void AddChild(UserInterfaceComponent* child);

	UserInterfaceComponent* CreateChildComponent();

	static void CreateLine(
		std::vector<Ogre::Vector2> points,
		const Ogre::ColourValue& color = Ogre::ColourValue::White,
		Ogre::Real thickness = 1.0f,
		bool cyclical = false);

	bool DestroyChild(UserInterfaceComponent* child);

	Ogre::Vector2 GetDimensions() const;

	Font GetFont() const;

	Ogre::String GetMarkupText() const;

	Ogre::Vector2 GetOffsetPosition() const;

	Ogre::Vector2 GetPosition() const;

	Ogre::Vector2 GetScreenPosition() const;

	Ogre::String GetText() const;

	Ogre::Vector2 GetTextMargin() const;

	// return true to swallow event.
	bool HandleEvent();

	bool IsVisible() const;

	void SetBackgroundColor(const Ogre::ColourValue& color) const;

	void SetBackgroundImage(const Ogre::String& sprite) const;

	void SetDimension(const Ogre::Vector2& dimension);

	void SetFont(Font font) const;

	void SetFontColor(const Ogre::ColourValue& color) const;

	void SetGradientColor(
		GradientDirection direction,
		Ogre::ColourValue startColor,
		Ogre::ColourValue endColor) const;

	void SetHeight(Ogre::Real height);

	void SetMarkupText(const Ogre::String& text) const;

	void SetOffsetPosition(const Ogre::Vector2& offset);

	void SetPosition(const Ogre::Vector2& position);

	void SetReceiveEvents(bool receiveEvents);

	void SetText(const Ogre::String& string) const;

	void SetTextMargin(Ogre::Real top, Ogre::Real left);

	void SetWidth(Ogre::Real width);

	void SetWorldPosition(const Ogre::Vector3& position) const;

	void SetWorldRotation(const Ogre::Quaternion& rotation) const;

	void SetVisible(bool visible);

private:
	std::vector<UserInterfaceComponent*> children_;

	Gorilla::Layer* const parentLayer_;

	Gorilla::ScreenRenderable* const screen_;

	Ogre::SceneNode* const sceneNode_;

	Gorilla::Caption* text_;

	Gorilla::Rectangle* rectangle_;

	Gorilla::MarkupText* markupText_;

	std::vector<UserInterfaceLineList*> lines_;

	Ogre::Vector2 topLeftPosition_;

	Ogre::Vector2 topLeftOffset_;

	Ogre::Vector2 dimensions_;

	Ogre::Vector2 textMargin_;

	bool visible_;

	Font font_;

	UserInterfaceComponent(const UserInterfaceComponent&);

	UserInterfaceComponent& operator=(const UserInterfaceComponent&);

	void Initialize();
};

#endif  // DEMO_FRAMEWORK_USER_INTERFACE_COMPONENT_H
