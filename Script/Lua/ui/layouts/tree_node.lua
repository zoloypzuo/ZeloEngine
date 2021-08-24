-- column
-- created on 2021/8/22
-- author @zoloypzuo
local AWidget = require("ui.widget")

local WidgetContainerMixin = require("ui.widget_container_mixin")
local TreeNode = Class(AWidget, function(self, parent, name, arrowClickToOpen)
    AWidget._ctor(self, parent)
    WidgetContainerMixin.included(self)

    self.name = name or ""
    self.arrowClickToOpen = arrowClickToOpen or false

    self.selected = false
    self.leaf = false

    self.processor = EventProcessor()
    self.ClickedEvent = EventWrapper("ClickedEvent")
    self.DoubleClickedEvent = EventWrapper("DoubleClickedEvent")
    self.OpenedEvent = EventWrapper("OpenedEvent")
    self.ClosedEvent = EventWrapper("ClosedEvent")

    self.m_shouldOpen = false;
    self.m_shouldClose = false;
    self.opened = false;

    self.m_autoExecutePlugins = false

end):include(WidgetContainerMixin)

function TreeNode:_UpdateImpl()
    if self.m_shouldOpen then
        ImGui.SetNextTreeNodeOpen(true)
        self.m_shouldOpen = false
    elseif self.m_shouldClose then
        ImGui.SetNextTreeNodeOpen(false)
        self.m_shouldClose = false;
    end
    local flags = ImGuiTreeNodeFlags.None
    if self.m_arrowClickToOpen then
        flags = bit.bor(flags, ImGuiTreeNodeFlags.OpenOnArrow)
    end
    if self.selected then
        flags = bit.bor(flags, ImGuiTreeNodeFlags.Selected)
    end
    if self.leaf then
        flags = bit.bor(flags, ImGuiTreeNodeFlags.Leaf)
    end
    opened = ImGui.TreeNodeEx(self.name, flags)

    local mx, my = ImGui.GetMousePos()
    local ix, iy = ImGui.GetItemRectMin()
    if ImGui.IsItemClicked and (mx - ix) > ImGui.GetTreeNodeToLabelSpacing() then
        self.ClickedEvent:HandleEvent()

        if trueImGui.IsMouseDoubleClicked(0) then
            self.DoubleClickedEvent:HandleEvent()
        end
    end

    if opened then
        if not self.opened then
            self.OpenedEvent:HandleEvent()
        end
        self.opened = true

        --self:ExecutePlugins() TODO
        self:UpdateWidgets()

        ImGui.TreePop()
    else
        if self.opened then
            self.ClosedEvent:HandleEvent()
        end
        self.opened = false

        --self:ExecutePlugins() TODO
    end
end

function TreeNode:Open()
    self.m_shouldOpen = true;
    self.m_shouldClose = false;
end

function TreeNode:Close()
    self.m_shouldClose = true;
    self.m_shouldOpen = false;
end

return TreeNode