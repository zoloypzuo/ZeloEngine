-- zelo_make.lua
-- created on 2019/10/9
-- author @zoloypzuo

-- 参考
-- premake（不能一样，他有一些问题）
-- 《Lua-Game-AI》使用premake
-- 要易于实例化和开关
--
-- 实例化
-- visual studio的wizard
-- 你要能脚本写一个任意的类型，然后只有几个参数，就可以实例化（名字，位置）
--
-- 开关
-- 注释一行调用，即可开关，不要注释掉一段代码，那很糟糕

--你可以开启一个cmd.exe，输入`lua -e "require 'cmake_compiler'"`来启动`Util/cmake_compiler/cmake_compiler.lua`
--
--这个脚本会加载lua配置，生成CMakeList.txt，重新生成和构建Visual Studio项目


-- zelo-make
-- 读取ProjectConfig文件，生成cmake，构建
-- 你用wizard创建好项目
-- 然后每次修改配置，用zelo-make重新构建

-- cmake变量，尽量不使用，我们用lua变量
--
-- ${PROJECT_SOURCE_DIR}暂时不用，我们主要使用顶层cmake-list文件，就是source-dir

--# 禁用cotiire，你还没有想清楚怎么用
--# 你应该弄一个独立的例子（比如某个cmake的lib，lumix或者ogre），哦，这样编译变快了
--#
--# cotire (https://github.com/sakra/cotire)
--#
--#set(CMAKE_MODULE_PATH "${CMAKE_SOURCE_DIR}")
--#include(cotir

--# 开发SandboxFramework，用lua5.1
--#
--# Lua
--#
--#link_libraries(lua.lib)
--#include_directories("${ExternalDir}lua-5.3.5/src")

--#
--# DirectX12TK (https://github.com/Microsoft/DirectXTK12)
--#
--link_libraries(directxtk12.lib)
--include_directories("${ExternalDir}DirectXTK12/Inc")

--# 不要使用ogre，要么你换vs2015编译（有可能可以；但是成本很高）
--# set(OGRE_DIR "C:/Users/zoloypzuo/Documents/vcpkg-master/installed/x64-windows/share/ogre")
--# find_package(OGRE CONFIG REQUIRED)
--
--# example单独编译（否则很乱），engine编译出库后cmake-export

--# 按从底层到高层的顺序

require "lfs"
require "cmake"

local config_dir = [[D:\ZeloEngine\Config\CMakeProjectConfig\]]
local project_config_manager = LuaConfigManager(config_dir, "ProjectConfig")
local import_lib_config_manager = LuaConfigManager(config_dir, "ImportLibConfig")
local exe_config_manager = LuaConfigManager(config_dir, "ExeTargetConfig")
local lib_config_manager = LuaConfigManager(config_dir, "LibTargetConfig")

-- 为一个exe导入一套库
-- 一个ImportLib实际上是一套库，因为dir是公用的
-- 而且我们实际上把一组库作为一个整体链接到一个exe上
ImportLibConfig = Class(function(self)
    --self.include_dirs = include_dirs
    --self.lib_dirs = lib_dirs
    --self.lib_names = lib_names
end)

function ImportLibConfig:generate_cmake_code(target)
    return List {
        target_include_directories(target, self.include_dirs);
        target_link_directories(target, self.lib_dirs);
        target_link_library(target, self.lib_names);
    }
end

-- 分离exe和lib
-- 1-lib先构建
-- 2-不分离，写在一起，你代码没法写通的
ProjectConfig = Class(function(self)
    --self.name = name
    --self.lib_targets = lib_targets
    --self.exe_targets = exe_targets
    --self.compile_definitions =
    --self.include_dirs =
    --self.link_libs =
end)

function ProjectConfig:generate_cmake_code()
    local code = List {
        cmake_header();
        project(self.name);
        add_compile_definitions(self.compile_definitions);
        include_directory(self.include_dirs);
        self.lib_targets:map(function(lib)
            return add_subdirectory(lib.dir)
        end):join_list();
        self.exe_targets:map(function(exe)
            return add_subdirectory(exe.dir)
        end):join_list()
        --link_libraries(self.link_libs)
    }
    self.lib_targets:map(function(t)
        return lib_config_manager:load_config(t):generate_cmake_code()
    end)
    self.exe_targets:map(function(t)
        return exe_config_manager:load_config(t):generate_cmake_code()
    end)
end

ExeTargetConfig = Class(function(self)
    --self.name = name
    --self.import_libs = import_libs
    --self.dir
end)

function ExeTargetConfig:generate_cmake_code()
    return List {
        file_glob_current_dir_to_source_list();
        add_executable_with_source_list(self.name);
    } .. self.import_libs:map(function(lib)
        return import_lib_config_manager:load_config(lib):generate_cmake_code(self.name)
    end)     :join_list()
end

LibTargetConfig = Class(function(self)
    --self.name
    --self.dir
end)

print(project_config_manager:load_config("ZeloEngine"):generate_cmake_code():concat())