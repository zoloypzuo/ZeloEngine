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
local GenerateActorCreationMenu = require("editor.panels.entity_creation_menu")

local founds = {}  -- list[TreeNode]
local nodesToCollapse = {}  -- list[TreeNode]

local HierarchyContextualMenu = Class(ContextualMenu, function(self, targetEntity, treeNode, panelMenu)
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
            --TheEditorActions:DelayAction(EDITOR_BIND(DuplicateActor, std::ref(*m_target), nullptr, true), 0)); TODO
        end)
        local deleteButton = self:CreateWidget(MenuItem("Delete"))
        deleteButton.ClickedEvent:AddEventHandler(function()
            TheEditorActions:DestroyActor(self.m_target)
        end)
    end

    local createActor = self:CreateWidget(MenuList, "Create...")
    GenerateActorCreationMenu(createActor, self.m_target, self.m_treeNode.Open)
end)

function HierarchyContextualMenu:Execute()
    if #self.widgets > 0 then
        HierarchyContextualMenu.Execute(self)
    end
end

local HierarchyPanel = Class(PanelWindow, function(self, title, opened, panelSetting)
    PanelWindow._ctor(self, title, opened, panelSetting)
    self.ActorSelectedEvent = nil -- TODO
    self.ActorUnselectedEvent = nil -- TODO
    self.m_sceneRoot = TreeNode()
    self.m_widgetActorLink = {}  -- Actor => TreeNode

    self:_SearchBar()
    self:_SceneGraph()
    -- TODO EDITOR_EVENT
    --    EDITOR_EVENT(ActorUnselectedEvent) += std::bind(&Hierarchy::UnselectActorsWidgets, this);
    --    EDITOR_CONTEXT(sceneManager).SceneUnloadEvent += std::bind(&Hierarchy::Clear, this);
    --    Actor::CreatedEvent += std::bind(&Hierarchy::AddActorByInstance, this, std::placeholders::_1);
    --    Actor::DestroyedEvent += std::bind(&Hierarchy::DeleteActorByInstance, this, std::placeholders::_1);
    --    EDITOR_EVENT(ActorSelectedEvent) += std::bind(&Hierarchy::SelectActorByInstance, this, std::placeholders::_1);
    --    Actor::AttachEvent += std::bind(&Hierarchy::AttachActorToParent, this, std::placeholders::_1);
    --    Actor::DettachEvent += std::bind(&Hierarchy::DetachFromParent, this, std::placeholders::_1);
end)

function HierarchyPanel:_SearchBar()
    local searchBar = self:CreateWidget(InputText)
    searchBar.ContentChangedEvent:AddEventHandler(function(content)
        founds = {}
        -- TODO lower content
        --        founds.clear();
        --        auto content = content;
        --        std::transform(content.begin(), content.end(), content.begin(), ::tolower);
        --
        --        for (auto&[actor, item] : m_widgetActorLink) {
        --            if (!content.empty()) {
        --                auto itemName = item->name;
        --                std::transform(itemName.begin(), itemName.end(), itemName.begin(), ::tolower);
        --
        --                if (itemName.find(content) != std::string::npos) {
        --                    founds.push_back(item);
        --                }
        --
        --                item->enabled = false;
        --            } else {
        --                item->enabled = true;
        --            }
        --        }
        --
        --        for (auto node : founds) {
        --            node->enabled = true;
        --
        --            if (node->HasParent()) {
        --                ExpandTreeNodeAndEnable(*static_cast<OvUI::Widgets::Layout::TreeNode *>(node->GetParent()),
        --                                        m_sceneRoot);
        --            }
        --        }
        --
        --        if (content.empty()) {
        --            for (auto node : nodesToCollapse) {
        --                node->Close();
        --            }
        --
        --            nodesToCollapse.clear();
        --        }
    end)
end

function HierarchyPanel:_SceneGraph()
    self.m_sceneRoot = self:CreateWidget(TreeNode, "Root", true)
    self.m_sceneRoot:Open()
    -- TODO AddPlugin
    self.m_sceneRoot:AddPlugin()
    --    m_sceneRoot->AddPlugin < OvUI::Plugins::DDTarget < std::pair < Actor * ,
    --            OvUI::Widgets::Layout::TreeNode *>>>("Actor").DataReceivedEvent += [this](
    --            std::pair<Actor *, OvUI::Widgets::Layout::TreeNode *> element) {
    --        if (element.second->HasParent())
    --            element.second->GetParent()->UnconsiderWidget(*element.second);
    --
    --        m_sceneRoot->ConsiderWidget(*element.second);
    --
    --        element.first->DetachFromParent();
    --    };
    --    m_sceneRoot->AddPlugin<HierarchyContextualMenu>(nullptr, *m_sceneRoot);
end

function HierarchyPanel:Clear()
    TheEditorActions:UnselectActor()
    self.m_sceneRoot:RemoveAllWidgets()
    self.m_widgetActorLink = {}
end

--    void UnselectActorsWidgets();
--
--    void SelectActorByInstance(Actor &actor);
--
--    void SelectActorByWidget(OvUI::Widgets::Layout::TreeNode &widget);
--
--    void AttachActorToParent(Actor &actor);
--
--    void DetachFromParent(Actor &actor);
--
--    void DeleteActorByInstance(Actor &actor);
--
--    void AddActorByInstance(Actor &actor);