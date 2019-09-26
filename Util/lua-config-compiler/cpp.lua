-- cpp.lua
-- created on 2019/9/26
-- author @zoloypzuo

require("global")

function tab(code)
    local ret = list()
    for i, line in pairs(code) do
        ret[i] = "\t" .. line
    end
    return ret
end

function join(code)
    return table.concat(code)
end

function header_guard(classname, code)
    local start = [[
#ifndef ZELOENGINE_D3DAPPCONFIG_H
#define ZELOENGINE_D3DAPPCONFIG_H
]]
    local _end = "#endif //ZELOENGINE_D3DAPPCONFIG_H\n"
    start = string.gsub(start, "D3DAPPCONFIG", string.upper(classname))
    _end = string.gsub(_end, "D3DAPPCONFIG", string.upper(classname))
    return list(start) .. code .. list(_end)
end

function include(header, use_quote)
    use_quote = use_quote or true
    if not use_quote then
        error()  -- TODO
    end
    return list("#include \"" .. header .. "\"\n")
end

function struct(name, code)
    return list(
            "struct " .. name .. "\n",
            "{\n") ..
            tab(code) ..
            list("};\n")
end

-- lua type to cpp type
local typemap = {
    ["string"] = "const char*",
    ["integer"] = "int",
    ["boolean"] = "bool",
}
function member_var_decl(type, name)
    return list(typemap[type] .. " " .. name .. "{};\n")
end


--print(header_guard("AAA", list()))
--print(include("lua.hpp"))