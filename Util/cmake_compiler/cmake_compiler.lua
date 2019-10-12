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
    local cmake_code = header() .. project(name) .. source_list() .. add_executable(name)
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

example_project "test"