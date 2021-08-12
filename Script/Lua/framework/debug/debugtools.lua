table.inspect = require("inspect")   -- add table pretty printer that understands recursive tables

local getinfo = debug.getinfo
local max = math.max
local concat = table.concat

local function filtersource(src)
    if not src then
        return "[?]"
    end
    if src:sub(1, 1) == "@" then
        src = src:sub(2)
    end
    return src
end

local function formatinfo(info)
    if not info then
        return "**error**"
    end
    local source = filtersource(info.source)
    if info.currentline then
        source = source .. ":" .. info.currentline
    end
    return ("\t%s in (%s) %s (%s) <%d-%d>"):format(source, info.namewhat, info.name or "?", info.what, info.linedefined, info.lastlinedefined)
end

function debugstack(start, top, bottom)
    if not bottom then
        bottom = 10
    end
    if not top then
        top = 12
    end
    start = (start or 1) + 1

    local count = max(2, start)
    while getinfo(count) do
        count = count + 1
    end

    count = count - start

    if top + bottom >= count then
        top = count
        bottom = nil
    end

    local s = { "stack traceback:" }
    for i = 1, top, 1 do
        s[#s + 1] = formatinfo(getinfo(start + i - 1))
    end
    if bottom then
        s[#s + 1] = "\t..."
        for i = bottom, 1, -1 do
            s[#s + 1] = formatinfo(getinfo(count - i + 1))
        end
    end

    return concat(s, "\n")
end

function debuglocals (level)
    local t = {}
    local index = 1
    while true do
        local name, value = debug.getlocal(level + 1, index)
        if not name then
            break
        end
        t[index] = string.format("%s = %s", name, tostring(value))
        index = index + 1
    end
    return table.concat(t, "\n")
end

function dumptable(obj, indent, recurse_levels)
    indent = indent or 1
    local i_recurse_levels = recurse_levels or 10
    if obj then
        local dent = ""
        if indent then
            for i = 1, indent do
                dent = dent .. "\t"
            end
        end
        if type(obj) == type("") then
            print(obj)
            return
        end
        for k, v in pairs(obj) do
            if type(v) == "table" and i_recurse_levels > 0 then
                print(dent .. "K: ", k)
                dumptable(v, indent + 1, i_recurse_levels - 1)
            else
                print(dent .. "K: ", k, " V: ", v)
            end
        end
    end
end

function tabletodictstring(obj, fn)
    if obj == nil then
        return "{ }"
    end
    local s = "{ "
    local first = true
    for k, v in pairs(obj) do
        if not first then
            s = s .. ", "
        else
            first = false
        end
        if fn then
            k, v = fn(k, v)
        end
        s = s .. tostring(k) .. "=" .. tostring(v)
    end
    s = s .. " }"
    return s
end
function tabletoliststring(obj, fn)
    if obj == nil then
        return "[ ]"
    end
    local s = "[ "
    local first = true
    for i, v in ipairs(obj) do
        if not first then
            s = s .. ", "
        else
            first = false
        end
        if fn then
            v = fn(v)
        end
        s = s .. tostring(v)
    end
    s = s .. " ]"
    return s
end
