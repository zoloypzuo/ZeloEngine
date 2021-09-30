# ZeloEngine

[![Build Status](https://travis-ci.org/gujans/travis-gtest-cmake-example.svg?branch=master)](https://travis-ci.org/gujans/travis-gtest-cmake-example) [![codecov](https://codecov.io/gh/gujans/travis-gtest-cmake-example/branch/master/graph/badge.svg)](https://codecov.io/gh/gujans/travis-gtest-cmake-example)

It is all about game engine.

自顶向下开发的游戏引擎Demo。

正在施工中。

![Snipaste_2021-09-30_19-41-26](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210930/Snipaste_2021-09-30_19-41-26.1b7emlmhome8.png)

# 动机

* 满足好奇心
* 熟悉游戏引擎架构
* 动手实现一些引擎模块和技术

# 权衡

* 开发效率优先
* 用正确的方法解决问题
* 如无必要，勿增实体

尽可能多的铺功能点，支持更多的平台，渲染接口，来验证架构和接口的扩展性。

不追求最先进的技术，踏实地实践可以完成的功能，把一样东西搞清楚。

勿增实体指的是，不要一拍脑袋就去做，向工程添加没用的东西，不管这个东西是否牛逼

# 特性列表

* Lua脚本
* 前向渲染管线
* 阴影
* 游戏编辑器

# 模块列表

* Core，引擎抽象层
* ImGui，立即绘制UI
* Input，输入
* Lua，脚本
* Math，数学
* Physics，物理
* Profile，性能剖析
* Resource，资源加载
* RHI，抽象渲染层
* Window，窗口
* ECS，实体组件

# 构建 & 依赖管理

目前以VS2019 Win32 Debug日常开发为主。

使用vcpkg来管理C++第三方库依赖，主要是方便，成本低。

引擎本体将所有代码编译为一个可执行文件，避免动态链接。

构建脚本在`Tools/`下，每个目标平台对应一个`buildxxx`脚本。

安装:

* vcpkg
* cmake
* VS2019

使用vcpkg安装依赖：

* spdlog
* glm
* SDL2
* assimp
* stb
* yaml-cpp
* imgui
* glad

运行`Tools\build_vs2019.bat`

## 构建相关笔记

[【ZeloEngine】构建概述 & 构建问题汇总](https://blog.csdn.net/zolo_mario/article/details/117652524)

[【ZeloEngine】跨平台构建](https://blog.csdn.net/zolo_mario/article/details/118087054)

长期更新中

# Roadmap

## Python Prototype

* simple renderer (with PyOpenGL, PyGlfw)
    * directional light
    * texture
    * transform
* game framework
    * stategraph (event-driven, DSL driven)
    * b-tree (sub-tree, DSL driven)
    * entity & components
    * prefab
* GUI & editor
    * imgui (in-game editor)
    * PyQt5 (general editor)
    * scene editor
    * property editor
    * node editor
* physics
    * bullet
    * cyclone

## C++ Runtime

* forward renderer
* lua script support
* scene & transform tree

# Demo

* cyclone physics demo
* forward renderer demo
* TPS AI demo

# 特性规划

* [ ] DSL驱动引擎
    * [x] 多种脚本语言
        * [x] Lua
        * [ ] ~~Python~~
        * [ ] ~~C#~~
    * [x] DSL驱动引擎模块，避免编辑器
        * [x] 行为树
        * [x] 状态机
    * [ ] DSL驱动渲染管线
        * [ ] 可编程渲染管线
        * [ ] 可编程后处理脚本
* [ ] 渲染器原型
    * [ ] RHI
        * [x] OpenGL
        * [ ] OpenGLES
        * [ ] DirectX11
        * [ ] ~~DirectX12~~
        * [ ] ~~Vulkan~~
    * [x] 前向渲染
        * [x] 场景树
        * [x] 模型加载
        * [x] 应用贴图
        * [x] 基本光照
        * [x] 基本阴影
        * [x] 上帝相机
    * [ ] 进阶阴影优化
    * [ ] 材质编辑器
    * [ ] PBR
* [ ] 跨平台支持
    * [x] Windows 10
    * [x] Linux
    * [x] ~~Mac OS X~~
    * [ ] Android
    * [ ] ~~IOS~~
* [x] 游戏逻辑框架
* [x] 脚本支持
* [x] 物理
    * [x] 刚体动力学
    * [x] 碰撞检测
* [x] 寻路
* [ ] 骨骼动画  
* [ ] 多线程引擎架构
* [ ] 跨平台渲染架构
* [ ] 网络引擎
* [ ] 使用引擎完成一个游戏
