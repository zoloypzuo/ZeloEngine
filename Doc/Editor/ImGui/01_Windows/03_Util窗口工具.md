# Util

Windows 实用工具

'current window' = 我们在 Begin()/End() 块中追加的窗口。

'next window' = 我们将开始（）进入的下一个窗口。

## bool IsWindowAppearing ();

## bool IsWindowCollapsed ();

## bool IsWindowFocused (ImGuiFocusedFlags flags= 0 ); 

当前窗口是否聚焦？或其根/子，取决于标志。查看选项的标志。

## bool IsWindowHovered (ImGuiHoveredFlags flags= 0 ); 

当前窗口是否悬停（通常：没有被弹出窗口/模式阻止）？查看选项的标志。注意：如果您尝试检查您的鼠标是否应该被分配到 imgui 或您的应用程序，您应该使用 'io.WantCaptureMouse' 布尔值！请阅读常见问题解答！

## ImDrawList* GetWindowDrawList ();    

获取与当前窗口关联的绘图列表，以附加您自己的绘图图元

## ImVec2 GetWindowPos ();         

获取当前窗口在屏幕空间中的位置（如果您想通过 DrawList API 进行自己的绘图，则很有用）

## ImVec2 GetWindowSize ();        

获取当前窗口大小

## floatGetWindowWidth ();       

获取当前窗口宽度（GetWindowSize().x 的快捷方式）

## floatGetWindowHeight ();      

获取当前窗口高度（GetWindowSize().y 的快捷方式）
