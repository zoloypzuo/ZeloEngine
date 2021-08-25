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

local HierarchyPanel = Class(PanelWindow, function(self, title, opened, panelSetting)
    PanelWindow._ctor(self, title, opened, panelSetting)
    self.ActorSelectedEvent = nil -- TODO
    self.ActorUnselectedEvent = nil -- TODO
    self.m_sceneRoot = TreeNode()
    self.m_widgetActorLink = {}  -- Actor => TreeNode

    self:_SearchBar()
    self:_SceneGraph()
    --    EDITOR_EVENT(ActorUnselectedEvent) += std::bind(&Hierarchy::UnselectActorsWidgets, this);
    --    EDITOR_CONTEXT(sceneManager).SceneUnloadEvent += std::bind(&Hierarchy::Clear, this);
    --    OvCore::ECS::Actor::CreatedEvent += std::bind(&Hierarchy::AddActorByInstance, this, std::placeholders::_1);
    --    OvCore::ECS::Actor::DestroyedEvent += std::bind(&Hierarchy::DeleteActorByInstance, this, std::placeholders::_1);
    --    EDITOR_EVENT(ActorSelectedEvent) += std::bind(&Hierarchy::SelectActorByInstance, this, std::placeholders::_1);
    --    OvCore::ECS::Actor::AttachEvent += std::bind(&Hierarchy::AttachActorToParent, this, std::placeholders::_1);
    --    OvCore::ECS::Actor::DettachEvent += std::bind(&Hierarchy::DetachFromParent, this, std::placeholders::_1);
end)

function HierarchyPanel:_SearchBar()
    --    auto &searchBar = CreateWidget<OvUI::Widgets::InputFields::InputText>();
    --    searchBar.ContentChangedEvent += [this](const std::string &content) {
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
    --    };
end

function HierarchyPanel:_SceneGraph()
    --    m_sceneRoot = &CreateWidget<OvUI::Widgets::Layout::TreeNode>("Root", true);
    --    static_cast<OvUI::Widgets::Layout::TreeNode *>(m_sceneRoot)->Open();
    --    m_sceneRoot->AddPlugin < OvUI::Plugins::DDTarget < std::pair < OvCore::ECS::Actor * ,
    --            OvUI::Widgets::Layout::TreeNode *>>>("Actor").DataReceivedEvent += [this](
    --            std::pair<OvCore::ECS::Actor *, OvUI::Widgets::Layout::TreeNode *> element) {
    --        if (element.second->HasParent())
    --            element.second->GetParent()->UnconsiderWidget(*element.second);
    --
    --        m_sceneRoot->ConsiderWidget(*element.second);
    --
    --        element.first->DetachFromParent();
    --    };
    --    m_sceneRoot->AddPlugin<HierarchyContextualMenu>(nullptr, *m_sceneRoot);
end

--    void Clear();
--
--    void UnselectActorsWidgets();
--
--    void SelectActorByInstance(OvCore::ECS::Actor &actor);
--
--    void SelectActorByWidget(OvUI::Widgets::Layout::TreeNode &widget);
--
--    void AttachActorToParent(OvCore::ECS::Actor &actor);
--
--    void DetachFromParent(OvCore::ECS::Actor &actor);
--
--    void DeleteActorByInstance(OvCore::ECS::Actor &actor);
--
--    void AddActorByInstance(OvCore::ECS::Actor &actor);