-- console_panel
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
local CheckBox = require("ui.widgets.checkbox")

local ConsolePanel = Class(PanelWindow, function(self, title, opened, panelSetting)
    PanelWindow._ctor(self, title, opened, panelSetting)
    self.m_clearOnPlay = true;
    self.m_showDefaultLog = true;
    self.m_showInfoLog = true;
    self.m_showWarningLog = true;
    self.m_showErrorLog = true;

    self.m_logGroup = nil  ---@type Group

    self.panelSettings.AlwaysHorizontalScrollbar = true

    local cleaButton = self:CreateWidget(Button, "Clear")
    cleaButton.size = Vector2(50, 0)
    cleaButton.idleBackgroundColor = RGBA(0.5, 0, 0)
    cleaButton.ClickedEvent:AddEventHandler(function()
        self.m_logGroup:Clear()
    end)
    cleaButton.lineBreak = false

    local clearOnPlay = self:CreateWidget(CheckBox, self.m_clearOnPlay, "Auto clear on play")

    self:CreateWidget(Spacing, 5).lineBreak = false

    local enableDefault = self:CreateWidget(CheckBox, true, "Default")
    local enableInfo = self:CreateWidget(CheckBox, true, "Info")
    local enableWarning = self:CreateWidget(CheckBox, true, "Warning")
    local enableError = self:CreateWidget(CheckBox, true, "Error")

    clearOnPlay.lineBreak = false;
    enableDefault.lineBreak = false;
    enableInfo.lineBreak = false;
    enableWarning.lineBreak = false;
    enableError.lineBreak = true;

    clearOnPlay.ValueChangedEvent:AddEventHandler(function(value)
        self.m_clearOnPlay = value
    end)
    enableDefault.ValueChangedEvent:AddEventHandler(function(value)
        print("TODO")
    end)
    enableInfo.ValueChangedEvent:AddEventHandler(function(value)
        print("TODO")
    end)
    enableWarning.ValueChangedEvent:AddEventHandler(function(value)
        print("TODO")
    end)
    enableError.ValueChangedEvent:AddEventHandler(function(value)
        print("TODO")
    end)

    self:CreateWidget(Separator)

    self.m_logGroup = self:CreateWidget(Group)
    -- TODO reverse draw order

    AddPrintLogger(function(s)
        self.m_logGroup:CreateWidget(Text, s)
    end)
end)

return ConsolePanel