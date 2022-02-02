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

[comment]: <> ([![Gitter]&#40;https://badges.gitter.im/ZeloEngine/community.svg&#41;]&#40;https://gitter.im/ZeloEngine/community?utm_source=badge&utm_medium=badge&utm_campaign=pr-badge&#41;)

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

[完整特性列表 @Doc/FeatureList.md](Doc/FeatureList.md)

## 构建

[【ZeloEngine】构建概述 & 构建问题汇总](https://blog.csdn.net/zolo_mario/article/details/117652524)

目前以VS2019 Win32 Debug作为日常开发和CI维护，其他平台的构建不维护。

使用vcpkg来管理C++第三方库依赖，主要是方便，成本低。

开发环境安装:

* cmake（3.18+）
* VS2019

一键下载和初始化依赖：

运行`Tools/Setup/setup.bat`

一键构建：

运行`Tools/Build/build_vs2019.bat`

一键运行：

运行`build_vs2019/bin/Hello.exe`

## Demo

在Release页下载程序二进制包和美术资源包

[Release v0.5](https://github.com/zoloypzuo/ZeloEngine/releases/tag/v0.5)

![Snipaste_2022-02-02_18-11-46](https://raw.githubusercontent.com/zolo-mario/image-host/main/Snipaste_2022-02-02_18-11-46.2lblvz9b6rq0.webp)

下载解压到根目录`Resource`即可

[【ZeloEngine】Demo演示视频](https://www.bilibili.com/video/BV1vq4y1c7f8/)


## 第三方库

(运行`Tools/export_requirement.py`)

[第三方库清单 @Doc/ThirdParty.md](Doc/ThirdParty.md)

## 文档

文档位于`Doc/`，主要是介绍设计思路，目前没有面向用户端开发的打算。

[更多文档和文章 @CSDN](https://blog.csdn.net/zolo_mario/category_10949225.html)

## 游戏引擎架构

![game-engine-arch-zh](https://raw.githubusercontent.com/zolo-mario/image-host/main/game-engine-arch-zh.4ahd0n4fx7e0.webp)

## 截图

[更多Demo截图说明 @Doc/Demo.md](Doc/Demo.md)

![Snipaste_2021-09-30_19-41-26](https://raw.githubusercontent.com/zolo-mario/image-host/main/20210930/Snipaste_2021-09-30_19-41-26.1b7emlmhome8.png)

![Snipaste_2021-10-21_00-41-23](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211021/Snipaste_2021-10-21_00-41-23.1ukj4tev8bgg.png)

![Snipaste_2021-12-01_23-04-50](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211201/Snipaste_2021-12-01_23-04-50.79gl1230jf40.png)

![Snipaste_2021-12-01_23-05-04](https://raw.githubusercontent.com/zolo-mario/image-host/main/20211201/Snipaste_2021-12-01_23-05-04.2g5wkodjr6as.png)

![Snipaste_2022-02-02_14-43-09](https://raw.githubusercontent.com/zolo-mario/image-host/main/20220121/Snipaste_2022-02-02_14-43-09.2z3rnhogwck0.webp)
