# created on 2021/7/26
# author @zoloypzuo
add_library(RHI
        Const/ERenderingCapability.h
        Const/EShaderType.h

        Resource/Shader.h
        Resource/Texture.h
        Resource/Material.cpp
        Resource/MeshManager.cpp Resource/MeshManager.h
        Resource/Mesh.cpp Resource/Mesh.h

        Buffer/Framebuffer.h
        Buffer/Buffer.h
        Buffer/VertexArray.h
        Buffer/BufferLayout.cpp
        Buffer/Vertex.h

        MeshGen/IMeshGen.h
        MeshGen/Plane.cpp MeshGen/Plane.h

        RenderSystem.cpp RenderSystem.h
        )