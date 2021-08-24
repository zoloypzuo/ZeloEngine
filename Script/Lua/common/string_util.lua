-- string_util
-- created on 2021/8/24
-- author @zoloypzuo
function string:split(sep)
    local sep, fields = sep or ":", {}
    local pattern = string.format("([^%s]+)", sep)
    self:gsub(pattern, function(c) fields[#fields+1] = c end)
    return fields
end


local Chars = {}
for Loop = 0, 255 do
    Chars[Loop+1] = string.char(Loop)
end
local String = table.concat(Chars)

local Built = {['.'] = Chars}

local AddLookup = function(CharSet)
    local Substitute = string.gsub(String, '[^'..CharSet..']', '')
    local Lookup = {}
    for Loop = 1, string.len(Substitute) do
        Lookup[Loop] = string.sub(Substitute, Loop, Loop)
    end
    Built[CharSet] = Lookup

    return Lookup
end

function string.random(Length, CharSet)
    -- Length (number)
    -- CharSet (string, optional); e.g. %l%d for lower case letters and digits

    local CharSet = CharSet or '.'

    if CharSet == '' then
        return ''
    else
        local Result = {}
        local Lookup = Built[CharSet] or AddLookup(CharSet)
        local Range = table.getn(Lookup)

        for Loop = 1,Length do
            Result[Loop] = Lookup[math.random(1, Range)]
        end

        return table.concat(Result)
    end
end
