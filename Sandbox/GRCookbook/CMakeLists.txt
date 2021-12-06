set_property(GLOBAL PROPERTY USE_FOLDERS ON)

include_directories(.)

add_library(GRCookbook
        GRCookbookPlugins.cpp
        FinalScenePlugin.cpp

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

        VtxData.cpp
        Scene.cpp
        Material.cpp
        Bitmap.h
        UtilsCubemap.cpp

        Utils.cpp
        )

find_package(glfw3 CONFIG REQUIRED)
find_package(gli CONFIG REQUIRED)
find_package(RapidJSON CONFIG REQUIRED)

target_link_libraries(GRCookbook PUBLIC Engine)
target_link_libraries(GRCookbook PUBLIC gli glfw)
target_include_directories(GRCookbook PUBLIC ${RAPIDJSON_INCLUDE_DIRS})