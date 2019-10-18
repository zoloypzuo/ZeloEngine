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

--${LIBHELLO_SRC}
cmake_variable = function(s)
    return "${" .. s .. "}"
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

add_executable = function(name, ...)
    return cmake_command("ADD_EXECUTABLE", name, ...)
end

--{{{指令 ADD_LIBRARY
--指令 ADD_LIBRARY
-- ADD_LIBRARY(libname [SHARED|STATIC|MODULE]
-- [EXCLUDE_FROM_ALL]
-- source1 source2 ... sourceN)
--你不需要写全 libhello.so，只需要填写 hello 即可，cmake 系统会自动为你生成
--libhello.X
--类型有三种:
--SHARED，动态库
--STATIC，静态库
--MODULE，在使用 dyld 的系统有效，如果不支持 dyld，则被当作 SHARED 对待。
--EXCLUDE_FROM_ALL 参数的意思是这个库不会被默认构建，除非有其他的组件依赖或者手
--工构建。
--
--ADD_LIBRARY(hello_dynamic SHARED ${LIBHELLO_SRC})
--ADD_LIBRARY(hello_static STATIC ${LIBHELLO_SRC})
add_library = function(name, lib_type, ...)
    return cmake_command("ADD_LIBRARY", target, lib_type, ...)
end

add_library_static = function(name, ...)
    return add_library(name, "STATIC", ...)
end

add_library_dynamic = function(name, ...)
    return add_library(name, "SHARED", ...)
end
--}}}

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

--{{{INSTALL 指令
--INSTALL 指令用于定义安装规则，安装的内容可以包括目标二进制、动态库、静态库以及
--文件、目录、脚本等。
--INSTALL 指令包含了各种安装类型，我们需要一个个分开解释：
--
-- # 目标文件的安装：
-- INSTALL(TARGETS targets...
-- [[ARCHIVE|LIBRARY|RUNTIME]
-- [DESTINATION <dir>]
-- [PERMISSIONS permissions...]
-- [CONFIGURATIONS
-- [Debug|Release|...]]
-- [COMPONENT <component>]
-- [OPTIONAL]
-- ] [...])
--参数中的 TARGETS 后面跟的就是我们通过 ADD_EXECUTABLE 或者 ADD_LIBRARY 定义的
--目标文件，可能是可执行二进制、动态库、静态库。
--目标类型也就相对应的有三种，ARCHIVE 特指静态库，LIBRARY 特指动态库，RUNTIME
--特指可执行目标二进制。
--DESTINATION 定义了安装的路径，如果路径以/开头，那么指的是绝对路径，这时候
--CMAKE_INSTALL_PREFIX 其实就无效了。如果你希望使用 CMAKE_INSTALL_PREFIX 来
--定义安装路径，就要写成相对路径，即不要以/开头，那么安装后的路径就是
--${CMAKE_INSTALL_PREFIX}/<DESTINATION 定义的路径>
--
-- # 普通文件的安装：
-- INSTALL(FILES files... DESTINATION <dir>
-- [PERMISSIONS permissions...]
-- [CONFIGURATIONS [Debug|Release|...]]
-- [COMPONENT <component>]
-- [RENAME <name>] [OPTIONAL])
--可用于安装一般文件，并可以指定访问权限，文件名是此指令所在路径下的相对路径。如果
--默认不定义权限 PERMISSIONS，安装后的权限为：
--OWNER_WRITE, OWNER_READ, GROUP_READ,和 WORLD_READ，即 644 权限。
--
-- # 非目标文件的可执行程序安装(比如脚本之类)：
-- INSTALL(PROGRAMS files... DESTINATION <dir>
-- [PERMISSIONS permissions...]
-- [CONFIGURATIONS [Debug|Release|...]]
-- [COMPONENT <component>]
-- [RENAME <name>] [OPTIONAL])
--跟上面的 FILES 指令使用方法一样，唯一的不同是安装后权限为:
--OWNER_EXECUTE, GROUP_EXECUTE, 和 WORLD_EXECUTE，即 755 权限
--
-- # 目录的安装：
-- INSTALL(DIRECTORY dirs... DESTINATION <dir>
-- [FILE_PERMISSIONS permissions...]
-- [DIRECTORY_PERMISSIONS permissions...]
-- [USE_SOURCE_PERMISSIONS]
-- [CONFIGURATIONS [Debug|Release|...]]
-- [COMPONENT <component>]
-- [[PATTERN <pattern> | REGEX <regex>]
-- [EXCLUDE] [PERMISSIONS permissions...]] [...])
--这里主要介绍其中的 DIRECTORY、PATTERN 以及 PERMISSIONS 参数。
--DIRECTORY 后面连接的是所在 Source 目录的相对路径，但务必注意：
--abc 和 abc/有很大的区别。
--如果目录名不以/结尾，那么这个目录将被安装为目标路径下的 abc，如果目录名以/结尾，
--代表将这个目录中的内容安装到目标路径，但不包括这个目录本身。
--PATTERN 用于使用正则表达式进行过滤，PERMISSIONS 用于指定 PATTERN 过滤后的文件
--权限。
--我们来看一个例子:
-- INSTALL(DIRECTORY icons scripts/ DESTINATION share/myproj
-- PATTERN "CVS" EXCLUDE
-- PATTERN "scripts/*"
-- PERMISSIONS OWNER_EXECUTE OWNER_WRITE OWNER_READ
-- GROUP_EXECUTE GROUP_READ)
--这条指令的执行结果是：
--将 icons 目录安装到 <prefix>/share/myproj，将 scripts/中的内容安装到
--<prefix>/share/myproj
--不包含目录名为 CVS 的目录，对于 scripts/*文件指定权限为 OWNER_EXECUTE
--OWNER_WRITE OWNER_READ GROUP_EXECUTE GROUP_READ.
--
-- # 安装时 CMAKE 脚本的执行：
--INSTALL([[SCRIPT <file>] [CODE <code>]] [...])
--SCRIPT 参数用于在安装时调用 cmake 脚本文件（也就是<abc>.cmake 文件）
--CODE 参数用于执行 CMAKE 指令，必须以双引号括起来。比如：
--INSTALL(CODE "MESSAGE(\"Sample install message.\")
local install = function()

end

-- 别忘了cmake指令要添加前缀
--https://cmake.org/cmake/help/v3.0/variable/CMAKE_INSTALL_PREFIX.html
--cmake -DCMAKE_INSTALL_PREFIX=/tmp/t2/usr ..


install_target = function()
end
--拷贝版权，readme
--INSTALL(FILES COPYRIGHT README DESTINATION share/doc/cmake/hello_world_out)
install_file = function()
end
--拷贝exe
--INSTALL(PROGRAMS runhello.sh DESTINATION bin)
install_program = function()
end
--拷贝文档
--INSTALL(DIRECTORY doc/ DESTINATION share/doc/cmake/hello_world_out)
install_directory = function()
end
install_script = function()
end
--}}}

--SET_TARGET_PROPERTIES，其基本语法是：
-- SET_TARGET_PROPERTIES(target1 target2 ...
-- PROPERTIES prop1 value1
-- prop2 value2 ...)
--这条指令可以用来设置输出的名称，对于动态库，还可以用来指定动态库版本和 API 版本。
--
-- 不要一次性设置很多
-- 一个一个设置
--
-- 例子
-- SET_TARGET_PROPERTIES(hello_dynamic PROPERTIES OUTPUT_NAME "hello")
set_target_property = function(target, props)
    local i = list()
    for k, v in pairs(props) do
        i.append(k .. " " .. v)
    end
    return cmake_command("SET_TARGET_PROPERTIES", target, table.unpack(i._list))
end

--与他对应的指令是：
--GET_TARGET_PROPERTY(VAR target property)
--具体用法如下例，我们向 lib/CMakeListst.txt 中添加：
--GET_TARGET_PROPERTY(OUTPUT_VALUE hello_static OUTPUT_NAME)
--MESSAGE(STATUS “This is the hello_static
--OUTPUT_NAME:”${OUTPUT_VALUE})
--如果没有这个属性定义，则返回 NOTFOUND.
get_target_property = function(target, VAR, property)
    return cmake_command("GET_TARGET_PROPERTY", VAR, target, property)
end

--INCLUDE_DIRECTORIES，其完整语法为：
--INCLUDE_DIRECTORIES([AFTER|BEFORE] [SYSTEM] dir1 dir2 ...)
--这条指令可以用来向工程添加多个特定的头文件搜索路径，路径之间用空格分割，如果路径
--中包含了空格，可以使用双引号将它括起来，默认的行为是追加到当前的头文件搜索路径的
--后面，你可以通过两种方式来进行控制搜索路径添加的方式：
--１，CMAKE_INCLUDE_DIRECTORIES_BEFORE，通过 SET 这个 cmake 变量为 on，可以
--将添加的头文件搜索路径放在已有路径的前面。
--２，通过 AFTER 或者 BEFORE 参数，也可以控制是追加还是置前。
include_directory = function(...)
    return cmake_command("INCLUDE_DIRECTORIES", ...)
end

--LINK_DIRECTORIES 的全部语法是：
--LINK_DIRECTORIES(directory1 directory2 ...)
link_directory = function(...)
    return cmake_command("LINK_DIRECTORIES", ...)
end

--TARGET_LINK_LIBRARIES 的全部语法是:
--TARGET_LINK_LIBRARIES(target library1
-- <debug | optimized> library2
-- ...)
--这个指令可以用来为 target 添加需要链接的共享库，本例中是一个可执行文件，但是同样
--可以用于为自己编写的共享库添加共享库链接。
target_link_library = function(target, ...)
    return cmake_command("TARGET_LINK_LIBRARIES", target, ...)
end

-- patterns
file_glob_recursive = function(...)
    return cmake_command("file", "GLOB_RECURSE", "SRC_LIST", ...)
end

-- (我们现在只需要)递归扫描h和cpp到SRC_LIST
-- 递归扫描整个目录中匹配模式的文件
--https://cmake.org/cmake/help/v3.12/command/file.html#glob-recurse
file_glob_recursive_h_cpp = function(...)
    local dirs = { ... }
    if #dirs == 0 then
        dirs = { "./" }
    end
    --print(#dirs)
    local patterns = map(function(dir)
        return dir .. "*.h" .. " " .. dir .. "*.cpp"
    end, dirs)
    return file_glob_recursive(table.unpack(patterns))
end

-- 暂时都是private的
-- flag是这样的 UNIT_TEST=1，不要有引号
--https://cmake.org/cmake/help/v3.0/command/target_compile_definitions.html
--target_compile_definitions(<target>
--  <INTERFACE|PUBLIC|PRIVATE> [items1...]
--  [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
target_compile_definitions = function(target, ...)
    return cmake_command("target_compile_definitions", target, "PRIVATE", ...)
end

-- 暂时都是private的
--https://cmake.org/cmake/help/latest/command/target_include_directories.html
--target_include_directories(<target> [SYSTEM] [BEFORE]
--  <INTERFACE|PUBLIC|PRIVATE> [items1...]
--  [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
target_include_directories = function(target, ...)
    return cmake_command("target_include_directories", target, "PRIVATE", ...)
end

--https://cmake.org/cmake/help/latest/command/target_link_directories.html
--target_link_directories(<target> [BEFORE]
--  <INTERFACE|PUBLIC|PRIVATE> [items1...]
--  [<INTERFACE|PUBLIC|PRIVATE> [items2...] ...])
target_link_directories = function(target, ...)
    return cmake_command("target_link_directories", target, "PRIVATE", ...)
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