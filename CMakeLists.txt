# created on 2019/9/23
# author @zoloypzuo
cmake_minimum_required(VERSION 3.8)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

project(ZeloEngine)

if (WIN32)
    set(VCPKG_TARGET_TRIPLET x86-windows)
else ()
    set(VCPKG_TARGET_TRIPLET x64-windows)
endif ()
include(/vcpkg/scripts/buildsystems/vcpkg.cmake)
find_package(spdlog CONFIG REQUIRED)
link_libraries(spdlog::spdlog spdlog::spdlog_header_only)
find_package(glm CONFIG REQUIRED)
link_libraries(glm)
find_package(SDL2 CONFIG REQUIRED)
link_libraries(SDL2::SDL2 SDL2::SDL2main)

add_subdirectory(Engine)

include_directories(Engine/include)
link_libraries(zelo)
add_executable(hello main.cpp)
