# ImGui.Begin

窗口

- Begin() = 将窗口推入堆栈并开始附加到它。End() = 从堆栈中弹出窗口。
- 传递 'bool* p_open != NULL' 在窗口的右上角显示一个关闭窗口的小部件，
  哪个点击将在点击时将布尔值设置为 false。
- 通过多次调用 Begin()/End() 对，您可以在同一帧中多次追加到同一窗口。
  一些信息，如'flags' 或'p_open' 只会在第一次调用Begin() 时考虑。
- Begin() 返回 false 以指示窗口已折叠或完全裁剪，因此您可以提前退出并省略提交
  任何到窗口的东西。始终为每个 Begin() 调用调用匹配的 End()，无论其返回值如何！
   [重要：由于遗留原因，这与大多数其他功能如BeginMenu/EndMenu不一致，
    BeginPopup/EndPopup 等，其中 EndXXX 调用只应在对应的 BeginXXX 函数时调用
   返回真。Begin 和 BeginChild 是唯一的奇数。将在未来的更新中修复。]
- 请注意，窗口堆栈的底部始终包含一个名为“调试”的窗口。

## 输出

![](https://pyimgui.readthedocs.io/en/latest/_images/imgui.core.begin_0.png)

## p_open

> Passing 'bool* p_open' displays a Close button on the upper-right corner of the window,
> the pointed value will be set to false when the button is pressed.

* 对应右上角的X
* 传入NULL则被忽略，不绘制X
* 传入false则不绘制窗口
* 按下X之后p_open置为false

这里p_open其实还有C#的可空类型的用法，额外带一个bool

```c
bool ImGui::Begin(const char* name, bool* p_open, ImGuiWindowFlags flags)
{
// ...

window->HasCloseButton = (p_open != NULL);

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

## return shouldDraw

左上角的小三角可以折叠窗口，如果折叠了返回false，不需要绘制

## open的评价

一个参数功能太多了

下面这种写法有冗余，其实if cond已经能控制是否绘制了，和窗口的open参数功能重合了

```lua
if show_app_about then
    ImGui.ShowAboutWindow(show_app_about)
end
```

写成这样就行了

```lua
if show_app_about then
    ImGui.ShowAboutWindow()
end
```

打脸了。。没有这种写法，这个窗口会关不掉，主要是我把每个窗口封装成一个函数时，需要传递这个开关参数
