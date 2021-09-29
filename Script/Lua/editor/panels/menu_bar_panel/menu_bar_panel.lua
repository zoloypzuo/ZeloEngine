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
    local buildMenu = self:CreateWidget(MenuList, "Build");
    buildMenu:CreateWidget(MenuItem, "Build game")--.ClickedEvent += EDITOR_BIND(Build, false, false);
    buildMenu:CreateWidget(MenuItem, "Build game and run")--.ClickedEvent += EDITOR_BIND(Build, true, false);
    buildMenu:CreateWidget(Separator);
    buildMenu:CreateWidget(MenuItem, "Temporary build")--.ClickedEvent += EDITOR_BIND(Build, true, true);
end

function MenuBarPanel:CreateWindowMenu()
end

function MenuBarPanel:CreateActorsMenu()
end

function MenuBarPanel:CreateResourcesMenu()
    local resourcesMenu = self:CreateWidget(MenuList, "Resources");
    resourcesMenu:CreateWidget(MenuItem, "Compile shaders")--.ClickedEvent += EDITOR_BIND(CompileShaders);
    resourcesMenu:CreateWidget(MenuItem, "Save materials")--.ClickedEvent += EDITOR_BIND(SaveMaterials);
end

function MenuBarPanel:CreateSettingsMenu()
end

function MenuBarPanel:CreateLayoutMenu()
end

function MenuBarPanel:CreateHelpMenu()
    local helpMenu = self:CreateWidget(MenuList, "Help");
    helpMenu:CreateWidget(MenuItem, "GitHub")--:ClickedEvent += [] {OvTools::Utils::SystemCalls::OpenURL("https://github:com/adriengivry/Overload"); };
    helpMenu:CreateWidget(MenuItem, "Tutorials")--:ClickedEvent += [] {OvTools::Utils::SystemCalls::OpenURL("https://github:com/adriengivry/Overload/wiki/Tutorials"); };
    helpMenu:CreateWidget(MenuItem, "Scripting API")--:ClickedEvent += [] {OvTools::Utils::SystemCalls::OpenURL("https://github:com/adriengivry/Overload/wiki/Scripting-API"); };
    helpMenu:CreateWidget(Separator);
    helpMenu:CreateWidget(MenuItem, "Bug Report")--:ClickedEvent += [] {OvTools::Utils::SystemCalls::OpenURL("https://github:com/adriengivry/Overload/issues/new?assignees=&labels=Bug&template=bug_report:md&title="); };
    helpMenu:CreateWidget(MenuItem, "Feature Request")--:ClickedEvent += [] {OvTools::Utils::SystemCalls::OpenURL("https://github:com/adriengivry/Overload/issues/new?assignees=&labels=Feature&template=feature_request:md&title="); };
    helpMenu:CreateWidget(Separator);
    helpMenu:CreateWidget(Text, "Version: v0.4");
end

return MenuBarPanel