# 内容区域

// - 从给定点检索可用空间。GetContentRegionAvail() 通常很有用。
// - 这些函数肯定会被重新设计（它们令人困惑、不完整，并且最小/最大返回值在局部窗口坐标中，这会增加混淆）
IMGUI_API ImVec2         GetContentRegionAvail ();                                        // == GetContentRegionMax() - GetCursorPos()
IMGUI_API ImVec2         GetContentRegionMax ();                                          //当前内容边界（通常是窗口边界，包括滚动或当前列边界），以窗口坐标表示
IMGUI_API ImVec2         GetWindowContentRegionMin ();                                    //内容边界 min (大致 (0,0)-Scroll)，在窗口坐标中
IMGUI_API ImVec2         GetWindowContentRegionMax ();                                    //内容边界最大（大约 (0,0)+Size-Scroll），其中大小可以用 SetNextWindowContentSize() 覆盖，在窗口坐标中
IMGUI_API float          GetWindowContentRegionWidth ();                                  //


# 样式读取访问
// - 使用样式编辑器（ShowStyleEditor() 函数）以交互方式查看颜色是什么）
ImFont*        GetFont ();                                                      //获取当前字体
float          GetFontSize ();                                                  //获取应用当前比例的当前字体的当前字体大小（= 以像素为单位的高度）
ImVec2         GetFontTexUvWhitePixel ();                                       //获取一段时间像素的 UV 坐标，有助于通过 ImDrawList API 绘制自定义形状
ImU32          GetColorU32 (ImGuiCol idx, float alpha_mul = 1 . 0f );              //使用样式 alpha 和可选的额外 alpha 乘数检索给定的样式颜色，打包为适合 ImDrawList 的 32 位值
ImU32          GetColorU32 ( const ImVec4& col);                                 //检索应用了样式 alpha 的给定颜色，打包为适合 ImDrawList 的 32 位值
ImU32          GetColorU32 (ImU32 col);                                         //检索应用了样式 alpha 的给定颜色，打包为适合 ImDrawList 的 32 位值
const ImVec4& GetStyleColorVec4 (ImGuiCol idx);                                //检索存储在 ImGuiStyle 结构中的样式颜色。用于反馈到 PushStyleColor()，否则使用 GetColorU32() 获取带有样式 alpha 烘焙的样式颜色。
