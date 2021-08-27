-- widget_container_mixin
-- created on 2021/8/23
-- author @zoloypzuo
local WidgetContainerMixin = Mixin(function(self)
    self.widgets = {}
end)

function WidgetContainerMixin:UpdateWidgets()
    for _, widget in ipairs(self.widgets) do
        widget:Update()
    end
end

function WidgetContainerMixin:CreateWidget(type_, ...)
    inst = type_(self, ...)
    self.widgets[#self.widgets + 1] = inst
    return inst
end

function WidgetContainerMixin:AddWidget(widget)
    self.widgets[#self.widgets + 1] = widget
    return widget
end

function WidgetContainerMixin:RemoveWidget(widget)
    RemoveByValue(self.widgets, widget)
end

function WidgetContainerMixin:Clear()
    self.widgets = {}
end

return WidgetContainerMixin