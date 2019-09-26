-- std_extension.lua
-- created on 2019/9/26
-- author @zoloypzuo

list = {}

function list.concat(a, b)
    return
end

-- 将列表a复制到列表b的末尾
function list.append(a, b)
    return table.move(a, 1, #a, #b + 1, b)
end


-- 返回a的浅拷贝
function list.clone(a)
    return table.move(a, 1, #a, 1, {})
end

function readall(path)
    local f = assert(io.open(path,"r"))
    local text = f:read("a")
    f:close()
    return text
end

function writeall(path, text)
    local f = assert(io.open(path,"w"))
    f:write(text)
    f:close()
end

-- 区分出int和float
local function ex_type(o)
    local t = type(o)
    if t == "number" then
        return math.type(o)
    else
        return type(o)
    end
end