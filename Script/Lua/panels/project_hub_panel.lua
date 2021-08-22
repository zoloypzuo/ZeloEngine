-- project_hub_panel
-- created on 2021/8/21
-- author @zoloypzuo
local APanel = require("ui.panel")
local Button = require("ui.widgets.button")
local InputText = require("ui.widgets.input_text")
local Spacing = require("ui.layouts.spacing")

local ProjectHubPanel = Class(APanel, function(self)
    APanel._ctor(self)

    -- PanelWindow
    --SetSize({ 1000, 580 });
    --SetPosition({ 0.f, 0.f });

    self:Header()

    for i = 1, 4 do
        self:CreateWidget(Spacing)
    end

    --CreateWidget<OvUI::Widgets::Visual::Separator>();
    --
    --for (uint8_t i = 0; i < 4; ++i)
    --	CreateWidget<OvUI::Widgets::Layout::Spacing>();
    --auto& columns = CreateWidget<OvUI::Widgets::Layout::Columns<2>>();
    --
    --columns.widths = { 750, 500 };

    self:ProjectList()


end)

function ProjectHubPanel:Header()
    local openProjectButton = self:CreateWidget(Button, "Open Project")
    local newProjectButton = self:CreateWidget(Button, "New Project")
    local pathField = self:CreateWidget(InputText, "?");
    local m_goButton = self:CreateWidget(Button, "GO")

    -- void UpdateGoButton(const std::string& p_path)
    --{
    --bool validPath = p_path != "";
    --m_goButton->idleBackgroundColor = validPath ? OvUI::Types::Color{ 0.f, 0.5f, 0.0f } : OvUI::Types::Color{ 0.1f, 0.1f, 0.1f };
    --m_goButton->disabled = !validPath;
    --}

    local function UpdateGoButton(p_path)
        validPath = p_path ~= ""
        if validPath then
            m_goButton.idleBackgroundColor = Vector3(0, 0.5, 0)
        else
            m_goButton.idleBackgroundColor = Vector3(0.1, 0.1, 0.1)
        end
        m_goButton.disabled = not validPath
    end

    UpdateGoButton("") -- init go button

    openProjectButton.idleBackgroundColor = Vector3 { 0.7, 0.5, 0. };
    newProjectButton.idleBackgroundColor = Vector3 { 0., 0.5, 0.0 };

    openProjectButton.lineBreak = false;
    newProjectButton.lineBreak = false;
    pathField.lineBreak = false;


    -- TODO
    -- pathField.ContentChangedEvent += [this, &pathField](std::string p_content)
    --{
    --	pathField.content = OvTools::Utils::PathParser::MakeWindowsStyle(p_content);
    --
    --	if (pathField.content != "" && pathField.content.back() != '\\')
    --		pathField.content += '\\';
    --
    --	UpdateGoButton(pathField.content);
    --};

    openProjectButton:AddOnClickHandler(function()
        -- OvWindowing::Dialogs::OpenFileDialog dialog("Open project");
        --dialog.AddFileType("Overload Project", "*.ovproject");
        --dialog.Show();
        --
        --std::string ovProjectPath = dialog.GetSelectedFilePath();
        --std::string rootFolderPath = OvTools::Utils::PathParser::GetContainingFolder(ovProjectPath);
        --
        --if (dialog.HasSucceeded())
        --{
        --	RegisterProject(rootFolderPath);
        --	OpenProject(rootFolderPath);
        --}
    end)

    newProjectButton:AddOnClickHandler(function()
        --OvWindowing::Dialogs::SaveFileDialog dialog("New project location");
        --dialog.DefineExtension("Overload Project", "..");
        --dialog.Show();
        --if (dialog.HasSucceeded())
        --{
        --	std::string result = dialog.GetSelectedFilePath();
        --	pathField.content = std::string(result.data(), result.data() + result.size() - std::string("..").size()); // remove auto extension
        --	pathField.content += "\\";
        --	UpdateGoButton(pathField.content);
        --}
    end)

    --m_goButton->ClickedEvent += [this, &pathField]
    --{
    --	CreateProject(pathField.content);
    --	RegisterProject(pathField.content);
    --	OpenProject(pathField.content);
    --};

    m_goButton:AddOnClickHandler(function()
        -- TODO
    end)
end

function ProjectHubPanel:ProjectList()

end

function ProjectHubPanel:Update()
    ImGui.PushStyleVar(ImGuiStyleVar.WindowPadding, 50, 50)
    ImGui.PushStyleVar(ImGuiStyleVar.WindowRounding, 0)
    APanel.Update(self)
    ImGui.PopStyleVar(2)
end

return ProjectHubPanel