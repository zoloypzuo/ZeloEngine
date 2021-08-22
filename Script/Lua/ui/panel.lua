-- panel
-- created on 2021/8/21
-- author @zoloypzuo
require("common.table_util")

local __PANEL_ID_INCREMENT = 0
local function GenPanelID()
    __PANEL_ID_INCREMENT = __PANEL_ID_INCREMENT + 1
    return __PANEL_ID_INCREMENT
end

local APanel = Class(function(self)
    -- Panel基类
    -- 成员变量：
    -- id       GUID
    -- enabled  使能
    -- widgets  控件表
    -- 成员函数：
    -- CreateWidget 创建控件
    self.id = "##" .. GenPanelID()
    self.enabled = true
    self.widgets = {}
end)

function APanel:Update()
    if self.enabled then
        self:_UpdateImpl()
    end
end

function APanel:_UpdateImpl()
    for _, widget in ipairs(self.widgets) do
        widget:Update()
    end
end

function APanel:CreateWidget(type_, ...)
    inst = type_(self, ...)
    self.widgets[#self.widgets + 1] = inst
    return inst
end

function APanel:RemoveWidget(widget)
    RemoveByValue(self.widgets, widget)
end

function APanel:Clear()
    self.widgets = {}
end

return { APanel = APanel }