# ZeloEngine

[![Build Status](https://travis-ci.org/gujans/travis-gtest-cmake-example.svg?branch=master)](https://travis-ci.org/gujans/travis-gtest-cmake-example) [![codecov](https://codecov.io/gh/gujans/travis-gtest-cmake-example/branch/master/graph/badge.svg)](https://codecov.io/gh/gujans/travis-gtest-cmake-example)

It is all about game engine.

自顶向下开发的游戏引擎Demo

# 动机

* 满足好奇心
* 熟悉游戏引擎架构
* 动手实现一些引擎模块和技术

# 目标

* DSL驱动引擎
    * 多种脚本语言，C#，Python，Lua
    * DSL驱动引擎模块，避免编辑器（行为树，状态机etc）
    * DSL驱动渲染管线（可编程渲染管线，frame graph）
* 多线程引擎架构
* 网络引擎

# Trade off

* 开发效率优先
* 用正确的方法解决问题

尽可能多的铺功能点，支持更多的平台，渲染接口，来验证架构和接口的扩展性

把事情做对，不要只是把事情做了

# 构建

目前以VS2019 Win32为主，使用vcpkg来管理C++第三方库依赖

首先使用vcpkg安装依赖：
* spdlog
* glm
* SDL2
* assimp
* stb
* yaml-cpp
* imgui

然后运行`Tools\build_vs2019.bat`

# Feature

Python prototype
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

# Demo

* cyclone physics demo

# Platform

* Windows 10
* Mac OS X
* MORE WORK TO DO
