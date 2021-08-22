-- panel_menu_bar
-- created on 2021/8/22
-- author @zoloypzuo
local APanel = require("ui.panel")

local PanelMenuBar = Class(APanel, function()
    -- 封装MainMenuBar
end)

function PanelMenuBar:_UpdateImpl()
    if self.widgets ~= {} and ImGui.BeginMainMenuBar() then
        self._base._UpdateImpl(self)
        ImGui.EndMainMenuBar()
    end
end