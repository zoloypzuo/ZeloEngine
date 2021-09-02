-- demo
-- created on 2021/9/3
-- author @zoloypzuo
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

local function ShowDemoWindow(open)
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
end