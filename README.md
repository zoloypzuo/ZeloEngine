# ZeloEngine

[![Build Status](https://travis-ci.org/gujans/travis-gtest-cmake-example.svg?branch=master)](https://travis-ci.org/gujans/travis-gtest-cmake-example) [![codecov](https://codecov.io/gh/gujans/travis-gtest-cmake-example/branch/master/graph/badge.svg)](https://codecov.io/gh/gujans/travis-gtest-cmake-example)

It is all about game engine.

自顶向下开发的游戏引擎Demo。

正在施工中。

![Snipaste_2021-09-30_19-41-26](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210930/Snipaste_2021-09-30_19-41-26.1b7emlmhome8.png)

Edge

![Snipaste_2021-10-17_21-48-52](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211017/Snipaste_2021-10-17_21-48-52.4uwaoph4mxa0.png)

Blur

![Snipaste_2021-10-18_11-33-53](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211018/Snipaste_2021-10-18_11-33-53.32tz2wzhidm0.png)

Bloom

![Snipaste_2021-10-18_17-49-56](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211018/Snipaste_2021-10-18_17-49-56.4hhw6w5wj64.png)

Shadow Map

![Snipaste_2021-10-21_00-41-23](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211021/Snipaste_2021-10-21_00-41-23.1ukj4tev8bgg.png)

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

NOTE 请把vcpkg装在`ThirdParty\Vcpkg`目录下

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

长期更新中

# 文档

文档位于`Doc/`，主要是介绍设计思路，目前没有面向UserEnd开发的打算
