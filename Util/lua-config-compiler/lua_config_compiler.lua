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

require("cpp")
require('lfs')

k_config_dir = [[D:\ZeloEngine\Src\LuaConfig]]
k_lua_config_class_dir = [[D:\ZeloEngine\Src\LuaConfig\LuaConfigClass\]]  -- 实验了一下，正反斜杠对lfs都是ok的
k_cpp_config_class_dir = [[D:\ZeloEngine\Src\LuaConfig\CppConfigClass_Generated\]]

function generate_member_var(symbol_table)
    local code = list()
    for name, type in pairs(symbol_table) do
        code = code .. member_var_decl(type, name)
    end
    return code
end

function generate_cpp_code(classname, symbol_table)
    local header_code = header_guard(classname,
            include("lua.hpp") ..
                    struct(classname,
                            generate_member_var(symbol_table) ..
                                    list(classname .. "();\n") ..
                                    list("friend class LuaConfigManager;\n") ..
                                    list("private:\n") ..
                                    list("static void LoadConfig(lua_State* L, " .. classname .. "* pConfig);\n")
                    )
    )
    print(join(header_code))
    writeall(k_cpp_config_class_dir .. classname .. "test.hpp", join(header_code))
    local cpp_code = {}

end

for filename in lfs.dir(k_lua_config_class_dir) do
    local path = k_lua_config_class_dir .. filename
    if lfs.attributes(path, "mode") == "file" then
        -- is file?
        print(filename)
        local classname = assert(string.match(filename, "([%a_][%w_]*)%.lua"))
        local cls = dofile(path)
        local o = cls()
        local symbol_table = {}
        for k, v in pairs(o) do
            symbol_table[k] = ex_type(v)
        end
        --print(table.tostring(symbol_table))
        generate_cpp_code(classname, symbol_table)
    end
end

