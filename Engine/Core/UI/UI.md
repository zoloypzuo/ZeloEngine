# UI

* [ ] ImGui Docking，需要拉分支，自己编译imgui，可以在全部面板写完之后再做
* [x] Font
* [x] Style
* [x] UIManager
* ~~[ ] imgui.ini~~ // 不是很重要，用默认的自动保存即可
* [x] Canvas，类比场景图，我们不需要切Canvas，没必要套一层Canvas
* [ ] ImGui控件，薄封装，脚本封装

## 基本层次结构

Canvas Root > Panel > Widget

Panel和Widget都有ID

# Binding

https://github-wiki-see.page/m/ocornut/imgui/wiki/Bindings

https://github.com/MSeys/sol2_ImGui_Bindings

https://github.com/cimgui/cimgui