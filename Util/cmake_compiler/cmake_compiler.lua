-- cmake_compiler.lua
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

require "lfs"
require "cmake_compiler.cmake"
require "cpp"

-- ZeloEngine/Examples下的示例项目
-- 每一个示例都是独立的项目（cmake project）
-- 调用此函数为你生成一个空白的项目
-- 包含一个目录，CMakeLists.txt，gitignore，一对C++源文件
-- 可以运行，什么都不做
-- 暂时不生成文件头信息，这个无所谓
example_project = function(name)
    local example_dir = [[D:\ZeloEngine\Example\]]
    local project_dir = example_dir .. name .. "\\"
    lfs.chdir(example_dir)
    lfs.mkdir(name)
    lfs.chdir(project_dir)
    writeall(project_dir .. ".gitignore", "build/**\n")
    local cmake_code = cmake_header() .. project(name) .. source_list() .. add_executable(name)
    -- 不要创建代码文件，因为
    --    writeall(project_dir .. "CMakeLists.txt", cmake_code)
    --    writeall(project_dir .. name .. ".h", "")
    --    writeall(project_dir .. name .. ".cpp", [[
    --int main(size_t argc, char** argv)
    --{
    --    return 0;
    --}
    --]])
end

--example_project "test"

--========================================================================================
--
-- 接下来我们将SandboxFramework从premake迁移到cmake
--

Solution = Class(function(self)

end)

Project = Class(function(self)
end)

--
BaseProject = Class(Project, function(self)
    -- lang = cpp，cmake不需要
    self.include_dirs = "%{SolutionDir}/src/include/"
    -- warning = extra。可以先忽略
    -- flags = xxxx，要看一下，有些影响编译
    -- vpaths = 这里不需要，cmake指定头文件和源文件即可
end)

FrameworkProject = Class(BaseProject, function(self)
    -- kind = static lib
    -- pch = XXX.h
    -- pch.c = XXX.c
    -- option = xx
    self.include_dirs = {
        "%{SolutionDir}/src/bulletxxx",
        "xxx"
    }

end)

target = "bullet_collision"
code = {
    cmake_header();
    project "bullet";
    file_glob_recursive_h_cpp("bullet_collision/");
    add_library(target, "${SRC_LIST}");
    target_include_directories(target,
            "bullet_collision/include/",
            "bullet_collision/include/BulletCollision/BroadphaseCollision",
            "bullet_collision/include/BulletCollision/CollisionDispatch",
            "bullet_collision/include/BulletCollision/CollisionShapes",
            "bullet_collision/include/BulletCollision/Gimpact",
            "bullet_collision/include/BulletCollision/NarrowPhaseCollision",
            "bullet_linearmath/include"
    );
    target_compile_definitions(target, "WIN32", "_CRT_SECURE_NO_WARNINGS")
}

-- TODO 这里的option没有处理
target = "bullet_dynamics"
code = {
    cmake_header();
    project "bullet";
    file_glob_recursive_h_cpp("bullet_dynamics/");
    add_library(target, "${SRC_LIST}");
    target_include_directories(target,
            "bullet_dynamics/include/",
            "bullet_collision/include/",
            "bullet_dynamics/include/BulletDynamics/Character",
            "bullet_dynamics/include/BulletDynamics/ConstraintSolver",
            "bullet_dynamics/include/BulletDynamics/Dynamics",
            "bullet_dynamics/include/BulletDynamics/Vehicle",
            "bullet_linearmath/include"
    );
    target_compile_definitions(target, "WIN32", "_CRT_SECURE_NO_WARNINGS")
}
code = (table.concat(code))

writeall([[D:\ZeloEngine\External\bullet\CMakeLists.txt]], code)

target = "bullet_linearmath"
code = {
    cmake_header();
    project "bullet";
    file_glob_recursive_h_cpp("bullet_linearmath/");
    add_library(target, "${SRC_LIST}");
    target_include_directories(target,
            "bullet_linearmath/include/",
            "bullet_linearmath/include/LinearMath"
    );
    target_compile_definitions(target, "WIN32", "_CRT_SECURE_NO_WARNINGS")
}
code = (table.concat(code))

writeall([[D:\ZeloEngine\External\bullet\CMakeLists.txt]], code)
