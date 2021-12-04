# created on 2019/9/23
# author @zoloypzuo
cmake_minimum_required(VERSION 3.18.4)

# C++ standard option
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

# cmake option
set_property(GLOBAL PROPERTY USE_FOLDERS ON)  # Visual Studio will group targets into folders

project(ZeloEngine)

# vcpkg root and triplet
if (WIN32)
    if (CMAKE_SIZEOF_VOID_P EQUAL 8)  # 64 bits
        set(VCPKG_TARGET_TRIPLET x64-windows)
    elseif (CMAKE_SIZEOF_VOID_P EQUAL 4)  # 32 bits
        set(VCPKG_TARGET_TRIPLET x86-windows)
    endif ()
    set(VcpkgDir ${CMAKE_CURRENT_SOURCE_DIR}/ThirdParty/Vcpkg)
    include(${VcpkgDir}/scripts/buildsystems/vcpkg.cmake)
elseif (UNIX)
    set(VCPKG_TARGET_TRIPLET x64-windows)
    message(STATUS CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE})
endif ()

# build third party from source
add_subdirectory(ThirdParty)

option(BuildPlaybox "BuildPlaybox" OFF)
if (BuildPlaybox)
    # build Playbox alone first
    add_subdirectory(Playbox)
endif (BuildPlaybox)

# lua
include_directories(ThirdParty/Lua/include)
link_libraries(Lua)

# imgui
include_directories(ThirdParty/ImGui)
link_libraries(ImGui)

# import third party from vcpkg
# sdl
find_package(SDL2 CONFIG REQUIRED)
link_libraries(SDL2::SDL2 SDL2::SDL2main)

# spdlog
find_package(spdlog CONFIG REQUIRED)
link_libraries(spdlog::spdlog spdlog::spdlog_header_only)

# optick
include_directories(ThirdParty/Optick/src)
link_libraries(Optick)

# glm
find_package(glm CONFIG REQUIRED)
link_libraries(glm::glm)
add_compile_definitions(GLM_FORCE_SWIZZLE)
add_compile_definitions(GLM_FORCE_RADIANS)

# assimp
find_package(assimp CONFIG REQUIRED)
link_libraries(assimp::assimp)

# stb
find_path(STB_INCLUDE_DIRS "stb.h")
include_directories(${STB_INCLUDE_DIRS})

# yaml-cpp
find_package(yaml-cpp CONFIG REQUIRED)
link_libraries(yaml-cpp)

# sol2
find_package(sol2 CONFIG REQUIRED)
link_libraries(sol2::sol2)
# sol enable safety check
add_compile_definitions(SOL_ALL_SAFETIES_ON)
# sol fix link error
add_compile_definitions(SOL_USING_CXX_LUA=1)

# rttr
find_package(rttr CONFIG REQUIRED)
link_libraries(RTTR::Core)

# taskflow
find_package(Taskflow CONFIG REQUIRED)
link_libraries(Taskflow::Taskflow)

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
# option(DetectMemoryLeak     "DetectMemoryLeak"     OFF)
# @formatter:on

# engine option
add_compile_definitions(ZELO_DEBUG)

# build engine
include_directories(Engine)
include_directories(Sandbox) # TODO
add_subdirectory(Engine)
link_libraries(Engine)

# build main
add_executable(Hello main.cpp
        ThirdParty/StackTrace/AutoExceptionStacktraceRegister.cpp
        ThirdParty/StackTrace/AutoExceptionStacktraceRegister.h
        ThirdParty/StackTrace/AutoSymInitialize.cpp
        ThirdParty/StackTrace/AutoSymInitialize.h
        ThirdParty/StackTrace/backward.h
        ThirdParty/StackTrace/Exceptions.h
        ThirdParty/StackTrace/Globals.h
        ThirdParty/StackTrace/StackTracePrinter.cpp
        ThirdParty/StackTrace/StackTracePrinter.h
        )

target_include_directories(Hello PRIVATE ThirdParty/StackTrace)

set_target_properties(Engine PROPERTIES FOLDER "Main")
set_target_properties(Hello PROPERTIES FOLDER "Main")

# build sandbox
add_subdirectory(Sandbox)

# copy boot config to exe directory
message(STATUS ${CMAKE_COMMAND})
message(STATUS ${CMAKE_CURRENT_SOURCE_DIR})
add_custom_command(
        TARGET Hello PRE_BUILD COMMAND
        py ${CMAKE_CURRENT_SOURCE_DIR}/build.py ${CMAKE_CURRENT_SOURCE_DIR} $<TARGET_FILE_DIR:Hello>
)
