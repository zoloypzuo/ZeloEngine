-- menu_bar_panel
-- created on 2021/9/29
-- author @zoloypzuo
local Separator = require("ui.widgets.separator")
local Text = require("ui.widgets.text")
local MenuItem = require("ui.widgets.menu_item")
local MenuList = require("ui.widgets.menu_list")

local PanelMenuBar = require("ui.panel_menu_bar")

local MenuBarPanel = Class(PanelMenuBar, function(self)
    PanelMenuBar._ctor(self)
    self.m_panels = {}
    self.m_windowMenu = nil

    self:_CreateFileMenu();
    self:_CreateBuildMenu();
    self:_CreateWindowMenu();
    self:_CreateActorsMenu();
    self:_CreateResourcesMenu();
    self:_CreateSettingsMenu();
    self:_CreateLayoutMenu();
    self:_CreateHelpMenu();
end)

function MenuBarPanel:HandleShortcuts()
    -- TODO handle shortcut from input manager
end

function MenuBarPanel:RegisterPanel(name, panel)
    local menu_item = self.m_windowMenu:CreateWidget(MenuItem, name)
    menu_item.ValueChangedEvent:AddEventHandler(function()
        panel:SetOpened(true)
    end)

    self.panels[name] = { panel, menu_item }
end

function MenuBarPanel:_UpdateToggle()
    for _, v in pairs(self.m_panels) do
        local panel, menu_item = v
        menu_item.checked = panel.opened
    end
end

function MenuBarPanel:_ToggleAllPanels(value)
    for _, v in pairs(self.m_panels) do
        local panel, _ = v
        panel:SetOpened(value)
    end
end

function MenuBarPanel:_CreateFileMenu()
    local fileMenu = self:CreateWidget(MenuList, "File")
    fileMenu:CreateWidget(MenuItem, "New Scene", "CTRL + N")
    fileMenu:CreateWidget(MenuItem, "Save Scene", "CTRL + S")
    fileMenu:CreateWidget(MenuItem, "Save Scene As ...", "CTRL + SHIFT + S")
    fileMenu:CreateWidget(MenuItem, "Exit", "ALT + F4")
end

function MenuBarPanel:_CreateBuildMenu()
    local buildMenu = self:CreateWidget(MenuList, "Build");
    buildMenu:CreateWidget(MenuItem, "Build game")--.ClickedEvent += EDITOR_BIND(Build, false, false);
    buildMenu:CreateWidget(MenuItem, "Build game and run")--.ClickedEvent += EDITOR_BIND(Build, true, false);
    buildMenu:CreateWidget(Separator);
    buildMenu:CreateWidget(MenuItem, "Temporary build")--.ClickedEvent += EDITOR_BIND(Build, true, true);
end

function MenuBarPanel:_CreateWindowMenu()
    self.m_windowMenu = self:CreateWidget(MenuList, "Window")
    self.m_windowMenu:CreateWidget(MenuItem, "Close all")
        .ClickedEvent:AddEventHandler(function()
        self:_ToggleAllPanels(false)
    end)
    self.m_windowMenu:CreateWidget(MenuItem, "Open all")
        .ClickedEvent:AddEventHandler(function()
        self:_ToggleAllPanels(true)
    end)
    self.m_windowMenu:CreateWidget(Separator)

    self.m_windowMenu.ClickedEvent:AddEventHandler(Bind(self, self._UpdateToggle))

end

function MenuBarPanel:_CreateActorsMenu()
end

function MenuBarPanel:_CreateResourcesMenu()
    local resourcesMenu = self:CreateWidget(MenuList, "Resources");
    resourcesMenu:CreateWidget(MenuItem, "Compile shaders")--.ClickedEvent += EDITOR_BIND(CompileShaders);
    resourcesMenu:CreateWidget(MenuItem, "Save materials")--.ClickedEvent += EDITOR_BIND(SaveMaterials);
end

function MenuBarPanel:_CreateSettingsMenu()
end

function MenuBarPanel:_CreateLayoutMenu()
end

function MenuBarPanel:_CreateHelpMenu()
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