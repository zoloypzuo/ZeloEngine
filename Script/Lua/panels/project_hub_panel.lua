-- project_hub_panel
-- created on 2021/8/21
-- author @zoloypzuo
local panel = require("ui.panel")
local button = require("ui.widgets.button")
local input_text = require("ui.widgets.input_text")
local APanel = panel.APanel

local ProjectHubPanel = Class(APanel, function(self)
    APanel._ctor(self)
    local openProjectButton = self:CreateWidget(button.Button, "Open Project")
    openProjectButton:AddOnClickHandler(function()
        print("button clicked")
    end)
    local pathField = self:CreateWidget(input_text.InputText, "?");
end)

function ProjectHubPanel:Update()
    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 50, 50)
    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 0)
    APanel.Update(self)
    ImGui.PopStyleVar(2)
end

return ProjectHubPanel