-- cmake.lua
-- created on 2019/10/12
-- author @zoloypzuo

-- cmake命令参考
-- https://cmake.org/cmake/help/latest/manual/cmake-commands.7.html

--基本语法规则
--”cmake 语言和语法”，最简单的语法规则是：
--1，变量使用${}方式取值，但是在 IF 控制语句中是直接使用变量名
--2，指令(参数 1 参数 2...)
--参数使用括弧括起，参数之间使用空格或分号分开。
--以上面的 ADD_EXECUTABLE 指令为例，如果存在另外一个 func.c 源文件，就要写成：
--ADD_EXECUTABLE(hello main.c func.c)或者
--ADD_EXECUTABLE(hello main.c;func.c)
--3，指令是大小写无关的，参数和变量是大小写相关的。但，推荐你全部使用大写指令。（我们生成大写指令，手写时用小写）

--关于语法的疑惑
--cmake 的语法还是比较灵活而且考虑到各种情况，比如
--SET(SRC_LIST main.c)也可以写成 SET(SRC_LIST “main.c”)
--是没有区别的，
--
--但是假设一个源文件的文件名是 fu nc.c(文件名中间包含了空格)。
--这时候就必须使用双引号，如果写成了 SET(SRC_LIST fu nc.c)，就会出现错误，提示
--你找不到 fu 文件和 nc.c 文件。这种情况，就必须写成:
--SET(SRC_LIST “fu nc.c”)
--
--此外，你可以可以忽略掉 source 列表中的源文件后缀，比如可以写成
--同时参数也可以使用分号来进行分割。
--下面的例子也是合法的：
--ADD_EXECUTABLE(t1 main.c t1.c)可以写成 ADD_EXECUTABLE(t1
--main.c;t1.c).
--我们只需要在编写 CMakeLists.txt 时注意形成统一的风格即可。

--{{{ 基础工具函数
cmake_string = function(s)
    return '"' .. s .. '"'
end

-- 返回一个单行的指令
-- 指令一定在本文件实现，所以private
local cmake_command = function(command, ...)
    return command .. "(" .. table.concat({ ... }, " ") .. ")\n"
end
--}}}

--{{{cmake语法成分；cmake指令
cmake_header = function()
    return [[
cmake_minimum_required(VERSION 3.8)  # cmake 3.8 to use VS_DEBUGGER_WORKING_DIRECTORY
set(CMAKE_C_STANDARD 11)
set(CMAKE_CXX_STANDARD 11)
]]
end

project = function(name)
    return "project(" .. name .. ")\n"
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

--{{{ MESSAGE 指令
--MESSAGE 指令的语法是：
--MESSAGE([SEND_ERROR | STATUS | FATAL_ERROR] "message to display"
--...)
--这个指令用于向终端输出用户定义的信息，包含了三种类型:
--SEND_ERROR，产生错误，生成过程被跳过。
--SATUS，输出前缀为—的信息。
--FATAL_ERROR，立即终止所有 cmake 过程.
local message = function(flag, ...)
    return "MESSAGE(" .. flag .. " " .. table.concat({ ... }, " ") .. ")\n"
end

-- ...是str列表
-- 例子
--MESSAGE(STATUS "This is BINARY dir " ${PROJECT_BINARY_DIR})
-- STATUS标志打印时会加一个前缀的连字符-
log = function(...)
    return message("STATUS", ...)
end

log_warning = function(...)
    return message("SEND_ERROR", ...)
end

log_error = function(...)
    return message("FATAL_ERROR", ...)
end
--}}}

-- 语法
--SET(VAR [VALUE] [CACHE TYPE DOCSTRING [FORCE]])
-- 我们只用
--SET(SRC_LIST main.c)
set = function(lhs, ...)
    return "SET(" .. lhs .. " " .. table.concat({ ... }, " ") .. ")\n"
end

--ADD_SUBDIRECTORY 指令
--ADD_SUBDIRECTORY(source_dir [binary_dir] [EXCLUDE_FROM_ALL])
--这个指令用于向当前工程添加存放源文件的子目录
--
--（下面两个参数我们都不用）
--并可以指定中间二进制和目标二进制存
--放的位置。
--EXCLUDE_FROM_ALL 参数的含义是将这个目录从编译过程中排除，比如，工程
--的 example，可能就需要工程构建完成后，再进入 example 目录单独进行构建(当然，你
--也可以通过定义依赖来解决此类问题)。
--
--例子
--ADD_SUBDIRECTORY(src bin)
--上面的例子定义了将 src 子目录加入工程，并指定编译输出(包含编译中间结果)路径为
--bin 目录。如果不进行 bin 目录的指定，那么编译结果(包括中间结果)都将存放在
--build/src 目录(这个目录跟原有的 src 目录对应)，指定 bin 目录后，相当于在编译时
--将 src 重命名为 bin，所有的中间结果和目标二进制都将存放在 bin 目录。
add_subdirectory = function(source_dir)
    return cmake_command("ADD_SUBDIRECTORY", source_dir)
end
--}}}


--{{{二次封装的常用工具函数
-- 默认头文件和源文件都在当前目录
source_list = function(inc_dir, src_dir)
    inc_dir = inc_dir or ""
    src_dir = src_dir or ""
    return "file(GLOB SRC_LIST " .. src_dir .. "*.cpp " .. inc_dir .. "*.h)\n"
end

-- 指定输出目录
--（我们不使用ADD_SUBDIRECTORY 指令来指定编译输出目录）
--我们都可以通过 SET 指令重新定义 EXECUTABLE_OUTPUT_PATH 和 LIBRARY_OUTPUT_PATH 变量
--来指定最终的目标二进制的位置(指最终生成的 hello 或者最终的共享库，不包含编译生成
--的中间文件)
--SET(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)
--SET(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)
--在第一节我们提到了<projectname>_BINARY_DIR 和 PROJECT_BINARY_DIR 变量，他
--们指的编译发生的当前目录，
--本节我们没有提到共享库和静态库的构建，所以，你可以不考虑第二条指令。
-- TODO
--}}}