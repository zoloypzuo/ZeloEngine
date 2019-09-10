# created on 2019/9/10
# author @zoloypzuo

cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

project(dxd12book)

add_compile_definitions(
        UNICODE
)

add_subdirectory(Common)
add_subdirectory("Chapter 4 Direct3D Initialization")
add_subdirectory("Chapter 6 Drawing in Direct3D")

include_directories(Common)