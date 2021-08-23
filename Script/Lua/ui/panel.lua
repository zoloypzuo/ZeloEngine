-- panel
-- created on 2021/8/21
-- author @zoloypzuo
require("common.table_util")
local WidgetContainerMixin = require("ui.widget_container_mixin")

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
end):include(WidgetContainerMixin)

function APanel:Update()
    if self.enabled then
        self:_UpdateImpl()
    end
end

function APanel:_UpdateImpl()
    self:UpdateWidgets()
end

return APanel