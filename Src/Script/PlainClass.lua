-- PlainClass.lua
-- created on 2019/9/15
-- author @zoloypzuo

-- 平凡类
-- Class的简化版
-- 用于配置类，要求写的类不会被复用，进行复杂的编程
function PlainClass(_ctor)
    local cls = {}

    assert(_ctor)
    cls._ctor = _ctor

    local mt = {}
    mt.__call = function(cls, ...)
        local o = {}  -- the new instance
        cls._ctor(o, ...)
        setmetatable(o, cls)
        return o
    end

    setmetatable(cls, mt)

    return cls
end