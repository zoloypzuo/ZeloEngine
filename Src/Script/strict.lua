-- strict.lua
-- 2019年10月5日
--
-- # 实现类似于Python的全局变量机制
-- main函数块（也就是“全局作用域”）是可以直接定义全局变量的
-- 其他作用域（也就是函数内），需要通过使用global函数声明全局变量，
-- 然后才能使用，否则get或set都会抛出异常
-- 上面是Lua函数的部分，C函数总是绕过这个机制，不会抛出异常
--
-- # 优点（也是动机，要解决的问题）
-- 更严格的检查，避免去访问未声明的全局变量
--
-- # 缺点
-- 必须运行时，因为lua的编译时没有这个检查，这个相当于是lua层的补丁
--
-- # __STRICT开关，不要关掉，否则你要严格干嘛
--
-- # 关于游戏Release版撤掉检查
-- 必要性和性能提升：这个只是检查全局变量
-- 所以看你的全局变量有多少，全局变量多，则strict.lua的附加开销大
-- 撤掉的方法，strict.lua代码清空，然后定义global函数为空函数体

local mt = getmetatable(_G)
if mt == nil then
    mt = {}
    setmetatable(_G, mt)
end

__STRICT = true
mt.__declared = {}

mt.__newindex = function(t, n, v)
    if __STRICT and not mt.__declared[n] then
        local w = debug.getinfo(2, "S").what
        if w ~= "main" and w ~= "C" then
            error("assign to undeclared variable '" .. n .. "'", 2)
        end
        mt.__declared[n] = true
    end
    rawset(t, n, v)
end

mt.__index = function(t, n)
    -- 判定全局变量未声明的条件：
    -- * 没有标记已声明
    -- * 访问该变量的函数是lua函数
    if not mt.__declared[n] and debug.getinfo(2, "S").what ~= "C" then
        error("variable '" .. n .. "' is not declared", 2)
    end
    return rawget(t, n)
end

-- 接受一个字符串列表，将这些名字标记为已声明
function global(...)
    for _, v in ipairs { ... } do
        mt.__declared[v] = true
    end
end

-- test 1
--local local_a = a  -- 这个会触发“variable 'a' is not declared”，get一个没有声明的变量，a没有任何值，你确实不应该这么做

--D:\ZeloEngine\lua.exe: ...eam/steamapps/common/dont_starve/data/scripts/strict.lua:54: variable 'a' is not declared
--stack traceback:
--[C]: in function 'error'
--...eam/steamapps/common/dont_starve/data/scripts/strict.lua:41: in metamethod '__index'
--...eam/steamapps/common/dont_starve/data/scripts/strict.lua:54: in main chunk
--[C]: in ?

-- test 2
--a = 1  -- 这样是ok的，main块（也就是全局作用域）可以直接定义全局变量，不需要用global函数
--local local_a = a  -- 然后就可以用a了

-- test 3
--function f()  -- 如果不赦免main块的话，全局函数也要先用global声明，就很麻烦
--    local local_a = a
--end
--
--f()

--D:\ZeloEngine\lua.exe: ...eam/steamapps/common/dont_starve/data/scripts/strict.lua:62: variable 'a' is not declared
--stack traceback:
--[C]: in function 'error'
--...eam/steamapps/common/dont_starve/data/scripts/strict.lua:41: in metamethod '__index'
--...eam/steamapps/common/dont_starve/data/scripts/strict.lua:62: in function 'f'
--...eam/steamapps/common/dont_starve/data/scripts/strict.lua:65: in main chunk
--[C]: in ?

-- test 4
--function f()
--    a = 1  -- 在函数中直接创建全局变量，或者为未声明的全局变量赋值，是错误的
--    local local_a = a
--end
--
--f()

--D:\ZeloEngine\lua.exe: ...eam/steamapps/common/dont_starve/data/scripts/strict.lua:84: assign to undeclared variable 'a'
--stack traceback:
--[C]: in function 'error'
--...eam/steamapps/common/dont_starve/data/scripts/strict.lua:29: in metamethod '__newindex'
--...eam/steamapps/common/dont_starve/data/scripts/strict.lua:84: in function 'f'
--...eam/steamapps/common/dont_starve/data/scripts/strict.lua:88: in main chunk
--[C]: in ?

-- test 5
--__STRICT = false  -- 关闭严格开关，就ok了
--function f()
--    a = 1
--    local local_a = a
--end