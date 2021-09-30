# Game View

用FrameBuffer渲染一个窗口

https://github.com/ocornut/imgui/blob/master/docs/FAQ.md#q-how-can-i-display-an-image-what-is-imtextureid-how-does-it-work
ImTextureID的说明

Image接口

```cpp
void Image(
ImTextureID user_texture_id, 
const ImVec2& size, 
const ImVec2& uv0 = ImVec2(0, 0), 
const ImVec2& uv1 = ImVec2(1,1), 
const ImVec4& tint_col = ImVec4(1,1,1,1), 
const ImVec4& border_col = ImVec4(0,0,0,0));
```
