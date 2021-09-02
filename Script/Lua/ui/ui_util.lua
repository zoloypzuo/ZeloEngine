-- ui_util
-- created on 2021/8/24
-- author @zoloypzuo
function ParseFlags(enumTable, flag)
    local names = {}
    for name, val in pairs(enumTable) do
        if bit.band(flag, val) ~= 0 then
            names[#names + 1] = name
        end
    end
    return names
end

function GenFlagFromTable(imguiFlags, setting, default)
    if default then
        -- use default
        for k, v in pairs(default) do
            if setting[k] ~= nil then
                setting[k] = v
            end
        end
    end

    local flag = 0
    for k, v in pairs(setting) do
        assert(imguiFlags[k], "flag not exists")
        if v then
            flag = bit.bor(flag, imguiFlags[k])
        end
    end
    return flag
end
-- TODO DefaultPanelWindowSettings
local DefaultPanelWindowSettings = {
    closable = false;
    resizable = true;
    movable = true;
    dockable = true;
    scrollable = true;
    hideBackground = false;
    forceHorizontalScrollbar = false;
    forceVerticalScrollbar = false;
    allowHorizontalScrollbar = false;
    bringToFrontOnFocus = true;
    collapsable = false;
    allowInputs = true;
    titleBar = true;
    autoSize = false;
}

local function GenFlagFromPaneSetting(panelSettings)
    local resizable = panelSettings.resizable
    local movable = panelSettings.movable
    local dockable = panelSettings.dockable
    local scrollable = panelSettings.scrollable
    local hideBackground = panelSettings.hideBackground
    local forceHorizontalScrollbar = panelSettings.forceHorizontalScrollbar
    local forceVerticalScrollbar = panelSettings.forceVerticalScrollbar
    local allowHorizontalScrollbar = panelSettings.allowHorizontalScrollbar
    local bringToFrontOnFocus = panelSettings.bringToFrontOnFocus
    local collapsable = panelSettings.collapsable
    local allowInputs = panelSettings.allowInputs
    local titleBar = panelSettings.titleBar

    return GenFlagFromTable(ImGuiWindowFlags, {
        NoResize = not resizable;
        NoMove = not movable;
        NoDocking = not dockable;
        NoBackground = hideBackground;
        AlwaysHorizontalScrollbar = forceHorizontalScrollbar;
        AlwaysVerticalScrollbar = forceVerticalScrollbar;
        HorizontalScrollbar = allowHorizontalScrollbar;
        NoBringToFrontOnFocus = not bringToFrontOnFocus;
        NoCollapse = not collapsable;
        NoInputs = not allowInputs;
        NoScrollWithMouse = not scrollable;
        NoScrollbar = not scrollable;
        NoTitleBar = not titleBar;
    }, DefaultPanelWindowSettings)
end
