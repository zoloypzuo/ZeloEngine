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
link_directories(${LibDir})

add_compile_definitions(
        UNICODE
        NOMINMAX  # see also github issue #116
)

#
# cotire (https://github.com/sakra/cotire)
#
set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")
include(cotire)

#
# Lua
#
link_libraries(lua.lib)
include_directories("${ExternalDir}lua-5.3.5/src")

#
# spdlog (https://github.com/gabime/spdlog)
#
link_libraries(spdlogd.lib)
include_directories("${ExternalDir}spdlog/include")

#
# DirectX12TK (https://github.com/Microsoft/DirectXTK12)
#
link_libraries(directxtk12.lib)
include_directories("${ExternalDir}DirectXTK12/Inc")

#
# include directory
#
include_directories(Src/LuaConfig/CppConfigClass_Generated)
include_directories(Src/LuaConfig)
include_directories(Src/Common)
include_directories(Src/Main)
include_directories(Src/Module/LogModule)
include_directories(Src/Module/LuaModule)

add_subdirectory(Src)
add_subdirectory(Example)