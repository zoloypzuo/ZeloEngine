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

function generate_param_list(param_type_name_list)
    -- in {{lua_State*, L}, {D3DAppConfig*, pConfig}}
    -- out "lua_State* L, D3DAppConfig* pConfig"
    return table.concat(map(function(t)
        return table.concat(t, " ")
    end, param_type_name_list), ", ")
end

function impl_member_function(ret_type, classname, method_name, param_type_name_list, code)
    return list(ret_type .. " " .. classname .. "::" .. method_name .. "(" ..
            generate_param_list(param_type_name_list) .. ")\n{\n") ..
            tab(code)
            .. list("}\n")
end

function empty_ctor(classname)
    return list(classname .. "::" .. classname .. "()\n" .. [[
{
}
]])
end

-- 赋值语句，左值和右值，这里简化为字符串，避免复杂化
function assign_stat(lvar, rvar)
    return list(lvar .. " = " .. rvar .. ";\n")
end

-- 函数调用表达式（注意不带分号），arglist是字符串列表，同样是简化了
function function_call_exp(funcname, arglist)
    return funcname .. "(" .. table.concat(arglist, ", ") .. ")"
end

-- 转换为cpp字符串字面量，暂时不考虑转义
function string_literal(s)
    return "\"" .. s .. "\""
end

--print(header_guard("AAA", list()))
--print(include("lua.hpp"))