-- project_setting_panel
-- created on 2021/9/30
-- author @zoloypzuo
local PanelWindow = require("ui.panel_window")
local Button = require("ui.widgets.button")
local InputText = require("ui.widgets.input_text")
local Spacing = require("ui.layouts.spacing")
local Separator = require("ui.widgets.separator")
local Columns = require("ui.layouts.column")
local Text = require("ui.widgets.text")
local Group = require("ui.layouts.group")
local GroupCollapsable = require("ui.layouts.group_collapsable")

local ProjectSettingPanel = Class(PanelWindow, function(self, title, opened, panelSetting)
    PanelWindow._ctor(self, title, opened, panelSetting)

    local saveButton = self:CreateWidget(Button, "Apply")
    saveButton.idleBackgroundColor = RGBA(0.0, 0.5, 0.0)
    saveButton.lineBreak = false
    saveButton.ClickedEvent:AddEventHandler(function()
        print("Apply TODO")
    end)

    local resetButton = self:CreateWidget(Button, "Reset")
    resetButton.idleBackgroundColor = RGBA(0.5, 0, 0)
    resetButton.ClickedEvent:AddEventHandler(function()
        print("Reset TODO")
    end)

    self:CreateWidget(Separator)

    do
        local rendererRoot = self:CreateWidget(GroupCollapsable, "Render")
        local columns  = rendererRoot:CreateWidget(Columns, 2)
        columns.widths[1] = 125
    end
end)

return ProjectSettingPanel