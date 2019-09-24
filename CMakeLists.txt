# created on 2019/9/23
# author @zoloypzuo

cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)

project(ZeloEngine)

#
# set variable
#
set(ExternalDir ${PROJECT_SOURCE_DIR}/External/)
set(LibDir ${PROJECT_SOURCE_DIR}/Lib/Win32Debug/)
message(STATUS "zlog " ${PROJECT_SOURCE_DIR})

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

add_library(ZeloEngine Src/dummy.h)
SET_TARGET_PROPERTIES(ZeloEngine PROPERTIES LINKER_LANGUAGE CXX)
target_link_libraries(ZeloEngine Main)
cotire(ZeloEngine)
link_libraries(ZeloEngine)

#
# Lua
#
link_libraries(lua.lib)
include_directories("${ExternalDir}lua-5.3.5/src")

add_subdirectory(Src)
add_subdirectory(Example)