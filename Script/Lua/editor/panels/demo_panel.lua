-- demo_panel
-- created on 2021/9/30
-- author @zoloypzuo
local PanelWindow = require("ui.panel_window")
local ShowDemoWindow = require("ui.demo.demo")

local DemoPanel = Class(PanelWindow, function(self, title, opened, panelSetting)
    PanelWindow._ctor(self, title, opened, panelSetting)
end)

function DemoPanel:_UpdateImpl()
    if not self.opened then
        return
    end

    self.opened = ShowDemoWindow(self.opened)
end

return DemoPanel