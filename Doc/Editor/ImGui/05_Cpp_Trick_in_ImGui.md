# Cpp Trick in ImGui

## 避免大函数，拆分成小函数

避免大函数，拆分成小函数，因为链接大函数的时间的复杂度是非线性的

## ImGui的调用风格

* 返回bool，给if去触发逻辑
* 额外的返回值通过指针参数传出
* pStatus承担了至多三种功能，输入和返回值，NULL时还是禁用
* 相对复杂的控件是带状态的，有控件ID，输入参数会被缓存在控件状态中

```cpp
bool MenuItem(const char * label, const char *shortcut, bool *p_selected, bool enabled=true);
```

## 变长参数

TextXXX文本控件有两个版本，比如Text和TextV

两个都是vararg，一个是接口，一个是内部实现

...用va_start和va_end可以收集到一个va_list中

```cpp
void ImGui::Text(const char* fmt, ...)
{
    va_list args;
    va_start(args, fmt);
    TextV(fmt, args);
    va_end(args);
}

void ImGui::TextV(const char* fmt, va_list args)
{
    ImGuiWindow* window = GetCurrentWindow();
    if (window->SkipItems)
        return;

    ImGuiContext& g = *GImGui;
    const char* text_end = g.TempBuffer + ImFormatStringV(g.TempBuffer, IM_ARRAYSIZE(g.TempBuffer), fmt, args);
    TextEx(g.TempBuffer, text_end, ImGuiTextFlags_NoWidthForLargeClippedText);
}
```