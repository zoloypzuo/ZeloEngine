# ZeloEngine
 
It is all about game engine.

## 安装指南

### 安装前提

* Windows10 操作系统
* Visual Studio 2017
* DirectX11（安装VS2017时勾选C++桌面应用安装win api时附带了dx11）

### 安装步骤

在根目录下点击cmake.bat，等待构建；

然后到根目录下新建的build目录下点击ZeloEngine.sln，打开VS2017项目，即可运行

## 3rdParty

目前三个第三方库，都在Github上有，直接搜索很容易获得

目前的构建工作流比较原始，每个第三方库就是Github上弄下来的样子；直接构建，生成的lib和pdb放到ZeloEngine/Lib目录下

考虑到ZeloEngine长期都会在当前的配置下工作，所以不过度地优化工作流
