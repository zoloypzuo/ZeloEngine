-- lua_config_compiler.lua
-- created on 2019/9/14
-- author @zoloypzuo
--
-- see Src/LuaConfig/D3DAppConfig as example
-- 1. load lua code, reflect and generate cpp code, NOTE to check config error
-- 2. copy generated cpp code to Src/LuaConfig dir
-- [x] update CMakeList.txt, make sure the cpp code is added to cmake: cmake will handle that
--
-- see design doc at github Lua配置管理的设计 #97
--
-- why it is called "compiler"? because it generate cpp code, and cpp code need to be compiled

-- foreach lua file in Class dir, require it
-- read its name and table
-- foreach item in the table, get name and type, check type is number (int and float), or string, or bool
-- generate a Cpp struct
-- generate load code, it is HARD

local config_dir = "Src/LuaConfig/"
local config_class_dir = "Src/LuaConfig/Class/"

local function handle_cls(classname)
    local cls = require(classname)
    local o = cls()
    for k, v in pairs(o) do
        local t = type(v)
        if t == "number" then
        elseif t == "string" then
        elseif t == "boolean" then
        end
    end
end
