# UI

* [x] ImGui Docking，需要拉分支，自己编译imgui，可以在全部面板写完之后再做
* [x] Font
* [x] Style
* [x] UIManager
* ~~[ ] imgui.ini~~ // 不是很重要，用默认的自动保存即可
* [x] Canvas，类比场景图，我们不需要切Canvas，没必要套一层Canvas
* [ ] ImGui控件，薄封装，脚本封装
* [ ] 向量类型转换

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

## 封装

不要封装的特别深，要解决问题，不要重新封装回保留模式，那就没有ImGui的意义了

## 模块划分

分三个模块：
1. Window，窗口类
2. UI，控件，对话框，输入
3. Editor，编辑器逻辑

窗口类用SDL代劳

对话框和输入是依赖于Win API的，不过划分在UI部分

