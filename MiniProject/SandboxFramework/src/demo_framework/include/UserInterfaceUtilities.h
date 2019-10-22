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

#ifndef DEMO_FRAMEWORK_INTERFACE_UTILITIES_H
#define DEMO_FRAMEWORK_INTERFACE_UTILITIES_H

#define LUA_UI_COMPONENT_METATABLE "UserInterfaceComponentType"

struct lua_State;

class UserInterfaceComponent;

class UserInterfaceUtilities
{
public:
	static void BindVMFunctions(lua_State* luaVM);

	static UserInterfaceComponent* GetUserInterfaceComponent(
		lua_State& luaVM, int stackIndex);

	static int PushCreatedChildComponent(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushDimensions(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushFont(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushMarkupText(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushOffsetPosition(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushPosition(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushScreenPosition(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushText(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushTextMargin(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushVisible(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushUserInterfaceComponent(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static int PushUserInterfaceComponentProperties(
		lua_State& luaVM, UserInterfaceComponent& uiComponent);

	static void SetBackgroundColor(
		UserInterfaceComponent& uiComponent,
		Ogre::Real red,
		Ogre::Real green,
		Ogre::Real blue,
		Ogre::Real alpha = 1.0f);

	static void SetDimension(
		UserInterfaceComponent& uiComponent,
		Ogre::Real width,
		Ogre::Real height);

	static void SetGradientColor(
		UserInterfaceComponent& uiComponent,
		const Ogre::String& gradientName,
		Ogre::Real startRed,
		Ogre::Real startGreen,
		Ogre::Real startBlue,
		Ogre::Real startAlpha,
		Ogre::Real endRed,
		Ogre::Real endGreen,
		Ogre::Real endBlue,
		Ogre::Real endAlpha);

	static void SetFont(
		UserInterfaceComponent& uiComponent,
		Ogre::String fontName);

	static void SetFontColor(
		UserInterfaceComponent& uiComponent,
		Ogre::Real red,
		Ogre::Real green,
		Ogre::Real blue,
		Ogre::Real alpha = 1.0f);

	static void SetMarkupText(
		UserInterfaceComponent& uiComponent,
		const Ogre::String& text);

	static void SetPosition(
		UserInterfaceComponent& uiComponent,
		Ogre::Real x,
		Ogre::Real y);

	static void SetText(
		UserInterfaceComponent& uiComponent,
		const Ogre::String& text);

	static void SetTextMargin(
		UserInterfaceComponent& uiComponent,
		Ogre::Real x,
		Ogre::Real y);

	static void SetVisible(
		UserInterfaceComponent& uiComponent,
		bool visible);

	static void SetWorldPosition(
		UserInterfaceComponent& uiComponent,
		const Ogre::Vector3& position);

	static void SetWorldRotation(
		UserInterfaceComponent& uiComponent,
		const Ogre::Quaternion& rotation);

private:
	UserInterfaceUtilities();
	~UserInterfaceUtilities();
	UserInterfaceUtilities(const UserInterfaceUtilities&);
	UserInterfaceUtilities& operator=(const UserInterfaceUtilities&);
};

#endif  // DEMO_FRAMEWORK_ANIMATION_UTILITIES_H
