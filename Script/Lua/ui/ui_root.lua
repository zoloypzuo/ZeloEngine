-- ui_root
-- created on 2021/8/21
-- author @zoloypzuo
local ShowDemoWindow = require("ui.demo.demo")
local TestDemoWindow = false

local PanelWindow = require("ui.panel_window")
local PanelMenuBar = require("ui.panel_menu_bar")

UIRoot = Class(function(self)
    self.panels = {}
end)

function UIRoot:Update()
    if TestDemoWindow then
        TestDemoWindow = ShowDemoWindow(TestDemoWindow)
    end
    for _, panel in pairs(self.panels) do
        panel:Update()
    end
end

function UIRoot:LoadPanel(type_, ...)
    if TestDemoWindow then
        return
    end

    assert(type(type_) == "table", "should load a panel")
    local panel = type_(...)
    self.panels[panel.id] = panel

    if panel:is_a(PanelWindow) then
        local menu_bar_panel = self:GetPanel(PanelMenuBar)
        menu_bar_panel:RegisterPanel(panel.name, panel)
    end

    return panel
end

function UIRoot:GetPanel(type_)
    for _, panel in pairs(self.panels) do
        if panel:is_a(type_) then
            return panel
        end
    end
    return nil
end