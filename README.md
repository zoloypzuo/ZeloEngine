# ZeloEngine

[![Build status](https://ci.appveyor.com/api/projects/status/43lymnm0g9083f38?svg=true)](https://ci.appveyor.com/project/Zolo-mario/zeloengine)
[![codecov](https://codecov.io/gh/gujans/travis-gtest-cmake-example/branch/master/graph/badge.svg)](https://codecov.io/gh/gujans/travis-gtest-cmake-example)
![msvc2017+](https://img.shields.io/badge/MSVC-2017+-ff69b4.svg)
[![Gitter](https://badges.gitter.im/ZeloEngine/community.svg)](https://gitter.im/ZeloEngine/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

<img alt="platforms" src="https://img.shields.io/badge/platforms-Windows-blue?style=flat-square"/></a>
<img alt="release" src="https://img.shields.io/github/v/release/zoloypzuo/ZeloEngine?style=flat-square"/></a>
<img alt="size" src="https://img.shields.io/github/repo-size/zoloypzuo/ZeloEngine?style=flat-square"/></a>
<br/>
<img alt="issues" src="https://img.shields.io/github/issues-raw/zoloypzuo/ZeloEngine.svg?color=yellow&style=flat-square"/></a>
<img alt="pulls" src="https://img.shields.io/github/issues-pr-raw/zoloypzuo/ZeloEngine?color=yellow&style=flat-square"/></a>
<br/>
<img alt="license" src="https://img.shields.io/github/license/zoloypzuo/ZeloEngine?color=green&style=flat-square"/></a>
<br/>
</p>

[![CodeScene Code Health](https://codescene.io/projects/12197/status-badges/code-health)](https://codescene.io/projects/12197)
[![CodeScene System Mastery](https://codescene.io/projects/12197/status-badges/system-mastery)](https://codescene.io/projects/12197)
[![CodeScene Missed Goals](https://codescene.io/projects/12197/status-badges/missed-goals)](https://codescene.io/projects/12197)

![](https://codescene.io/projects/12197/status.svg)

> It is all about game engine.

自顶向下开发的游戏引擎Demo。

正在施工中。

## 特性列表

* Lua脚本
* 前向渲染管线
* 平行光阴影（PCF）
* 游戏编辑器

## 构建

[【ZeloEngine】构建概述 & 构建问题汇总](https://blog.csdn.net/zolo_mario/article/details/117652524)

目前以VS2019 Win32 Debug作为日常开发和CI维护，其他平台的构建不维护。

使用vcpkg来管理C++第三方库依赖，主要是方便，成本低。

开发环境安装:

* cmake
* VS2019

一键下载和初始化依赖：

运行`Tools\Setup\setup.bat`

一键构建：

运行`Tools\Build\build_vs2019.bat`

一键运行：

运行`build_vs2019\bin\Hello.exe`

美术资源分发暂时没找到比较好的方案，TODO WIP

## 第三方库

(运行`Tools\export_requirement.py`)

build from source:
* imgui
* lua
* luabitop
* optick
* sol2
* stacktrace
* vcpkg
* whereami

build from vcpkg:
* assimp
* curl
* glad
* glfw3
* gli
* glm
* nativefiledialog
* rapidjson
* sdl2
* spdlog
* sqlite3
* taskflow

## 文档

文档位于`Doc/`，主要是介绍设计思路，目前没有面向用户端开发的打算。

## 截图

![Snipaste_2021-09-30_19-41-26](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210930/Snipaste_2021-09-30_19-41-26.1b7emlmhome8.png)

Edge

![Snipaste_2021-10-17_21-48-52](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211017/Snipaste_2021-10-17_21-48-52.4uwaoph4mxa0.png)

Blur

![Snipaste_2021-10-18_11-33-53](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211018/Snipaste_2021-10-18_11-33-53.32tz2wzhidm0.png)

Shadow Map

![Snipaste_2021-10-21_00-41-23](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211021/Snipaste_2021-10-21_00-41-23.1ukj4tev8bgg.png)

MC
![mc](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211124/mc.4lfwn87vrla0.gif)

PBR

![Snipaste_2021-12-01_23-10-31](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211201/Snipaste_2021-12-01_23-10-31.18mulvpf469s.png)

gltf

![Snipaste_2021-12-01_23-04-50](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211201/Snipaste_2021-12-01_23-04-50.79gl1230jf40.png)

![Snipaste_2021-12-01_23-05-04](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211201/Snipaste_2021-12-01_23-05-04.2g5wkodjr6as.png)
