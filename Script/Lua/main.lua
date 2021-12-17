-- main.lua
-- created on 2021/5/5
-- author @zoloypzuo
print("start running main.lua")

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

local ENABLE_LUA_PANDA = true
if ENABLE_LUA_PANDA then
    local ZBS = "D:\\Installed\\ZeroBraneStudio"
    package.path = package.path .. ";" .. ZBS .. "\\lualibs\\?\\?.lua;" .. ZBS .. "\\lualibs\\?.lua"
    package.cpath = package.cpath .. ";" .. ZBS .. "\\bin\\?.dll;" .. ZBS .. "\\bin\\clibs\\?.dll"
    require("debugger.LuaPanda").start("127.0.0.1", 8818)
-- require("mobdebug").start()
end

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

global("CWD")
CWD = SCRIPT_DIR .. "/Lua"

-- global require
--require("strict")

require("imgui.imgui_consts")

require("consts")
require("debugprint")

require("config")
require("main_function")
require("vector3")
require("class")
require("debug/debugtools")
require("scheduler")
require("stategraph")
require("behaviourtree")
require("prefabs")
require("entityscript")
require("profiler")
require("brain")

require("ui.ui_root")
require("framework.events")
require("framework.vector2")
require("framework.color")

--debug key init
global("CHEATS_ENABLED")
CHEATS_ENABLED = false
if CHEATS_ENABLED then
    require "debugcommands"
    require "debugkeys"
end

FRAME = 1 / 30

Prefabs = {}
Ents = {}
AwakeEnts = {}
UpdatingEnts = {}
NewUpdatingEnts = {}
StopUpdatingEnts = {}

StopUpdatingComponents = {}

WallUpdatingEnts = {}
NewWallUpdatingEnts = {}
num_updating_ents = 0
NumEnts = 0

MeshGenerators = {}

ResourceMap = {}
ResourceLoaders = {}

global("TheCamera")
TheCamera = nil

global("TheFrontEnd")
TheFrontEnd = UIRoot()

inGamePlay = false

require "stacktrace"
require "debughelpers"

print("finish running main.lua")
