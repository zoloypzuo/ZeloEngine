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

#include "demo_framework/include/LuaScriptBindings.h"
#include "demo_framework/include/LuaScriptUtilities.h"
#include "demo_framework/include/UserInterfaceComponent.h"
#include "demo_framework/include/UserInterfaceUtilities.h"

namespace
{
    const luaL_Reg LuaUIComponentFunctions[] =
    {
        { "CreateChild",                Lua_Script_UICreateChild },
        { "GetDimensions",              Lua_Script_UIGetDimensions },
        { "GetFont",                    Lua_Script_UIGetFont },
        { "GetMarkupText",              Lua_Script_UIGetMarkupText },
        { "GetOffsetPosition",          Lua_Script_UIGetOffsetPosition },
        { "GetPosition",                Lua_Script_UIGetPosition },
        { "GetScreenPosition",          Lua_Script_UIGetScreenPosition },
        { "GetText",                    Lua_Script_UIGetText },
        { "GetTextMargin",              Lua_Script_UIGetTextMargin },
        { "IsVisible",                  Lua_Script_UIIsVisible },
        { "SetBackgroundColor",         Lua_Script_UISetBackgroundColor },
        { "SetDimensions",              Lua_Script_UISetDimensions },
        { "SetGradientColor",           Lua_Script_UISetGradientColor },
        { "SetFont",                    Lua_Script_UISetFont },
        { "SetFontColor",               Lua_Script_UISetFontColor },
        { "SetPosition",                Lua_Script_UISetPosition },
        { "SetMarkupText",              Lua_Script_UISetMarkupText },
        { "SetText",                    Lua_Script_UISetText },
        { "SetTextMargin",              Lua_Script_UISetTextMargin },
        { "SetVisible",                 Lua_Script_UISetVisible },
        { "SetWorldPosition",           Lua_Script_UISetWorldPosition },
        { "SetWorldRotation",           Lua_Script_UISetWorldRotation },
        { NULL, NULL }
    };

    const luaL_Reg LuaUIComponentMetatable[] =
    {
        { "__towatch",                  Lua_Script_UIComponentToWatch },
        { NULL, NULL }
    };
}  // anonymous namespace

void UserInterfaceUtilities::BindVMFunctions(lua_State* const luaVM)
{
    luaL_newmetatable(luaVM, LUA_UI_COMPONENT_METATABLE);
    luaL_register(luaVM, NULL, LuaUIComponentMetatable);

    luaL_register(luaVM, "UI", LuaUIComponentFunctions);
}

UserInterfaceComponent* UserInterfaceUtilities::GetUserInterfaceComponent(
    lua_State& luaVM, const int stackIndex)
{
    return *static_cast<UserInterfaceComponent**>(
        luaL_checkudata(&luaVM, stackIndex, LUA_UI_COMPONENT_METATABLE));
}

int UserInterfaceUtilities::PushCreatedChildComponent(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    return PushUserInterfaceComponent(
        luaVM, *uiComponent.CreateChildComponent());
}

int UserInterfaceUtilities::PushDimensions(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    return LuaScriptUtilities::PushVector2(&luaVM, uiComponent.GetDimensions());
}

int UserInterfaceUtilities::PushFont(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    return LuaScriptUtilities::PushString(
        &luaVM, UserInterfaceComponent::FontToString(uiComponent.GetFont()));
}

int UserInterfaceUtilities::PushMarkupText(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    return LuaScriptUtilities::PushString(&luaVM, uiComponent.GetMarkupText());
}

int UserInterfaceUtilities::PushOffsetPosition(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    return LuaScriptUtilities::PushVector2(
        &luaVM, uiComponent.GetOffsetPosition());
}

int UserInterfaceUtilities::PushPosition(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    return LuaScriptUtilities::PushVector2(&luaVM, uiComponent.GetPosition());
}

int UserInterfaceUtilities::PushScreenPosition(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    return LuaScriptUtilities::PushVector2(
        &luaVM, uiComponent.GetScreenPosition());
}

int UserInterfaceUtilities::PushText(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    return LuaScriptUtilities::PushString(&luaVM, uiComponent.GetText());
}

int UserInterfaceUtilities::PushTextMargin(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    return LuaScriptUtilities::PushVector2(&luaVM, uiComponent.GetPosition());
}

int UserInterfaceUtilities::PushUserInterfaceComponent(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    const size_t uiComponentSize = sizeof(uiComponent);

    UserInterfaceComponent** const luaUIComponent =
        static_cast<UserInterfaceComponent**>(
            lua_newuserdata(&luaVM, uiComponentSize));

    *luaUIComponent = &uiComponent;

    luaL_getmetatable(&luaVM, LUA_UI_COMPONENT_METATABLE);
    lua_setmetatable(&luaVM, -2);

    return 1;
}

int UserInterfaceUtilities::PushUserInterfaceComponentProperties(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    lua_pushstring(&luaVM, "UserInterfaceComponent");
    lua_newtable(&luaVM);
    const int tableIndex = lua_gettop(&luaVM);

    LuaScriptUtilities::PushStringAttribute(
        &luaVM,
        UserInterfaceComponent::FontToString(uiComponent.GetFont()),
        "font",
        tableIndex);

    LuaScriptUtilities::PushVector2Attribute(
        &luaVM, uiComponent.GetScreenPosition(), "screenPosition", tableIndex);

    LuaScriptUtilities::PushVector2Attribute(
        &luaVM, uiComponent.GetPosition(), "position", tableIndex);

    LuaScriptUtilities::PushVector2Attribute(
        &luaVM, uiComponent.GetOffsetPosition(), "offsetPosition", tableIndex);

    LuaScriptUtilities::PushVector2Attribute(
        &luaVM, uiComponent.GetTextMargin(), "textMargin", tableIndex);

    LuaScriptUtilities::PushStringAttribute(
        &luaVM, uiComponent.GetText(), "text", tableIndex);

    LuaScriptUtilities::PushStringAttribute(
        &luaVM, uiComponent.GetMarkupText(), "markupText", tableIndex);

    LuaScriptUtilities::PushVector2Attribute(
        &luaVM, uiComponent.GetDimensions(), "dimensions", tableIndex);

    LuaScriptUtilities::PushBoolAttribute(
        &luaVM, uiComponent.IsVisible(), "visible", tableIndex);

    return 2;
}

int UserInterfaceUtilities::PushVisible(
    lua_State& luaVM, UserInterfaceComponent& uiComponent)
{
    lua_pushboolean(&luaVM, uiComponent.IsVisible());
    return 1;
}

void UserInterfaceUtilities::SetBackgroundColor(
    UserInterfaceComponent& uiComponent,
    const Ogre::Real red,
    const Ogre::Real green,
    const Ogre::Real blue,
    const Ogre::Real alpha)
{
    uiComponent.SetBackgroundColor(
        Ogre::ColourValue(
            std::min(red, 1.0f),
            std::min(green, 1.0f),
            std::min(blue, 1.0f),
            std::min(alpha, 1.0f)));
}

void UserInterfaceUtilities::SetDimension(
    UserInterfaceComponent& uiComponent,
    const Ogre::Real width,
    const Ogre::Real height)
{
    uiComponent.SetDimension(Ogre::Vector2(width, height));
}

void UserInterfaceUtilities::SetGradientColor(
    UserInterfaceComponent& uiComponent,
    const Ogre::String& gradientName,
    const Ogre::Real startRed,
    const Ogre::Real startGreen,
    const Ogre::Real startBlue,
    const Ogre::Real startAlpha,
    const Ogre::Real endRed,
    const Ogre::Real endGreen,
    const Ogre::Real endBlue,
    const Ogre::Real endAlpha)
{
    uiComponent.SetGradientColor(
        UserInterfaceComponent::StringToGradient(gradientName),
        Ogre::ColourValue(startRed, startGreen, startBlue, startAlpha),
        Ogre::ColourValue(endRed, endGreen, endBlue, endAlpha));
}

void UserInterfaceUtilities::SetFont(
    UserInterfaceComponent& uiComponent, const Ogre::String fontName)
{
    uiComponent.SetFont(UserInterfaceComponent::StringToFont(fontName));
}

void UserInterfaceUtilities::SetFontColor(
    UserInterfaceComponent& uiComponent,
    const Ogre::Real red,
    const Ogre::Real green,
    const Ogre::Real blue,
    const Ogre::Real alpha)
{
    uiComponent.SetFontColor(Ogre::ColourValue(red, green, blue, alpha));
}

void UserInterfaceUtilities::SetMarkupText(
    UserInterfaceComponent& uiComponent, const Ogre::String& text)
{
    uiComponent.SetMarkupText(text);
}

void UserInterfaceUtilities::SetPosition(
    UserInterfaceComponent& uiComponent,
    const Ogre::Real x,
    const Ogre::Real y)
{
    uiComponent.SetPosition(Ogre::Vector2(x, y));
}

void UserInterfaceUtilities::SetText(
    UserInterfaceComponent& uiComponent, const Ogre::String& text)
{
    uiComponent.SetText(text);
}

void UserInterfaceUtilities::SetTextMargin(
    UserInterfaceComponent& uiComponent,
    const Ogre::Real x,
    const Ogre::Real y)
{
    uiComponent.SetTextMargin(x, y);
}

void UserInterfaceUtilities::SetVisible(
    UserInterfaceComponent& uiComponent, const bool visible)
{
    uiComponent.SetVisible(visible);
}

void UserInterfaceUtilities::SetWorldPosition(
    UserInterfaceComponent& uiComponent,
    const Ogre::Vector3& position)
{
    uiComponent.SetWorldPosition(position);
}

void UserInterfaceUtilities::SetWorldRotation(
    UserInterfaceComponent& uiComponent,
    const Ogre::Quaternion& rotation)
{
    uiComponent.SetWorldRotation(rotation);
}