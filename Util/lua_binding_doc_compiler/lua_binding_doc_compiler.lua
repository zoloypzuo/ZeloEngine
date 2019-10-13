-- lua_binding_doc_compiler.lua
-- created on 2019/10/13
-- author @zoloypzuo

--from pprint import pprint
--from re import match
--from emmylua import *

require "lua_binding_doc_compiler.emmylua"
require "pl"
require "regex_patterb"

function gen(modname)
    lua_name2cname = {}
    local lines = pl.utils.readlines(modname .. ".txt")
    --# { "SetVelocity",                Lua_Script_AgentSetVelocity },
    for _, line in pairs(lines) do
        local k, v = assert(string.match(line, RE_C_ARRAY))
        --SetVelocity	Lua_Script_AgentSetVelocity
        lua_name2cname[k] = v
    end

    --# c func name => doc comment in a line array
    --#
    --# (doc comment in a line array, c func name)如下
    --# example1:
    --# [(['/**\n',
    --#    ' * @summary Apply a three dimensional force in meters to the agent.\n',
    --#    ' * @param agent Agent to apply force on.\n',
    --#    ' * @param vector Representing force in meters.\n',
    --#    ' * @package Agent\n',
    --#    ' * @example force = Agent.ApplyForce(agent, Vector.new(1, 0, 0));\n',
    --#    ' */\n'],
    --#   'Lua_Script_AgentApplyForce'),
    --# example2:
    --# ([], 'Lua_Script_AnimationGetLength'),
    raw_api_s = {}
    local lines = pl.utils.readlines("LuaScriptBindings.h")
    --# 这里当然不写parser，简单的方法是观察一下
    --# 我们读取到c函数定义就结束，生成一个api，否则加到buffer里

   --[[
   TODO 懒得写了，要么你重写一下
    with open("LuaScriptBindings.h", 'r') as f:
        # int Lua_Script_AgentForceToAlign(lua_State* luaVM);
        RE_LUA_C_FUNCTION = "int (.*)\(lua_State\* luaVM\);"
        RE_C_COMMENT = "/\*(.*)\*/"

        # 这里当然不写parser，简单的方法是观察一下
        # 我们读取到c函数定义就结束，生成一个api，否则加到buffer里
        buffer = []
        line = f.readline()
        while line:
            o = match(RE_LUA_C_FUNCTION, line)
            if o:
                # generate an api
                raw_api_s[o.group(1)] = buffer
                buffer = []
                f.readline()  # pass a blank line
            else:
                buffer.append(line)
            line = f.readline()
    # pprint(raw_api_s)

    func_s = []
    for k, v in lua_name2cname.items():
        doc = raw_api_s[v]
        if len(doc) > 0:
            del doc[0]
            del doc[len(doc) - 1]
            doc = ['---' + line.lstrip().lstrip('*') for line in doc]
        func_s += func(modname, k, (modname.lower(),), doc)

    out = ''.join(mod(modname, func_s))
    # pprint(''.join(mod(modname, func_s)))
    with open('doc.lua', 'w') as f:
        f.write(out)

   ]]
    for _, line in pairs(lines) do
        --# int Lua_Script_AgentForceToAlign(lua_State* luaVM);
        local o = string.match(line, RE_LUA_CFUNCTION)
        -- ... TODO
    end
    func_s = list()
    for k,v in pairs(lua_name2cname) do
        doc = raw_api_s[v]
        if #doc >0 then

        end
    end
end
--
--# Agent
--# Animation
--# Core
--# Vector
--# Sandbox
gen('UI')
--
--# TODO 不必一下子做得太狠，现在反正能用
--# TODO 生成parlist
--# TODO doc要改，param里加个@隔开注释
--# TODO 如何强调是table的array
--# region功能
--# --{{{
--# --}}}
