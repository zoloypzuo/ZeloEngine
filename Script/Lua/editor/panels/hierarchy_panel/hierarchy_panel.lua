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
local MenuItem = require("ui.widgets.menu_item")
local MenuList = require("ui.widgets.menu_list")
local DDTarget = require("ui.plugins.ddtarget")
local DDSource = require("ui.plugins.ddsource")

local HierarchyContextualMenu = require("editor.panels.hierarchy_panel.hierarchy_contextual_menu")

-- static
local s_founds = {}  -- list[TreeNode]
local s_nodesToCollapse = {}  -- list[TreeNode]

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

    self:SetSize({ 1000, 580 });
    self:SetPosition({ 0., 0 });

    local processor = EventProcessor()
    self.EntitySelectedEvent = EventWrapper(processor, "EntitySelectedEvent")
    self.EntityUnselectedEvent = EventWrapper(processor, "EntityUnselectedEvent")
    self.m_sceneRoot = nil
    self.m_widgetEntityLink = {}  -- Entity => TreeNode

    self:_SearchBar()
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
        self:_OnAddEntity(entity, name)
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

function HierarchyPanel:Clear()
    TheEditorActions:UnselectEntity()
    self.m_sceneRoot:RemoveAllWidgets()
    self.m_widgetEntityLink = {}
end

function HierarchyPanel:_OnAddEntity(entity, name)
    local textSelectable = self.m_sceneRoot:CreateWidget(TreeNode, entity.name, true)
    textSelectable.leaf = true
    textSelectable:Open()
    textSelectable:AddPlugin(HierarchyContextualMenu, entity, textSelectable)

    -- TODO implement drag and drop
    global("IMGUI_SUPPORT_DD")
    IMGUI_SUPPORT_DD = false
    if IMGUI_SUPPORT_DD then
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
    end

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