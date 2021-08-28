# Lua驱动配置

给C++的配置，需要导表工具生成C++配置类

下面这个配置类，需要支持：
1. 强类型读写，不要像json那样的接口
2. 序列化
3. 热更

这个需求在《游戏引擎架构》里已经实现过了，不需要搞很多套写法

参考imgui.ini

```c++
struct WindowSettings 
{
    static const int32_t DontCare = -1;
    
    std::string title;
    
    uint16_t width;
    
    uint16_t height;
    
    int16_t minimumWidth = DontCare;
    
    int16_t minimumHeight = DontCare;
    
    int16_t maximumWidth = DontCare;
    
    int16_t maximumHeight = DontCare;
    
    bool fullscreen = false;
    
    bool decorated = true;
    
    bool resizable = true;
    
    bool focused = true;
    
    bool maximized = false;
    
    bool floating = false;
    
    bool visible = true;
    
    bool autoIconify = true;
    
    int32_t refreshRate = WindowSettings::DontCare;
    
    Cursor::ECursorMode cursorMode = Cursor::ECursorMode::NORMAL;
    
    Cursor::ECursorShape cursorShape = Cursor::ECursorShape::ARROW;
    
    uint32_t samples = 4;
};
```