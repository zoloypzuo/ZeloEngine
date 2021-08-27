# Docking

https://github.com/ocornut/imgui/issues/2109

* 把多个窗口合并到一个窗口的分页
![](https://user-images.githubusercontent.com/8225057/46304087-00035580-c5ae-11e8-8904-f27a9434574a.gif)
* 把窗口吸附到窗口边上
* 多视口，是指可以把imgui窗口拖出Windows窗口独立存在
  * 这个目前仅在Windows上测试通过
  * 这个功能对代码的改动比较大
  
## 接口

### 启用Docking

```cpp
UIManager.EnableDocking
```

### PanelWindow启动Docking

```lua
local DefaultPanelWindowSettings = {
    dockable = true;
}
  ```