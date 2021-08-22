-- project_hub_panel
-- created on 2021/8/21
-- author @zoloypzuo
local APanel = require("ui.panel")
local Button = require("ui.widgets.button")
local InputText = require("ui.widgets.input_text")
local Spacing = require("ui.layouts.spacing")
local Separator = require("ui.widgets.separator")
local Columns = require("ui.layouts.column")
local Text = require("ui.widgets.text")
local Group = require("ui.layouts.group")

local ProjectHubPanel = Class(APanel, function(self)
    APanel._ctor(self)

    -- PanelWindow
    --SetSize({ 1000, 580 });
    --SetPosition({ 0.f, 0.f });

    self:Header()

    for i = 1, 4 do
        self:CreateWidget(Spacing)
    end

    self:CreateWidget(Separator)

    for i = 1, 4 do
        self:CreateWidget(Spacing)
    end

    self:ProjectList()

end)

function ProjectHubPanel:Header()
    local openProjectButton = self:CreateWidget(Button, "Open Project")
    local newProjectButton = self:CreateWidget(Button, "New Project")
    local pathField = self:CreateWidget(InputText, "?");
    local m_goButton = self:CreateWidget(Button, "GO")

    local function UpdateGoButton(p_path)
        validPath = p_path ~= ""
        if validPath then
            m_goButton.idleBackgroundColor = RGBA(0, 0.5, 0)
        else
            m_goButton.idleBackgroundColor = RGBA(0.1, 0.1, 0.1)
        end
        m_goButton.disabled = not validPath
    end

    UpdateGoButton("") -- init go button

    openProjectButton.idleBackgroundColor = RGBA(0.7, 0.5, 0.);
    newProjectButton.idleBackgroundColor = RGBA(0., 0.5, 0.0);

    openProjectButton.lineBreak = false;
    newProjectButton.lineBreak = false;
    pathField.lineBreak = false;

    pathField:AddOnContentChangedHandler(function(content)
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

    m_goButton:AddOnClickHandler(function()
        print("GO", pathField.content)
        -- TODO close panel and return boot args
    end)
end

function ProjectHubPanel:ProjectList()
    local columns = self:CreateWidget(Columns, 2)
    columns.widths = { 750, 500 }
    for i, line in ipairs({ "test1", "test2", "test3" }) do
        print(line)
        local text = columns:CreateWidget(Text, line)
        local actions = columns:CreateWidget(Group)
        local openButton = actions:CreateWidget(Button, "Open")
        local deleteButton = actions:CreateWidget(Button, "Delete")

        openButton.idleBackgroundColor = RGBA(0.7, 0.5, 0.)
        deleteButton.idleBackgroundColor = RGBA(0.5, 0., 0.)

        openButton:AddOnClickHandler(function()
            print("OpenProject", line)
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
    APanel.Update(self)
    ImGui.PopStyleVar(2)
end

return ProjectHubPanel