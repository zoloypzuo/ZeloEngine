# ImGui

自己实现ImGui

* ImGui，公共接口文件和运行时核心实现
* ImWidget，控件类实现
* ImUtil，工具函数
* ImGuiManager，集成RHI后端，作为引擎模块与引擎对接
* ImGuiInternal，内部接口
* ImGuiSample，示例接口

//-----------------------------------------------------------------------------
// Helpers
//-----------------------------------------------------------------------------
// Helpers at bottom of the file:
// - if (IMGUI_ONCE_UPON_A_FRAME)		// Execute a block of code once per frame only
// - struct ImGuiTextFilter				// Parse and apply text filter. In format "aaaaa[,bbbb][,ccccc]"
// - struct ImGuiTextBuffer				// Text buffer for logging/accumulating text
// - struct ImGuiStorage				// Custom key value storage (if you need to alter open/close states manually)
// - struct ImDrawList					// Draw command list
// - struct ImBitmapFont				// Bitmap font loader