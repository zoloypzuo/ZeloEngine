-- class.lua
-- Compatible with Lua 5.1 (not 5.0).
-- 2019年10月5日
--
-- 这个模块主要是Class函数
-- Class函数附赠makereadonly，addsetter，removesetter，和一个TrackClassInstances开关

local TrackClassInstances = false

-- 类注册表
-- 派生类 => 基类继承的字段的表
-- ClassRegistry[c] = c_inherited
-- 说明一下，这个不是继承链，继承链直接在类的_base字段就体现了
-- 这个是区分一个成员是继承还是自己本身的
-- 因为构造一个类的时候，c和c_inherited都会深复制一份基类的成员
-- 之后c自己加了自己的成员，有了c_inherited就可以区别出来
ClassRegistry = {}

-- TrackClassInstances开关（跟踪类实例）
-- 增加跟踪表和跟踪间隔两个全局变量
if TrackClassInstances == true then
    global("ClassTrackingTable")
    global("ClassTrackingInterval")

    ClassTrackingInterval = 100
end

--
-- 只读属性和setter这两个功能，使用了_字段重写属性
-- 一个属性变成一个tuple，tuple[0]是属性，tuple[1]是函数
--

-- 加入只读和setter功能的index元方法
-- 返回t._[k][1]，如果没有递归查找元表
local function __index(t, k)
    local p = rawget(t, "_")[k]
    if p ~= nil then
        return p[1]
    end
    return getmetatable(t)[k]
end

-- 加入只读和setter功能的newindex元方法
-- t._[k]，如果还没有这个k，就直接set，否则触发t_[k][2]的方法
local function __newindex(t, k, v)
    local p = rawget(t, "_")[k]
    if p == nil then
        rawset(t, k, v)
    else
        local old = p[1]
        p[1] = v
        p[2](t, v, old)
    end
end

local function __dummy()
end

-- 设置只读属性时检查是否改变了值，如果改变了则抛出异常
local function onreadonly(t, v, old)
    assert(v == old, "Cannot change read only property")
end

-- 将t的k变成只读的
-- t有一个_字段，代表t有只读属性，否则抛出异常
function makereadonly(t, k)
    local _ = rawget(t, "_")
    assert(_ ~= nil, "Class does not support read only properties")
    -- 从_访问k，_[k]是一个tuple，将第二个元素设为onreadonly
    local p = _[k]
    if p == nil then
        _[k] = { t[k], onreadonly }
        rawset(t, k, nil)
    else
        p[2] = onreadonly
    end
end

-- 为t的k设置setter
-- t有一个_字段,否则抛出异常
function addsetter(t, k, fn)
    local _ = rawget(t, "_")
    assert(_ ~= nil, "Class does not support property setters")
    -- 从_访问k，_[k]是一个tuple，将第二个元素设为fn
    local p = _[k]
    if p == nil then
        _[k] = { t[k], fn }
        rawset(t, k, nil)
    else
        p[2] = fn
    end
end

-- 移除setter
function removesetter(t, k)
    local _ = rawget(t, "_")
    if _ ~= nil and _[k] ~= nil then
        rawset(t, k, _[k][1])
        _[k] = nil
    end
end

-- 返回一个类，指定基类，构造函数和props
-- 大部分情况下，只用_ctor一个参数（我们按照这个作为下面的描述的默认假设）
--
-- props是一个字典，k是成员名字，v是函数，这个是上面提到的属性的概念，比如setter
-- props这个参数，如果有的话
-- * c的__index和__newindex（也就是实例的元方法）被设为上面的两个函数
-- * 实例创建一个名为_的表，存放特别的属性，用props初始化
--
-- c._base
-- c._ctor
-- c:is_a(klass)：类有继承链，所以is_a（基类）是true
--
-- 类的实例的元表默认是类本身
--
-- 类的元表暴露一个__call，用<classname>(<args>)的形式调用

--
function Class(base, _ctor, props)
    local c = {}    -- a new class instance
    local c_inherited = {}
    if not _ctor and type(base) == 'function' then
        _ctor = base
        base = nil
    elseif type(base) == 'table' then
        -- our new class is a shallow copy of the base class!（派生类是基类的浅拷贝）
        -- while at it also store our inherited members so we can get rid of them 
        -- while monkey patching for the hot reload（然而它也存储继承下来的成员，这样monkey patching的热加载时就可以消除它们）
        -- if our class redefined a function personally（如果派生类重新定义了一个函数）
        -- the function pointed to by our member is not the in in our inherited table（这个函数不是指向基类表的）
        for i, v in pairs(base) do
            c[i] = v
            c_inherited[i] = v
        end
        c._base = base
    end

    -- 注意这里不是设置类的元表，而是设置实例的元表
    -- the class will be the metatable for all its objects,（类将是所有实例的元表）
    -- and they will look up their methods in it.（这样在类中查找方法）
    if props ~= nil then
        c.__index = __index
        c.__newindex = __newindex
    else
        c.__index = c
    end

    -- expose a constructor which can be called by <classname>(<args>)（类的元表暴露一个__call，用<classname>(<args>)的形式调用）
    local mt = {}

    -- CWD没有找到定义
    -- CWD是current working directory的意思
    if TrackClassInstances == true and CWD ~= nil then
        if ClassTrackingTable == nil then
            ClassTrackingTable = {}
        end
        ClassTrackingTable[mt] = {}
        local dataroot = "@" .. CWD .. "\\"
        local tablemt = {}
        setmetatable(ClassTrackingTable[mt], tablemt)
        tablemt.__mode = "k"         -- now the instancetracker has weak keys

        local source = "**unknown**"
        if _ctor then
            -- what is the file this ctor was created in?

            local info = debug.getinfo(_ctor, "S")
            -- strip the drive letter
            -- convert / to \\
            source = info.source
            source = string.gsub(source, "/", "\\")
            source = string.gsub(source, dataroot, "")
            local path = source

            local file = io.open(path, "r")
            if file ~= nil then
                local count = 1
                for i in file:lines() do
                    if count == info.linedefined then
                        source = i
                        -- okay, this line is a class definition
                        -- so it's [local] name = Class etc
                        -- take everything before the =
                        local equalsPos = string.find(source, "=")
                        if equalsPos then
                            source = string.sub(source, 1, equalsPos - 1)
                        end
                        -- remove trailing and leading whitespace
                        source = source:gsub("^%s*(.-)%s*$", "%1")
                        -- do we start with local? if so, strip it
                        if string.find(source, "local ") ~= nil then
                            source = string.sub(source, 7)
                        end
                        -- trim again, because there may be multiple spaces
                        source = source:gsub("^%s*(.-)%s*$", "%1")
                        break
                    end
                    count = count + 1
                end
                file:close()
            end
        end

        mt.__call = function(class_tbl, ...)
            local obj = {}
            if props ~= nil then
                obj._ = { _ = { nil, __dummy } }
                for k, v in pairs(props) do
                    obj._[k] = { nil, v }
                end
            end
            setmetatable(obj, c)
            ClassTrackingTable[mt][obj] = source
            if c._ctor then
                c._ctor(obj, ...)
            end
            return obj
        end
    else
        -- 类的构造过程
        -- 我先强调一下，不是具体的构造函数，而是通用的类的构造过程
        -- 设置props，将类设为实例的元表，调用构造函数，就返回了
        mt.__call = function(class_tbl, ...)
            local obj = {}
            if props ~= nil then
                obj._ = { _ = { nil, __dummy } }
                for k, v in pairs(props) do
                    obj._[k] = { nil, v }
                end
            end
            setmetatable(obj, c)
            if c._ctor then
                c._ctor(obj, ...)
            end
            return obj
        end
    end

    c._ctor = _ctor
    c.is_a = function(self, klass)
        local m = getmetatable(self)
        while m do
            if m == klass then
                return true
            end
            m = m._base
        end
        return false
    end
    setmetatable(c, mt)
    ClassRegistry[c] = c_inherited
    --    local count = 0
    --    for i,v in pairs(ClassRegistry) do
    --        count = count + 1
    --    end
    --    if string.split then
    --        print("ClassRegistry size : "..tostring(count))
    --    end
    return c
end

local lastClassTrackingDumpTick = 0

function HandleClassInstanceTracking()
    if TrackClassInstances then
        lastClassTrackingDumpTick = lastClassTrackingDumpTick + 1

        if lastClassTrackingDumpTick >= ClassTrackingInterval then
            collectgarbage()
            print("------------------------------------------------------------------------------------------------------------")
            lastClassTrackingDumpTick = 0
            if ClassTrackingTable then
                local sorted = {}
                local index = 1
                for i, v in pairs(ClassTrackingTable) do
                    local count = 0
                    local first = nil
                    for j, k in pairs(v) do
                        if count == 1 then
                            first = k
                        end
                        count = count + 1
                    end
                    if count > 1 then
                        sorted[#sorted + 1] = { first, count - 1 }
                    end
                    index = index + 1
                end
                -- get the top 10
                table.sort(sorted, function(a, b)
                    return a[2] > b[2]
                end)
                for i = 1, 10 do
                    local entry = sorted[i]
                    if entry then
                        print(tostring(i) .. " : " .. tostring(sorted[i][1]) .. " - " .. tostring(sorted[i][2]))
                    end
                end
                print("------------------------------------------------------------------------------------------------------------")
            end
        end
    end
end