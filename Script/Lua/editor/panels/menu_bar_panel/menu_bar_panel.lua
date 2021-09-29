-- menu_bar_panel
-- created on 2021/9/29
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

local PanelMenuBar = require("ui.panel_menu_bar")

local MenuBarPanel = Class(PanelMenuBar, function(self)
    PanelMenuBar._ctor(self)
    self.m_panels = {}
    self.m_windowMenu = nul

    self:CreateFileMenu();
    self:CreateBuildMenu();
    self:CreateWindowMenu();
    self:CreateActorsMenu();
    self:CreateResourcesMenu();
    self:CreateSettingsMenu();
    self:CreateLayoutMenu();
    self:CreateHelpMenu();
end)

function MenuBarPanel:CreateFileMenu()
    local fileMenu = self:CreateWidget(MenuList, "File")
    fileMenu:CreateWidget(MenuItem, "New Scene", "CTRL + N")
    fileMenu:CreateWidget(MenuItem, "Save Scene", "CTRL + S")
    fileMenu:CreateWidget(MenuItem, "Save Scene As ...", "CTRL + SHIFT + S")
    fileMenu:CreateWidget(MenuItem, "Exit", "ALT + F4")
end

function MenuBarPanel:CreateBuildMenu()
end

function MenuBarPanel:CreateWindowMenu()
end

function MenuBarPanel:CreateActorsMenu()
end

function MenuBarPanel:CreateResourcesMenu()
end

function MenuBarPanel:CreateSettingsMenu()
end

function MenuBarPanel:CreateLayoutMenu()
end

function MenuBarPanel:CreateHelpMenu()
end

return MenuBarPanel