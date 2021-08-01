# created on 2021/7/26
# author @zoloypzuo
add_library(RHI
        Const/ERenderingCapability.h
        Const/EShaderType.h

        Resource/Shader.cpp
        Resource/Texture.cpp

        Buffer/Framebuffer.cpp
        Buffer/Buffer.cpp
        Buffer/VertexArray.cpp
        Buffer/BufferLayout.cpp

        RenderCommand.cpp RenderSystem.h
        RenderSystem.cpp RenderSystem.h
        )