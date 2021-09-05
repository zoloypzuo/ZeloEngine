//光标/布局
// - “光标”是指当前的输出位置。
// - 典型的小部件行为是在当前光标位置输出自身，然后将光标向下移动一行。
// - 您可以在小部件之间调用 SameLine() 以撤消前一个小部件右侧的最后一个回车和输出。
// - 注意！我们目前在窗口本地位置和绝对位置之间存在不一致，我们将在未来的 API 中修复：
//    窗口局部坐标：SameLine()、GetCursorPos()、SetCursorPos()、GetCursorStartPos()、GetContentRegionMax()、GetWindowContentRegion*()、PushTextWrapPos()
//    绝对坐标：GetCursorScreenPos()、SetCursorScreenPos()、所有ImDrawList::函数。
void           Separator ();                                                    //分隔符，一般是水平的。在菜单栏内或在水平布局模式下，这将成为垂直分隔符。
void           SameLine ( float offset_from_start_x= 0 . 0f ,浮动间距=- 1 . 0f );  //在小部件或组之间调用以水平布局它们。在窗口坐标中给出的 X 位置。
void           NewLine ();                                                      //在水平布局上下文中撤消 SameLine() 或强制换行。
void           Spacing ();                                                      //添加垂直间距。
void           Dummy ( const Imvec2& size);                                      //添加一个给定大小的虚拟项目。与 InvisibleButton() 不同，Dummy() 不会接受鼠标点击或导航。
void           Indent ( float indent_w = 0 . 0f );                                  //向右移动内容位置，通过 indent_w 或 style.IndentSpacing 如果 indent_w <= 0
void           Unindent ( float indent_w = 0 . 0f );                                //将内容位置向左移动，通过 indent_w 或 style.IndentSpacing 如果 indent_w <= 0
void           BeginGroup ();                                                   //锁定水平起始位置
void           EndGroup ();                                                     //解锁水平起始位置 + 将整个组边界框捕获到一个“项目”中（因此您可以在整个组上使用 IsItemHovered() 或布局原语，例如 SameLine() 等）
ImVec2         GetCursorPos ();                                                 //窗口坐标中的光标位置（相对于窗口位置）
float          GetCursorPosX ();                                                //    （一些函数使用了窗口相对坐标，例如：GetCursorPos、GetCursorStartPos、GetContentRegionMax、GetWindowContentRegion* 等。
float          GetCursorPosY ();                                                //    其他函数，例如 GetCursorScreenPos 或 ImDrawList 中的所有内容::
void           SetCursorPos ( const ImVec2& local_pos);                          //    使用主要的绝对坐标系。
void           SetCursorPosX ( float local_x);                                   //     GetWindowPos() + GetCursorPos() == GetCursorScreenPos() 等等)
void           SetCursorPosY ( float local_y);                                   //
ImVec2         GetCursorStartPos ();                                            //窗口坐标中的初始光标位置
ImVec2         GetCursorScreenPos ();                                           //绝对坐标中的光标位置（对于使用 ImDrawList API 很有用）。通常在单视口模式下左上角 == GetMainViewport()->Pos == (0,0)，在单视口模式下右下角 == GetMainViewport()->Pos+Size == io.DisplaySize。
void           SetCursorScreenPos ( const Imvec2& pos);                          //绝对坐标中的光标位置
void           AlignTextToFramePadding ();                                      //将即将到来的文本基线垂直对齐到 FramePadding.y，以便它可以正确对齐到有规律的框架项目（如果您在框架项目之前的一行中有文本，请调用）
float          GetTextLineHeight ();                                            // ~ 字体大小
float          GetTextLineHeightWithSpacing ();                                 // ~ FontSize + style.ItemSpacing.y（两连续文本行之间的像素距离）
float          GetFrameHeight ();                                               // ~ 字体大小 + style.FramePadding.y * 2
float          GetFrameHeightWithSpacing ();                                    // ~ FontSize + style.FramePadding.y * 2 + style.ItemSpacing.y（带框小部件的 2 个连续行之间的距离（以像素为单位））

//视口
// - 当前代表由托管我们亲爱的 ImGui 窗口的应用程序创建的平台窗口。
// - 在启用多视口的“停靠”分支中，我们扩展了这个概念以拥有多个活动视口。
// - 未来我们将进一步扩展这个概念，以代表平台监视器并支持“无主平台窗口”操作模式。
ImGuiViewport* GetMainViewport ();                                                 //返回主/默认视口。这永远不能为 NULL。

//其他实用程序
bool           IsRectVisible ( const Imvec2& size);                                  //测试矩形（给定大小，从光标位置开始）是否可见/未裁剪。
bool           IsRectVisible ( const ImVec2& rect_min, const ImVec2& rect_max);      //测试矩形（在屏幕空间中）是否可见/未裁剪。在用户端进行粗剪。
double         GetTime ();                                                          //获取全局 imgui 时间。每帧增加 io.DeltaTime。
int            GetFrameCount ();                                                    //获取全局 imgui 帧数。每帧增加1。
ImDrawList*    GetBackgroundDrawList ();                                            //这个绘制列表将是第一个渲染列表。用于在亲爱的 imgui 内容后面快速绘制形状/文本。
ImDrawList*    GetForegroundDrawList ();                                            //此绘制列表将是最后渲染的绘制列表。用于在亲爱的 imgui 内容上快速绘制形状/文本。
ImDrawListSharedData* GetDrawListSharedData ();                                    //您可以在创建自己的 ImDrawList 实例时使用它。
const  char *    GetStyleColorName (ImGuiCol idx);                                    //获取与枚举值对应的字符串（用于显示、保存等）。
void           SetStateStorage (ImGuiStorage* storage);                             //用我们自己的替换当前窗口存储（如果你想自己操作它，通常清除它的子部分）
ImGuiStorage* GetStateStorage ();
void           CalcListClipping ( int items_count, float items_height, int * out_items_display_start, int * out_items_display_end);    //计算大小均匀项目的大列表的粗剪裁。如果可以，最好使用 ImGuiListClipper 更高级别的帮助程序。
bool           BeginChildFrame (ImGuiID id, const ImVec2& size, ImGuiWindowFlags flags = 0 ); //创建一个看起来像普通小部件框架的子窗口/滚动区域的助手
void           EndChildFrame ();                                                    //无论 BeginChildFrame() 返回值如何（表示折叠/剪切窗口），始终调用 EndChildFrame()

//文本工具
ImVec2         CalcTextSize ( const  char * text, const  char * text_end = NULL , bool hide_text_after_double_hash = false , float wrap_width = - 1 . 0f );

//颜色工具
ImVec4         ColorConvertU32ToFloat4 (ImU32 in);
ImU32          ColorConvertFloat4ToU32 ( const Imvec4& in);
void           ColorConvertRGBtoHSV ( float r, float g, float b, float & out_h, float & out_s, float & out_v);
void           ColorConvertHSVtoRGB ( float h, float s, float v, float & out_r, float & out_g, float & out_b);

//输入工具：键盘
// - 对于“int user_key_index”，您可以根据后端/引擎将它们存储在 io.KeysDown[] 中的方式使用您自己的索引/枚举。
// - 我们不知道这些值的含义。您可以使用 GetKeyIndex() 将 ImGuiKey_ 值映射到用户索引中。
int            GetKeyIndex (ImGuiKey imgui_key);                                    //将 ImGuiKey_* 值映射到用户的键索引中。== io.KeyMap[key]
bool           IsKeyDown ( int user_key_index);                                      //是被持有的密钥。== io.KeysDown[user_key_index]。
bool           IsKeyPressed ( int user_key_index, bool repeat = true );               //是否按下了键（从 !Down 到 Down）？如果 repeat=true，则使用 io.KeyRepeatDelay / KeyRepeatRate
bool           IsKeyReleased ( int user_key_index);                                  //键是否被释放（从 Down 到 !Down）？
int            GetKeyPressedAmount ( int key_index, float repeat_delay, float rate); //使用提供的重复率/延迟。返回一个计数，最常见的是 0 或 1，但如果 R​​epeatRate 足够小以至于 DeltaTime > RepeatRate 可能是 >1
IMGUI_API空隙          CaptureKeyboardFromApp（布尔want_capture_keyboard_value =真）;    //注意：误导性的名字！手动覆盖下一帧的 io.WantCaptureKeyboard 标志（所述标志完全留给您的应用程序处理）。例如，当您的小部件悬停时强制捕获键盘。这相当于设置“io.WantCaptureKeyboard = want_capture_keyboard_value”；在下一个 NewFrame() 调用之后。

//输入工具：鼠标
// - 要引用鼠标按钮，您可以在代码中使用命名枚举，例如 ImGuiMouseButton_Left、ImGuiMouseButton_Right。
// - 您也可以使用常规整数：永远保证 0=Left, 1=Right, 2=Middle。
// - 只有在鼠标从初始点击位置移开一定距离后才会报告拖动操作（参见“lock_threshold”和“io.MouseDraggingThreshold”）
bool           IsMouseDown（ImGuiMouseButton 按钮）；                               //鼠标按钮是否被按住？
bool           IsMouseClicked (ImGuiMouseButton 按钮, bool repeat = false );       // 是否点击了鼠标按钮？（从 !Down 到 Down）
bool           IsMouseReleased（ImGuiMouseButton 按钮）；                           //鼠标按钮释放了吗？（从 Down 到 !Down）
bool           IsMouseDoubleClicked（ImGuiMouseButton 按钮）；                      // 是否双击了鼠标按钮？（注意双击也会报 IsMouseClicked() == true）
bool           IsMouseHoveringRect ( const ImVec2& r_min, const ImVec2& r_max, bool clip = true ); //鼠标悬停在给定的边界矩形（在屏幕空间中）。由当前裁剪设置裁剪，但不考虑焦点/窗口排序/弹出块的其他考虑。
bool           IsMousePosValid ( const ImVec2* mouse_pos = NULL );                    //按照惯例，我们使用 (-FLT_MAX,-FLT_MAX) 来表示没有可用的鼠标
bool           IsAnyMouseDown ();                                                   //是否有任何鼠标按钮被按住？
ImVec2         GetMousePos ();                                                      //用户提供的ImGui::GetIO().MousePos的快捷方式，与其他调用保持一致
ImVec2         GetMousePosOnOpeningCurrentPopup ();                                 //在打开弹出窗口时检索鼠标位置，我们将 BeginPopup() 放入（帮助避免用户自己支持该值）
bool           IsMouseDragging (ImGuiMouseButton 按钮，浮动lock_threshold = - 1 . 0f );         //鼠标拖动？（如果 lock_threshold < -1.0f，使用 io.MouseDraggingThreshold）
ImVec2         GetMouseDragDelta (ImGuiMouseButton button = 0 , float lock_threshold = - 1 . 0f );   //当鼠标按钮被按下或刚刚释放时，从初始点击位置返回增量。这是锁定并返回 0.0f 直到鼠标移动超过距离阈值至少一次（如果 lock_threshold < -1.0f，使用 io.MouseDraggingThreshold）
void           ResetMouseDragDelta (ImGuiMouseButton button = 0 );                   //
ImGuiMouseCursor GetMouseCursor ();                                                //获取所需的光标类型，在 ImGui::NewFrame() 中重置，在帧期间更新。在 Render() 之前有效。如果您通过设置 io.MouseDrawCursor 使用软件渲染，ImGui 将为您渲染这些
void           SetMouseCursor (ImGuiMouseCursor cursor_type);                       //设置所需的光标类型
void           CaptureMouseFromApp ( bool want_capture_mouse_value = true );          //注意：误导性的名字！手动覆盖下一帧的 io.WantCaptureMouse 标志（所述标志完全留给您的应用程序处理）。这相当于设置“io.WantCaptureMouse = want_capture_mouse_value;” 在下一个 NewFrame() 调用之后。

//剪贴板工具
// - 另请参阅 LogToClipboard() 函数以将 GUI 捕获到剪贴板，或轻松地将文本数据输出到剪贴板。
const  char *    GetClipboardText ();
void           SetClipboardText ( const  char * text);

//设置/.ini 实用程序
// - 如果 io.IniFilename != NULL（默认为“imgui.ini”），则会自动调用磁盘函数。
// - 将 io.IniFilename 设置为 NULL 以手动加载/保存。阅读有关手动处理 .ini 保存的 io.WantSaveIniSettings 描述。
// - 重要提示：默认值“imgui.ini”是相对于当前工作目录的！大多数应用程序都希望将其锁定到绝对路径（例如与可执行文件相同的路径）。
void           LoadIniSettingsFromDisk ( const  char * ini_filename);                  //在 CreateContext() 之后和第一次调用 NewFrame() 之前调用。NewFrame() 自动调用 LoadIniSettingsFromDisk(io.IniFilename)。
void           LoadIniSettingsFromMemory ( const  char * ini_data, size_t ini_size= 0 ); //在 CreateContext() 之后和第一次调用 NewFrame() 之前调用以从您自己的数据源提供 .ini 数据。
void           SaveIniSettingsToDisk ( const  char * ini_filename);                    //在任何应该反映在 .ini 文件（以及 DestroyContext）中的修改后几秒钟，它会自动调用（如果 io.IniFilename 不为空）。
const  char *    SaveIniSettingsToMemory ( size_t * out_ini_size = NULL );               //返回一个带有 .ini 数据的以零结尾的字符串，您可以根据自己的意思保存。io.WantSaveIniSettings 设置时调用，然后按自己的方式保存数据并清除io.WantSaveIniSettings。

//调试工具
// - 这由 IMGUI_CHECKVERSION() 宏使用。
bool           DebugCheckVersionAndDataLayout ( const  char * version_str, size_t sz_io, size_t sz_style, size_t sz_vec2, size_t sz_vec4, size_t sz_drawvert, size_t sz_drawidx); //这是由 IMGUI_CHECKVERSION() 宏调用的。

//内存分配器
// - 这些函数不依赖于当前上下文。
// - DLL 用户：不跨 DLL 边界共享堆和全局变量！您将需要调用 SetCurrentContext() + SetAllocatorFunctions()
//   对于您正在调用的每个静态/DLL 边界。阅读 imgui.cpp 的“上下文和内存分配器”部分以获取更多详细信息。
void           SetAllocatorFunctions (ImGuiMemAllocFunc alloc_func, ImGuiMemFreeFunc free_func, void * user_data = NULL );
void           GetAllocatorFunctions (ImGuiMemAllocFunc* p_alloc_func, ImGuiMemFreeFunc* p_free_func, void ** p_user_data);
void *          MemAlloc ( size_t size);
void           MemFree ( void * ptr);
