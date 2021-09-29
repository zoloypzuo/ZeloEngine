-- panel_menu_bar
-- created on 2021/8/22
-- author @zoloypzuo
local APanel = require("ui.panel")

local PanelMenuBar = Class(APanel, function(self)
    APanel._ctor(self)
end)

function PanelMenuBar:_UpdateImpl()
    if #self.widgets > 0 and ImGui.BeginMainMenuBar() then
        self:UpdateWidgets()
        ImGui.EndMainMenuBar()
    end
end

return PanelMenuBar