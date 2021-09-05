# BeginChild

子窗口
- 使用子窗口开始进入主机窗口内独立的独立滚动/剪切区域。子窗口可以嵌入自己的子窗口。
- 对于'size'的每个独立轴：==0.0f：使用剩余的宿主窗口大小/>0.0f：固定大小/<0.0f：使用剩余窗口大小减去abs(size)/每个轴可以使用不同的模式，例如 ImVec2(0,400)。
- BeginChild() 返回 false 以指示窗口已折叠或完全裁剪，因此您可以提前退出并省略向窗口提交任何内容。
  始终为每个 BeginChild() 调用调用匹配的 EndChild()，无论其返回值如何。
   [重要：由于遗留原因，这与大多数其他功能如BeginMenu/EndMenu不一致，
    BeginPopup/EndPopup 等，其中 EndXXX 调用只应在对应的 BeginXXX 函数时调用
   返回真。Begin 和 BeginChild 是唯一的奇数。将在未来的更新中修复。]

## 输出

![](https://pyimgui.readthedocs.io/en/latest/_images/imgui.core.begin_child_0.png)

## border

显示边缘

## return shouldDraw