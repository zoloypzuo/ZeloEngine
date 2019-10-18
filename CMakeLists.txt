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

# 禁用cotiire，你还没有想清楚怎么用
# 你应该弄一个独立的例子（比如某个cmake的lib，lumix或者ogre），哦，这样编译变快了
#
# cotire (https://github.com/sakra/cotire)
#
#set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")
#include(cotire)

# 开发SandboxFramework，用lua5.1
#
# Lua
#
#link_libraries(lua.lib)
#include_directories("${ExternalDir}lua-5.3.5/src")

#
# DirectX12TK (https://github.com/Microsoft/DirectXTK12)
#
link_libraries(directxtk12.lib)
include_directories("${ExternalDir}DirectXTK12/Inc")

# 不要使用ogre，要么你换vs2015编译（有可能可以；但是成本很高）
# set(OGRE_DIR "C:/Users/zoloypzuo/Documents/vcpkg-master/installed/x64-windows/share/ogre")
# find_package(OGRE CONFIG REQUIRED)

#
# include directory
#
include_directories(Src/LuaConfig/CppConfigClass_Generated)
include_directories(Src/LuaConfig)
include_directories(Src/Common)
include_directories(Src/ZeloMain)
include_directories(Src/Module/LogModule)
include_directories(Src/Module/LuaModule)

add_subdirectory(Src)
# example单独编译（否则很乱），engine编译出库后cmake-export
# add_subdirectory(Example)
# 按从底层到高层的顺序
add_subdirectory(Src/Common)
#add_subdirectory(Src/Framework)
#add_subdirectory(SResourceManager)
#add_subdirectory(Module)
#add_subdirectory(ZeloMain)

add_subdirectory(Example/Init_Sandbox)