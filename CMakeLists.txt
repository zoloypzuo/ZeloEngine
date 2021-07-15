# created on 2019/9/23
# author @zoloypzuo
cmake_minimum_required(VERSION 3.18.4)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 17)

if (APPLE)
elseif (UNIX)  # fix std::filesystem link error
    set(CMAKE_CXX_STANDARD_REQUIRED ON)
    link_libraries(stdc++fs)
endif ()

project(ZeloEngine)

# vcpkg import third party
if (WIN32)
    set(VCPKG_TARGET_TRIPLET x86-windows)
    set(VcpkgDir "D:/vcpkg" CACHE STRING "vcpkg install directory")
    message(STATUS include=${VcpkgDir}/scripts/buildsystems/vcpkg.cmake)
    include(${VcpkgDir}/scripts/buildsystems/vcpkg.cmake)
elseif (UNIX)
    set(VCPKG_TARGET_TRIPLET x64-windows)
    message(STATUS CMAKE_TOOLCHAIN_FILE=${CMAKE_TOOLCHAIN_FILE})
endif ()

find_package(spdlog CONFIG REQUIRED)
link_libraries(spdlog::spdlog spdlog::spdlog_header_only)

if (WIN32)
    find_package(glm CONFIG REQUIRED)
    link_libraries(glm)
elseif (UNIX)
    find_package(glm CONFIG REQUIRED)
    link_libraries(glm::glm)
endif ()

if (WIN32)
    find_package(SDL2 CONFIG REQUIRED)
    link_libraries(SDL2::SDL2 SDL2::SDL2main)
elseif (UNIX)
    find_package(SDL2 CONFIG REQUIRED)
    link_libraries(SDL2::SDL2main SDL2::SDL2-static)
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

# memory leak check
option(DetectMemoryLeak "DetectMemoryLeak" OFF)
message(STATUS DetectMemoryLeak=${DetectMemoryLeak})

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

# use precompiled header
option(UsePreCompiledHeader "UsePreCompiledHeader" OFF)
message(STATUS UsePreCompiledHeader=${UsePreCompiledHeader})

if (UsePreCompiledHeader)
    set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}/CMake")
    include(cotire)
endif ()

# build engine
include_directories(Engine)
add_subdirectory(Engine)
link_libraries(Common)

# build main
add_executable(hello main.cpp)
if (UsePreCompiledHeader)
    set_target_properties(hello PROPERTIES COTIRE_CXX_PREFIX_HEADER_INIT "Engine/ZeloPreCompiledHeader.h")
    cotire(hello)
endif ()

# after build main, copy config file to exe directory
message(STATUS ${CMAKE_COMMAND})
message(STATUS ${CMAKE_CURRENT_SOURCE_DIR})
add_custom_command(TARGET hello PRE_BUILD
        COMMAND python ${CMAKE_CURRENT_SOURCE_DIR}/build.py ${CMAKE_CURRENT_SOURCE_DIR} $<TARGET_FILE_DIR:hello>)

# build test
option(BuildTest "BuildTest" OFF)
message(STATUS BuildTest=${BuildTest})

if (BuildTest)
    find_package(gtest CONFIG REQUIRED)

    include(CTest)
    enable_testing()
    add_subdirectory(Engine/Test)
endif ()
