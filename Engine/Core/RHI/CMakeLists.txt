# created on 2021/7/26
# author @zoloypzuo
add_library(RHI
        Const/ERenderingCapability.h
        Const/EShaderType.h

        Shader.cpp
        Texture.cpp
        RenderCommand.cpp
        Framebuffer.cpp
        Buffer.cpp
        VertexArray.cpp
        BufferLayout.cpp
        RenderSystem.cpp RenderSystem.h
        )