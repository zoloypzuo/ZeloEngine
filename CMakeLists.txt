# created on 2019/9/23
# author @zoloypzuo

cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

project(ZeloEngine)

add_compile_definitions(
        UNICODE
)

#
# cotire (https://github.com/sakra/cotire)
#
set (CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")
include(cotire)
#
# 想要用cotire预编译加速一个target，cotire下即可，如：
#
#​add_executable(MyExecutable ${MyExecutableSources})
#​target_link_libraries(MyExecutable ${MyExecutableLibraries})
#​cotire(MyExecutable)

add_executable(ZeloEngine Src/main.cpp Src/main.h)
cotire(ZeloEngine)

add_subdirectory(Src)