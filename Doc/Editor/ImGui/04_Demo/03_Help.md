# Help

大段纯文本，其实和markdown是对应的，Text=普通文本，BulletText=点列表，Indent=缩进，Separator=分割线

文本渲染，支持换行，横向缩放窗口时，多余的字会被截断，不会自动换行

![Snipaste_2021-09-16_00-00-51](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210704/Snipaste_2021-09-16_00-00-51.38ch7buatea0.png)

```cpp
if (ImGui::CollapsingHeader("Help"))
{
ImGui::Text("ABOUT THIS DEMO:");
ImGui::BulletText("Sections below are demonstrating many aspects of the library.");
ImGui::BulletText("The \"Examples\" menu above leads to more demo contents.");
ImGui::BulletText("The \"Tools\" menu above gives access to: About Box, Style Editor,\n"
"and Metrics/Debugger (general purpose Dear ImGui debugging tool).");
ImGui::Separator();

ImGui::Text("PROGRAMMER GUIDE:");
ImGui::BulletText("See the ShowDemoWindow() code in imgui_demo.cpp. <- you are here!");
ImGui::BulletText("See comments in imgui.cpp.");
ImGui::BulletText("See example applications in the examples/ folder.");
ImGui::BulletText("Read the FAQ at http://www.dearimgui.org/faq/");
ImGui::BulletText("Set 'io.ConfigFlags |= NavEnableKeyboard' for keyboard controls.");
ImGui::BulletText("Set 'io.ConfigFlags |= NavEnableGamepad' for gamepad controls.");
ImGui::Separator();

ImGui::Text("USER GUIDE:");
ImGui::ShowUserGuide();
}

// Helper to display basic user controls.
// void ImGui::ShowUserGuide()
// {
ImGuiIO& io = ImGui::GetIO();
ImGui::BulletText("Double-click on title bar to collapse window.");
ImGui::BulletText(
"Click and drag on lower corner to resize window\n"
"(double-click to auto fit window to its contents).");
ImGui::BulletText("CTRL+Click on a slider or drag box to input value as text.");
ImGui::BulletText("TAB/SHIFT+TAB to cycle through keyboard editable fields.");
if (io.FontAllowUserScaling)
    ImGui::BulletText("CTRL+Mouse Wheel to zoom window contents.");
ImGui::BulletText("While inputing text:\n");
ImGui::Indent();
ImGui::BulletText("CTRL+Left/Right to word jump.");
ImGui::BulletText("CTRL+A or double-click to select all.");
ImGui::BulletText("CTRL+X/C/V to use clipboard cut/copy/paste.");
ImGui::BulletText("CTRL+Z,CTRL+Y to undo/redo.");
ImGui::BulletText("ESCAPE to revert.");
ImGui::BulletText("You can apply arithmetic operators +,*,/ on numerical values.\nUse +- to subtract.");
ImGui::Unindent();
ImGui::BulletText("With keyboard navigation enabled:");
ImGui::Indent();
ImGui::BulletText("Arrow keys to navigate.");
ImGui::BulletText("Space to activate a widget.");
ImGui::BulletText("Return to input text into a widget.");
ImGui::BulletText("Escape to deactivate a widget, close popup, exit child window.");
ImGui::BulletText("Alt to jump to the menu layer of a window.");
ImGui::BulletText("CTRL+Tab to select a window.");
ImGui::Unindent();
//}
```