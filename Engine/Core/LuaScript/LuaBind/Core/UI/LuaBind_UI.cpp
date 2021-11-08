// LuaBind_UI.cpp
// created on 2021/8/9
// author @zoloypzuo
#include <sol/sol.hpp>
#include "Core/UI/UIManager.h"
#include "Core/UI/Resource/Font.h"

using namespace Zelo::Core::UI;

void LuaBind_UI(sol::state &luaState) {

luaState.new_usertype<Font>("Font",
sol::constructors<Font(const std::string&, float)>()
);

luaState.new_usertype<UIManager>("UIManager",
"GetSingletonPtr", &UIManager::getSingletonPtr,
"ApplyStyle", &UIManager::ApplyStyle,
"UseFont", &UIManager::UseFont,
"ResetLayout", &UIManager::ResetLayout,
"OpenFileDialog", &UIManager::OpenFileDialog,
"SaveFileDialog", &UIManager::SaveFileDialog,
"MessageBox", &UIManager::MessageBox,
"enable_docking", sol::property(&UIManager::IsDockingEnabled, &UIManager::EnableDocking),
"__Dummy", []{}
);

// @formatter: on
}
