# created on 2019/9/23
# author @zoloypzuo
cmake_minimum_required(VERSION 3.18.4)

# C++ standard option
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

if (UNIX)  # fix std::filesystem link error
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    link_libraries(stdc++fs)
endif ()

# cmake option
set_property(GLOBAL PROPERTY USE_FOLDERS ON)  # Visual Studio中将target划分到目录中

project(ZeloEngine)

# C++ or platform options
if (WIN32)
    # ignore warning
    add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
    # avoid some bugs with Windows...
    add_compile_definitions(NOMINMAX)
    # We do this to speed up the build process,
    # it reduces the size of the Win32 header files by excluding some of the less used APIs.
    add_compile_definitions(WIN32_LEAN_AND_MEAN)
endif ()

# use unicode, wstring and etc
add_compile_definitions(UNICODE)

# options
# @formatter:off
option(DetectMemoryLeak     "DetectMemoryLeak"     OFF)  # 内存泄漏检测

option(BuildCycloneDemo     "BuildCycloneDemo"     OFF)  # 构建物理Demo
option(BuildCyclone         "BuildCyclone"         OFF)  # 构建物理
# @formatter:on

# engine option
if (APPLE)  # TODO fix osx ZELO_ASSERT
else ()
    add_compile_definitions(ZELO_DEBUG)
endif ()
add_compile_definitions(DEBUG_SHADOWMAP)  # 调试shadow-map，在右上角显示shadow-map
#add_compile_definitions(SWIGRUNTIME_DEBUG)  # Swig运行时DebugLog，量很大，你忍一下

# vcpkg root
if (WIN32)
    set(VCPKG_TARGET_TRIPLET x86-windows)
    set(VcpkgDir "D:/vcpkg" CACHE STRING "vcpkg install directory")
    message(STATUS include=${VcpkgDir}/scripts/buildsystems/vcpkg.cmake)
    include(${VcpkgDir}/scripts/buildsystems/vcpkg.cmake)
elseif (UNIX)
    set(VCPKG_TARGET_TRIPLET x64-windows)
    message(STATUS CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE})
endif ()

# sdl build before imgui
if (WIN32)
    find_package(SDL2 CONFIG REQUIRED)
    link_libraries(SDL2::SDL2 SDL2::SDL2main)
elseif (UNIX)
    find_package(SDL2 CONFIG REQUIRED)
    link_libraries(SDL2::SDL2main SDL2::SDL2-static)
endif ()

# build third party from source
add_subdirectory(ThirdParty)

# lua
include_directories(ThirdParty/Lua/include)
link_libraries(Lua)

# imgui, build from source
#find_package(imgui CONFIG REQUIRED)
#link_libraries(imgui::imgui)
include_directories(ThirdParty/ImGui)
link_libraries(ImGui)

# vcpkg import third party
find_package(spdlog CONFIG REQUIRED)
link_libraries(spdlog::spdlog spdlog::spdlog_header_only)

if (WIN32)
    find_package(glm CONFIG REQUIRED)
    link_libraries(glm)
elseif (UNIX)
    find_package(glm CONFIG REQUIRED)
    link_libraries(glm::glm)
endif ()

if (APPLE)
    message(WARNING "Mac OSX vcpkg install assimp failed, please run apt-get install assimp")
else ()
    find_package(assimp CONFIG REQUIRED)
    link_libraries(assimp::assimp)
endif ()

find_path(STB_INCLUDE_DIRS "stb.h")
include_directories(${STB_INCLUDE_DIRS})

find_package(yaml-cpp CONFIG REQUIRED)
link_libraries(yaml-cpp)

# vcpkg import sol
find_package(sol2 CONFIG REQUIRED)
link_libraries(sol2::sol2)
# sol enable safety check
add_compile_definitions(SOL_ALL_SAFETIES_ON)
# sol fix link error
add_compile_definitions(SOL_USING_CXX_LUA=1)

# glm
add_compile_definitions(GLM_FORCE_SWIZZLE)
add_compile_definitions(GLM_FORCE_RADIANS)

# rttr
find_package(rttr CONFIG REQUIRED)
link_libraries(RTTR::Core)

# memory leak check
if (DetectMemoryLeak)
    add_compile_definitions(DETECT_MEMORY_LEAK)
    set(VldIncludeDir "C:/Program Files (x86)/Visual Leak Detector/include")
    if (WIN32)
        set(VldLibDir "C:/Program Files (x86)/Visual Leak Detector/lib/Win32")
    else ()
        set(VldLibDir "C:/Program Files (x86)/Visual Leak Detector/lib/Win64")
    endif ()
    include_directories(${VldIncludeDir})
    link_directories(${VldLibDir})
endif ()

# build engine
include_directories(Engine)
add_subdirectory(Engine)
link_libraries(Engine)
set_target_properties(Engine PROPERTIES FOLDER "Main")

# build main
add_executable(Hello main.cpp)
set_target_properties(Hello PROPERTIES FOLDER "Main")

# after build main, copy config file to exe directory
message(STATUS ${CMAKE_COMMAND})
message(STATUS ${CMAKE_CURRENT_SOURCE_DIR})
add_custom_command(
        TARGET Hello PRE_BUILD COMMAND
        py ${CMAKE_CURRENT_SOURCE_DIR}/build.py ${CMAKE_CURRENT_SOURCE_DIR} $<TARGET_FILE_DIR:Hello>
)
