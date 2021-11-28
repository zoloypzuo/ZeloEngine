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

set(GLAD_SOURCES deps/glad/src/gl.c deps/glad/src/vulkan.c)
if(WIN32)
	set(GLAD_SOURCES ${GLAD_SOURCES} deps/glad/src/wgl.c)
endif()

add_library(glad ${GLAD_SOURCES})

find_package(glfw3 CONFIG REQUIRED)
link_libraries(glfw)

set_property(TARGET glad          PROPERTY FOLDER "ThirdPartyLibraries")
# shared utils code for GL and Vulkan
add_subdirectory(shared)

add_subdirectory(Chapter3/GL01_APIWrapping)
add_subdirectory(Chapter3/GL02_VtxPulling)
add_subdirectory(Chapter3/GL03_CubeMap)

add_subdirectory(Chapter5/GL01_Grid)
add_subdirectory(Chapter5/GL03_MeshRenderer)

add_subdirectory(Chapter6/GL01_PBR)

add_subdirectory(Chapter7/GL01_LargeScene)

add_subdirectory(Chapter8/GL01_ShadowMapping)
add_subdirectory(Chapter8/GL02_SSAO)
add_subdirectory(Chapter8/GL03_HDR)
add_subdirectory(Chapter8/GL04_HDR_Adaptation)

add_subdirectory(Chapter10/GL01_CullingCPU)
add_subdirectory(Chapter10/GL02_CullingGPU)
add_subdirectory(Chapter10/GL03_OITransparency)
add_subdirectory(Chapter10/GL04_LazyLoading)
add_subdirectory(Chapter10/GL05_Final)
