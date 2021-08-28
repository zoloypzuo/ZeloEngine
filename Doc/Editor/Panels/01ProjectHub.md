# ProjectHub

这是一个Boot界面，设计为函数式接口，Run返回启动参数

![](https://cdn.jsdelivr.net/gh/zolo-mario/image-host@main/20210712/Snipaste_2021-08-20_17-30-09.3k96ueo1ysu0.png)

属性和Editor是一样的，不过会去掉一些资源等

因为我们需要一个纯imgui界面去获取用户输入的路径

## 窗口

整个窗口只有一个Panel

## 第一行 FirstLine

pathField输入内容改变时，路径resolve成windows的格式，刷新Go按钮，路径非法则禁用Go

openProjectButton，创建一个对话框，注册对应路径

newProjectButton，创建新项目

## 项目列表 ProjectList

然后读取project.ini（APPDATA临时文件），每一行是缓存的项目路径ID

生成每一行，包含打开和删除项目两个按钮

## 主循环

他直接创建了一个类似编辑器的小的主循环，确认后退出，返回参数

```c++
// ProjectHub ctor
// { Start SetupContext();
// ...
// } End SetupContext()

m_mainPanel = std::make_unique<ProjectHubPanel>(
    m_readyToGo, m_projectPath, m_projectName);

// Run
m_uiManager->SetCanvas(m_canvas);
m_canvas.AddPanel(*m_mainPanel);

m_renderer->SetClearColor(0.f, 0.f, 0.f, 1.f);

while (!m_window->ShouldClose()) {
    m_renderer->Clear();
    m_device->PollEvents();
    m_uiManager->Render();
    m_window->SwapBuffers();

    if (!m_mainPanel->IsOpened())
        m_window->SetShouldClose(true);
}

return {m_readyToGo, m_projectPath, m_projectName};
```