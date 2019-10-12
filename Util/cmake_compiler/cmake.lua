-- cmake.lua
-- created on 2019/10/12
-- author @zoloypzuo

-- cmake命令参考
-- https://cmake.org/cmake/help/latest/manual/cmake-commands.7.html

header = function()
    return [[
cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
]]
end

project = function(name)
    return "project(" .. name .. ")\n"
end

-- 默认头文件和源文件都在当前目录
source_list = function(inc_dir, src_dir)
    inc_dir = inc_dir or ""
    src_dir = src_dir or ""
    return "file(GLOB SRC_LIST " .. src_dir .. "*.cpp " .. inc_dir .. "*.h)\n"
end


-- 默认使用SRC_LIST
add_executable = function(name, ...)
    -- ... is source list
    local source_list = { ... }
    if #source_list == 0 then
        source_list = { "${SRC_LIST}" }
    end
    return "add_executable(" .. name .. " " .. table.concat(source_list) .. ")\n"
end


add_library = function(name, ...)
    -- ... is source list
    local source_list = { ... }
    if #source_list == 0 then
        source_list = { "${SRC_LIST}" }
    end
    return "add_library(" .. name .. " " .. table.concat(source_list) .. ")\n"
end

print(add_executable "aaa")  -- add_executable(aaa )