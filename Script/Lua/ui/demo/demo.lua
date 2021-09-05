-- demo
-- created on 2021/9/3
-- author @zoloypzuo
require("ui.ui_util")
require("ui.demo.ShowExampleMenuFile")
require("ui.demo.ShowUserGuide")
require("ui.demo.ShowDemoWindowWidgets")

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
        ImGui.ShowMetricsWindow()
    end

    if show_app_about then
        ImGui.ShowAboutWindow()
    end

    if show_app_style_editor then
        ImGui.Begin("Dear ImGui Style Editor");
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
            ImGui.ShowExampleMenuFile();
            ImGui.EndMenu();
        end
        if (ImGui.BeginMenu("Examples")) then
            show_app_main_menu_bar = ImGui.MenuItem("Main menu bar", show_app_main_menu_bar)
            show_app_console = ImGui.MenuItem("Console", show_app_console)
            show_app_log = ImGui.MenuItem("Log", show_app_log)
            show_app_layout = ImGui.MenuItem("Simple layout", show_app_layout)
            show_app_property_editor = ImGui.MenuItem("Property editor", show_app_property_editor)
            show_app_long_text = ImGui.MenuItem("Long text display", show_app_long_text)
            show_app_auto_resize = ImGui.MenuItem("Auto-resizing window", show_app_auto_resize)
            show_app_constrained_resize = ImGui.MenuItem("Constrained-resizing window", show_app_constrained_resize)
            show_app_simple_overlay = ImGui.MenuItem("Simple overlay", show_app_simple_overlay)
            show_app_fullscreen = ImGui.MenuItem("Fullscreen window", show_app_fullscreen)
            show_app_window_titles = ImGui.MenuItem("Manipulating window titles", show_app_window_titles)
            show_app_custom_rendering = ImGui.MenuItem("Custom rendering", show_app_custom_rendering)
            show_app_dockspace = ImGui.MenuItem("Dockspace", show_app_dockspace)
            show_app_documents = ImGui.MenuItem("Documents", show_app_documents)
            ImGui.EndMenu();
        end
        if (ImGui.BeginMenu("Tools")) then
            show_app_metrics = ImGui.MenuItem("Metrics/Debugger")
            show_app_style_editor = ImGui.MenuItem("Style Editor")
            show_app_about = ImGui.MenuItem("About Dear ImGui")
            ImGui.EndMenu();
        end
        ImGui.EndMenuBar();
    end

    ImGui.Text("dear imgui says hello. (1.84.1)");
    ImGui.Spacing();

    if (ImGui.CollapsingHeader("Help")) then
        ImGui.Text("ABOUT THIS DEMO:");
        ImGui.BulletText("Sections below are demonstrating many aspects of the library.");
        ImGui.BulletText("The \"Examples\" menu above leads to more demo contents.");
        ImGui.BulletText("The \"Tools\" menu above gives access to: About Box, Style Editor,\n" ..
                "and Metrics/Debugger (general purpose Dear ImGui debugging tool).");
        ImGui.Separator();

        ImGui.Text("PROGRAMMER GUIDE:");
        ImGui.BulletText("See the ShowDemoWindow() code in imgui_demo.cpp. <- you are herenot ");
        ImGui.BulletText("See comments in imgui.cpp.");
        ImGui.BulletText("See example applications in the examples/ folder.");
        ImGui.BulletText("Read the FAQ at http:--www.dearimgui.org/faq/");
        ImGui.BulletText("Set 'io.ConfigFlags |= NavEnableKeyboard' for keyboard controls.");
        ImGui.BulletText("Set 'io.ConfigFlags |= NavEnableGamepad' for gamepad controls.");
        ImGui.Separator();

        ImGui.Text("USER GUIDE:");
        ImGui.ShowUserGuide();
    end

    -- TODO io
    --if (ImGui.CollapsingHeader("Configuration"))then
    --    ImGuiIO& io = ImGui.GetIO();
    --
    --    if (ImGui.TreeNode("Configuration----2"))then
    --        ImGui.CheckboxFlags("io.ConfigFlags: NavEnableKeyboard",    &io.ConfigFlags, ImGuiConfigFlags_NavEnableKeyboard);
    --        ImGui.SameLine(); HelpMarker("Enable keyboard controls.");
    --        ImGui.CheckboxFlags("io.ConfigFlags: NavEnableGamepad",     &io.ConfigFlags, ImGuiConfigFlags_NavEnableGamepad);
    --        ImGui.SameLine(); HelpMarker("Enable gamepad controls. Require backend to set io.BackendFlags |= ImGuiBackendFlags_HasGamepad.\n\nRead instructions in imgui.cpp for details.");
    --        ImGui.CheckboxFlags("io.ConfigFlags: NavEnableSetMousePos", io.ConfigFlags, ImGuiConfigFlags_NavEnableSetMousePos);
    --        ImGui.SameLine(); HelpMarker("Instruct navigation to move the mouse cursor. See comment for ImGuiConfigFlags_NavEnableSetMousePos.");
    --        ImGui.CheckboxFlags("io.ConfigFlags: NoMouse",              &io.ConfigFlags, ImGuiConfigFlags_NoMouse);
    --        if (io.ConfigFlags & ImGuiConfigFlags_NoMouse)then
    --            -- The "NoMouse" option can get us stuck with a disabled mousenot  Let's provide an alternative way to fix it:
    --            if (fmodf((float)ImGui.GetTime(), 0..0) < 0..0)then
    --                ImGui.SameLine();
    --                ImGui.Text("<<PRESS SPACE TO DISABLE>>");
    --            end
    --            if (ImGui.IsKeyPressed(ImGui.GetKeyIndex(ImGuiKey_Space)))
    --                io.ConfigFlags &= ~ImGuiConfigFlags_NoMouse;
    --        end
    --        ImGui.CheckboxFlags("io.ConfigFlags: NoMouseCursorChange", io.ConfigFlags, ImGuiConfigFlags_NoMouseCursorChange);
    --        ImGui.SameLine(); HelpMarker("Instruct backend to not alter mouse cursor shape and visibility.");
    --
    --        ImGui.CheckboxFlags("io.ConfigFlags: DockingEnable", io.ConfigFlags, ImGuiConfigFlags_DockingEnable);
    --        ImGui.SameLine(); HelpMarker("Drag from window title bar or their tab to dock/undock. Hold SHIFT to disable docking.\n\nDrag from window menu button (upper-left button) to undock an entire node (all windows).");
    --        if (io.ConfigFlags & ImGuiConfigFlags_DockingEnable)then
    --            ImGui.Indent();
    --            ImGui.Checkbox("io.ConfigDockingNoSplit", io.ConfigDockingNoSplit);
    --            ImGui.SameLine(); HelpMarker("Simplified docking mode: disable window splitting, so docking is limited to merging multiple windows together into tab-bars.");
    --            ImGui.Checkbox("io.ConfigDockingAlwaysTabBar", io.ConfigDockingAlwaysTabBar);
    --            ImGui.SameLine(); HelpMarker("Create a docking node and tab-bar on single floating windows.");
    --            ImGui.Checkbox("io.ConfigDockingTransparentPayload", io.ConfigDockingTransparentPayload);
    --            ImGui.SameLine(); HelpMarker("Make window or viewport transparent when docking and only display docking boxes on the target viewport. Useful if rendering of multiple viewport cannot be synced. Best used with ConfigViewportsNoAutoMerge.");
    --            ImGui.Unindent();
    --        end
    --
    --        ImGui.CheckboxFlags("io.ConfigFlags: ViewportsEnable", io.ConfigFlags, ImGuiConfigFlags_ViewportsEnable);
    --        ImGui.SameLine(); HelpMarker("[beta] Enable beta multi-viewports support. See ImGuiPlatformIO for details.");
    --        if (io.ConfigFlags & ImGuiConfigFlags_ViewportsEnable)then
    --            ImGui.Indent();
    --            ImGui.Checkbox("io.ConfigViewportsNoAutoMerge", io.ConfigViewportsNoAutoMerge);
    --            ImGui.SameLine(); HelpMarker("Set to make all floating imgui windows always create their own viewport. Otherwise, they are merged into the main host viewports when overlapping it.");
    --            ImGui.Checkbox("io.ConfigViewportsNoTaskBarIcon", io.ConfigViewportsNoTaskBarIcon);
    --            ImGui.SameLine(); HelpMarker("Toggling this at runtime is normally unsupported (most platform backends won't refresh the task bar icon state right away).");
    --            ImGui.Checkbox("io.ConfigViewportsNoDecoration", io.ConfigViewportsNoDecoration);
    --            ImGui.SameLine(); HelpMarker("Toggling this at runtime is normally unsupported (most platform backends won't refresh the decoration right away).");
    --            ImGui.Checkbox("io.ConfigViewportsNoDefaultParent", io.ConfigViewportsNoDefaultParent);
    --            ImGui.SameLine(); HelpMarker("Toggling this at runtime is normally unsupported (most platform backends won't refresh the parenting right away).");
    --            ImGui.Unindent();
    --        end
    --
    --        ImGui.Checkbox("io.ConfigInputTextCursorBlink", io.ConfigInputTextCursorBlink);
    --        ImGui.SameLine(); HelpMarker("Enable blinking cursor (optional as some users consider it to be distracting)");
    --        ImGui.Checkbox("io.ConfigDragClickToInputText", io.ConfigDragClickToInputText);
    --        ImGui.SameLine(); HelpMarker("Enable turning DragXXX widgets into text input with a simple mouse click-release (without moving).");
    --        ImGui.Checkbox("io.ConfigWindowsResizeFromEdges", io.ConfigWindowsResizeFromEdges);
    --        ImGui.SameLine(); HelpMarker("Enable resizing of windows from their edges and from the lower-left corner.\nThis requires (io.BackendFlags & ImGuiBackendFlags_HasMouseCursors) because it needs mouse cursor feedback.");
    --        ImGui.Checkbox("io.ConfigWindowsMoveFromTitleBarOnly", io.ConfigWindowsMoveFromTitleBarOnly);
    --        ImGui.Checkbox("io.MouseDrawCursor", io.MouseDrawCursor);
    --        ImGui.SameLine(); HelpMarker("Instruct Dear ImGui to render a mouse cursor itself. Note that a mouse cursor rendered via your application GPU rendering path will feel more laggy than hardware cursor, but will be more in sync with your other visuals.\n\nSome desktop applications may use both kinds of cursors (e.g. enable software cursor only when resizing/dragging something).");
    --        ImGui.Text("Also see Style->Rendering for rendering options.");
    --        ImGui.TreePop();
    --        ImGui.Separator();
    --    end
    --
    --    if (ImGui.TreeNode("Backend Flags"))then
    --        HelpMarker(
    --            "Those flags are set by the backends (imgui_impl_xxx files) to specify their capabilities.\n"
    --            "Here we expose them as read-only fields to avoid breaking interactions with your backend.");
    --
    --        -- Make a local copy to avoid modifying actual backend flags.
    --        ImGuiBackendFlags backend_flags = io.BackendFlags;
    --        ImGui.CheckboxFlags("io.BackendFlags: HasGamepad",             &backend_flags, ImGuiBackendFlags_HasGamepad);
    --        ImGui.CheckboxFlags("io.BackendFlags: HasMouseCursors",        &backend_flags, ImGuiBackendFlags_HasMouseCursors);
    --        ImGui.CheckboxFlags("io.BackendFlags: HasSetMousePos",         &backend_flags, ImGuiBackendFlags_HasSetMousePos);
    --        ImGui.CheckboxFlags("io.BackendFlags: PlatformHasViewports",   &backend_flags, ImGuiBackendFlags_PlatformHasViewports);
    --        ImGui.CheckboxFlags("io.BackendFlags: HasMouseHoveredViewport",&backend_flags, ImGuiBackendFlags_HasMouseHoveredViewport);
    --        ImGui.CheckboxFlags("io.BackendFlags: RendererHasVtxOffset",   &backend_flags, ImGuiBackendFlags_RendererHasVtxOffset);
    --        ImGui.CheckboxFlags("io.BackendFlags: RendererHasViewports",   &backend_flags, ImGuiBackendFlags_RendererHasViewports);
    --        ImGui.TreePop();
    --        ImGui.Separator();
    --    end
    --
    --    if (ImGui.TreeNode("Style"))then
    --        HelpMarker("The same contents can be accessed in 'Tools->Style Editor' or by calling the ShowStyleEditor() function.");
    --        ImGui.ShowStyleEditor();
    --        ImGui.TreePop();
    --        ImGui.Separator();
    --    end
    --
    --    if (ImGui.TreeNode("Capture/Logging"))then
    --        HelpMarker(
    --            "The logging API redirects all text output so you can easily capture the content of "
    --            "a window or a block. Tree nodes can be automatically expanded.\n"
    --            "Try opening any of the contents below in this window and then click one of the \"Log To\" button.");
    --        ImGui.LogButtons();
    --
    --        HelpMarker("You can also call ImGui.LogText() to output directly to the log without a visual output.");
    --        if (ImGui.Button("Copy \"Hello, worldnot \" to clipboard"))then
    --            ImGui.LogToClipboard();
    --            ImGui.LogText("Hello, worldnot ");
    --            ImGui.LogFinish();
    --        end
    --        ImGui.TreePop();
    --    end
    --end

    -- TODO table is beta
    --if (ImGui.CollapsingHeader("Window options"))then
    --    if (ImGui.BeginTable("split", 3))then
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No titlebar", no_titlebar);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No scrollbar", no_scrollbar);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No menu", no_menu);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No move", no_move);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No resize", no_resize);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No collapse", no_collapse);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No close", no_close);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No nav", no_nav);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No background", no_background);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No bring to front", no_bring_to_front);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("No docking", no_docking);
    --        ImGui.TableNextColumn(); ImGui.Checkbox("Unsaved document", unsaved_document);
    --        ImGui.EndTable();
    --    end
    --end

    -- All demo contents
    ImGui.ShowDemoWindowWidgets();
    --ShowDemoWindowLayout();
    --ShowDemoWindowPopups();
    --ShowDemoWindowTables();
    --ShowDemoWindowMisc();

    -- End of ShowDemoWindow()
    ImGui.PopItemWidth();
    ImGui.End();
end

return ShowDemoWindow