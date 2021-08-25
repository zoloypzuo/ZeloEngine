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
    self.m_inspectorHeader.enabled = false
    self.m_actorInfo = self:CreateWidget(Group)

    local headerColumns = self.m_inspectorHeader:CreateWidget(Columns, 2)
    
    --    auto &headerColumns = m_inspectorHeader->CreateWidget < OvUI::Widgets::Layout::Columns < 2 >> ();
    --
    --    auto nameGatherer = [this] { return m_targetActor ? m_targetActor->GetName() : "%undef%"; };
    --    auto nameProvider = [this](const std::string &newName) { if (m_targetActor) m_targetActor->SetName(newName); };
    --    DrawString(headerColumns, "Name", nameGatherer, nameProvider);
    --
    --    auto tagGatherer = [this] { return m_targetActor ? m_targetActor->GetTag() : "%undef%"; };
    --    auto tagProvider = [this](const std::string &newName) { if (m_targetActor) m_targetActor->SetTag(newName); };
    --    DrawString(headerColumns, "Tag", tagGatherer, tagProvider);
    --
    --    auto activeGatherer = [this] { return m_targetActor ? m_targetActor->IsSelfActive() : false; };
    --    auto activeProvider = [this](bool active) { if (m_targetActor) m_targetActor->SetActive(active); };
    --    DrawBoolean(headerColumns, "Active", activeGatherer, activeProvider);
end)