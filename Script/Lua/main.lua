-- main.lua
-- created on 2021/5/5
-- author @zoloypzuo

-- amend LUA_PATH
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/common/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/engine/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/scriptlibs/?.lua"

-- global require
require("os")
require("class")

print("=== dump path info")
print("package.path", package.path)
--print("package.cpath", package.cpath)
--print("PATH", os.getenv("PATH"))
--print("SCRIPT_DIR", SCRIPT_DIR)

require("engine")
