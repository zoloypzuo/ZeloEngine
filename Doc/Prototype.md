# Prototype

## Python requirement

包依赖管理

```c
venv\Scripts\python.exe -m pip install -r requirements.txt
venv\Scripts\python.exe -m pip freeze > requirements.txt
```

## 本地化

本质上是加一个SID的抽象层，关键是工作流，具体参见《饥荒本地化流程》

## pyimgui

* ImGui建议自己编译，自己Bind，因为更新太快了，官方没空维护Binding
* pyimgui的接口文档仍然值得参考
* 最常见的，将Runtime值封装成控件，可以做抽象
  * 控件，如何交互，表现
  * 数值，Runtime数据，C++可以传指针，python脚本需要传o和属性名
  * 转换，将控件数据与Runtime数据进行双向映射，可以做校验
  * 控件参数
* 更复杂的，并非UI交互的会更加困难

## BT & SG

* 每个项目都有自己的实现，由于烂大街了不值一提
* 工作流和工具链很重要，可视化调试，功能封装，定位问题
* 本质上是一种DSL，而且是提供给策划的，建议有编程能力直接写脚本，辅助调试工具

## Event

* 每个项目都有自己的实现，有多种变体，比如是否使用事件队列

## 图形接口

* 不要在脚本层写，pyopengl能力非常有限，写单文件的Demo可以

## Entity

Entity指游戏中的动态物体，是玩法的载体

理论上，Entity只包含ID，通过组件去组合功能，但是一些常见功能还是会被直接写在Entity类里，相当于缓存

* tag
* SG
* BT
* event

## 输入

* 输入不是特别重要的模块
* 游戏逻辑需要状态和事件两种输入，输入需要的是抽象的接口，可能需要多次映射
* 确定平台是第一件事，能省很多事，因为跨平台输入交互兼容是比较麻烦的
  * PC键鼠/主机手柄/手机
* PC键鼠，首先是平台接口，比如Windows接口
* 手柄有自己的接口
* 手机使用UI来输入
