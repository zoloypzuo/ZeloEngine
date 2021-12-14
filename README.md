# ZeloEngine

[//]: # (build status)

[![Build Status](https://ci.appveyor.com/api/projects/status/43lymnm0g9083f38?svg=true)](https://ci.appveyor.com/project/Zolo-mario/zeloengine)

[//]: # (platform and compiler)

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

[![Gitter](https://badges.gitter.im/ZeloEngine/community.svg)](https://gitter.im/ZeloEngine/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge)

[//]: # (code scene)

[![CodeScene Code Health](https://codescene.io/projects/12197/status-badges/code-health)](https://codescene.io/projects/12197)
[![CodeScene System Mastery](https://codescene.io/projects/12197/status-badges/system-mastery)](https://codescene.io/projects/12197)

<a target="_top" href="https://flamingtext.com/" ><img src="https://blog.flamingtext.com/blog/2021/12/10/flamingtext_com_1639115962_727159265.png" border="0" alt="Logo Design by FlamingText.com" title="Logo Design by FlamingText.com"></a>

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

[Doc/ThirdParty.md](Doc/ThirdParty.md)

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
