# 窗口滚动
float GetScrollX ();      //获取滚动量 [0 .. GetScrollMaxX()]
float GetScrollY ();      //获取滚动量 [0 .. GetScrollMaxY()]
void  SetScrollX ( float scroll_x); //设置滚动量 [0 .. GetScrollMaxX()]
void  SetScrollY ( float scroll_y); //设置滚动量 [0 .. GetScrollMaxY()]
float GetScrollMaxX ();   //获取最大滚动量~~ ContentSize.x - WindowSize.x - DecorationsSize.x
float GetScrollMaxY ();   //获取最大滚动量~~ ContentSize.y - WindowSize.y - DecorationsSize.y
void  SetScrollHereX ( float center_x_ratio = 0 . 5f );  //调整滚动量以使当前光标位置可见。center_x_ratio=0.0：左，0.5：中心，1.0：右。当用于使“默认/当前项目”可见时，请考虑改用 SetItemDefaultFocus()。
void  SetScrollHereY ( float center_y_ratio = 0 . 5f );  //调整滚动量以使当前光标位置可见。center_y_ratio=0.0：顶部，0.5：中心，1.0：底部。当用于使“默认/当前项目”可见时，请考虑改用 SetItemDefaultFocus()。
void  SetScrollFromPosX ( float local_x, float center_x_ratio = 0 . 5f );  //调整滚动量以使给定位置可见。通常 GetCursorStartPos() + offset 来计算有效位置。
void  SetScrollFromPosY ( float local_y, float center_y_ratio = 0 . 5f );  //调整滚动量以使给定位置可见。通常 GetCursorStartPos() + offset 来计算有效位置。

# 参数栈（共享）
void  PushFont (ImFont* 字体);     //使用NULL作为推送默认字体的快捷方式
void  PopFont ();
void  PushStyleColor (ImGuiCol idx, ImU32 col);      //修改样式颜色。如果在 NewFrame() 之后修改样式，请始终使用它。
void  PushStyleColor (ImGuiCol idx, const ImVec4& col);
void  PopStyleColor ( int count = 1 );
void  PushStyleVar (ImGuiStyleVar idx, float val);   //修改样式浮动变量。如果在 NewFrame() 之后修改样式，请始终使用它。
void  PushStyleVar (ImGuiStyleVar idx, const ImVec2& val);    //修改样式 ImVec2 变量。如果在 NewFrame() 之后修改样式，请始终使用它。
void  PopStyleVar ( int count = 1 );
void  PushAllowKeyboardFocus ( bool allow_keyboard_focus );     // == 制表位启用。允许使用 TAB/Shift-TAB 聚焦，默认启用，但您可以为某些小部件禁用它
void  PopAllowKeyboardFocus ();
void  PushButtonRepeat（布尔重复）；       //在 'repeat' 模式下，Button*() 函数以类型方式返回重复的 true（使用 io.KeyRepeatDelay/io.KeyRepeatRate 设置）。请注意，您可以在任何 Button() 之后调用 IsItemActive() 来判断按钮是否在当前帧中。
void  PopButtonRepeat ();

# 参数栈（当前窗口）
void  PushItemWidth ( float item_width);     //为常见的大型“项目+标签”小部件推送项目的宽度。>0.0f：以像素为单位的宽度，<0.0f 将 xx 像素对齐到窗口右侧（因此 -FLT_MIN 始终将宽度对齐到右侧）。
void  PopItemWidth ();
void  SetNextItemWidth ( float item_width);  //设置 _next_ 公共大“项目+标签”小部件的宽度。>0.0f：以像素为单位的宽度，<0.0f 将 xx 像素对齐到窗口右侧（因此 -FLT_MIN 始终将宽度对齐到右侧）
float CalcItemWidth ();   //给定推送设置和当前光标位置的项目宽度。与大多数“项目”功能不同，不一定是最后一个项目的宽度。
void  PushTextWrapPos ( float wrap_local_pos_x = 0 . 0f );        //为 Text*() 命令推送自动换行位置。< 0.0f：没有包裹；0.0f：换行到窗口（或列）的末尾；> 0.0f: 在窗口局部空间中的 'wrap_pos_x' 位置换行
void  PopTextWrapPos ();
