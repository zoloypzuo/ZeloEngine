local print_loggers = {}

function AddPrintLogger( fn )
    table.insert(print_loggers, fn)
end

require"util" -- for string:split

global("CWD")

local dir = CWD or ""
dir = string.gsub(dir, "\\", "/") .. "/"
local oldprint = print

matches =
{
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
    for i,v in ipairs({...}) do
        str = str..tostring(v).."\t"
    end
    return str
end
--this wraps print in code that shows what line number it is coming from, and pushes it out to all of the print loggers
print = function(...)

	local info = debug.getinfo(2, "Sl") or { source = "*engine*" }
	local source = info.source 
	local str = ""
	if info and info.source and string.sub(info.source,1,1)=="@" then
		source = source:sub(2)
		source = source:gsub("^"..escape_lua_pattern(dir), "")
		str = string.format("%s(%d,1) %s", tostring(source), info.currentline, packstring(...))
	else
		str = packstring(...)
	end

	for i,v in ipairs(print_loggers) do
		v(str)
	end

end

--This is for times when you want to print without showing your line number (such as in the interactive console)
nolineprint = function(...)

    for i,v in ipairs(print_loggers) do
        v(...)
    end
    
end


---- This keeps a record of the last n print lines, so that we can feed it into the debug console when it is visible
local debugstr = {}
local MAX_CONSOLE_LINES = 20

local consolelog = function(...)
    
    local str = packstring(...)
    str = string.gsub(str, dir, "")

    for idx,line in ipairs(string.split(str, "\r\n")) do
        table.insert(debugstr, line)
    end

    while #debugstr > MAX_CONSOLE_LINES do
        table.remove(debugstr,1)
    end
end

function GetConsoleOutputList()
    return debugstr
end

-- add our print loggers
AddPrintLogger(consolelog)

