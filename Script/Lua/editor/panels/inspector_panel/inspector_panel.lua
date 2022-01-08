-- inspector_panel
-- created on 2021/8/25
-- author @zoloypzuo

-- widgets
local PanelWindow = require("ui.panel_window")
local Button = require("ui.widgets.button")
local InputText = require("ui.widgets.input_text")
local Separator = require("ui.widgets.separator")
local Columns = require("ui.layouts.column")
local Group = require("ui.layouts.group")
local GroupCollapsable = require("ui.layouts.group_collapsable")
local ComboBox = require("ui.widgets.combobox")

local TheEditorDrawer = require("editor.editor_drawer")

local EEngineComponents = {
    {
        name = "Camera"; -- display name
        ctype = "PERSPECTIVE_CAMERA"; -- C++ Component getType()
        add_fn = "AddCamera"  -- addComponent function name
    };
    {
        name = "FreeLook";
        ctype = "FREE_LOOK";
        add_fn = "AddFreeLook"
    };
    {
        name = "FreeMove";
        ctype = "FREE_MOVE";
        add_fn = "AddFreeMove"
    };
    {
        name = "Light";
        ctype = "LIGHT";
        add_fn = "AddLight"
    };
    {
        name = "MeshRenderer";
        ctype = "MESH_RENDERER";
        add_fn = "AddMeshRenderer"
    };
}

local EComponent = {}
local EAddComponent = {}
for _, value in ipairs(EEngineComponents) do
    EComponent[string.lower(value.ctype)] = value.name
end

for _, value in ipairs(EEngineComponents) do
    EAddComponent[string.lower(value.ctype)] = value.add_fn
end

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
    self.m_componentSelectorWidget.lineBreak = false

    local addComponentButton = self.m_inspectorHeader:CreateWidget(Button, "Add Component", Vector2(100, 0))
    addComponentButton.idleBackgroundColor = RGBA(0.7, 0.5, 0.);
    addComponentButton.textColor = RGBA.White
    addComponentButton.ClickedEvent:AddEventHandler(function()
        local choice = self.m_componentSelectorWidget.currentChoice
        print("addComponentButton", choice)
        local entity = self.m_targetEntity.entity
        local add_fn = EAddComponent[choice]
        entity[add_fn](entity)
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
    self:DrawTransform()

    for k, v in pairs(self.m_targetEntity.components) do
        self:DrawComponent(k, v)
    end

    self.m_inspectorHeader.enabled = true
end

function Inspector:DrawTransform()
    local header = self.m_entityInfo:CreateWidget(Group, "Transform")
    local columns = header:CreateWidget(Columns, 2)
    columns.widths[1] = 200

    local transform = self.m_targetEntity.components.transform
    TheEditorDrawer:DrawVec3Direct(columns, "Position", transform, "position")
    TheEditorDrawer:DrawVec3Direct(columns, "Rotation", transform, "rotation")
    TheEditorDrawer:DrawVec3Direct(columns, "Scale", transform, "scale")
end

function Inspector:DrawComponent(name, component)
    if name == "transform" then
        -- ignore transform, transform is always drawed first
        return
    end
    local header = self.m_entityInfo:CreateWidget(GroupCollapsable, EComponent[name])
    local columns = header:CreateWidget(Columns, 2)
    columns.widths[1] = 200
    local fn_name = EComponent[name]
    if not fn_name then
        return
    end
    local fn = self["Draw" .. fn_name]
    if fn then
        fn(self, component, columns)
    end
end

function Inspector:DrawMeshRenderer(component, parent)
    -- TODO DrawMeshRenderer
end

function Inspector:DrawLight(component, parent)
    local header = self.m_entityInfo:CreateWidget(Group, "Light")
    local columns = header:CreateWidget(Columns, 2)
    columns.widths[1] = 200

    local light = self.m_targetEntity.components.light
    local lightTypeWidget = TheEditorDrawer:DrawEnum(columns, "Type", ELightType, function()
        return light.Type
    end, function(value)
        light.Type = value
    end)

    -- light base, color and intensity
    TheEditorDrawer:DrawColor(columns, "Color", false, function()
        local color = light.Color
        return { color.x, color.y, color.z }
    end, function(value)
        light.Color = Vector3(value[1], value[2], value[3])
    end)

    TheEditorDrawer:DrawNumber(columns, "Intensity", function()
        return light.Intensity
    end, function(value)
        light.Intensity = value
    end)

    local function drawPropByType()
        columns.lightFPropGroup = columns:CreateWidget(Columns, 2)
        columns.widths[1] = 200

        -- Attenuation = { "Constant", "Linear", "Quadratic" }
        -- local allFprops = {"Constant", "Linear", "Quadratic", "Cutoff", "OuterCutoff"}

        local fpropsByType = {
            [ELightType.POINT] = { "Constant", "Linear", "Quadratic" },
            [ELightType.DIRECTIONAL] = {},
            [ELightType.SPOT] = { "Constant", "Linear", "Quadratic", "Cutoff", "OuterCutoff" },
            [ELightType.AMBIENT_BOX] = { },
            [ELightType.AMBIENT_SPHERE] = { "Radius" }
        }

        for _, fprop in ipairs(fpropsByType[light.Type]) do
            local widget = TheEditorDrawer:DrawNumber(columns.lightFPropGroup, fprop, function()
                return light[fprop]
            end, function(value)
                light[fprop] = value
            end)
        end

        if light.Type == ELightType.AMBIENT_BOX then
            TheEditorDrawer:DrawVec3(columns.lightFPropGroup, "Size", function()
                local size = light.Size
                return { size.x, size.y, size.z }
            end, function(value)
                light.Size = Vector3(value[1], value[2], value[3])
            end)
        end
    end

    lightTypeWidget.ValueChangedEvent:AddEventHandler(function(value)
        columns:RemoveWidget(columns.lightFPropGroup)
        drawPropByType()
    end)

    drawPropByType()
end

function Inspector:UnFocus()
    if self.m_targetEntity then
        self.m_inspectorHeader.enabled = false
        self.m_entityInfo:Clear()
        self.m_targetEntity = nil
    end
end

return Inspector