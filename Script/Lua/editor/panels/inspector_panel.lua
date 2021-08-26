-- inspector_panel
-- created on 2021/8/25
-- author @zoloypzuo
local PanelWindow = require("ui.panel_window")
local Button = require("ui.widgets.button")
local InputText = require("ui.widgets.input_text")
local Spacing = require("ui.layouts.spacing")
local Separator = require("ui.widgets.separator")
local Columns = require("ui.layouts.column")
local Text = require("ui.widgets.text")
local Group = require("ui.layouts.group")
local TreeNode = require("ui.layouts.tree_node")
local ContextualMenu = require("ui.plugins.contextual_menu")
local MenuItem = require("ui.widgets.menu_item")
local MenuList = require("ui.widgets.menu_list")
local TheEditorDrawer = require("editor.editor_drawer")

local Inspector = Class(PanelWindow, function(self, title, opened, panelSetting)
    PanelWindow._ctor(self, title, opened, panelSetting)
    self.m_targetActor = nil
    self.m_actorInfo = nil
    self.m_inspectorHeader = nil
    self.m_componentSelectorWidget = nil
    self.m_scriptSelectorWidget = nil

    self.m_componentAddedListener = 0
    self.m_componentRemovedListener = 0
    self.m_behaviourAddedListener = 0
    self.m_behaviourRemovedListener = 0
    self.m_destroyedListener = 0

    self.m_inspectorHeader = self:CreateWidget(Group)
    self.m_inspectorHeader.enabled = true  -- TODO false
    self.m_actorInfo = self:CreateWidget(Group)

    self:_HeaderColumns()
    self:_ComponentSelectorWidget()
    self:_ScriptSelectorWidget()
end)

function Inspector:_HeaderColumns()
    local headerColumns = self.m_inspectorHeader:CreateWidget(Columns, 2)

    TheEditorDrawer:DrawString(headerColumns, "Name",
            function()
                return self.m_targetActor and self.m_targetActor.name or "?"
            end,
            function(name)
                if self.m_targetActor then
                    self.m_targetActor.name = name
                end
            end)

    TheEditorDrawer:DrawString(headerColumns, "Tag",
            function()
                return self.m_targetActor and self.m_targetActor.tag or "?"
            end,
            function(tag)
                if self.m_targetActor then
                    self.m_targetActor.tag = tag
                end
            end)

    TheEditorDrawer:DrawBoolean(headerColumns, "Active",
            function()
                return self.m_targetActor and self.m_targetActor.active or false
            end,
            function(tag)
                if self.m_targetActor then
                    self.m_targetActor.active = active
                end
            end)
end

function Inspector:_ComponentSelectorWidget()
    self.m_componentSelectorWidget = self.m_inspectorHeader:CreateWidget(ComboBox, 0)
    local componentSelectorWidget = self.m_componentSelectorWidget
    componentSelectorWidget.lineBreak = false
    componentSelectorWidget.choices = {
        [0] = "Model Renderer";
        [0] = "Model Renderer";
        [1] = "Camera";
        [2] = "Physical Box";
        [3] = "Physical Sphere";
        [4] = "Physical Capsule";
        [5] = "Point Light";
        [6] = "Directional Light";
        [7] = "Spot Light";
        [8] = "Ambient Box Light";
        [9] = "Ambient Sphere Light";
        [10] = "Material Renderer";
        [11] = "Audio Source";
        [12] = "Audio Listener";
    }

    local addComponentButton = self.m_inspectorHeader:CreateWidget(Button, "Add Component", Vector2(100, 0))
    addComponentButton.idleBackgroundColor = RGBA(0.7, 0.5, 0.);
    addComponentButton.textColor = RGBA.White
    addComponentButton.ClickedEvent:AddEventHandler(function()
        print("addComponentButton", componentSelectorWidget.currentChoice)
        componentSelectorWidget.ValueChangedEvent:HandleEvent(componentSelectorWidget.currentChoice)
        -- TODO switch
        --        case 0:
        --            GetTargetActor()->AddComponent<CModelRenderer>();
        --            GetTargetActor()->AddComponent<CMaterialRenderer>();
        --            break;
        --        case 1:
        --            GetTargetActor()->AddComponent<CCamera>();
        --            break;
        --        case 2:
        --            GetTargetActor()->AddComponent<CPhysicalBox>();
        --            break;
        --        case 3:
        --            GetTargetActor()->AddComponent<CPhysicalSphere>();
        --            break;
        --        case 4:
        --            GetTargetActor()->AddComponent<CPhysicalCapsule>();
        --            break;
        --        case 5:
        --            GetTargetActor()->AddComponent<CPointLight>();
        --            break;
        --        case 6:
        --            GetTargetActor()->AddComponent<CDirectionalLight>();
        --            break;
        --        case 7:
        --            GetTargetActor()->AddComponent<CSpotLight>();
        --            break;
        --        case 8:
        --            GetTargetActor()->AddComponent<CAmbientBoxLight>();
        --            break;
        --        case 9:
        --            GetTargetActor()->AddComponent<CAmbientSphereLight>();
        --            break;
        --        case 10:
        --            GetTargetActor()->AddComponent<CMaterialRenderer>();
        --            break;
        --        case 11:
        --            GetTargetActor()->AddComponent<CAudioSource>();
        --            break;
        --        case 12:
        --            GetTargetActor()->AddComponent<CAudioListener>();
        --            break;
    end)

    componentSelectorWidget.ValueChangedEvent:AddEventHandler(function(value)
        local function defineButtonsStates(componentExists)
            addComponentButton.disabled = componentExists
            addComponentButton.idleBackgroundColor = componentExists and RGBA(0.7, 0.5, 0) or RGBA(0.1, 0.1, 0.1)
        end
        -- TODO
        --    switch (value) {
        --        case 0:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CModelRenderer>());
        --            return;
        --        case 1:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CCamera>());
        --            return;
        --        case 2:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CPhysicalObject>());
        --            return;
        --        case 3:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CPhysicalObject>());
        --            return;
        --        case 4:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CPhysicalObject>());
        --            return;
        --        case 5:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CPointLight>());
        --            return;
        --        case 6:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CDirectionalLight>());
        --            return;
        --        case 7:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CSpotLight>());
        --            return;
        --        case 8:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CAmbientBoxLight>());
        --            return;
        --        case 9:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CAmbientSphereLight>());
        --            return;
        --        case 10:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CMaterialRenderer>());
        --            return;
        --        case 11:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CAudioSource>());
        --            return;
        --        case 12:
        --            defineButtonsStates(GetTargetActor()->GetComponent<CAudioListener>());
        --            return;
        --    }
    end)
end

function Inspector:_ScriptSelectorWidget()
    self.m_scriptSelectorWidget = self.m_inspectorHeader:CreateWidget(InputText, "")
    self.m_scriptSelectorWidget.lineBreak = false

    -- TODO ddTarget
    --auto &ddTarget =
    --        m_scriptSelectorWidget->AddPlugin < OvUI::Plugins::DDTarget < std::pair < std::string, Layout::Group
    --*>>>("File");

    local addScriptButton = self.m_inspectorHeader:CreateWidget()
    --
    --auto &addScriptButton = m_inspectorHeader->CreateWidget<EntityButtons::Button>("Add Script",
    --                                                                                        OvMaths::FVector2{100.f,
    --                                                                                                            0});
    --addScriptButton.idleBackgroundColor = OvUI::Types::Color{0.7f, 0.5f, 0.f};
    --addScriptButton.textColor = OvUI::Types::Color::White;
    --
    --const auto updateAddScriptButton = [&addScriptButton, this](const std::string &script) {
    --    const std::string realScriptPath = EDITOR_CONTEXT(projectScriptsPath) + script + ".lua";
    --
    --    const auto targetActor = GetTargetActor();
    --    const bool isScriptValid =
    --            std::filesystem::exists(realScriptPath) && targetActor && !targetActor->GetBehaviour(script);
    --
    --    addScriptButton.disabled = !isScriptValid;
    --    addScriptButton.idleBackgroundColor = isScriptValid ? OvUI::Types::Color{0.7f, 0.5f, 0.f}
    --                                                        : OvUI::Types::Color{0.1f, 0.1f, 0.1f};
    --};
    --
    --m_scriptSelectorWidget->ContentChangedEvent += updateAddScriptButton;
    --
    --addScriptButton.ClickedEvent += [updateAddScriptButton, this] {
    --    const std::string realScriptPath =
    --            EDITOR_CONTEXT(projectScriptsPath) + m_scriptSelectorWidget->content + ".lua";
    --
    --    if (std::filesystem::exists(realScriptPath)) {
    --        GetTargetActor()->AddBehaviour(m_scriptSelectorWidget->content);
    --        updateAddScriptButton(m_scriptSelectorWidget->content);
    --    }
    --};
    --
    --ddTarget.DataReceivedEvent += [updateAddScriptButton, this](std::pair<std::string, Layout::Group *> data) {
    --    m_scriptSelectorWidget->content = EDITOR_EXEC(GetScriptPath(data.first));
    --    updateAddScriptButton(m_scriptSelectorWidget->content);
    --};
end

return Inspector