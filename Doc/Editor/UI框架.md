# UI框架

## 基本架构

ImGui(C++) => sol wrapper => ImGui(Lua) => ImGui Framework

框架主要是做一个薄封装和分类，便于开发

## 薄封装

ImGui接口本身都是全局函数，有两个问题：
* 没有做分类，量很大，从开发者角度有一些冗余
  * 同样功能不同接口二选一，Column和Table
  * 实际用不到的
  * 过时的接口
  * beta接口
* 脚本绑定后Lua接口和C接口的差异
* ImGui更新（docking分支目前仍然不是主分支），后向兼容性的风险

## 分类

* panel
* widget
* layout
* plugin

## 脚本绑定减少重载

既然脚本层封装了，那么绑定层就不要提供太多重载，影响性能

以MenuItem为例，下面这样写太复杂了，封装成一个接口就可以了

```cpp
bool MenuItem ( const  char * label, const  char *shortcut = NULL , bool selected = false , bool enabled = true );  
激活时返回真。

bool MenuItem ( const  char * label, const  char * shortcut, bool * p_selected, bool enabled = true );    
激活时返回 true + toggle (*p_selected) 如果 p_selected != NULL
```

```cpp
inline bool MenuItem(const std::string &label) { return ImGui::MenuItem(label.c_str()); }

inline bool MenuItem(const std::string &label, const std::string &shortcut) {
    return ImGui::MenuItem(label.c_str(), shortcut.c_str());
}

inline std::tuple<bool, bool> MenuItem(const std::string &label, bool selected) {
    bool activated = ImGui::MenuItem(label.c_str(), nullptr, &selected);
    return std::make_tuple(selected, activated);
}

inline std::tuple<bool, bool> MenuItem(const std::string &label, const std::string &shortcut, bool selected) {
    bool activated = ImGui::MenuItem(label.c_str(), shortcut.c_str(), &selected);
    return std::make_tuple(selected, activated);
}

inline std::tuple<bool, bool> MenuItem(const std::string &label, const std::string &shortcut, bool selected,
                                       bool enabled) {
    bool activated = ImGui::MenuItem(label.c_str(), shortcut.c_str(), &selected, enabled);
    return std::make_tuple(selected, activated);
}
```

```lua
--- Parameters A: text (label), text (shortcut) [0]
--- Parameters B: text (label), text (shortcut), bool (selected)
--- Parameters C: text (label), bool (selected)
--- Returns A: bool (activated)
--- returns B: bool (selected), bool (activated)
--- Overloads
--- activated = ImGui.MenuItem("Label")
--- activated = ImGui.MenuItem("Label", "ALT+F4")
--- selected, activated = ImGui.MenuItem("Label", selected)
--- selected, activated = ImGui.MenuItem("Label", "ALT+F4", selected)
--- selected, activated = ImGui.MenuItem("Label", "ALT+F4", selected, true)
--- ```
function ImGui.MenuItem(label, shortcut, selected) end
```