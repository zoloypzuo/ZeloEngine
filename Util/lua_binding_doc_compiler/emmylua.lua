-- emmylua.lua
-- created on 2019/10/13
-- author @zoloypzuo

--# 输入
--# (doc comment in a line array, c func name)
--#
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
--#
--# 输出
--#
--# 不考虑缩进


function func(modname, fname, parlist, doc)
    return doc .. list(string.format([[
function %s.%s(%s)
end
]], modname, fname, table.concat(parlist, ",")))
end

function comment(cmt)
    return '-- ' .. cmt .. '\n'
end

function mod(modname, func_s)
    return list(comment(modname .. ".lua")) ..
            list(modname + ' = {}\n') ..
            func_s ..
            list('return ' + modname)
end