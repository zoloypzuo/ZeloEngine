# created on 2021/7/26
# author @zoloypzuo
add_library(RHI
        Const/ERenderingCapability.h
        Const/EShaderType.h

        Resource/Shader.h
        Resource/Texture.h

        Buffer/Framebuffer.h
        Buffer/Buffer.h
        Buffer/VertexArray.h
        Buffer/BufferLayout.cpp

        RenderSystem.h
        RenderSystem.cpp RenderSystem.h
        )