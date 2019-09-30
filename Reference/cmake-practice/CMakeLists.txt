#
# cmake各种东西确实很烦。干脆把教程完整地放在这里了，去谷歌也是很麻烦的事情，我只想短平快
# 这个CMakeLists.txt不会被用到，仅作为一个教程文件
#


#cmake最简单的语法规则是：
#1，变量使用${}方式取值，但是在IF控制语句中是直接使用变量名
#2，指令(参数1 参数 2...)
#参数使用括弧括起，参数之间使用空格或分号分开。

# template header declaration
cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
#PROJECT指令的语法是：
#PROJECT(projectname [CXX] [C] [Java])
#你可以用这个指令定义工程名称，并可指定工程支持的语言，支持的语言列表是可以忽略的，
#默认情况表示支持所有语言。这个指令隐式的定义了两个 cmake 变量:
#<projectname>_BINARY_DIR以及<projectname>_SOURCE_DIR
project(ZeloEngine)

#同时cmake 系统也帮助我们预定义了 PROJECT_BINARY_DIR和PROJECT_SOURCE_DIR
#变量，他们的值分别跟HELLO_BINARY_DIR与HELLO_SOURCE_DIR一致。
#为了统一起见，建议以后直接使用PROJECT_BINARY_DIR，PROJECT_SOURCE_DIR，即
#使修改了工程名称，也不会影响这两个变量。
#
#MESSAGE指令的语法是：
#MESSAGE([SEND_ERROR | STATUS | FATAL_ERROR] "message to display"
#...)
#这个指令用于向终端输出用户定义的信息，包含了三种类型:
#SEND_ERROR，产生错误，生成过程被跳过。
#SATUS — ，输出前缀为 的信息。
#FATAL_ERROR，立即终止所有cmake 过程.
#
#cmake 的语法还是比较灵活而且考虑到各种情况，比如
#SET(SRC_LIST main.c)也可以写成 SET(SRC_LIST “main.c”)
message(STATUS "binary dir: " ${ZeloEngine_BINARY_DIR})
message(STATUS "binary dir: " ${ZeloEngine_SOURCE_DIR})


#
# define C++ macro
#
#if (CMAKE_BUILD_TYPE EQUAL "DEBUG")
        message("debug mode")
        add_compile_definitions(
                _CRT_SECURE_NO_WARNINGS
                _CRTDBG_MAP_ALLOC
                LUA_USE_APICHECK
        )
#endif (CMAKE_BUILD_TYPE EQUAL "DEBUG")

#
# set variable
#
set(3rdPartyDir ${PROJECT_SOURCE_DIR}/3rdParty/)
set(LibDir ${PROJECT_SOURCE_DIR}/Lib/Win32Debug/)

link_directories(${LibDir})

#
# basic lib
#
link_libraries(
        D3D11.lib
#        comctl32.lib
#        d3dcompiler.lib
#        usp10.lib
#        dxguid.lib
#        winmm.lib
        )

#
# DXUT
#
link_libraries(
        DXUT.lib
        DXUTOpt.lib)

include_directories(
        ${3rdPartyDir}DXUT-apr2019/Core
        ${3rdPartyDir}DXUT-apr2019/Optional)

#
# Lua
#
link_libraries(lua.lib)

include_directories("${3rdPartyDir}lua-5.3.5/src")

#
#
#
link_libraries(Effects11d.lib)

include_directories("${3rdPartyDir}FX11/inc")

# include LuaConfig
include_directories(${PROJECT_SOURCE_DIR}/Introduction_to_3D_GameProgramming_with_Direct3D/Config/)

#
# add_subdirectory
#
#语法解释：
#ADD_SUBDIRECTORY指令
#ADD_SUBDIRECTORY(source_dir [binary_dir] [EXCLUDE_FROM_ALL])
#这个指令用于向当前工程添加存放源文件的子目录，并可以指定中间二进制和目标二进制存
#放的位置。
add_subdirectory(Introduction_to_3D_GameProgramming_with_Direct3D)