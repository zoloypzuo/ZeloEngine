# ImGui

## Begin

p_open

> Passing 'bool* p_open' displays a Close button on the upper-right corner of the window, 
> the pointed value will be set to false when the button is pressed.

对应右上角的X，传入NULL则被忽略，不绘制X

按下X之后p_open置为false

```c
bool ImGui::Begin(const char* name, bool* p_open, ImGuiWindowFlags flags)
{
// ...

if (p_open != NULL && window->Viewport->PlatformRequestClose && window->Viewport != GetMainViewport())
{
    if (!window->DockIsActive || window->DockTabIsVisible)
    {
        window->Viewport->PlatformRequestClose = false;
        g.NavWindowingToggleLayer = false; // Assume user mapped PlatformRequestClose on ALT-F4 so we disable ALT for menu toggle. False positive not an issue.
        IMGUI_DEBUG_LOG_VIEWPORT("Window '%s' PlatformRequestClose\n", window->Name);
        *p_open = false;
    }
}
}
```