# template header declaration
cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
project(ZeloEngine)

#
# define C++ macro
#
add_compile_definitions(
        _CRT_SECURE_NO_WARNINGS
        _CRTDBG_MAP_ALLOC)

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

# include Config
include_directories(${PROJECT_SOURCE_DIR}/Introduction_to_3D_GameProgramming_with_Direct3D/Config/)

#
# add_subdirectory
#
add_subdirectory(Introduction_to_3D_GameProgramming_with_Direct3D)