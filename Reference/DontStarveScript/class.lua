-- class.lua
-- Compatible with Lua 5.1 (not 5.0).

local TrackClassInstances = false

ClassRegistry = {}

if TrackClassInstances == true then
    global("ClassTrackingTable")
    global("ClassTrackingInterval")

    ClassTrackingInterval = 100
end

local function __index(t, k)
    local p = rawget(t, "_")[k]
    if p ~= nil then
        return p[1]
    end
    return getmetatable(t)[k]
end

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

local function onreadonly(t, v, old)
    assert(v == old, "Cannot change read only property")
end

function makereadonly(t, k)
    local _ = rawget(t, "_")
    assert(_ ~= nil, "Class does not support read only properties")
    local p = _[k]
    if p == nil then
        _[k] = { t[k], onreadonly }
        rawset(t, k, nil)
    else
        p[2] = onreadonly
    end
end

function addsetter(t, k, fn)
    local _ = rawget(t, "_")
    assert(_ ~= nil, "Class does not support property setters")
    local p = _[k]
    if p == nil then
        _[k] = { t[k], fn }
        rawset(t, k, nil)
    else
        p[2] = fn
    end
end

function removesetter(t, k)
    local _ = rawget(t, "_")
    if _ ~= nil and _[k] ~= nil then
        rawset(t, k, _[k][1])
        _[k] = nil
    end
end

function Class(base, _ctor, props)
    local c = {}    -- a new class instance
    local c_inherited = {}
    if not _ctor and type(base) == 'function' then
        _ctor = base
        base = nil
    elseif type(base) == 'table' then
        -- our new class is a shallow copy of the base class!
        -- while at it also store our inherited members so we can get rid of them 
        -- while monkey patching for the hot reload
        -- if our class redefined a function peronally the function pointed to by our member is not the in in our inherited
        -- table
        for i,v in pairs(base) do
            c[i] = v
            c_inherited[i] = v
        end
        c._base = base
    end
    
    -- the class will be the metatable for all its objects,
    -- and they will look up their methods in it.
    if props ~= nil then
        c.__index = __index
        c.__newindex = __newindex
    else
        c.__index = c
    end

    -- expose a constructor which can be called by <classname>(<args>)
    local mt = {}
    
    if TrackClassInstances == true and CWD~=nil then
        if ClassTrackingTable == nil then
            ClassTrackingTable = {}
        end
        ClassTrackingTable[mt] = {}
        local dataroot = "@"..CWD.."\\"
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
                        local equalsPos = string.find(source,"=")
                        if equalsPos then
                            source = string.sub(source,1,equalsPos-1)
                        end 
                        -- remove trailing and leading whitespace
                        source = source:gsub("^%s*(.-)%s*$", "%1")
                        -- do we start with local? if so, strip it
                        if string.find(source,"local ") ~= nil then
                            source = string.sub(source,7)
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
            if m == klass then return true end
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
                for i,v in pairs(ClassTrackingTable) do
                    local count = 0
                    local first = nil
                    for j,k in pairs(v) do
                        if count == 1 then
                            first = k
                        end
                        count = count + 1
                    end
                    if count>1 then
                        sorted[#sorted+1] = {first, count-1}
                    end
                    index = index + 1
                end
                -- get the top 10
                table.sort(sorted, function(a,b) return a[2] > b[2] end )
                for i=1,10 do
                    local entry = sorted[i]
                    if entry then
                        print(tostring(i).." : "..tostring(sorted[i][1]).." - "..tostring(sorted[i][2]))
                    end 
                end
                print("------------------------------------------------------------------------------------------------------------")
            end
        end
    end
end