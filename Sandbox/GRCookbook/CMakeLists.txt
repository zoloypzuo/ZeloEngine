set_property(GLOBAL PROPERTY USE_FOLDERS ON)

include_directories(.)
include_directories(deps/src)
include_directories(deps/src/gli)
include_directories(deps/glad/include)
include_directories(deps/src/taskflow)
include_directories(deps/src/rapidjson/include)
include_directories(deps/src/stb)
include_directories(deps/src/ImGuizmo/src)

add_subdirectory(deps/cmake/ImGuizmo)

find_package(glfw3 CONFIG REQUIRED)
link_libraries(glfw)

# shared utils code for GL and Vulkan
#add_subdirectory(shared)

#add_subdirectory(Chapter3/GL01_APIWrapping)
#add_subdirectory(Chapter3/GL02_VtxPulling)
#add_subdirectory(Chapter3/GL03_CubeMap)
#
#add_subdirectory(Chapter5/GL03_MeshRenderer)
#
#add_subdirectory(Chapter6/GL01_PBR)
#
#add_subdirectory(Chapter7/GL01_LargeScene)
#
#add_subdirectory(Chapter8/GL01_ShadowMapping)
#add_subdirectory(Chapter8/GL02_SSAO)
#add_subdirectory(Chapter8/GL03_HDR)
#add_subdirectory(Chapter8/GL04_HDR_Adaptation)
#
#add_subdirectory(Chapter10/GL01_CullingCPU)
#add_subdirectory(Chapter10/GL02_CullingGPU)
#add_subdirectory(Chapter10/GL03_OITransparency)
#add_subdirectory(Chapter10/GL04_LazyLoading)
#add_subdirectory(Chapter10/GL05_Final)

add_library(GRCookbook
		GRCookbookPlugins.cpp
		Resource/GLMesh1.cpp
		Resource/GLBuffer.cpp
		Resource/GLMeshPVP.cpp
		Resource/GLMesh2.cpp

		shared/scene/VtxData.cpp
		shared/glFramework/GLTexture.cpp
		shared/Bitmap.h
		shared/UtilsCubemap.cpp
		shared/glFramework/GLSceneData.cpp
		shared/scene/Scene.cpp
		shared/scene/Material.cpp
		)
