# UI

* [x] ImGui后端接入
* [x] ImGui Docking，需要拉分支，自己编译imgui，可以在全部面板写完之后再做
* [x] Font
* [x] Style，封装了三套配色，建议用拾色器去配置
* [x] UIManager
* ~~[ ] imgui.ini~~ // 不是很重要，用默认的自动保存即可
* ~~[ ] Canvas~~ // 类比场景图，我们不需要切Canvas，没必要套一层Canvas
* [x] ImGui控件，薄封装，脚本封装
* [x] 向量类型转 Converter
    * [x] Vector类型
    * [x] Color类型，支持RGB等构造
* [ ] -


## 控件

* [x] Button
* [x] InputText
* [ ]

### 控件属性

* idleBackgroundColor，背景色
* disabled，禁用
* content，输入框内容
* lineBreak，换行

## 对话框 Dialog

* [ ] OpenFileDialog
* [ ] SaveFileDialog

# 输入 Input

* [ ] 键盘输入
* [ ] 鼠标输入
* [ ] 剪贴板

## 面板 Panel

* [ ] ProjectHub，启动界面


## 基本层次结构

`Canvas/Root > Panel > Widget`

Panel和Widget都有ID

Panel用map维护，各个Panel的绘制顺序不依赖

Widget用list维护，因为ImGui调用是依赖顺序去绘制的

## 脚本Binding

脚本化是必须的，界面逻辑全部放在脚本写，网上找一个binding自己改一下

https://github-wiki-see.page/m/ocornut/imgui/wiki/Bindings

https://github.com/MSeys/sol2_ImGui_Bindings

https://github.com/cimgui/cimgui

===

对比一下控件的使用，写C++的心智负担非常重

UI框架因为没有经验需要试错，C++重构的成本非常大

```cpp
auto &openProjectButton = CreateWidget<Button>("Open Project");
openProjectButton.ClickedEvent += [this] { /*...*/ };

auto &pathField = CreateWidget<InputText>("");
pathField.ContentChangedEvent += [this, &pathField](std::string content) {
pathField.content = PathParser::MakeWindowsStyle(content);
if (pathField.content != "" && pathField.content.back() !=)
pathField.content +=;
};
```

```lua
local openProjectButton = self:CreateWidget(button.Button, "Open Project")
openProjectButton:AddOnClickHandler(function()
    print("button clicked")
end)

local pathField = self:CreateWidget(input_text.InputText, "?");
```

## 封装

不要封装的特别深，要解决问题，不要重新封装回保留模式，那就没有ImGui的意义了

## 模块划分

分三个模块：
1. Window，窗口类
2. UI，控件，对话框，输入
3. Editor，编辑器逻辑

窗口类用SDL代劳

对话框和输入是依赖于Win API的，不过划分在UI部分

## imgui.ini

存的是layout，编辑器布局，每个panel的位置会保存下来

IniFilename，设置ini位置，没有则不保存

IniSavingRate，保存频率

LoadIniSettingsFromDisk，重载

## 字体

AddFontFromFileTTF，加载字体资源

FontDefault，设置字体资源

Push和Pop，封了一下，但是没做。。

imgui的每个字号都需要单独加载，他估计内部直接加载了一个纹理

# 类型转换

Vector/Color的C API对应float4参数，sol接口层额外构造float4，节约心智负担
