-- project_hub_panel
-- created on 2021/8/21
-- author @zoloypzuo
local PanelWindow = require("ui.panel_window")
local Button = require("ui.widgets.button")
local InputText = require("ui.widgets.input_text")
local Spacing = require("ui.layouts.spacing")
local Separator = require("ui.widgets.separator")
local Columns = require("ui.layouts.column")
local Text = require("ui.widgets.text")
local Group = require("ui.layouts.group")

local ProjectHubPanel = Class(PanelWindow, function(self)
    PanelWindow._ctor(self, "Project Hub", true)

    self:SetSize({ 1000, 580 });
    self:SetPosition({ 0., 0 });

    self:_Header()

    self:_Spacing()

    self:_ProjectList()
end)

function ProjectHubPanel:_Header()
    local openProjectButton = self:CreateWidget(Button, "Open Project")
    local newProjectButton = self:CreateWidget(Button, "New Project")
    local pathField = self:CreateWidget(InputText, "");
    local goButton = self:CreateWidget(Button, "GO")

    local function UpdateGoButton(p_path)
        validPath = p_path ~= ""
        if validPath then
            goButton.idleBackgroundColor = RGBA(0, 0.5, 0)
        else
            goButton.idleBackgroundColor = RGBA(0.1, 0.1, 0.1)
        end
        goButton.disabled = not validPath
    end

    UpdateGoButton("") -- init go button

    openProjectButton.idleBackgroundColor = RGBA(0.7, 0.5, 0.);
    newProjectButton.idleBackgroundColor = RGBA(0., 0.5, 0.0);

    openProjectButton.lineBreak = false;
    newProjectButton.lineBreak = false;
    pathField.lineBreak = false;

    pathField.ContentChangedEvent:AddEventHandler(function(content)
        print(content)
        UpdateGoButton(pathField.content)
    end)

    openProjectButton:AddOnClickHandler(function()
        local result = UI:OpenFileDialog()
        pathField.content = result
        UpdateGoButton(pathField.content)
    end)

    newProjectButton:AddOnClickHandler(function()
        local result = UI:OpenFileDialog()
        pathField.content = result
        UpdateGoButton(pathField.content)
    end)

    goButton:AddOnClickHandler(function()
        print("GO", pathField.content)
        -- TODO close panel and return boot args
    end)
end

function ProjectHubPanel:_Spacing()
    for _ = 1, 4 do
        self:CreateWidget(Spacing)
    end

    self:CreateWidget(Separator)

    for _ = 1, 4 do
        self:CreateWidget(Spacing)
    end
end

function ProjectHubPanel:_ProjectList()
    local sandbox_configs = require("sandbox.sandbox_config")
    local columns = self:CreateWidget(Columns, 2)
    columns.widths = { 1000, 500 }
    for _, sandbox_config in ipairs(sandbox_configs) do
        local text = columns:CreateWidget(Text, sandbox_config.name)
        local actions = columns:CreateWidget(Group)
        local openButton = actions:CreateWidget(Button, "Open")
        local deleteButton = actions:CreateWidget(Button, "Delete")

        openButton.idleBackgroundColor = RGBA(0.7, 0.5, 0.)
        deleteButton.idleBackgroundColor = RGBA(0.5, 0., 0.)

        openButton:AddOnClickHandler(function()
            print("OpenProject", sandbox_config.name)
            local file = io.open("project_hub.txt", "w")
            file:write(sandbox_config.name)
            file:close()
            Quit()
        end)
        deleteButton:AddOnClickHandler(function()
            --text.Destroy();
            --actions.Destroy();
            columns:RemoveWidget(text)
            columns:RemoveWidget(actions)
        end)
        openButton.lineBreak = false
        deleteButton.lineBreak = false
    end
end

function ProjectHubPanel:Update()
    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 50, 50)
    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 0)
    PanelWindow.Update(self)
    ImGui.PopStyleVar(2)
end

return ProjectHubPanel