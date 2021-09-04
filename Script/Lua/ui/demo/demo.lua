-- demo
-- created on 2021/9/3
-- author @zoloypzuo
require("ui.ui_util")
local ShowExampleMenuFile = require("ui.demo.ShowExampleMenuFile")

local show_app_main_menu_bar = false;
local show_app_dockspace = false;
local show_app_documents = false;

local show_app_console = false;
local show_app_log = false;
local show_app_layout = false;
local show_app_property_editor = false;
local show_app_long_text = false;
local show_app_auto_resize = false;
local show_app_constrained_resize = false;
local show_app_simple_overlay = false;
local show_app_fullscreen = false;
local show_app_window_titles = false;
local show_app_custom_rendering = false;

local show_app_metrics = false;
local show_app_style_editor = false;
local show_app_about = false;

-- Demonstrate the various window flags. Typically you would just use the default!
local no_titlebar = false;
local no_scrollbar = false;
local no_menu = false;
local no_move = false;
local no_resize = false;
local no_collapse = false;
local no_close = false;
local no_nav = false;
local no_background = false;
local no_bring_to_front = false;
local no_docking = false;
local unsaved_document = false;

local function ShowDemoWindow(p_open)
    -- @formatter:off
    if (show_app_main_menu_bar)       then ShowExampleAppMainMenuBar() end
    if (show_app_dockspace)           then ShowExampleAppDockSpace(show_app_dockspace)end     -- Process the Docking app first, as explicit DockSpace() nodes needs to be submitted early (read comments near the DockSpace function)
    if (show_app_documents)           then ShowExampleAppDocuments(show_app_documents)end     -- Process the Document app next, as it may also use a DockSpace()

    if (show_app_console)             then ShowExampleAppConsole(show_app_console) end
    if (show_app_log)                 then ShowExampleAppLog(show_app_log) end
    if (show_app_layout)              then ShowExampleAppLayout(show_app_layout) end
    if (show_app_property_editor)     then ShowExampleAppPropertyEditor(show_app_property_editor) end
    if (show_app_long_text)           then ShowExampleAppLongText(show_app_long_text) end
    if (show_app_auto_resize)         then ShowExampleAppAutoResize(show_app_auto_resize) end
    if (show_app_constrained_resize)  then ShowExampleAppConstrainedResize(show_app_constrained_resize) end
    if (show_app_simple_overlay)      then ShowExampleAppSimpleOverlay(show_app_simple_overlay) end
    if (show_app_fullscreen)          then ShowExampleAppFullscreen(show_app_fullscreen) end
    if (show_app_window_titles)       then ShowExampleAppWindowTitles(show_app_window_titles) end
    if (show_app_custom_rendering)    then ShowExampleAppCustomRendering(show_app_custom_rendering) end

    -- @formatter:on
    if show_app_metrics then
        ImGui.ShowMetricsWindow(show_app_metrics)
    end

    if show_app_about then
        ImGui.ShowAboutWindow(show_app_about)
    end

    if show_app_style_editor then
        ImGui.Begin("Dear ImGui Style Editor", show_app_style_editor);
        ImGui.ShowStyleEditor();
        ImGui.End();
    end

    local window_flags = GenFlagFromTable(ImGuiWindowFlags, {
        NoTitleBar = no_titlebar;
        NoScrollbar = no_scrollbar;
        MenuBar = not no_menu;
        NoMove = no_move;
        NoResize = no_resize;
        NoCollapse = no_collapse;
        NoNav = no_nav;
        NoBackground = no_background;
        NoBringToFrontOnFocus = no_bring_to_front;
        NoDocking = no_docking;
        UnsavedDocument = unsaved_document;
    })

    -- We specify a default position/size in case there's no data in the .ini file.
    -- We only do it to make the demo applications a little more welcoming, but typically this isn't required.
    --const ImGuiViewport* main_viewport = ImGui.GetMainViewport();
    --ImGui.SetNextWindowPos(ImVec2(main_viewport->WorkPos.x + 650, main_viewport->WorkPos.y + 20), ImGuiCond_FirstUseEver);
    --ImGui.SetNextWindowSize(ImVec2(550, 680), ImGuiCond_FirstUseEver);

    -- Main body of the Demo window starts here.
    local p_open, shouldDraw = ImGui.Begin("Dear ImGui Demo", p_open, window_flags)
    if not shouldDraw then
        -- Early out if the window is collapsed, as an optimization.
        return ;
    end

    -- Most "big" widgets share a common width settings by default. See 'Demo->Layout->Widgets Width' for details.

    -- e.g. Use 2/3 of the space for widgets and 1/3 for labels (right align)
    --ImGui.PushItemWidth(-ImGui.GetWindowWidth() * 0.35f);

    -- e.g. Leave a fixed amount of width for labels (by passing a negative value), the rest goes to widgets.
    ImGui.PushItemWidth(ImGui.GetFontSize() * -12);

    -- Menu Bar
    if (ImGui.BeginMenuBar()) then
        if (ImGui.BeginMenu("Menu")) then
            ShowExampleMenuFile();
            ImGui.EndMenu();
        end
        if (ImGui.BeginMenu("Examples")) then
            ImGui.MenuItem("Main menu bar", show_app_main_menu_bar);
            ImGui.MenuItem("Console", show_app_console);
            ImGui.MenuItem("Log", show_app_log);
            ImGui.MenuItem("Simple layout", show_app_layout);
            ImGui.MenuItem("Property editor", show_app_property_editor);
            ImGui.MenuItem("Long text display", show_app_long_text);
            ImGui.MenuItem("Auto-resizing window", show_app_auto_resize);
            ImGui.MenuItem("Constrained-resizing window", show_app_constrained_resize);
            ImGui.MenuItem("Simple overlay", show_app_simple_overlay);
            ImGui.MenuItem("Fullscreen window", show_app_fullscreen);
            ImGui.MenuItem("Manipulating window titles", show_app_window_titles);
            ImGui.MenuItem("Custom rendering", show_app_custom_rendering);
            ImGui.MenuItem("Dockspace", show_app_dockspace);
            ImGui.MenuItem("Documents", show_app_documents);
            ImGui.EndMenu();
        end
        if (ImGui.BeginMenu("Tools")) then
            ImGui.MenuItem("Metrics/Debugger", show_app_metrics);
            ImGui.MenuItem("Style Editor", show_app_style_editor);
            ImGui.MenuItem("About Dear ImGui", show_app_about);
            ImGui.EndMenu();
        end
        ImGui.EndMenuBar();
    end

    ImGui.End();
end

return ShowDemoWindow