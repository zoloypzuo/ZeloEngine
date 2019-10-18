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

require "lfs"
require "cmake"

-- 为一个target导入一套库
ImportLibConfig = Class(function(self, include_dirs, lib_dirs, lib_names)
    -- "include/"
    self.include_dirs = include_dirs or {}
    -- "lib/x64/"
    self.lib_dirs = lib_dirs or {}
    -- "lua.lib"
    self.lib_names = lib_names or {}
end)

function ImportLibConfig:generate_cmake_code(target)
    local code = {
        target_include_directories(target, table.unpack(self.include_dirs));
        target_link_directories(target, table.unpack(self.lib_dirs));
        target_link_library(target, table.unpack(self.lib_names));
    }
    return code
end

ProjectConfig = Class(function(self, name, targets)
    self.name = name or ""
    -- e.g. ExeConfig
    self.targets = targets or {}
end)

function ProjectConfig:generate_cmake_code()
    local code = {
        cmake_header();
        project(self.name);
        log(cmake_string "This is BINARY dir ", "${PROJECT_BINARY_DIR}");
    }
    return code
end

ExeTargetConfig = Class(function(self)
    self.name = ""
    -- ImportLibConfig list
    self.import_libs = {}
end)

function ExeTargetConfig:generate_cmake_code()
    local code = {
        file_glob_recursive_h_cpp();
        add_executable(self.name, "${SRC_LIST}");
    }
    return code
end

--print(table.concat(ProjectConfig("Init_Sandbox"):generate_cmake_code()))
print(table.concat(dofile([[D:\ZeloEngine\Config\CMakeProjectConfig\ImportLibConfig_sandbox.lua]]):generate_cmake_code("Init_Sandbox")))

