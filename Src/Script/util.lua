-- util.lua
-- created on 2019/10/13
-- author @zoloypzuo

-- 返回当前脚本的绝对路径
-- D:\ZeloEngine\Util\test.lua
--
-- 注意和lfs.currentdir()对比一下，这种是固定的路径，
function script_path()
    local str = debug.getinfo(2, "S").source:sub(2)
    print(str)
    return str:match("(.*/)")
end

print(script_path())