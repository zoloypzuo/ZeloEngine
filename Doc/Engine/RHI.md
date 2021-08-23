# RHI

渲染抽象层RHI

## RHI在引擎中的位置

下层是GL调用层（然后是显卡驱动层，然后是显卡硬件）
上层是引擎使用渲染层

## RHI的作用

从使用角度，封装GL调用
引擎其他模块要渲染功能，调用RHI，而不是直接调用GL
比如ImGui的后端，有了RHI之后就不需要那么多图形接口的实现了，直接调用RHI

从引擎开发角度，老的引擎开发会有一个问题，就是引擎到处都是GL调用，RHI作为一个隔离层

## Zelo目前的RHI设计

### 薄封装

薄封装，主要是短期内不会去兼容多种图形接口（DX，Vulkan），直接在GL上封装一层即可

Zelo在使用第三方库时一般是不封装的，因为先用起来，熟悉了再封装

GL是必须封装的，主要是上面提到的RHI好处，还有是用OOP将GL封装一遍，降低使用的心智负担

直接使用GL，到处#include GL头文件，一堆全局变量，全局枚举，和全局函数，非常恶心

### 角色划分

RenderSystem，渲染管理器，初始化GL，维护CPU端的GL状态

RenderCommand，渲染命令抽象，从RenderSystem拆除来，把GL调用封装一遍

Buffer，显存抽象
VertexArray，模型顶点列表，支持顶点索引，支持自定义顶点格式
Framebuffer，RTT

Resource，资源抽象，可以解析的对象
Shader，Texture，有对应独立的GL对象
Model，对应VertexArray

Object，低阶渲染对象，Camera，Light