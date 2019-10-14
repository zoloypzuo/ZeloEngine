# ZeloEngine

It is all about game engine.

## 安装指南

### 安装前提

* Windows10 操作系统
* Visual Studio 2019
* DirectX12（安装VS时勾选C++桌面应用安装win sdk时附带了dx）
* TODO，其他（没空管）

### 安装步骤

点击install.bat

## 使用Lua脚本工具

`Util`目录下大部分是lua写的工具模块

这些模块可以独立使用

你可以开启一个cmd.exe，输入`lua -e "require 'cmake_compiler'"`来启动`Util/cmake_compiler/cmake_compiler.lua`

这个脚本会加载lua配置，生成CMakeList.txt，重新生成和构建Visual Studio项目

## 目录结构

### 顶层目录概览

目录名 | 描述
---- | ----
build | 构建（临时目录）
Config | 引擎配置文件
Example | 使用引擎的示例项目
External | 第三方库
Lib | 库（临时目录）
Reference | 参考书籍和项目
Src | 引擎源码
Util | 引擎工具

### 一个更加深入的目录描述

```batch
├─build  // 构建（临时目录）
├─Config  // 配置文件
│  └─LuaConfig
│      ├─CppConfigClass_Generated  // 生成的C++类（临时目录）
│      └─LuaConfigClass
├─Example  // 示例项目
│  └─Init-Direct3D  // Direct3D12的HelloWorld
├─External  // 第三方库
│  ├─DirectXTK12
│  └─lua-5.3.5
├─Lib  // 第三方库编译出的库
│  └─Win32Debug
├─Reference  // 参考书籍和项目
│  ├─c-programming-a-modern-approach
│  ├─cmake-practice
│  ├─cyclone-physics
│  ├─d3d12book
│  ├─DontStarveScript
│  ├─GameEngineFromScratch
│  ├─Lua-Game-AI-Programming
│  ├─Programming_in_Lua_4th
│  ├─UnityCsReference
│  └─zept-game-engine
├─Src  // 引擎源码
│  ├─Common  // 通用inbox
│  ├─Framework  // 底层框架：渲染和物理
│  ├─Module  // 上层模块
│  │  └─LuaModule  // Lua相关模块，为引擎接入Lua编程语言
│  ├─ResourceManager  // 中层：资源管理
│  ├─Script  // Lua脚本
│  └─ZeloMain  // 引擎入口
└─Util  // 引擎工具
    ├─build_util
    ├─cmake_compiler
    ├─install_util
    ├─lua_binding_doc_compiler
    ├─lua_config_compiler
    ├─material_compiler
    └─windows_batch_compiler
```
