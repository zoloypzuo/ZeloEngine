-- project_setting_panel
-- created on 2021/9/30
-- author @zoloypzuo
local PanelWindow = require("ui.panel_window")
local Button = require("ui.widgets.button")
local Separator = require("ui.widgets.separator")
local Columns = require("ui.layouts.column")
local GroupCollapsable = require("ui.layouts.group_collapsable")
local Group = require("ui.layouts.group")

local TheEditorDrawer = require("editor.editor_drawer")

local MaterialEditorPanel = Class(PanelWindow, function(self, title, opened, panelSetting)
    PanelWindow._ctor(self, title, opened, panelSetting)

    self.m_target = nil
    self.m_shader = nil

    self.m_targetMaterialText = nil
    self.m_shaderText = nil

    self.m_materialDroppedEvent = nil
    self.m_shaderDroppedEvent = nil

    self.m_settings = nil
    self.m_materialSettings = nil
    self.m_shaderSettings = nil

    self.m_shaderSettingsColumns = nil
    self.m_materialSettingsColumns = nil

    self:_CreateHeaderButtons()
    self:CreateWidget(Separator)
    self:_CreateMaterialSelector()
    self.m_settings = self:CreateWidget(Group)
    self:_CreateShaderSelector()
    self:_CreateMaterialSettings()
    self:_CreateShaderSettings()

    self.m_settings.enabled = false
    self.m_shaderSettings.enabled = false

    -- TODO event
    -- m_materialDroppedEvent += std::bind(&MaterialEditor::OnMaterialDropped, this);
    -- m_shaderDroppedEvent += std::bind(&MaterialEditor::OnShaderDropped, this);
end)

-- public

function MaterialEditorPanel:Refresh()
    if (self.m_target) then
        self:SetTarget(m_target)
    end
end

function MaterialEditorPanel:SetTarget(newTarget)
    self.m_target = newTarget
    self.m_targetMaterialText.content = newTarget.path
    self:OnMaterialDropped()
end

function MaterialEditorPanel:GetTarget()
    return m_target
end

function MaterialEditorPanel:ClearTarget()
    self.m_target = nil
    self.m_targetMaterialText.content = "Empty"
    self:OnMaterialDropped()
end

function MaterialEditorPanel:Reset()
    if self.m_target and self.m_shader then
        self.m_target:SetShader(nil)
        self:OnShaderDropped()
    end
end

-- private
function MaterialEditorPanel:OnMaterialDropped()
    self.m_settings.enabled = self.m_target;
    if (self.m_settings.enabled) then
        self:GenerateMaterialSettingsContent();
        self.m_shaderText.content = self.m_target:GetShader() and self.m_target:GetShader().path or "Empty";
        self.m_shader = self.m_target:GetShader();
    else
        self.m_materialSettingsColumns:Clear();
    end

    self.m_shaderSettings.enabled = false;
    self.m_shaderSettingsColumns:Clear();

    if (self.m_target and self.m_target:GetShader()) then
        self:OnShaderDropped();
    end
end

function MaterialEditorPanel:OnShaderDropped()
    self.m_shaderSettings.enabled = self.m_shader;
    if (self.m_shader ~= self.m_target:GetShader()) then
        self.m_target:SetShader(self.m_shader);
    end

    if (self.m_shaderSettings.enabled) then
        self:GenerateShaderSettingsContent();
    else
        self.m_shaderSettingsColumns:Clear();
    end
end

function MaterialEditorPanel:_CreateHeaderButtons()
    local saveButton = self:CreateWidget(Button, "Save to file");
    saveButton.idleBackgroundColor = RGBA(0.0, 0.5, 0.0);
    saveButton.ClickedEvent:AddEventHandler(function()
        if (self.m_target) then
            print("TODO")
            -- OvCore::Resources::Loaders::MaterialLoader::Save(*m_target, EDITOR_EXEC(GetRealPath(m_target->path)));
        end
    end)
    saveButton.lineBreak = false;

    local reloadButton = self:CreateWidget(Button, "Reload from file");
    reloadButton.idleBackgroundColor = RGBA(0.7, 0.5, 0.0);
    reloadButton.ClickedEvent:AddEventHandler(function()
        if (self.m_target) then
            print("TODO")
            -- OvCore::Resources::Loaders::MaterialLoader::Reload(*m_target, EDITOR_EXEC(GetRealPath(m_target->path)));
        end
        self:OnMaterialDropped();
    end)
    reloadButton.lineBreak = false;

    -- local previewButton = selfCreateWidget<Buttons::Button>("Preview");
    -- previewButton.idleBackgroundColor = { 0.7f, 0.5f, 0.0f };
    -- previewButton.ClickedEvent += std::bind(MaterialEditor::Preview, this);
    -- previewButton.lineBreak = false;

    local resetButton = self:CreateWidget(Button, "Reset to default");
    resetButton.idleBackgroundColor = RGBA(0.5, 0.0, 0.0);
    resetButton.ClickedEvent:AddEventHandler(Bind(self, "Reset"));
end

function MaterialEditorPanel:_CreateMaterialSelector()
    local columns = self:CreateWidget(Columns, 2)
    columns.widths[0] = 150
    self.m_targetMaterialText = TheEditorDrawer:DrawMaterial(columns, "Material", self.m_target, self.m_materialDroppedEvent)
end

function MaterialEditorPanel:_CreateShaderSelector()
    local columns = self:CreateWidget(Columns, 2)
    columns.widths[0] = 150
    -- self.m_shaderText = TheEditorDrawer:DrawShader(columns, "Shader", self.m_shader, self.m_shaderDroppedEvent)
end

function MaterialEditorPanel:_CreateMaterialSettings()
    self.m_materialSettings = self.m_settings:CreateWidget(GroupCollapsable, "Material Settings");
    self.m_materialSettingsColumns = self.m_materialSettings:CreateWidget(Columns, 2)
    self.m_materialSettingsColumns.widths[0] = 150;
end

function MaterialEditorPanel:_CreateShaderSettings()
    self.m_shaderSettings = self.m_settings:CreateWidget(GroupCollapsable, "Shader Settings");
    self.m_shaderSettingsColumns = self.m_shaderSettings:CreateWidget(Columns, 2)
    self.m_shaderSettingsColumns.widths[0] = 150;
end

--void OvEditor::Panels::MaterialEditor::GenerateShaderSettingsContent() {
--    using namespace Zelo::Renderer::Resources;
--
--    self.m_shaderSettingsColumns.Clear();
--    std::multimap<int, std::pair<std::string, std::any *>> sortedUniformsData;
--
--    for (auto&[name, value] : self.m_target.GetUniformsData()) {
--        int orderID = 0;
--
--        auto uniformData = self.m_target.GetShader().GetUniformInfo(name);
--
--        if (uniformData) {
--            switch (uniformData.type) {
--                case UniformType::UNIFORM_SAMPLER_2D:
--                    orderID = 0;
--                    break;
--                case UniformType::UNIFORM_FLOAT_VEC4:
--                    orderID = 1;
--                    break; case UniformType::UNIFORM_FLOAT_VEC3:
--                    orderID = 2;
--                    break;
--                case UniformType::UNIFORM_FLOAT_VEC2:
--                    orderID = 3;
--                    break;
--                case UniformType::UNIFORM_FLOAT:
--                    orderID = 4;
--                    break;
--                case UniformType::UNIFORM_INT:
--                    orderID = 5;
--                    break;
--                case UniformType::UNIFORM_BOOL:
--                    orderID = 6;
--                    break;
--            }
--
--            sortedUniformsData.emplace(orderID, std::pair < std::string, std::any * > {name, &value});
--        }
--    }
--
--    for (auto&[order, info] : sortedUniformsData) {
--        auto uniformData = self.m_target.GetShader().GetUniformInfo(info.first);
--
--        if (uniformData) {
--            switch (uniformData.type) {
--                case UniformType::UNIFORM_BOOL:
--                    TheEditorDrawer:DrawBoolean(*self.m_shaderSettingsColumns, UniformFormat(info.first),
--                                           reinterpret_cast<bool &>(*info.second));
--                    break;
--                case UniformType::UNIFORM_INT:
--                    TheEditorDrawer:DrawScalar<int>(*self.m_shaderSettingsColumns, UniformFormat(info.first),
--                                               reinterpret_cast<int &>(*info.second));
--                    break;
--                case UniformType::UNIFORM_FLOAT:
--                    TheEditorDrawer:DrawScalar<float>(*self.m_shaderSettingsColumns, UniformFormat(info.first),
--                                                 reinterpret_cast<float &>(*info.second), 0.01f, TheEditorDrawer:_MIN_FLOAT,
--                                                 TheEditorDrawer:_MAX_FLOAT);
--                    break;
--                case UniformType::UNIFORM_FLOAT_VEC2:
--                    TheEditorDrawer:DrawVec2(*self.m_shaderSettingsColumns, UniformFormat(info.first),
--                                        reinterpret_cast<OvMaths::FVector2 &>(*info.second), 0.01f,
--                                        TheEditorDrawer:_MIN_FLOAT, TheEditorDrawer:_MAX_FLOAT);
--                    break;
--                case UniformType::UNIFORM_FLOAT_VEC3:
--                    DrawHybridVec3(*self.m_shaderSettingsColumns, UniformFormat(info.first),
--                                   reinterpret_cast<OvMaths::FVector3 &>(*info.second), 0.01f, TheEditorDrawer:_MIN_FLOAT,
--                                   TheEditorDrawer:_MAX_FLOAT);
--                    break;
--                case UniformType::UNIFORM_FLOAT_VEC4:
--                    DrawHybridVec4(*self.m_shaderSettingsColumns, UniformFormat(info.first),
--                                   reinterpret_cast<OvMaths::FVector4 &>(*info.second), 0.01f, TheEditorDrawer:_MIN_FLOAT,
--                                   TheEditorDrawer:_MAX_FLOAT);
--                    break;
--                case UniformType::UNIFORM_SAMPLER_2D:
--                    TheEditorDrawer:DrawTexture(*self.m_shaderSettingsColumns, UniformFormat(info.first),
--                                           reinterpret_cast<Texture *&>(*info.second));
--                    break;
--            }
--        }
--    }
--}
--
--void OvEditor::Panels::MaterialEditor::GenerateMaterialSettingsContent() {
--    self.m_materialSettingsColumns.Clear();
--    TheEditorDrawer:DrawBoolean(*self.m_materialSettingsColumns, "Blendable",
--                           std::bind(&OvCore::Resources::Material::IsBlendable, self.m_target),
--                           std::bind(&OvCore::Resources::Material::SetBlendable, self.m_target, std::placeholders::_1));
--    TheEditorDrawer:DrawBoolean(*self.m_materialSettingsColumns, "Back-face Culling",
--                           std::bind(&OvCore::Resources::Material::HasBackfaceCulling, self.m_target),
--                           std::bind(&OvCore::Resources::Material::SetBackfaceCulling, self.m_target,
--                                     std::placeholders::_1));
--    TheEditorDrawer:DrawBoolean(*self.m_materialSettingsColumns, "Front-face Culling",
--                           std::bind(&OvCore::Resources::Material::HasFrontfaceCulling, self.m_target),
--                           std::bind(&OvCore::Resources::Material::SetFrontfaceCulling, self.m_target,
--                                     std::placeholders::_1));
--    TheEditorDrawer:DrawBoolean(*self.m_materialSettingsColumns, "Depth Test",
--                           std::bind(&OvCore::Resources::Material::HasDepthTest, self.m_target),
--                           std::bind(&OvCore::Resources::Material::SetDepthTest, self.m_target, std::placeholders::_1));
--    TheEditorDrawer:DrawBoolean(*self.m_materialSettingsColumns, "Depth Writing",
--                           std::bind(&OvCore::Resources::Material::HasDepthWriting, self.m_target),
--                           std::bind(&OvCore::Resources::Material::SetDepthWriting, self.m_target, std::placeholders::_1));
--    TheEditorDrawer:DrawBoolean(*self.m_materialSettingsColumns, "Color Writing",
--                           std::bind(&OvCore::Resources::Material::HasColorWriting, self.m_target),
--                           std::bind(&OvCore::Resources::Material::SetColorWriting, self.m_target, std::placeholders::_1));
--    TheEditorDrawer:DrawScalar<int>(*self.m_materialSettingsColumns, "GPU Instances",
--                               std::bind(&OvCore::Resources::Material::GetGPUInstances, self.m_target),
--                               std::bind(&OvCore::Resources::Material::SetGPUInstances, self.m_target,
--                                         std::placeholders::_1), 1.0f, 0, 100000);
--}
function MaterialEditorPanel:GenerateShaderSettingsContent()
end

function MaterialEditorPanel:GenerateMaterialSettingsContent()
end

return MaterialEditorPanel