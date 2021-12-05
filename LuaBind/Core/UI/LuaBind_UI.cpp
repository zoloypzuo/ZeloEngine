// LuaBind_UI.cpp
// created on 2021/8/9
// author @zoloypzuo
#include <sol/sol.hpp>
#include "Core/UI/ImGuiManager.h"
#include "Core/UI/Resource/Font.h"

using namespace Zelo::Core::UI;

void LuaBind_UI(sol::state &luaState) {
// @formatter:off
luaState.new_usertype<Font>("Font",
sol::constructors<Font(const std::string&, float)>()
);

luaState.new_usertype<ImGuiManager>("ImGuiManager",
sol::constructors<ImGuiManager()>(),
sol::base_classes, sol::bases<Plugin>(),
"GetSingletonPtr", &ImGuiManager::getSingletonPtr,
"ApplyStyle", &ImGuiManager::ApplyStyle,
"UseFont", &ImGuiManager::UseFont,
"ResetLayout", &ImGuiManager::ResetLayout,
"OpenFileDialog", &ImGuiManager::OpenFileDialog,
"SaveFileDialog", &ImGuiManager::SaveFileDialog,
"MessageBox", &ImGuiManager::MessageBox,
"enable_docking", sol::property(&ImGuiManager::IsDockingEnabled, &ImGuiManager::EnableDocking),
"__Dummy", []{}
);
// @formatter:on
}
