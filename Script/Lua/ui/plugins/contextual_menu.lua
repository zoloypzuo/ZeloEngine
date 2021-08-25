-- contextual_menu
-- created on 2021/8/25
-- author @zoloypzuo
local WidgetContainerMixin = require("ui.widget_container_mixin")
local ContextualMenu = Class(function(self)
    WidgetContainerMixin.included(self)
    self.userData = nil
end):include(WidgetContainerMixin)

function ContextualMenu:Execute()
    if ImGui.BeginPopupContextItem() then
        self.UpdateWidgets()
        ImGui.EndPopup()
    end
end

function ContextualMenu:Close()
    ImGui.CloseCurrentPopup()
end

return ContextualMenu