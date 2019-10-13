-- regex_pattern.lua
-- created on 2019/10/13
-- author @zoloypzuo

-- 全局常量，这样命名，丑一点，特别一点
-- 尽管不是regex，但是方便，容易辨识

local function capture(s)
    return "(" .. s .. ")"
end

local function star(s)
    return s .. "*"
end

-- 这个函数很重要，否则你的正则就很难看了
local function tokens(...)
    local tks = { ... }
    return table.concat(tks, RE_WHITESPACE_SEQUENCE) .. RE_WHITESPACE_SEQUENCE
end

local function c_string(s)
    return '"' .. s .. '"'
end

-- 注意括号和捕获的区别，捕获是pattern语法的特殊控制字符
-- 括号， 就是普通字符
local function raw_bracket(s)
    return "\(" .. s .. ")"
end

RE_WHITESPACE_SEQUENCE = "%s*"  -- 不要用+，那样如果没有空白就不能匹配了
RE_IDENTIFIER = "[_%a][_%w]*"

-- 这个c array没有任何用处，因为c array的元素是表达式，那个你是肯定写不出来的
-- 所以你必须手写元素的re
--RE_C_ARRAY = tokens("{", star(capture(tokens(capture(RE_IDENTIFIER), ","))), "}")
--print(RE_C_ARRAY) -- {%s+(([_%a][_%w])%s+,%s+)*%s+}%s+

-- 还不如在这里写好呢
RE_C_ARRAY = tokens("{", c_string(capture(RE_IDENTIFIER)), ",", capture(RE_IDENTIFIER), "}")
print(RE_C_ARRAY) -- {%s*"([_%a][_%w]*)"%s*,%s*([_%a][_%w]*)%s*}%s*
print(string.match("{ \"SetVelocity\",                Lua_Script_AgentSetVelocity },", RE_C_ARRAY))

RE_LUA_CFUNCTION = tokens("int", "(.*)", raw_bracket("lua_State\*", "luaVM"), ";")
RE_C_COMMENT = "/\*(.*)\*/"