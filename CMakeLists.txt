# created on 2019/9/23
# author @zoloypzuo
cmake_minimum_required(VERSION 3.18.4)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

project(ZeloEngine)

if (WIN32)
    set(VCPKG_TARGET_TRIPLET x86-windows)
else ()
    set(VCPKG_TARGET_TRIPLET x64-windows)
endif ()

set(VcpkgDir "D:/vcpkg" CACHE STRING "vcpkg install directory")
message(STATUS VcpkgDir=${VcpkgDir})

include(${VcpkgDir}/scripts/buildsystems/vcpkg.cmake)

find_package(spdlog CONFIG REQUIRED)
link_libraries(spdlog::spdlog spdlog::spdlog_header_only)

find_package(glm CONFIG REQUIRED)
link_libraries(glm)

find_package(SDL2 CONFIG REQUIRED)
link_libraries(SDL2::SDL2 SDL2::SDL2main)

find_package(assimp CONFIG REQUIRED)
link_libraries(assimp::assimp)

find_path(STB_INCLUDE_DIRS "stb.h")
include_directories(${STB_INCLUDE_DIRS})

find_package(yaml-cpp CONFIG REQUIRED)
link_libraries(yaml-cpp)

find_package(imgui CONFIG REQUIRED)
link_libraries(imgui::imgui)

# we do not use vcpkg lua
#include(FindLua)
#find_package(Lua REQUIRED)
add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
add_subdirectory(Engine/Lua)
set(LUA_LIBRARIES Lua)
set(LUA_INCLUDE_DIR Engine/Lua/include)
include_directories(${LUA_INCLUDE_DIR})
link_libraries(${LUA_LIBRARIES})

find_package(sol2 CONFIG REQUIRED)
link_libraries(sol2::sol2)

# use unicode, wstring and etc
add_compile_definitions(UNICODE)
# avoid some bugs with Windows...
add_compile_definitions(NOMINMAX)
# We do this to speed up the build process,
# it reduces the size of the Win32 header files by excluding some of the less used APIs.
#add_compile_definitions(WIN32_LEAN_AND_MEAN)
# define ZELO_AUTOLIB to automatically include the libs needed for DXUT
add_compile_definitions(ZELO_AUTOLIB)
# INIReader use some unsecure std api
#add_compile_definitions(_CRT_SECURE_NO_WARNINGS)
# glm
add_compile_definitions(GLM_FORCE_SWIZZLE)
add_compile_definitions(GLM_FORCE_RADIANS)

# sol2 fix link error
add_compile_definitions(SOL_USING_CXX_LUA=0)

add_compile_definitions(ZELO_DEBUG)
add_subdirectory(Engine)

include_directories(Engine)
link_libraries(Common)

add_executable(hello main.cpp)

message(STATUS ${CMAKE_COMMAND})
message(STATUS ${CMAKE_CURRENT_SOURCE_DIR})
add_custom_command(TARGET hello PRE_BUILD
        COMMAND python ${CMAKE_CURRENT_SOURCE_DIR}/build.py ${CMAKE_CURRENT_SOURCE_DIR} $<TARGET_FILE_DIR:hello>)

# build test
option(BuildTest "BuildTest" OFF)
message(STATUS BuildTest=${BuildTest})

if (BuildTest)  # build swig in win32 release
    find_package(gtest CONFIG REQUIRED)

    include(CTest)
    enable_testing()
    add_subdirectory(Engine/Test)
endif ()
