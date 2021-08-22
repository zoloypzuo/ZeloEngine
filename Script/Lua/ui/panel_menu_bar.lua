-- panel_menu_bar
-- created on 2021/8/22
-- author @zoloypzuo
local panel = require("ui.panel")

local PanelMenuBar = Class(panel.APanel, function(self)
    -- 封装MainMenuBar
    panel.APanel._ctor(self)
end)

function PanelMenuBar:_UpdateImpl()
    if self.widgets ~= {} and ImGui.BeginMainMenuBar() then
        self._base._UpdateImpl(self)
        ImGui.EndMainMenuBar()
    end
end