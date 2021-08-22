-- button
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")
local AButton = require("ui.widgets.abutton")

local Button = Class(AButton, function(self, parent, label, size, disabled)
    AButton._ctor(self)
    self.parent = parent
    self.label = label or ""
    self.size = size or Vector2()
    self.disabled = disabled or false

    self.idleBackgroundColor = nil;
    self.hoveredBackgroundColor = nil;
    self.clickedBackgroundColor = nil;

    self.textColor = nil;

    -- TODO
    -- auto &style = ImGui::GetStyle();
    --    idleBackgroundColor = Internal::Converter::ToColor(style.Colors[ImGuiCol_Button]);
    --    hoveredBackgroundColor = Internal::Converter::ToColor(style.Colors[ImGuiCol_ButtonHovered]);
    --    clickedBackgroundColor = Internal::Converter::ToColor(style.Colors[ImGuiCol_ButtonActive]);
    --    textColor = Internal::Converter::ToColor(style.Colors[ImGuiCol_Text]);
end)

function Button:_UpdateImpl()
    --     auto &style = ImGui::GetStyle();
    --
    --    auto defaultIdleColor = style.Colors[ImGuiCol_Button];
    --    auto defaultHoveredColor = style.Colors[ImGuiCol_ButtonHovered];
    --    auto defaultClickedColor = style.Colors[ImGuiCol_ButtonActive];
    --    auto defaultTextColor = style.Colors[ImGuiCol_Text];
    --
    --    style.Colors[ImGuiCol_Button] = OvUI::Internal::Converter::ToImVec4(idleBackgroundColor);
    --    style.Colors[ImGuiCol_ButtonHovered] = OvUI::Internal::Converter::ToImVec4(hoveredBackgroundColor);
    --    style.Colors[ImGuiCol_ButtonActive] = OvUI::Internal::Converter::ToImVec4(clickedBackgroundColor);
    --    style.Colors[ImGuiCol_Text] = OvUI::Internal::Converter::ToImVec4(textColor);
    --
    --    if (ImGui::ButtonEx((label + m_widgetID).c_str(), Internal::Converter::ToImVec2(size),
    --                        disabled ? ImGuiButtonFlags_Disabled : 0))
    --        ClickedEvent.Invoke();
    --
    --    style.Colors[ImGuiCol_Button] = defaultIdleColor;
    --    style.Colors[ImGuiCol_ButtonHovered] = defaultHoveredColor;
    --    style.Colors[ImGuiCol_ButtonActive] = defaultClickedColor;
    --    style.Colors[ImGuiCol_Text] = defaultTextColor;
    if ImGui.Button(self.label, self.size.x, self.size.y) then
        self:_OnClick()
    end
end

return Button