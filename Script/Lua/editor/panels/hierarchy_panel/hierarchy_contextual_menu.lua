-- HierarchyContextualMenu
-- created on 2021/9/5
-- author @zoloypzuo
local ContextualMenu = require("ui.plugins.contextual_menu")
local MenuItem = require("ui.widgets.menu_item")
local MenuList = require("ui.widgets.menu_list")

local GenerateEntityCreationMenu = require("editor.panels.hierarchy_panel.entity_creation_menu").GenerateEntityCreationMenu

local HierarchyContextualMenu = Class(ContextualMenu, function(self, targetEntity, treeNode)
    ContextualMenu._ctor(self)

    self.target = targetEntity
    self.tree_node = treeNode

    if self.target then
        local focusButton = self:CreateWidget(MenuItem, "Focus")
        focusButton.ClickedEvent:AddEventHandler(function()
            TheEditorActions:MoveToTarget(self.m_target)
        end)
        local duplicateButton = self:CreateWidget(MenuItem, "Duplicate")
        duplicateButton.ClickedEvent:AddEventHandler(function()
            -- if failed, call imm instead
            TheEditorActions:DelayAction(1, "DuplicateEntity", m_target, nullptr, true)
        end)
        local deleteButton = self:CreateWidget(MenuItem, "Delete")
        deleteButton.ClickedEvent:AddEventHandler(function()
            TheEditorActions:DestroyEntity(self.m_target)
        end)
    end

    local createEntity = self:CreateWidget(MenuList, "Create...")
    GenerateEntityCreationMenu(createEntity, self.m_target, Bind(self.tree_node, "Open"))
end)

function HierarchyContextualMenu:Execute()
    if #self.widgets > 0 then
        ContextualMenu.Execute(self)
    end
end

return HierarchyContextualMenu