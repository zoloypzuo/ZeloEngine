include_directories(.)

add_library(GRCookbook
        GRCookbookPlugins.cpp
        FinalScenePlugin.cpp
        PBRPlugin.cpp

        Resource/GLMesh1.cpp
        Resource/GLBuffer.cpp
        Resource/GLMeshPVP.cpp
        Resource/GLMesh2.cpp
        Resource/GLMesh9.cpp
        Resource/GLSkyboxRenderer.cpp
        Resource/GLTexture.cpp
        Resource/GLSceneData.cpp
        Resource/GLSceneDataLazy.cpp
        Resource/GLFramebuffer.cpp

        VtxData/MeshData.cpp
        Scene.cpp
        Material.cpp
        Bitmap.h
        UtilsCubemap.cpp

        Utils.cpp
        )

find_package(glfw3 CONFIG REQUIRED)
find_package(gli CONFIG REQUIRED)
find_package(RapidJSON CONFIG REQUIRED)
find_package(Taskflow CONFIG REQUIRED)


target_link_libraries(GRCookbook PUBLIC Engine)
target_link_libraries(GRCookbook PUBLIC gli glfw)
target_include_directories(GRCookbook PUBLIC ${RAPIDJSON_INCLUDE_DIRS})
target_include_directories(GRCookbook PRIVATE ${STB_INCLUDE_DIRS})
target_link_libraries(GRCookbook PRIVATE Taskflow::Taskflow)
