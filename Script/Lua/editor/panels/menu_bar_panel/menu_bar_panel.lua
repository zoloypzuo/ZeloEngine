local PanelMenuBar = require("ui.panel_menu_bar")
local Separator = require("ui.widgets.separator")
local Text = require("ui.widgets.text")
local MenuItem = require("ui.widgets.menu_item")
local MenuList = require("ui.widgets.menu_list")
local GenerateEntityCreationMenu = require("editor.panels.hierarchy_panel.entity_creation_menu")
        .GenerateEntityCreationMenu

local MenuBarPanel = Class(PanelMenuBar, function(self)
    PanelMenuBar._ctor(self)
    self.m_panels = {}
    self.m_windowMenu = nil

    self.m_metricsMenuItem = nil
    self.m_styleEditorMenuItem = nil
    self.m_userGuideMenuItem = nil

    --self:_CreateFileMenu();
    --self:_CreateBuildMenu();
    self:_CreateWindowMenu();
    --self:_CreateEntityMenu();
    --self:_CreateResourcesMenu();
    --self:_CreateSettingsMenu();
    --self:_CreateLayoutMenu();
    self:_CreateToolMenu();
    self:_CreateHelpMenu();
    self:_CreateSandboxMenu();
end)

function MenuBarPanel:_UpdateImpl()
    PanelMenuBar._UpdateImpl(self)

    local show_app_metrics = self.m_metricsMenuItem.checked
    local show_app_style_editor = self.m_styleEditorMenuItem.checked
    local show_user_guide = self.m_userGuideMenuItem.checked

    if show_app_metrics then
        ImGui.ShowMetricsWindow()
    end

    if show_app_style_editor then
        ImGui.Begin("Dear ImGui Style Editor");
        ImGui.ShowStyleEditor();
        ImGui.End();
    end

    if show_user_guide then
        ImGui.Begin("User Guide")
        ImGui.ShowUserGuide()
        ImGui.End()
    end
end

function MenuBarPanel:HandleShortcuts()

end

function MenuBarPanel:RegisterPanel(name, panel)
    local menu_item = self.m_windowMenu:CreateWidget(MenuItem, name, "", true, true)
    menu_item.ValueChangedEvent:AddEventHandler(function(value)
        panel:SetOpened(value)
    end)

    self.m_panels[name] = { panel, menu_item }
end

function MenuBarPanel:_UpdateToggle()
    if not self.m_panels then
        return
    end
    for _, v in pairs(self.m_panels) do
        local panel, menu_item = unpack(v)
        menu_item.checked = panel.opened
    end
end

function MenuBarPanel:_ToggleAllPanels(value)
    for _, v in pairs(self.m_panels) do
        local panel, _ = unpack(v)
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
    buildMenu:CreateWidget(MenuItem, "Build game")
    buildMenu:CreateWidget(MenuItem, "Build game and run")
    buildMenu:CreateWidget(Separator);
    buildMenu:CreateWidget(MenuItem, "Temporary build")
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

function MenuBarPanel:_CreateEntityMenu()
    GenerateEntityCreationMenu(self:CreateWidget(MenuList, "Entity"))
end

function MenuBarPanel:_CreateResourcesMenu()
    local resourcesMenu = self:CreateWidget(MenuList, "Resources");
    resourcesMenu:CreateWidget(MenuItem, "Compile shaders")
    resourcesMenu:CreateWidget(MenuItem, "Save materials")
end

function MenuBarPanel:_CreateSettingsMenu()
end

function MenuBarPanel:_CreateLayoutMenu()
    local layoutMenu = self:CreateWidget(MenuList, "Layout")
    layoutMenu:CreateWidget(MenuItem, "Reset")
              .ClickedEvent:AddEventHandler(Bind(TheEditorActions, "ResetLayout"))
end

function MenuBarPanel:_CreateToolMenu()
    local toolMenu = self:CreateWidget(MenuList, "Tool")
    self.m_metricsMenuItem = toolMenu:CreateWidget(MenuItem, "Metrics Debugger", "", true, false)
    self.m_styleEditorMenuItem = toolMenu:CreateWidget(MenuItem, "Style Editor", "", true, false)
end

function MenuBarPanel:_CreateHelpMenu()
    local helpMenu = self:CreateWidget(MenuList, "Help");
    self.m_userGuideMenuItem = helpMenu:CreateWidget(MenuItem, "User Guide", "", true, false)
    helpMenu:CreateWidget(MenuItem, "GitHub")
    helpMenu:CreateWidget(MenuItem, "Tutorials")
    helpMenu:CreateWidget(MenuItem, "Scripting API")
    helpMenu:CreateWidget(Separator);
    helpMenu:CreateWidget(MenuItem, "Bug Report")
    helpMenu:CreateWidget(MenuItem, "Feature Request")
    helpMenu:CreateWidget(Separator);
    helpMenu:CreateWidget(Text, "Version: v0.4");
end

function MenuBarPanel:_CreateSandboxMenu()
    local sandboxMenu = self:CreateWidget(MenuList, "Sandbox")
    local sandbox_configs = require("sandbox.sandbox_config")
    for _, sandbox_config in ipairs(sandbox_configs) do
        sandboxMenu:CreateWidget(MenuItem, sandbox_config.name).ClickedEvent:AddEventHandler(function()
            TheEditorActions:LoadSandbox(sandbox_config.name)
        end)
    end
end

return MenuBarPanel