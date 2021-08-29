-- inspector_panel
-- created on 2021/8/25
-- author @zoloypzuo

-- widgets
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
local ComboBox = require("ui.widgets.combobox")

local TheEditorDrawer = require("editor.editor_drawer")

local EEngineComponents = {
    {
        name = "Camera";
        ctype = "PERSPECTIVE_CAMERA";
        add_fn = "AddCamera"
    };
    {
        name = "Free Look";
        ctype = "FREE_LOOK";
        add_fn = "AddFreeLook"
    };
    {
        name = "Free Move";
        ctype = "FREE_MOVE";
        add_fn = "AddFreeMove"
    };
    {
        name = "Directional Light";
        ctype = "DIRECTIONAL_LIGHT";
        add_fn = "AddDirectionalLight"
    };
    {
        name = "Point Light";
        ctype = "POINT_LIGHT";
        add_fn = "AddPointLight"
    };
    {
        name = "Spot Light";
        ctype = "POINT_LIGHT";
        add_fn = "AddSpotLight"
    };
    {
        name = "Mesh Renderer";
        ctype = "MESH_RENDERER";
        add_fn = "AddMeshRenderer"
    };
}

local EComponent = {}
local EAddComponent = {}
for _, value in ipairs(EEngineComponents) do
    EComponent[value.ctype] = value.name
end

for _, value in ipairs(EEngineComponents) do
    EAddComponent[value.ctype] = value.add_fn
end

-- TODO all entity components
-- TODO resource manager
-- TODO MessageBox

local Inspector = Class(PanelWindow, function(self, title, opened, panelSetting)
    PanelWindow._ctor(self, title, opened, panelSetting)

    self:SetSize({ 1000, 580 });
    self:SetPosition({ 0., 0 });

    self.m_targetEntity = nil
    self.m_entityInfo = nil
    self.m_inspectorHeader = nil
    self.m_componentSelectorWidget = nil
    self.m_scriptSelectorWidget = nil

    self.m_componentAddedListener = 0
    self.m_componentRemovedListener = 0
    self.m_behaviourAddedListener = 0
    self.m_behaviourRemovedListener = 0
    self.m_destroyedListener = 0

    self.m_inspectorHeader = self:CreateWidget(Group)
    self.m_inspectorHeader.enabled = false
    self.m_entityInfo = self:CreateWidget(Group)

    self:_HeaderColumns()
    self:_ComponentSelectorWidget()
    self:_ScriptSelectorWidget()

    TheEditorActions.OnSelectEntity:AddEventHandler(Bind(self, "FocusEntity"))
end)

function Inspector:_HeaderColumns()
    local headerColumns = self.m_inspectorHeader:CreateWidget(Columns, 2)

    TheEditorDrawer:DrawString(headerColumns, "Name", function()
        return self.m_targetEntity and tostring(self.m_targetEntity.name) or "?"
    end, function(name)
        if self.m_targetEntity then
            self.m_targetEntity.name = name
        end
    end)

    TheEditorDrawer:DrawString(headerColumns, "Tag", function()
        return self.m_targetEntity and self.m_targetEntity.entity.tag or "?"
    end, function(tag)
        if self.m_targetEntity then
            self.m_targetEntity.entity.tag = tag
        end
    end)

    TheEditorDrawer:DrawBoolean(headerColumns, "Active", function()
        return self.m_targetEntity and self.m_targetEntity.entity.active or false
    end, function(active)
        if self.m_targetEntity then
            self.m_targetEntity.entity.active = active
        end
    end)
end

function Inspector:_ComponentSelectorWidget()
    self.m_componentSelectorWidget = self.m_inspectorHeader:CreateWidget(ComboBox, EComponent)
    local componentSelectorWidget = self.m_componentSelectorWidget
    componentSelectorWidget.lineBreak = false

    local addComponentButton = self.m_inspectorHeader:CreateWidget(Button, "Add Component", Vector2(100, 0))
    addComponentButton.idleBackgroundColor = RGBA(0.7, 0.5, 0.);
    addComponentButton.textColor = RGBA.White
    addComponentButton.ClickedEvent:AddEventHandler(function()
        local choice = componentSelectorWidget.currentChoice
        print("addComponentButton", choice)
        componentSelectorWidget.ValueChangedEvent:HandleEvent(choice)
        local entity = self.m_targetEntity.entity
        local add_fn = EAddComponent[choice]
        entity[add_fn](entity)
    end)

    componentSelectorWidget.ValueChangedEvent:AddEventHandler(function(value)
        local function defineButtonsStates(componentExists)
            addComponentButton.disabled = componentExists
            addComponentButton.idleBackgroundColor = componentExists and RGBA(0.7, 0.5, 0) or RGBA(0.1, 0.1, 0.1)
        end
    end)
end

function Inspector:_ScriptSelectorWidget()
    local function updateAddScriptButton(script)
        --    const std::string realScriptPath = EDITOR_CONTEXT(projectScriptsPath) + script + ".lua";
        --
        --    const auto targetEntity = GetTargetEntity();
        --    const bool isScriptValid =
        --            std::filesystem::exists(realScriptPath) && targetEntity && !targetEntity->GetBehaviour(script);
        --
        --    addScriptButton.disabled = !isScriptValid;
        --    addScriptButton.idleBackgroundColor = isScriptValid ? OvUI::Types::Color{0.7f, 0.5f, 0.f}
        --                                                        : OvUI::Types::Color{0.1f, 0.1f, 0.1f};
    end

    self.m_scriptSelectorWidget = self.m_inspectorHeader:CreateWidget(InputText, "?")
    self.m_scriptSelectorWidget.lineBreak = false

    -- TODO ddTarget
    --auto &ddTarget =
    --        m_scriptSelectorWidget->AddPlugin < OvUI::Plugins::DDTarget < std::pair < std::string, Layout::Group
    --*>>>("File");
    --ddTarget.DataReceivedEvent += [updateAddScriptButton, this](std::pair<std::string, Layout::Group *> data) {
    --    m_scriptSelectorWidget->content = EDITOR_EXEC(GetScriptPath(data.first));
    --    updateAddScriptButton(m_scriptSelectorWidget->content);
    --};

    local addScriptButton = self.m_inspectorHeader:CreateWidget(Button, "Add Script", Vector2(100, 0))
    addScriptButton.idleBackgroundColor = RGBA(0.7, 0.5, 0)
    addScriptButton.textColor = RGBA.White

    self.m_scriptSelectorWidget.ContentChangedEvent:AddEventHandler(updateAddScriptButton)

    addScriptButton.ClickedEvent:AddEventHandler(function()
        --    const std::string realScriptPath =
        --            EDITOR_CONTEXT(projectScriptsPath) + m_scriptSelectorWidget->content + ".lua";
        --
        --    if (std::filesystem::exists(realScriptPath)) {
        --        GetTargetEntity()->AddBehaviour(m_scriptSelectorWidget->content);
        --        updateAddScriptButton(m_scriptSelectorWidget->content);
        --    }
    end)

    self.m_inspectorHeader:CreateWidget(Separator)
    --    m_destroyedListener = OvCore::ECS::Entity::DestroyedEvent += [this](OvCore::ECS::Entity &destroyed) {
    --        if (&destroyed == m_targetEntity)
    --            UnFocus();
    --    };
end

function Inspector:FocusEntity(target)
    print("Focus Entity", target.name)
    if self.m_targetEntity then
        self:UnFocus()
    end
    self.m_targetEntity = target
    require("table")
    do
        -- draw transform
        local header = self.m_entityInfo:CreateWidget(Group, "Transform")
        local columns = header:CreateWidget(Columns, 2)
        columns.widths[1] = 200
        TheEditorDrawer:DrawVec3(columns, "Position", function()
            local position = self.m_targetEntity.components.transform.position
            return { position.x, position.y, position.z }
        end, function(value)
            self.m_targetEntity.components.transform.position = Vector3(value[1], value[2], value[3])
        end)
        TheEditorDrawer:DrawVec3(columns, "Rotation", function()
            local rotation = self.m_targetEntity.components.transform.rotation
            return { rotation.x, rotation.y, rotation.z }
        end, function(value)

        end)
        TheEditorDrawer:DrawVec3(columns, "Scale", function()
            local scale = self.m_targetEntity.components.transform.scale
            return { scale.x, scale.y, scale.z }
        end, function(value)
            self.m_targetEntity.components.transform.scale = Vector3(value[1], value[2], value[3])
        end)
    end

    self.m_inspectorHeader.enabled = true
end

function Inspector:UnFocus()
    if self.m_targetEntity then
        self.m_inspectorHeader.enabled = false
        self.m_entityInfo:Clear()
        self.m_targetEntity = nil
    end
end

--    void SoftUnFocus();
--
--    Entity *GetTargetEntity() const;
--
--    void CreateEntityInspector(OvCore::ECS::Entity &target);
--
--    void DrawComponent(AComponent &component);
--
--    void DrawBehaviour(Behaviour &behaviour);
--
--    void Refresh();

return Inspector