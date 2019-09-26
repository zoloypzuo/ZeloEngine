-- PlainClass.lua
-- created on 2019/9/15
-- author @zoloypzuo

-- 全局函数，因为太常用了，其实是标准库
function PlainClass(_ctor)
    local cls = {}

    assert(_ctor)
    cls._ctor = _ctor

    local mt = {}
    mt.__call = function(cls, ...)
        print(...)
        local o = {}  -- the new instance
        cls._ctor(o, ...)
        setmetatable(o, cls)
        return o
    end

    setmetatable(cls, mt)

    return cls
end