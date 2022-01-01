# ZeloEngine

[//]: # (build status, platform and compiler)

[![Build Status](https://ci.appveyor.com/api/projects/status/43lymnm0g9083f38?svg=true)](https://ci.appveyor.com/project/Zolo-mario/zeloengine)
![Platform](https://img.shields.io/badge/platforms-Windows-blue)
![Compiler](https://img.shields.io/badge/MSVC-2019-ff69b4.svg)

[//]: # (repo status)

![Release](https://img.shields.io/github/v/release/zoloypzuo/ZeloEngine)
![Size](https://img.shields.io/github/repo-size/zoloypzuo/ZeloEngine)
![Licence](https://img.shields.io/github/license/zoloypzuo/ZeloEngine)
![Issues](https://img.shields.io/github/issues-raw/zoloypzuo/ZeloEngine.svg)
![PR](https://img.shields.io/github/issues-pr-raw/zoloypzuo/ZeloEngine)
[![Activity](https://img.shields.io/github/commit-activity/m/zoloypzuo/ZeloEngine.svg)](https://github.com/zoloypzuo/ZeloEngine/pulse)

[//]: # (interaction)

[comment]: <> ([![Gitter]&#40;https://badges.gitter.im/ZeloEngine/community.svg&#41;]&#40;https://gitter.im/ZeloEngine/community ?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&#41;)

[//]: # (code scene)

[![CodeScene Code Health](https://codescene.io/projects/12197/status-badges/code-health)](https://codescene.io/projects/12197)
[![CodeScene System Mastery](https://codescene.io/projects/12197/status-badges/system-mastery)](https://codescene.io/projects/12197)

<a target="_top" href="https://flamingtext.com/" ><img src="https://blog.flamingtext.com/blog/2021/12/10/flamingtext_com_1639115962_727159265.png" border=" 0" alt="Logo Design by FlamingText.com" title="Logo Design by FlamingText.com"></a>

> It is all about game engine.

Game engine Demo developed in top-down approach.

Under construction.

## Feature list

* Lua scripting
* Forward rendering pipeline
* Directional light shadow (PCF)
* ImGui in-game editor

## Build Instruction

[[ZeloEngine] Buildion Overview & Summary of Buildion Issues](https://blog.csdn.net/zolo_mario/article/details/117652524)

Currently, VS2019 Win32 Debug is used as daily development and CI maintenance, and the build of other platforms is not maintained.

Vcpkg is used to manage C++ third-party library dependencies, mainly for convenience and low cost.

Development environment installation:

* cmake (3.18+)
* Visual Studio 2019

One-click download and initialization of dependencies:

Run `Tools/Setup/setup.bat`

One-click construction:

Run `Tools/Build/build_vs2019.bat`

One-click operation:

Run `build_vs2019/bin/Hello.exe`

## Demo

Code Binary：

[Release v0.5 ZeloEngineBinary.zip](https://github.com/zoloypzuo/ZeloEngine/releases/tag/v0.5)

Art resources:

Download and unzip it to the root directory `Resource`, only the lastest art resources corresponding to the latest version of the code is kept. 

[Resource.zip](https://1drv.ms/u/s!AtVMh2FmVQ2aanRFvNFlHOprqRI?e=IbSybb)

## Third Party Library

(Run `Tools/export_requirement.py`)

[List of third-party libraries @Doc/ThirdParty.md](Doc/ThirdParty.md)

## Documentation

The document is located in `Doc/`, which mainly introduces design ideas. There is currently no plan for user-end development.

[More documents and articles @CSDN](https://blog.csdn.net/zolo_mario/category_10949225.html)

## screenshot

[More Demo screenshot instructions @Doc/Demo.md](Doc/Demo.md)

Editor
![Snipaste_2021-09-30_19-41-26](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210930/Snipaste_2021-09-30_19-41-26.1b7emlmhome8.png)

Shadow Map
![Snipaste_2021-10-21_00-41-23](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211021/Snipaste_2021-10-21_00-41-23.1ukj4tev8bgg.png)

Mesh Scene
![Snipaste_2021-12-01_23-04-50](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211201/Snipaste_2021-12-01_23-04-50.79gl1230jf40.png)

Transparent
![Snipaste_2021-12-01_23-05-04](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211201/Snipaste_2021-12-01_23-05-04.2g5wkodjr6as.png)

## Game Engine Architecture

![fig-runtime-arch](https://raw.githubusercontent.com/zolo-mario/image-host/main/20220101/fig-runtime-arch.7bxat45r9xk0.jpg)
