-- windows_batch_compiler.lua
-- created on 2019/10/11
-- author @zoloypzuo

-- 动机和使用这个工具的优势
-- 封装win-batch的参数，将win-batch转换为直观，好用的lua接口
-- 不必再去每次了解win-batch细节，减轻记忆和手误的负担

-- 术语表
-- cmd：xcopy称为cmd，命令，也就是函数名字
-- arg：xcopy的选项，参数
-- statement：语句，生成的一整条命令，一般也就是一行

-- 路径分隔符（path sep）
-- 我们采用消极的方式，将/转换为\\，不抱怨，因为这样很方便，毕竟只是工具

-- 生成的bat命令中必须使用绝对路径
-- 因为这样不容易出错
-- batch这种东西是没法调试的，所以不要复杂化

-- 路径使用双引号包裹
-- 避免空格

-- D:\_Resources\[nss]\trunk\NssUnityProj\Assets\Editor\TATools\ToolMergeBranch
-- 生成bat的路径
output_file_path = "."

copyfile_cmd = "echo f|xcopy"

-- /y	Suppresses prompting to confirm that you want to overwrite an existing destination file.
-- （避免确认信息，当覆写已有文件时）
copyfile_args = "/Y "

copydir_cmd = "xcopy"

-- /e	Copies all subdirectories, even if they are empty. Use /e with the /s and /t command-line options.
-- （递归拷贝整个子树，即使一个目录是空的）
copydir_args = "/e /Y"

assert_not_nil_or_empty_str = function(s, msg)
    return assert(s and s ~= "", msg)
end

copyfile_statment = function(src_path, dest_path)
    assert_not_nil_or_empty_str(src_path)
    assert_not_nil_or_empty_str(dest_path)
    string.gsub("/", "\\")
    local stat = copyfile_cmd .. '"' .. src_path .. '" "' .. dest_path .. copyfile_args
    return stat
end

copydir_statement = function(src_path, dest_path)
    assert_not_nil_or_empty_str(src_path)
    assert_not_nil_or_empty_str(dest_path)
    string.gsub("/", "\\")
    local stat = copydir_cmd .. '"' .. src_path .. '" "' .. dest_path .. copydir_args
    return stat
end

-- 然后要提供一个目录下文件和目录的批量删除（可能是要过滤）


del_file_cmd = "del /s /Q"
del_dir_cmd = "rd /s /q"

del_file_statement = function(path)
    local statment = del_file_cmd ..'"'..path..'"'
end


-- del dir 一样
-- add pause if you need