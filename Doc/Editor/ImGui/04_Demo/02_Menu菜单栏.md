# Menu

一个假的菜单栏，展示菜单栏的样式，还展示了菜单栏是可以递归的

![Snipaste_2021-09-15_23-43-53](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210704/Snipaste_2021-09-15_23-43-53.1gp0ujr2k6n4.png)

一些示例入口

![Snipaste_2021-09-15_23-44-01](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210704/Snipaste_2021-09-15_23-44-01.77z493greug0.png)

ImGui工具窗口，调试，样式

![Snipaste_2021-09-15_23-44-09](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210704/Snipaste_2021-09-15_23-44-09.1dpp4cvo7y5c.png)


```cpp
// Menu Bar
if (ImGui::BeginMenuBar())
{
    if (ImGui::BeginMenu("Menu"))
    {
        ShowExampleMenuFile();
        ImGui::EndMenu();
    }
    if (ImGui::BeginMenu("Examples"))
    {
        ImGui::MenuItem("Main menu bar", NULL, &show_app_main_menu_bar);
        ImGui::MenuItem("Console", NULL, &show_app_console);
        ImGui::MenuItem("Log", NULL, &show_app_log);
        ImGui::MenuItem("Simple layout", NULL, &show_app_layout);
        ImGui::MenuItem("Property editor", NULL, &show_app_property_editor);
        ImGui::MenuItem("Long text display", NULL, &show_app_long_text);
        ImGui::MenuItem("Auto-resizing window", NULL, &show_app_auto_resize);
        ImGui::MenuItem("Constrained-resizing window", NULL, &show_app_constrained_resize);
        ImGui::MenuItem("Simple overlay", NULL, &show_app_simple_overlay);
        ImGui::MenuItem("Fullscreen window", NULL, &show_app_fullscreen);
        ImGui::MenuItem("Manipulating window titles", NULL, &show_app_window_titles);
        ImGui::MenuItem("Custom rendering", NULL, &show_app_custom_rendering);
        ImGui::MenuItem("Dockspace", NULL, &show_app_dockspace);
        ImGui::MenuItem("Documents", NULL, &show_app_documents);
        ImGui::EndMenu();
    }
    if (ImGui::BeginMenu("Tools"))
    {
        ImGui::MenuItem("Metrics/Debugger", NULL, &show_app_metrics);
        ImGui::MenuItem("Style Editor", NULL, &show_app_style_editor);
        ImGui::MenuItem("About Dear ImGui", NULL, &show_app_about);
        ImGui::EndMenu();
    }
    ImGui::EndMenuBar();
}

```