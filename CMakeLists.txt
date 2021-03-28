# created on 2019/9/23
# author @zoloypzuo
cmake_minimum_required(VERSION 3.8)
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

project(ZeloEngine)

add_subdirectory(Engine)

include_directories(Engine/include)
link_libraries(zelo)
add_executable(hello main.cpp)
