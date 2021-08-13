local print_loggers = {}

function AddPrintLogger(fn)
    table.insert(print_loggers, fn)
end

require "util" -- for string:split

global("CWD")

local dir = CWD or ""
dir = string.gsub(dir, "\\", "/") .. "/"
local _ = print

matches = {
    ["^"] = "%^",
    ["$"] = "%$",
    ["("] = "%(",
    [")"] = "%)",
    ["%"] = "%%",
    ["."] = "%.",
    ["["] = "%[",
    ["]"] = "%]",
    ["*"] = "%*",
    ["+"] = "%+",
    ["-"] = "%-",
    ["?"] = "%?",
    ["\0"] = "%z",
}
function escape_lua_pattern(s)
    return (s:gsub(".", matches))
end

local function packstring(...)
    local str = ""
    for i, v in ipairs({ ... }) do
        str = str .. tostring(v) .. "\t"
    end
    return str
end
--this wraps print in code that shows what line number it is coming from, and pushes it out to all of the print loggers
print = function(...)

    local info = debug.getinfo(2, "Sl")
    local source = info.source
    local str = ""
    if info.source and string.sub(info.source, 1, 1) == "@" then
        source = source:sub(2)
        source = source:gsub("^" .. escape_lua_pattern(dir), "")
        str = string.format("%s(%d,1) %s", tostring(source), info.currentline, packstring(...))
    else
        str = packstring(...)
    end

    for i, v in ipairs(print_loggers) do
        v(str)
    end

end
