macro(SETUP_GROUPS src_files)
	foreach(FILE ${src_files})
		get_filename_component(PARENT_DIR "${FILE}" PATH)

		# skip src or include and changes /'s to \\'s
		set(GROUP "${PARENT_DIR}")
		string(REPLACE "/" "\\" GROUP "${GROUP}")

		source_group("${GROUP}" FILES "${FILE}")
	endforeach()
endmacro()

macro(SET_OUTPUT_NAMES projname)
	set_target_properties(${projname} PROPERTIES OUTPUT_NAME_DEBUG ${projname}_Debug)
	set_target_properties(${projname} PROPERTIES OUTPUT_NAME_RELEASE ${projname}_Release)
	set_target_properties(${projname} PROPERTIES OUTPUT_NAME_RELWITHDEBINFO ${projname}_ReleaseDebInfo)

	# On Linux/macOS the binaries go to <root>/bin folder
	if (UNIX)
		set_target_properties(${projname} PROPERTIES RUNTIME_OUTPUT_DIRECTORY "${CMAKE_SOURCE_DIR}/bin")
	endif()
endmacro()

macro(SETUP_APP projname chapter)
	set(FOLDER_NAME ${chapter})
	set(PROJECT_NAME ${projname})
	project(${PROJECT_NAME} CXX)

	file(GLOB_RECURSE SRC_FILES LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} src/*.c??)
	file(GLOB_RECURSE HEADER_FILES LIST_DIRECTORIES false RELATIVE ${CMAKE_CURRENT_SOURCE_DIR} src/*.h)

	include_directories(src)
	add_executable(${PROJECT_NAME} ${SRC_FILES} ${HEADER_FILES})
	if(MSVC)
		add_definitions(-D_CONSOLE)
	endif()
	SETUP_GROUPS("${SRC_FILES}")
	SETUP_GROUPS("${HEADER_FILES}")

	SET_OUTPUT_NAMES(${PROJECT_NAME})

	set_property(TARGET ${PROJECT_NAME} PROPERTY FOLDER ${FOLDER_NAME})

	set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD 20)
	set_property(TARGET ${PROJECT_NAME} PROPERTY CXX_STANDARD_REQUIRED ON)

	if(MSVC)
		set_property(TARGET ${PROJECT_NAME} PROPERTY VS_DEBUGGER_WORKING_DIRECTORY "${CMAKE_SOURCE_DIR}")
	endif()

endmacro()

set_property(GLOBAL PROPERTY USE_FOLDERS ON)

add_subdirectory(deps/src/etc2comp)

include_directories(deps/src/vulkan/include)

add_subdirectory(deps/src/glfw)
add_subdirectory(deps/src/volk)

set(ENABLE_GLSLANG_BINARIES  OFF  CACHE BOOL "")
set(ENABLE_HLSL              OFF  CACHE BOOL "")
set(ENABLE_CTEST             OFF  CACHE BOOL "")
set(ENABLE_OPT               OFF  CACHE BOOL "")
set(SKIP_GLSLANG_INSTALL     ON   CACHE BOOL "")
add_subdirectory(deps/src/glslang)

include_directories(.)
include_directories(deps/src)
include_directories(deps/src/gli)
include_directories(deps/glad/include)
include_directories(deps/src/assimp/include)
include_directories(deps/src/etc2comp/EtcLib/Etc)
include_directories(deps/src/etc2comp/EtcLib/EtcCodec)
include_directories(deps/src/glslang/glslang/Include)
include_directories(deps/src/taskflow)
include_directories(deps/src/rapidjson/include)
include_directories(${CMAKE_CURRENT_BINARY_DIR}/deps/src/assimp/include)
include_directories(deps/src/stb)
include_directories(deps/src/glslang)
include_directories(deps/src/glslang/StandAlone)
include_directories(deps/src/glslang/src)
include_directories(deps/src/ImGuizmo/src)

add_subdirectory(deps/cmake/ImGuizmo)

set(GLAD_SOURCES deps/glad/src/gl.c deps/glad/src/vulkan.c)
if(WIN32)
	set(GLAD_SOURCES ${GLAD_SOURCES} deps/glad/src/wgl.c)
endif()

add_library(glad ${GLAD_SOURCES})

find_package(glfw3 CONFIG REQUIRED)
link_libraries(glfw)

find_package(Bullet CONFIG REQUIRED)
# Note: 2 target(s) were omitted.
# target_link_libraries(main PRIVATE LinearMath Bullet3Common BulletDynamics BulletSoftBody)

set_property(TARGET EtcLib        PROPERTY FOLDER "ThirdPartyLibraries")
set_property(TARGET EtcTool       PROPERTY FOLDER "ThirdPartyLibraries")
set_property(TARGET glad          PROPERTY FOLDER "ThirdPartyLibraries")
set_property(TARGET volk          PROPERTY FOLDER "ThirdPartyLibraries")
set_property(TARGET glslang       PROPERTY FOLDER "ThirdPartyLibraries/glslang")
set_property(TARGET OGLCompiler   PROPERTY FOLDER "ThirdPartyLibraries/glslang")
set_property(TARGET OSDependent   PROPERTY FOLDER "ThirdPartyLibraries/glslang")
set_property(TARGET SPIRV         PROPERTY FOLDER "ThirdPartyLibraries/glslang")
set_property(TARGET SPVRemapper   PROPERTY FOLDER "ThirdPartyLibraries/glslang")