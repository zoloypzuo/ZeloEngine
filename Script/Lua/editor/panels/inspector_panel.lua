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

return Inspector