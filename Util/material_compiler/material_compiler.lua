-- material_compiler.lua
-- created on 2019/9/28
-- author @zoloypzuo
--
-- 解析shader，自动生成C++层的适配代码
-- 这个功能会比较复杂，有很多独立的部分
-- 1. 顶点着色器输入
-- 找到“VS”这个函数（顶点着色器），把它的参数列表解析一下；生成C++ struct和input layout，初始化和绑定这个输入到渲染管线
--

-- ====
-- 用例1
-- ====
-- 输入：shader代码片段
shader = [[
...
VertexOut VS(float3 iPos : POSITION,
             float3 iNormal : NORMAL,
             float2 iTex0 : TEXCOORD0.
             float2 iTex1 : TEXCOORD1)
...
]]
-- 输出：生成C++ struct
cpp_struct = [[
struct Vertex2
{
  XMFLOAT3 Pos;
  XMFLOAT3 Normal;
  XMFLOAT2 Tex0;
  XMFLOAT2 Tex1;
};
]]
-- 输出：生成C++ dx12 输入布局描述（input layout description）
-- 关注几个参数；有几个目前是固定的，与instancing有关；还有一个是指定寄存器槽，也固定
-- 1. 语义名字，这个就是字符串
-- 2. 语义索引，需要从语义名分离出来
-- 3. 字段偏移，这个我记得c std有offset函数，sizeof表需要自己手工存储一个map
cpp_input_layout_description = [[
D3D12_INPUT_ELEMENT_DESC desc2 [] =
{
  {"POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0},
  {"COLOR", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 12, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0},
  {"TEXCOORD", 0, DXGI_FORMAT_R32G32_FLOAT, 0, 24, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0},
  {"TEXCOORD", 1, DXGI_FORMAT_R32G32_FLOAT, 0, 32, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0}
};
]]

-- ====
-- 用例2
-- ====
cpp_struct = [[
struct Vertex1
{
  XMFLOAT3 Pos;
  XMFLOAT4 Color;
};
]]
cpp_input_layout_description = [[
D3D12_INPUT_ELEMENT_DESC desc1 [] =
{
  {"POSITION", 0, DXGI_FORMAT_R32G32B32_FLOAT, 0, 0, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0},
  {"COLOR", 0, DXGI_FORMAT_R32G32B32A32_FLOAT, 0, 12, D3D12_INPUT_CLASSIFICATION_PER_VERTEX_DATA, 0}
};
]]