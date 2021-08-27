-- hierarchy
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
local DDTarget = require("ui.plugins.ddtarget")
local DDSource = require("ui.plugins.ddsource")

local GenerateEntityCreationMenu = require("editor.panels.hierarchy_panel.entity_creation_menu")

-- static
local s_founds = {}  -- list[TreeNode]
local s_nodesToCollapse = {}  -- list[TreeNode]

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
    --GenerateEntityCreationMenu(createEntity, self.m_target, self.m_treeNode.Open) TODO
end)

function HierarchyContextualMenu:Execute()
    if #self.widgets > 0 then
        ContextualMenu.Execute(self)
    end
end

local function _Match(pattern, s)
    return pattern == s
end

local function _ExpandTreeNodeAndEnable(toExpand, root)
    -- TreeNode, TreeNode
    if not toExpand:IsOpened() then
        toExpand:Open()
        s_nodesToCollapse[#s_nodesToCollapse + 1] = toExpand
    end
    toExpand.enabled = true
    if toExpand ~= root and toExpand:HasParent() then
        _ExpandTreeNodeAndEnable(toExpand:GetParent(), root)
    end
end

local HierarchyPanel = Class(PanelWindow, function(self, title, opened, panelSetting)
    PanelWindow._ctor(self, title, opened, panelSetting)
    local processor = EventProcessor()
    self.EntitySelectedEvent = EventWrapper(processor, "EntitySelectedEvent")
    self.EntityUnselectedEvent = EventWrapper(processor, "EntityUnselectedEvent")
    self.m_sceneRoot = nil
    self.m_widgetEntityLink = {}  -- Entity => TreeNode

    --self:_SearchBar() TODO
    self:_SceneGraph()
    -- TODO EDITOR_EVENT
    --    EDITOR_EVENT(EntityUnselectedEvent) += std::bind(&Hierarchy::UnselectEntitysWidgets, this);
    --    EDITOR_CONTEXT(sceneManager).SceneUnloadEvent += std::bind(&Hierarchy::Clear, this);
    --    Entity::CreatedEvent += std::bind(&Hierarchy::AddEntityByInstance, this, std::placeholders::_1);
    --    Entity::DestroyedEvent += std::bind(&Hierarchy::DeleteEntityByInstance, this, std::placeholders::_1);
    --    EDITOR_EVENT(EntitySelectedEvent) += std::bind(&Hierarchy::SelectEntityByInstance, this, std::placeholders::_1);
    --    Entity::AttachEvent += std::bind(&Hierarchy::AttachEntityToParent, this, std::placeholders::_1);
    --    Entity::DettachEvent += std::bind(&Hierarchy::DetachFromParent, this, std::placeholders::_1);
    MainFunctionEvent:AddEventHandler("SpawnPrefab", function(entity, name)
        -- TODO listen to entity creation
        local textSelectable = self.m_sceneRoot:CreateWidget(TreeNode, name .. entity.GUID, true)
        textSelectable.leaf = true
        textSelectable:Open()
        textSelectable:AddPlugin(HierarchyContextualMenu, entity, textSelectable)

        -- Entity, TreeNode
        textSelectable:AddPlugin(DDSource, "Entity", "Attach To...", { entity, textSelectable })
        local ddtarget = textSelectable:AddPlugin(DDTarget, "Entity")
        ddtarget.DataReceivedEvent:AddEventHandler(function(_entity, _textSelectable)
            print("DDTarget DataReceivedEvent", _entity.GUID)
            if _textSelectable:HasParent() then
                local parent = _textSelectable:GetParent()
                if parent then
                    parent:RemoveWidget(_textSelectable)
                end
                textSelectable:AddWidget(_textSelectable)
                -- TODO entity在树上的移动接口
                --	p_element.first->SetParent(p_actor);
            end
        end)

        textSelectable.getter = function()
            return name .. entity.GUID
        end

        self.m_widgetEntityLink[entity] = textSelectable

        textSelectable.ClickedEvent:AddEventHandler(function()
            TheEditorActions:SelectEntity(entity)
        end)

        textSelectable.DoubleClickedEvent:AddEventHandler(function()
            TheEditorActions:MoveToTarget(entity)
        end)
    end)
end)

function HierarchyPanel:_SearchBar()
    local searchBar = self:CreateWidget(InputText)
    searchBar.ContentChangedEvent:AddEventHandler(function(content)
        if content == "" then
            -- if pattern is "", do cleanup
            for _, node in pairs(self.m_widgetEntityLink) do
                node.enabled = true
            end
            for _, node in ipairs(s_nodesToCollapse) do
                node:Close()
            end
            s_nodesToCollapse = {}
            return
        end

        -- find pattern in tree
        s_founds = {}
        for _, node in pairs(self.m_widgetEntityLink) do
            if _Match(content, node.name) then
                s_founds[#s_founds + 1] = node
            end
            node.enabled = false
        end

        -- handle matched nodes
        for _, node in ipairs(s_founds) do
            node.enabled = true
            if node:HasParent() then
                _ExpandTreeNodeAndEnable(node:GetParent(), self.m_sceneRoot)
            end
        end
    end)
end

function HierarchyPanel:_SceneGraph()
    self.m_sceneRoot = self:CreateWidget(TreeNode, "Root", true)
    self.m_sceneRoot:Open()
    -- TODO AddPlugin DDTarget
    --self.m_sceneRoot:AddPlugin()
    --    m_sceneRoot->AddPlugin < OvUI::Plugins::DDTarget < std::pair < Entity * ,
    --            OvUI::Widgets::Layout::TreeNode *>>>("Entity").DataReceivedEvent += [this](
    --            std::pair<Entity *, OvUI::Widgets::Layout::TreeNode *> element) {
    --        if (element.second->HasParent())
    --            element.second->GetParent()->UnconsiderWidget(*element.second);
    --
    --        m_sceneRoot->ConsiderWidget(*element.second);
    --
    --        element.first->DetachFromParent();
    --    };
    self.m_sceneRoot:AddPlugin(HierarchyContextualMenu, self.m_sceneRoot)
end

function HierarchyPanel:LoadScene()
end

function HierarchyPanel:Clear()
    TheEditorActions:UnselectEntity()
    self.m_sceneRoot:RemoveAllWidgets()
    self.m_widgetEntityLink = {}
end

function HierarchyPanel:SelectEntity(entity)
    print("HierarchyPanel:SelectEntity")
end


--    void UnselectEntitysWidgets();
--
--    void SelectEntityByInstance(Entity &entity);
--
--    void SelectEntityByWidget(OvUI::Widgets::Layout::TreeNode &widget);
--
--    void AttachEntityToParent(Entity &entity);
--
--    void DetachFromParent(Entity &entity);
--
--    void DeleteEntityByInstance(Entity &entity);

return HierarchyPanel