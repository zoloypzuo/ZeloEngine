-- std_extension.lua
-- created on 2019/9/26
-- author @zoloypzuo
--
-- 扩展标准库

function readall(path)
    local f = assert(io.open(path, "r"))
    local text = f:read("a")
    f:close()
    return text
end

function writeall(path, text)
    local f = assert(io.open(path, "w"))
    f:write(text)
    f:close()
end

-- 区分出int和float
-- ex是扩展，增强的意思，不要覆盖标准库的type，这样会造成令人困惑的错误
function ex_type(o)
    local t = type(o)
    if t == "number" then
        return math.type(o)
    else
        return type(o)
    end
end

function map(func, array)
    local new_array = {}
    for i, v in ipairs(array) do
        new_array[i] = func(v)
    end
    return new_array
end

function table.tostring(t)
    local a = {}
    for k, v in pairs(t) do
        print(k, v)
        a[#a + 1] = tostring(k) .. " : " .. tostring(v)
    end
    return "{" .. table.concat(a, ", ") .. "}"
end