# created on 2021/7/26
# author @zoloypzuo
add_library(RHI
        Const/ERenderingCapability.h
        Const/EShaderType.h
        Const/EProjectionMode.h
        Const/ETextureFilteringMode.h
        Const/EAccessSpecifier.h

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

        MeshGen/Plane.cpp MeshGen/Plane.h
        MeshGen/Ingredients/TriangleMeshAdapter.cpp
        MeshGen/Ingredients/cube.cpp
        MeshGen/Ingredients/cube.h
        MeshGen/Ingredients/plane.cpp
        MeshGen/Ingredients/plane.h
        MeshGen/Ingredients/sphere.cpp
        MeshGen/Ingredients/sphere.h
        MeshGen/Ingredients/torus.cpp
        MeshGen/Ingredients/torus.h

        Object/Camera.cpp
        Object/ALight.cpp

        RenderSystem.cpp RenderSystem.h
        )