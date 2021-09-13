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
