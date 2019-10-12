# ZeloEngine
 
It is all about game engine.

## 安装指南

### 安装前提

* Windows10 操作系统
* Visual Studio 2019
* DirectX12（安装VS时勾选C++桌面应用安装win sdk时附带了dx）
* TODO，其他

### 安装步骤

点击install.bat

## 使用Lua脚本工具

`Util`目录下大部分是lua写的工具模块

这些模块可以独立使用

你可以开启一个cmd.exe，输入`lua -e "require 'cmake_compiler'"`来启动`Util/cmake_compiler/cmake_compiler.lua`

这个脚本会加载lua配置，生成CMakeList.txt，重新生成和构建Visual Studio项目