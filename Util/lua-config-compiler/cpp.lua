-- cpp.lua
-- created on 2019/9/26
-- author @zoloypzuo

require("global")

function tab(code)
    local ret = {}
    for i, line in ipairs(code) do
        ret[i] = "\t" + line
    end
    return ret
end

function join(code)
    return table.concat(code)
end

function header_guard(classname, code)
    local start = [[
#ifndef ZELOENGINE_D3DAPPCONFIG_H
#define ZELOENGINE_D3DAPPCONFIG_H]]
    local _end = [[#endif //ZELOENGINE_D3DAPPCONFIG_H]]
    start = string.gsub(start, "D3DAPPCONFIG", classname)
    _end = string.gsub(_end, "D3DAPPCONFIG", classname)
    return list.append()
end