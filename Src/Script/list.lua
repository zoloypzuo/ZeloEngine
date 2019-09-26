-- list.lua
-- created on 2019/9/26
-- author @zoloypzuo

require("std_extension")
require("PlainClass")

list = PlainClass(function(self, ...)
    self._list = { ... }  -- internal list
end)


-- 列表拼接
list.__concat = function(a, b)
    local ret = list()
    table.move(a._list, 1, #a, 1, ret._list)
    table.move(b._list, 1, #b, #ret + 1, ret._list)
    return ret
end

list.__index = function(self, key)
    local mt = getmetatable(self)
    if mt[key] ~= nil then
        return mt[key]
    end
    return self._list[key]
end

list.__newindex = function(self, key, value)
    self._list[key] = value
end

list.__tostring = function(self)
    return "[" .. table.concat(map(tostring, self._list), ", ") .. "]"
end

list.__len = function(self)
    return #self._list
end

list.__pairs = function(t)
    return function(_t, i)
        i = i + 1
        local v = _t._list[i]
        if v then
            return i, v
        end
    end, t, 0
end

function list:append(item)
    self._list[#self + 1] = item
end

-- some test


--local oldp = print
--print = function()
--end
--
--local a = list()
--print(table.tostring(a))
--a[1] = 2
--a[2] = 3
--a[3] = 4
--local b = list()
--b[1] = 5
--b[2] = 6
--b[3] = 7
--print(a .. b)
--a:append(1)
--print(a)
--print(table.tostring(list))
--
--for i, item in pairs(list(1, 2, 3)) do
--    print(i, item)
--end
--
--print = oldp