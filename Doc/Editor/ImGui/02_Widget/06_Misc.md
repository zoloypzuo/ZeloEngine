# 小部件：拖动滑块
- CTRL+单击任何拖动框将它们变成输入框。手动输入的值不会被限制并且可以越界。
- 对于每个函数的所有 Float2/Float3/Float4/Int2/Int3/Int4 版本，请注意“float v[X]”函数参数与“float* v”相同，数组语法只是一个记录预期可访问的元素数量的方法。您可以从连续集合中传递第一个元素的地址，例如 &myvector.x
- 调整格式字符串以使用前缀、后缀装饰值，或调整编辑和显示精度，例如 "%.3f" -> 1.234; “%5.2f 秒”-> 01.23 秒；"饼干: %.0f" -> 饼干: 1; 等等。
- 格式字符串也可以设置为 NULL 或使用默认格式（“%f”或“%d”）。
- 速度是鼠标移动的每个像素（v_speed=0.2f：鼠标需要移动 5 个像素才能将值增加 1）。对于游戏手柄/键盘导航，最小速度为 Max(v_speed, minimum_step_at_given_precision)。
- 使用 v_min < v_max 将编辑限制在给定的范围内。请注意，CTRL+Click 手动输入可以覆盖这些限制。
- 使用 v_max = FLT_MAX / INT_MAX 等避免钳制到最大值，与 v_min = -FLT_MAX / INT_MIN 相同以避免钳制到最小值。
- 我们为 DragXXX() 和 SliderXXX() 函数使用相同的标志集，因为它们的功能是相同的，这样可以更容易地交换它们。
- 传统：在 1.78 之前，有 DragXXX() 函数签名接受最终的 `float power=1.0f' 参数而不是 `ImGuiSliderFlags flags=0' 参数。
  如果您收到将浮点数转换为 ImGuiSliderFlags 的警告，请阅读 https://github.com/ocornut/imgui/issues/3361
bool   DragFloat ( const  char * label, float * v, float v_speed = 1 . 0f , float v_min = 0 . 0f , float v_max = 0 . 0f , const  char * format = " %.3f " , ImGuiSliderFlags flags = 0 ) ;     //如果 v_min >= v_max 我们没有界限
bool   DragFloat2 ( const  char * label, float v[ 2 ], float v_speed = 1 . 0f , float v_min = 0 . 0f , float v_max = 0 . 0f , const  char * format = " %.3f " , ImGuiSliderFlags flags = 0 );
bool   DragFloat3 ( const  char * label, float v[ 3 ], float v_speed = 1 . 0f , float v_min = 0 . 0f , float v_max = 0 . 0f , const  char * format = " %.3f " , ImGuiSliderFlags flags = 0 );
bool   DragFloat4 ( const  char * label, float v[ 4 ], float v_speed = 1 . 0f , float v_min = 0 . 0f , float v_max = 0 . 0f , const  char * format = " %.3f " , ImGuiSliderFlags flags = 0 );
bool   DragFloatRange2 ( const  char * label, float * v_current_min, float * v_current_max, float v_speed = 1 . 0f , float v_min = 0 . 0f , float v_max = 0 . 0f , const  char * format = " %.3f " , const  char * format_max = NULL , ImGuiSliderFlags 标志 = 0 );
bool   DragInt ( const  char * label, int * v, float v_speed = 1 . 0f , int v_min = 0 , int v_max = 0 , const  char * format = " %d " , ImGuiSliderFlags flags = 0 );  //如果 v_min >= v_max 我们没有界限
bool   DragInt2 ( const  char * label, int v[ 2 ], float v_speed = 1 . 0f , int v_min = 0 , int v_max = 0 , const  char * format = " %d " , ImGuiSliderFlags flags = 0 );
bool   DragInt3 ( const  char * label, int v[ 3 ], float v_speed = 1 . 0f , int v_min = 0 , int v_max = 0 , const  char * format = " %d " , ImGuiSliderFlags flags = 0 );
bool   DragInt4 ( const  char * label, int v[ 4 ], float v_speed = 1 . 0f , int v_min = 0 , int v_max = 0 , const  char * format = " %d " , ImGuiSliderFlags flags = 0 );
bool   DragIntRange2 ( const  char * label, int * v_current_min, int * v_current_max, float v_speed = 1 . 0f , int v_min = 0 , int v_max = 0 , const  char * format = " %d " , const  char * format_max = NULL , ImGuiSliderFlags 标志 = 0 );
bool   DragScalar ( const  char * label, ImGuiDataType data_type, void * p_data , float v_speed = 1 . 0f , const  void * p_min = NULL , const  void * p_max = NULL , const  char * format = NULL , ImGuiSliderFlags flags = 0 );
bool   DragScalarN ( const  char * label, ImGuiDataType data_type, void * p_data , int components, float v_speed = 1 . 0f , const  void * p_min = NULL , const  void * p_max = NULL , const  char * format = NULL , ImGuiSliderFlags flags = 0 );

# 小部件：常规滑块
- CTRL+单击任何滑块将它们变成输入框。手动输入的值不会被限制并且可以越界。
- 调整格式字符串以使用前缀、后缀装饰值，或调整编辑和显示精度，例如 "%.3f" -> 1.234; “%5.2f 秒”-> 01.23 秒；"饼干: %.0f" -> 饼干: 1; 等等。
- 格式字符串也可以设置为 NULL 或使用默认格式（“%f”或“%d”）。
- 传统：1.78 之前的 SliderXXX() 函数签名采用最终的 `float power=1.0f' 参数而不是 `ImGuiSliderFlags flags=0' 参数。
  如果您收到将浮点数转换为 ImGuiSliderFlags 的警告，请阅读 https://github.com/ocornut/imgui/issues/3361
bool   SliderFloat ( const  char * label, float * v, float v_min, float v_max, const  char * format = " %.3f " , ImGuiSliderFlags flags = 0 );     //调整格式以使用前缀或后缀装饰值以用于滑块内标签或单位显示。
bool   SliderFloat2 ( const  char * label, float v[ 2 ], float v_min, float v_max, const  char * format = " %.3f " , ImGuiSliderFlags flags = 0 );
bool   SliderFloat3 ( const  char * label, float v[ 3 ], float v_min, float v_max, const  char * format = " %.3f " , ImGuiSliderFlags flags = 0 );
bool   SliderFloat4 ( const  char * label, float v[ 4 ], float v_min, float v_max, const  char * format = " %.3f " , ImGuiSliderFlags flags = 0 );
bool   SliderAngle ( const  char * label, float * v_rad, float v_degrees_min = - 360 . 0f , float v_degrees_max = + 360 . 0f , const  char * format = " %.0f deg " , ImGuiSliderFlags flags = 0 );
bool   SliderInt ( const  char * label, int * v, int v_min, int v_max, const  char * format = " %d " , ImGuiSliderFlags flags = 0 );
bool   SliderInt2 ( const  char * label, int v[ 2 ], int v_min, int v_max, const  char * format = " %d " , ImGuiSliderFlags flags = 0 );
bool   SliderInt3 ( const  char * label, int v[ 3 ], int v_min, int v_max, const  char * format = " %d " , ImGuiSliderFlags flags = 0 );
bool   SliderInt4 ( const  char * label, int v[ 4 ], int v_min, int v_max, const  char * format = " %d " , ImGuiSliderFlags flags = 0 );
bool   SliderScalarN ( const  char * label, ImGuiDataType data_type, void * p_data , int components, const  void * p_min, const  void * p_max, const  char * format = NULL , ImGuiSliderFlags flags = 0 );
bool   VSliderFloat ( const  char * label, const ImVec2& size, float * v, float v_min, float v_max, const  char * format = " %.3f " , ImGuiSliderFlags flags = 0 );
bool   VSliderInt ( const  char * label, const ImVec2& size, int * v, int v_min, int v_max, const  char * format = " %d " , ImGuiSliderFlags flags = 0 );

# 小部件：使用键盘输入
- 如果您想将 InputText() 与 std::string 或任何自定义动态字符串类型一起使用，请参阅 misc/cpp/imgui_stdlib.h 和 imgui_demo.cpp 中的注释。
- 大多数 ImGuiInputTextFlags 标志仅对 InputText() 有用，而不对 InputFloatX、InputIntX、InputDouble 等有用。
bool   InputText ( const  char * label, char * buf, size_t buf_size, ImGuiInputTextFlags flags = 0 , ImGuiInputTextCallback callback = NULL , void * user_data = NULL );
bool   InputTextMultiline ( const  char * label, char * buf, size_t buf_size, const ImVec2& size = ImVec2( 0 , 0 ), ImGuiInputTextFlags flags = 0, ImGuiInputTextCallback callback = NULL, void* user_data = NULL);
bool   InputTextWithHint ( const  char * label, const  char *hint, char * buf, size_t buf_size, ImGuiInputTextFlags flags = 0 , ImGuiInputTextCallback callback = NULL , void * user_data = NULL );
bool   InputFloat ( const  char * label, float * v, float step = 0 . 0f , float step_fast = 0 . 0f , const  char * format = " %.3f " , ImGuiInputTextFlags flags = 0 );
bool   InputFloat2 ( const  char * label, float v[ 2 ], const  char * format = " %.3f " , ImGuiInputTextFlags flags = 0 );
bool   InputFloat3 ( const  char * label, float v[ 3 ], const  char * format = " %.3f " , ImGuiInputTextFlags flags = 0 );
bool   InputFloat4 ( const  char * label, float v[ 4 ], const  char * format = " %.3f " , ImGuiInputTextFlags flags = 0 );
bool   InputInt ( const  char * label, int * v, int step = 1 , int step_fast = 100 , ImGuiInputTextFlags flags = 0 );
bool   InputInt2 ( const  char * label, int v[ 2 ], ImGuiInputTextFlags flags = 0 );
bool   InputInt3 ( const  char * label, int v[ 3 ], ImGuiInputTextFlags flags = 0 );
bool   InputInt4 ( const  char * label, int v[ 4 ], ImGuiInputTextFlags flags = 0 );
bool   InputDouble ( const  char * label, double * v, double step = 0.0 , double step_fast = 0.0 , const  char * format = " %.6f " , ImGuiInputTextFlags flags = 0 );
bool   InputScalar ( const  char * label, ImGuiDataType data_type, void * p_data , const  void * p_step = NULL , const  void * p_step_fast = NULL , const  char * format = NULL , ImGuiInputTextFlags flags = 0 );
bool   InputScalarN ( const  char * label, ImGuiDataType data_type, void * p_data , int components, const  void * p_step = NULL , const  void * p_step_fast = NULL , const  char * format = NULL , ImGuiInputTextFlags flags = 0 );

# 小部件：颜色编辑器/选择器（提示：ColorEdit* 函数有一个小颜色方块，可以左键单击打开选择器，右键单击打开选项菜单。）
- 请注意，在 C++ 中，'float v[X]' 函数参数与 'float* v' _same_，数组语法只是一种记录预期可访问元素数量的方法。
- 您可以从连续结构中传递第一个浮点元素的地址，例如 &myvector.x
bool   ColorEdit3 ( const  char * label, float col[ 3 ], ImGuiColorEditFlags flags = 0 );
bool   ColorEdit4 ( const  char * label, float col[ 4 ], ImGuiColorEditFlags flags = 0 );
bool   ColorPicker3 ( const  char * label, float col[ 3 ], ImGuiColorEditFlags flags = 0 );
bool   ColorPicker4 ( const  char * label, float col[ 4 ], ImGuiColorEditFlags flags = 0 , const  float * ref_col = NULL );
bool   ColorButton ( const  char * desc_id, const ImVec4& col, ImGuiColorEditFlags flags = 0 , ImVec2 size = ImVec2( 0 , 0 )); //显示一个颜色方块/按钮，悬停查看详细信息，按下时返回 true。
void   SetColorEditOptions (ImGuiColorEditFlags);     //如果您想选择默认格式、选择器类型等，则初始化当前选项（通常在应用程序启动时）。除非您将 _NoOptions 标志传递给您的调用，否则用户将能够更改许多设置。

# 小部件：树
- TreeNode 函数在节点打开时返回 true，在这种情况下，您还需要在完成显示树节点内容后调用 TreePop()。
bool   TreeNode ( const  char * label);
bool   TreeNode ( const  char * str_id, const  char * fmt, ...) IM_FMTARGS( 2 );   //帮助器变体以轻松地从显示的字符串中去除 id。阅读有关为什么以及如何使用 ID 的常见问题解答。要在与 TreeNode() 相同的级别对齐任意文本，您可以使用 Bullet()。
bool   TreeNode ( const  void * ptr_id, const  char * fmt, ...) IM_FMTARGS( 2 );   // "
bool   TreeNodeV ( const  char * str_id, const  char * fmt, va_list args) IM_FMTLIST( 2 );
bool   TreeNodeV ( const  void * ptr_id, const  char * fmt, va_list args) IM_FMTLIST( 2 );
bool   TreeNodeEx ( const  char * label, ImGuiTreeNodeFlags flags = 0 );
bool   TreeNodeEx ( const  char * str_id, ImGuiTreeNodeFlags 标志, const  char * fmt, ...) IM_FMTARGS( 3 );
bool   TreeNodeEx ( const  void * ptr_id, ImGuiTreeNodeFlags 标志, const  char * fmt, ...) IM_FMTARGS( 3 );
bool   TreeNodeExV ( const  char * str_id, ImGuiTreeNodeFlags 标志, const  char * fmt, va_list args) IM_FMTLIST( 3 );
bool   TreeNodeExV ( const  void * ptr_id, ImGuiTreeNodeFlags flags, const  char * fmt, va_list args) IM_FMTLIST( 3 );
void   TreePush ( const  char * str_id);       // ~ Indent()+PushId()。返回 true 时已由 TreeNode() 调用，但如果需要，您可以自己调用 TreePush/TreePop。
void   TreePush ( const  void * ptr_id = NULL );// "
void   TreePop ();  // ~ Unindent()+PopId()
float  GetTreeNodeToLabelSpacing ();//当使用 TreeNode*() 或 Bullet() == (g.FontSize + style.FramePadding.x*2) 用于常规无框 TreeNode 时，标签前的水平距离
bool   CollapsingHeader ( const  char * label, ImGuiTreeNodeFlags flags = 0 );  //如果返回“true”，则标头是打开的。不缩进也不推送 ID 堆栈。用户不必调用 TreePop()。
bool   CollapsingHeader ( const  char * label, bool * p_visible, ImGuiTreeNodeFlags flags = 0 ); // when 'p_visible != NULL': if '*p_visible==true' 在标题的右上角显示一个额外的小关闭按钮，单击时将 bool 设置为 false，如果 '*p_visible==false' 不t 显示标题。
void   SetNextItemOpen ( bool is_open, ImGuiCond cond = 0 );  //设置下一个 TreeNode/CollapsingHeader 打开状态。

# 小部件：可选择项
- 悬停时可选择的高亮显示，选中时可以显示另一种颜色。
- 可选择的邻居扩展其高亮边界，以便在它们之间不留空隙。这使一系列选定的 Selectable 看起来是连续的。
bool   Selectable ( const  char * label, bool selected = false , ImGuiSelectableFlags flags = 0 , const ImVec2& size = ImVec2( 0 , 0 )); // "bool selected" 携带选择状态（只读）。单击 Selectable() 时返回 true，因此您可以修改选择状态。size.x==0.0：使用剩余宽度，size.x>0.0：指定宽度。size.y==0.0：使用标签高度，size.y>0.0：指定高度
bool   Selectable ( const  char * label, bool * p_selected, ImGuiSelectableFlags flags = 0 , const ImVec2& size = ImVec2( 0 , 0 ));      // "bool* p_selected" 指向选择状态（读写），作为一个方便的助手。

# 小部件：列表框
- 这本质上是对使用 BeginChild/EndChild 进行一些风格更改的薄包装。
- BeginListBox()/EndListBox() api 允许您通过创建例如 Selectable() 或任何项目来管理您想要的内容和选择状态。
- 简化的/旧的 ListBox() api 是 BeginListBox()/EndListBox() 的帮助器，为了方便起见，它们保持可用。这类似于组合的创建方式。
- 选择框架宽度：size.x > 0.0f: custom / size.x < 0.0f or -FLT_MIN: right-align / size.x = 0.0f (default): use current ItemWidth
- 选择框架高度: size.y > 0.0f: custom / size.y < 0.0f or -FLT_MIN: bottom-align / size.y = 0.0f (default): 任意默认高度，可以容纳~7个项目
bool   BeginListBox ( const  char * label, const ImVec2& size = ImVec2( 0 , 0 )); //打开一个带边框的滚动区域
void   EndListBox ();       //只有在 BeginListBox() 返回 true 时才调用 EndListBox()！
bool   ListBox ( const  char * label, int * current_item, const  char * const items[], int items_count, int height_in_items = - 1 );
bool   ListBox ( const  char * label, int * current_item, bool (*items_getter)( void * data, int idx, const  char ** out_text), void* data, int items_count, int height_in_items = -1);

# 小部件：数据绘图
- 考虑使用 ImPlot (https://github.com/epezent/implot)
void   PlotLines ( const  char * label, const  float * values, int values_count, int values_offset = 0 , const  char * overlay_text = NULL , float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2( 0 , 0 ), int步幅 = sizeof( float ));
void   PlotLines ( const  char * label, float (*values_getter)( void * data, int idx), void* data, int values_count, int values_offset = 0, const char* overlay_text = NULL, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2( 0 , 0 ));
void   PlotHistogram ( const  char * label, const  float * values, int values_count, int values_offset = 0 , const  char * overlay_text = NULL , float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2( 0 , 0 ), int步幅 = sizeof( float ));
void   PlotHistogram ( const  char * label, float (*values_getter)( void * data, int idx), void* data, int values_count, int values_offset = 0, const char* overlay_text = NULL, float scale_min = FLT_MAX, float scale_max = FLT_MAX, ImVec2 graph_size = ImVec2( 0 , 0 ));

# 小部件：Value() 助手。
- 这些只是使用格式字符串调用 Text() 的快捷方式。以“名称：值”格式输出单个值（提示：在代码中自由声明更多来处理您的类型。您可以向 ImGui 命名空间添加函数）
void   Value ( const  char * prefix, bool b);
void   Value ( const  char * prefix, int v);
void   Value ( const  char * 前缀, unsigned  int v);
void   Value ( const  char * prefix, float v, const  char * float_format = NULL );

# 小部件：菜单
- 在窗口 ImGuiWindowFlags_MenuBar 上使用 BeginMenuBar() 以附加到其菜单栏。
- 使用 BeginMainMenuBar() 在屏幕顶部创建一个菜单栏并附加到它。
- 使用 BeginMenu() 创建菜单。您可以使用相同的标识符多次调用 BeginMenu() 以向其附加更多项目。
- 不是 MenuItem() 键盘快捷键是为了方便而显示的，而是亲爱的 ImGui 目前_未处理_。
bool   BeginMenuBar ();     //附加到当前窗口的菜单栏（需要在父窗口上设置 ImGuiWindowFlags_MenuBar 标志）。
void   EndMenuBar ();       //只有在 BeginMenuBar() 返回 true 时才调用 EndMenuBar()！
bool   BeginMainMenuBar (); //创建并附加到全屏菜单栏。
void   EndMainMenuBar ();   //只有在 BeginMainMenuBar() 返回 true 时才调用 EndMainMenuBar()！
bool   BeginMenu ( const  char * label, bool enabled = true );  //创建一个子菜单项。只有在返回 true 时才调用 EndMenu()！
void   EndMenu ();  //只有在 BeginMenu() 返回 true 时才调用 EndMenu()！
bool   MenuItem ( const  char * label, const  char *shortcut = NULL , bool selected = false , bool enabled = true );  //激活时返回真。
bool   MenuItem ( const  char * 标签, const  char * 快捷方式, bool * p_selected, bool enabled = true );      //激活时返回 true + toggle (*p_selected) 如果 p_selected != NULL

# 工具提示
- 工具提示是跟随鼠标的窗口。他们不会分散注意力。
void   BeginTooltip ();     //开始/附加一个工具提示窗口。创建功能齐全的工具提示（包含任何类型的项目）。
void   EndTooltip ();
void   SetTooltip ( const  char * fmt, ...) IM_FMTARGS( 1 );     //设置纯文本工具提示，通常与 ImGui::IsItemHovered() 一起使用。覆盖之前对 SetTooltip() 的任何调用。
void   SetTooltipV ( const  char * fmt, va_list args) IM_FMTLIST( 1 );

# 弹出窗口，模态
- 它们会阻止正常的鼠标悬停检测（以及大多数鼠标交互）在它们后面。
- 如果不是模态：可以通过单击它们外部的任何位置或按 ESCAPE 来关闭它们。
- 它们的可见性状态 (~bool) 是在内部保存的，而不是像我们习惯于使用常规的 Begin*() 调用那样由程序员保存。
- 上面的 3 个属性是相关的：我们需要在库中保留弹出窗口可见性状态，因为弹出窗口可能随时关闭。
- 您可以在调用 IsItemHovered() 或 IsWindowHovered() 时使用 ImGuiHoveredFlags_AllowWhenBlockedByPopup 绕过悬停限制。
- 重要提示：Popup 标识符是相对于当前 ID 堆栈的，因此 OpenPopup 和 BeginPopup 通常需要在堆栈的同一级别。
   这有时会导致令人困惑的错误。将来可能会重做这个。

# 弹出窗口：开始/结束函数
- BeginPopup(): 查询弹出状态，如果打开则开始追加到窗口中。之后调用 EndPopup()。ImGuiWindowFlags 被转发到窗口。
- BeginPopupModal(): 阻止窗口后面的所有交互，不能被用户关闭，添加一个变暗的背景，有一个标题栏。
bool   BeginPopup ( const  char * str_id, ImGuiWindowFlags flags = 0 ); //如果弹出窗口已打开，则返回 true，您可以开始向其输出。
bool   BeginPopupModal ( const  char * name, bool * p_open = NULL , ImGuiWindowFlags flags = 0 ); //如果模态打开，则返回true，您可以开始向其输出。
void   EndPopup (); //只有在 BeginPopupXXX() 返回 true 时才调用 EndPopup()！

# 弹出窗口：打开/关闭函数
- OpenPopup(): 设置弹出状态为打开。ImGuiPopupFlags 可用于打开选项。
- 如果不是模态：可以通过单击它们外部的任何位置或按 ESCAPE 来关闭它们。
- CloseCurrentPopup()：在 BeginPopup()/EndPopup() 范围内使用以手动关闭。
- CloseCurrentPopup() 在激活时默认由 Selectable()/MenuItem() 调用（FIXME：需要一些选项）。
- 使用 ImGuiPopupFlags_NoOpenOverExistingPopup 来避免在同一级别已经有一个弹出窗口时打开一个弹出窗口。这相当于例如在 OpenPopup() 之前测试 !IsAnyPopupOpen()。
- 在 BeginPopup() 之后使用 IsWindowAppearing() 判断窗口是否刚刚打开。
void   OpenPopup ( const  char * str_id, ImGuiPopupFlags popup_flags = 0 );     //调用以将弹出窗口标记为打开（不要调用每一帧！）。
void   OpenPopup (ImGuiID id, ImGuiPopupFlags popup_flags = 0 );     // id 重载以方便从嵌套堆栈调用
void   OpenPopupOnItemClick ( const  char * str_id = NULL , ImGuiPopupFlags popup_flags = 1 );   //当点击最后一项时打开弹出窗口的助手。默认为 ImGuiPopupFlags_MouseButtonRight == 1。（注意：实际触发鼠标 _released_ 事件与弹出行为一致）
void   CloseCurrentPopup ();//手动关闭我们开始进入的弹出窗口。

# 弹出窗口：打开+开始组合函数助手
- 执行 OpenPopup+BeginPopup 的助手，其中通过例如悬停项目和右键单击来触发打开操作。
- 它们便于轻松创建上下文菜单，因此得名。
- 重要提示：请注意，BeginPopupContextXXX 与 OpenPopup() 一样采用 ImGuiPopupFlags，而与 BeginPopup() 不同。为了完全一致，我们将来可能会在 BeginPopupContextXXX 函数中添加 ImGuiWindowFlags。
- 重要提示：我们特别将它们的标志默认为 1 (== ImGuiPopupFlags_MouseButtonRight) 以与采用“int mouse_button = 1”参数的旧 API 向后兼容，因此如果您添加其他标志，请记住重新添加 ImGuiPopupFlags_MouseButtonRight。
bool   BeginPopupContextItem ( const  char * str_id = NULL , ImGuiPopupFlags popup_flags = 1 );  //当点击最后一个项目时打开+开始弹出。使用 str_id==NULL 将弹出窗口与上一项相关联。如果您想在诸如 Text() 之类的非交互式项目上使用它，您需要在此处传入一个显式 ID。阅读 .cpp 中的评论！
bool   BeginPopupContextWindow ( const  char * str_id = NULL , ImGuiPopupFlags popup_flags = 1 ); //在当前窗口上单击时打开+开始弹出。
bool   BeginPopupContextVoid ( const  char * str_id = NULL , ImGuiPopupFlags popup_flags = 1 );  //在void（没有窗口）中单击时打开+开始弹出窗口。

# 弹出窗口：查询函数
- IsPopupOpen()：如果弹出窗口在弹出堆栈的当前 BeginPopup() 级别打开，则返回 true。
- IsPopupOpen() 和 ImGuiPopupFlags_AnyPopupId：如果在弹出堆栈的当前 BeginPopup() 级别打开任何弹出窗口，则返回 true。
- IsPopupOpen() with ImGuiPopupFlags_AnyPopupId + ImGuiPopupFlags_AnyPopupLevel：如果有任何弹出窗口打开，则返回 true。
bool   IsPopupOpen ( const  char * str_id, ImGuiPopupFlags flags = 0 ); //如果弹出窗口已打开，则返回 true。

# 表格
[BETA API] API 可能会稍微进化！如果你使用这个，请在​​它出来时更新到下一个版本！
- 旧列 API 的全功能替代。
- 有关演示代码，请参见 Demo->Tables。
- 有关一般评论，请参阅 imgui_tables.cpp 的顶部。
- 有关可用标志的描述，请参阅 ImGuiTableFlags_ 和 ImGuiTableColumnFlags_ 枚举。

典型的调用流程是：
- 1. 调用 BeginTable()。
- 2. 可选择调用 TableSetupColumn() 以提交列名/标志/默认值。
- 3. 可选地调用 TableSetupScrollFreeze() 以请求滚动冻结列/行。
- 4. 可选择调用 TableHeadersRow() 以提交标题行。名称是从 TableSetupColumn() 数据中提取的。
- 5. 填充内容：
- 在大多数情况下，您可以使用 TableNextRow() + TableSetColumnIndex(N) 开始追加到列中。
- 如果您使用表格作为一种网格，其中每一列都包含相同类型的内容，
     您可能更喜欢使用 TableNextColumn() 而不是 TableNextRow() + TableSetColumnIndex()。
     如果需要，TableNextColumn() 将自动环绕到下一行。
- 重要提示：与旧的 Columns() API 相比，我们需要为第一列调用 TableNextColumn()！
- 可能的调用流程摘要：
------------------------------------------------ -------------------------------------------------- ------
TableNextRow() -> TableSetColumnIndex(0) -> Text("Hello 0") -> TableSetColumnIndex(1) -> Text("Hello 1") // OK
TableNextRow() -> TableNextColumn() -> Text("Hello 0") -> TableNextColumn() -> Text("Hello 1") // OK
TableNextColumn() -> Text("Hello 0") -> TableNextColumn() -> Text("Hello 1") // OK：TableNextColumn() 自动进入下一行！
TableNextRow() -> Text("Hello 0") // 不行！缺少 TableSetColumnIndex() 或 TableNextColumn()！文字不会出现！
------------------------------------------------ -------------------------------------------------- ------
- 5. 调用 EndTable()
bool   BeginTable ( const  char * str_id, int column, ImGuiTableFlags flags = 0 , const ImVec2& outer_size = ImVec2( 0 . 0f , 0 . 0f ), float inner_width = 0.0f);
void   EndTable (); //只有在 BeginTable() 返回 true 时才调用 EndTable()！
void   TableNextRow (ImGuiTableRowFlags row_flags = 0 , float min_row_height = 0 . 0f ); //追加到新行的第一个单元格中。
bool   TableNextColumn ();  //追加到下一列（如果当前在最后一列，则追加到下一行的第一列）。当列可见时返回 true。
bool   TableSetColumnIndex ( int column_n);  //追加到指定的列中。当列可见时返回 true。

# 表格：标题和列声明
- 使用 TableSetupColumn() 来指定标签、调整大小策略、默认宽度/重量、id、各种其他标志等。
- 使用 TableHeadersRow() 创建标题行并自动为每列提交一个 TableHeader()。
  标题需要执行：重新排序、排序和打开上下文菜单。
  也可以使用 ImGuiTableFlags_ContextMenuInBody 在列主体中提供上下文菜单。
- 您可以使用 TableNextRow() + TableHeader() 调用手动提交标题，但这仅在
  一些高级用例（例如在标题行中添加自定义小部件）。
- 使用 TableSetupScrollFreeze() 锁定列/行，以便它们在滚动时保持可见。
void   TableSetupColumn ( const  char * label, ImGuiTableColumnFlags flags = 0 , float init_width_or_weight = 0 . 0f , ImGuiID user_id = 0 );
void   TableSetupScrollFreeze ( int cols, int rows); //锁定列/行，使其在滚动时保持可见。
空隙  TableHeadersRow（）;  //根据提供给 TableSetupColumn() 的数据提交所有标题单元格 + 提交上下文菜单
无效  的tableHeader（常量 字符*标签）;     //手动提交一个标题单元格（很少使用）

# 表格：排序
- 调用 TableGetSortSpecs() 以检索表的最新排序规范。不排序时为 NULL。
- 当 'SpecsDirty == true' 时，您应该对数据进行排序。当排序规范发生变化时，这将是真的
  自上次调用或第一次调用以来。确保在排序后设置 'SpecsDirty = false'，否则你可能
  浪费地对每一帧的数据进行排序！
- Lifetime：不要在多个帧上保持这个指针，也不要超过对 BeginTable() 的任何后续调用。
ImGuiTableSortSpecs*   TableGetSortSpecs ();//获取表的最新排序规范（如果不排序则为 NULL）。

# 表格：杂项功能
- 函数 args 'int column_n' 将默认值 -1 视为与传递当前列索引相同。
int    TableGetColumnCount ();      //返回列数（传递给 BeginTable 的值）
int    TableGetColumnIndex ();      //返回当前列索引。
int    TableGetRowIndex (); //返回当前行索引。
const  char *    TableGetColumnName ( int column_n = - 1 );      //如果列没有由 TableSetupColumn() 声明的名称，则返回 ""。传递 -1 以使用当前列。
ImGuiTableColumnFlags TableGetColumnFlags ( int column_n = - 1 );     //返回列标志，以便您可以查询它们的启用/可见/排序/悬停状态标志。传递 -1 以使用当前列。
void   TableSetColumnEnabled ( int column_n, bool v); //更改用户可访问的列的启用/禁用状态。设置为 false 以隐藏该列。用户可以使用上下文菜单自行更改此设置（在标题中右键单击，或使用 ImGuiTableFlags_ContextMenuInBody 在列正文中单击鼠标右键）
void   TableSetBgColor（ImGuiTableBgTarget 目标，ImU32 颜色，int column_n = - 1）；  //更改单元格、行或列的颜色。有关详细信息，请参阅 ImGuiTableBgTarget_ 标志。

# Legacy Columns API（更喜欢使用表格！）
- 您还可以使用 SameLine(pos_x) 来模拟简化的列。
void   Columns ( int count = 1 , const  char * id = NULL , bool border = true );
void   NextColumn ();       //下一列，如果当前行完成，则默认为当前行或下一行
int    GetColumnIndex ();   //获取当前列索引
float  GetColumnWidth ( int column_index = - 1 );      //获取列宽（以像素为单位）。通过 -1 使用当前列
void   SetColumnWidth ( int column_index, float width);      //设置列宽（以像素为单位）。通过 -1 使用当前列
float  GetColumnOffset ( int column_index = - 1 );     //获取列行的位置（以像素为单位，从内容区域的左侧开始）。通过 -1 使用当前列，否则为 0..GetColumnsCount() 包括。第 0 列通常为 0.0f
void   SetColumnOffset ( int column_index, float offset_x);  //设置列线的位置（以像素为单位，从内容区域的左侧开始）。通过 -1 使用当前列
int    GetColumnsCount ();

# 标签栏，标签
bool   BeginTabBar ( const  char * str_id, ImGuiTabBarFlags flags = 0 );//创建并附加到 TabBar
void   EndTabBar ();//只有在 BeginTabBar() 返回 true 时才调用 EndTabBar()！
bool   BeginTabItem ( const  char * label, bool * p_open = NULL , ImGuiTabItemFlags flags = 0 ); //创建一个标签。如果选择了选项卡，则返回 true。
void   EndTabItem ();       //只有在 BeginTabItem() 返回 true 时才调用 EndTabItem()！
bool   TabItemButton ( const  char * label, ImGuiTabItemFlags flags = 0 );      //创建一个类似于按钮的 Tab。单击时返回 true。无法在标签栏中选择。
void   SetTabItemClosed ( const  char * tab_or_docked_window_label);   //通知 TabBar 或 Docking 系统前面关闭的选项卡/窗口（有助于减少可重新排序的选项卡栏上的视觉闪烁）。对于标签栏：在 BeginTabBar() 之后和 Tab 提交之前调用。否则使用窗口名称调用。

# 记录/捕获
- 从界面输出的所有文本都可以捕获到 tty/file/clipboard 中。默认情况下，树节点在日志记录期间自动打开。
void   LogToTTY ( int auto_open_depth = - 1 ); //开始记录到 tty (stdout)
void   LogToFile ( int auto_open_depth = - 1 , const  char * filename = NULL );   //开始记录到文件
void   LogToClipboard ( int auto_open_depth = - 1 );   //开始记录到操作系统剪贴板
void   LogFinish ();//停止记录（关闭文件等）
void   LogButtons ();       //显示用于记录到 tty/file/clipboard 的按钮的助手
void   LogText ( const  char * fmt, ...) IM_FMTARGS( 1 );//将文本数据直接传递给日志（不显示）
void   LogTextV ( const  char * fmt, va_list args) IM_FMTLIST( 1 );

# 拖放
- 在源项目上，调用 BeginDragDropSource()，如果返回 true 也调用 SetDragDropPayload() + EndDragDropSource()。
- 在目标候选上，调用 BeginDragDropTarget()，如果返回 true 也调用 AcceptDragDropPayload() + EndDragDropTarget()。
- 如果您停止调用 BeginDragDropSource()，则有效负载将被保留，但不会有预览工具提示（我们目前显示后备“...”工具提示，请参阅 #1725）
- 一个项目既可以是拖放源，也可以是放置目标。
bool   BeginDragDropSource (ImGuiDragDropFlags flags = 0 );      //在提交可能被拖动的项目后调用。当返回 true 时，您可以调用 SetDragDropPayload() + EndDragDropSource()
bool   SetDragDropPayload ( const  char * type, const  void * data, size_t sz, ImGuiCond cond = 0 );  // type 是用户定义的最多 32 个字符的字符串。以“_”开头的字符串是为亲爱的 imgui 内部类型保留的。数据由 imgui 复制和保存。
void   EndDragDropSource ();    //只有在 BeginDragDropSource() 返回 true 时才调用 EndDragDropSource()！
bool   BeginDragDropTarget ();  //在提交可能接收有效载荷的项目后调用。如果返回 true，您可以调用 AcceptDragDropPayload() + EndDragDropTarget()
const ImGuiPayload*    AcceptDragDropPayload ( const  char * type, ImGuiDragDropFlags flags = 0 );  //接受给定类型的内容。如果设置了 ImGuiDragDropFlags_AcceptBeforeDelivery，您可以在释放鼠标按钮之前查看有效负载。
void   EndDragDropTarget ();    //仅当 BeginDragDropTarget() 返回 true 时才调用 EndDragDropTarget()！
const ImGuiPayload*    GetDragDropPayload ();   //从任何地方直接查看当前有效负载。可能返回 NULL。使用 ImGuiPayload::IsDataType() 测试负载类型。

# 禁用 [BETA API]
- 禁用所有用户交互和昏暗的项目视觉效果（在当前颜色上应用 style.DisabledAlpha）
- BeginDisabled(false) 本质上没有任何用处，只是为了方便布尔表达式的使用。如果您可以避免调用 BeginDisabled(False)/EndDisabled() 最好避免它。
void   BeginDisabled ( bool disabled = true );
void   EndDisabled ();

# 剪裁
- 鼠标悬停受 ImGui::PushClipRect() 调用的影响，与仅渲染的 ImDrawList::PushClipRect() 直接调用不同。
void   PushClipRect ( const ImVec2& clip_rect_min, const ImVec2& clip_rect_max, bool intersect_with_current_clip_rect);
void   PopClipRect ();

# 焦点，激活
- 当适用于表示“这是默认项目”时，更喜欢使用“SetItemDefaultFocus()”而不是“if (IsWindowAppearing()) SetScrollHereY()”
void   SetItemDefaultFocus ();      //使最后一项成为窗口的默认焦点项。
void   SetKeyboardFocusHere ( int offset = 0 );       //将键盘焦点放在下一个小部件上。使用正“偏移量”访问多组件小部件的子组件。使用 -1 访问以前的小部件。

# 项目/小部件实用程序和查询功能
- 大部分函数都引用了之前提交的 Item。
- 请参阅“小部件->查询状态”下的演示窗口，以获取大多数这些功能的交互式可视化。
bool   IsItemHovered (ImGuiHoveredFlags flags = 0 ); //最后一个项目是悬停的吗？（并且可用，也就是不被弹出窗口等阻止）。有关更多选项，请参阅 ImGuiHoveredFlags。
bool   IsItemActive ();     //最后一项是否有效？（例如按住按钮，编辑文本字段。在项目上按住鼠标按钮时，这将持续返回 true。不交互的项目将始终返回 false）
bool   IsItemFocused ();    //最后一项是键盘/游戏手柄导航的焦点吗？
bool   IsItemClicked (ImGuiMouseButton mouse_button = 0 );   //最后一个项目是否悬停并点击了鼠标？(**) == IsMouseClicked(mouse_button) && IsItemHovered() 重要。(**) 这不等同于例如 Button() 的行为。阅读函数定义中的注释。
bool   IsItemVisible ();    //最后一项是否可见？（项目可能会因为剪切/滚动而看不见）
bool   IsItemEdited ();     //最后一项是否在此帧中修改了其基础值？还是被压了？这通常与许多小部件的“bool”返回值相同。
bool   IsItemActivated ();  //是刚刚激活的最后一个项目（该项目之前处于非活动状态）。
bool   IsItemDeactivated ();//是刚刚变为非活动状态的最后一个项目（项目之前处于活动状态）。对于需要连续编辑的小部件的撤消/重做模式很有用。
bool   IsItemDeactivatedAfterEdit ();       //最后一个项目是否刚刚变为非活动状态并在活动时更改了值？（例如滑块/拖动移动）。对于需要连续编辑的小部件的撤消/重做模式很有用。请注意，您可能会得到误报（某些小部件，例如 Combo()/ListBox()/Selectable() 即使在单击已选择的项目时也会返回 true）。
bool   IsItemToggledOpen ();//是否切换了最后一个项目的打开状态？由 TreeNode() 设置。
bool   IsAnyItemHovered (); //是否有任何项目悬停？
bool   IsAnyItemActive ();  //是否有任何项目处于活动状态？
bool   IsAnyItemFocused (); //是否有任何项目聚焦？
ImVec2 GetItemRectMin ();   //获取最后一项的左上边界矩形（屏幕空间）
ImVec2 GetItemRectMax ();   //获取最后一项（屏幕空间）的右下边界矩形
ImVec2 GetItemRectSize ();  //获取最后一项的大小
void   SetItemAllowOverlap ();      //允许最后一个项目与后续项目重叠。有时使用隐形按钮、可选等来捕捉未使用的区域很有用。
