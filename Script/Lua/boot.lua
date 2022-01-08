-- boot.lua
-- created on 2021/12/23
-- author @zoloypzuo
print("start running boot.lua")

-- LUA_PATH
-- config
package.path = package.path .. ";" .. CONFIG_DIR .. "/?.lua"

-- resource
package.path = package.path .. ";" .. RESOURCE_DIR .. "/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/Materials/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/Models/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/Textures/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Fonts/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Shaders/?.lua"

-- script
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/common/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/engine/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/framework/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/framework/debug/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/prefabs/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/scriptlibs/?.lua"

DUMP_LUA_PATH = false
if DUMP_LUA_PATH then
    print("=== Start dump path info")
    print("package.path", package.path)
    print("package.cpath", package.cpath)
    print("PATH", os.getenv("PATH"))
    print("SCRIPT_DIR", SCRIPT_DIR)
    print("=== End dump path info")
end

global = function(name)
end
--require("strict")

global("ConfigCache")
ConfigCache = {}
function registerConfigClass(klass_name)
    local klass = _G[klass_name]
    local mt = getmetatable(klass)
    mt.__call = function(class_tbl, data)
        local o = class_tbl.new()
        for k, v in pairs(data) do
            o[k] = v
        end
        ConfigCache[#ConfigCache + 1] = o
        return o
    end
end

print("finish running boot.lua")
