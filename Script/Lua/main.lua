-- main.lua
-- created on 2021/5/5
-- author @zoloypzuo
local ENABLE_DEBUGGER = false
if ENABLE_DEBUGGER then
    print("LuaDebuggee StartDebug @'127.0.0.1', 9826")
    require('LuaDebuggee').StartDebug('127.0.0.1', 9826)
end
-- LUA_PATH
-- resource
package.path = package.path .. ";" .. RESOURCE_DIR .. "/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/Materials/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/Models/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/Textures/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Fonts/?.lua"

-- script
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/common/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/engine/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/framework/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/framework/debug/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/prefabs/?.lua"
package.path = package.path .. ";" .. SCRIPT_DIR .. "/Lua" .. "/scriptlibs/?.lua"

if false then
    print("=== dump path info")
    print("package.path", package.path)
    print("package.cpath", package.cpath)
    print("PATH", os.getenv("PATH"))
    print("SCRIPT_DIR", SCRIPT_DIR)
end

-- global require
--require("strict")

--require("debugprint")
-- add our print loggers
--AddPrintLogger(function(...)
--    TheSim:LuaPrint(...)
--end)

global = function(name)
end

require("config")
--require("languages/language")
require("main_function")
--require("preloadsounds")
--require("mods")
--require("json")
require("vector3")
--require("tuning")
--require("strings")
--require("stringutil")
--require("dlcsupport_strings")
--require("constants")
require("class")
--require("actions")
require("debug/debugtools")
--require("simutil")
--require("util")
require("scheduler")
require("stategraph")
require("behaviourtree")
require("prefabs")
require("entityscript")
require("profiler")
--require("recipes")
require("brain")
--require("emitters")
--require("dumper")
--require("input")
--require("upsell")
--require("stats")

--require("fileutil")
--require("screens/scripterrorscreen")
--require("prefablist")
--require("standardcomponents")
--require("update")
--require("mathutil")

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

print("running main.lua")

--math.randomseed(TheSim:GetRealTime())

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

MeshGenerators = {
    plane = PlaneMeshGen;
}

ResourceMap = {}
ResourceLoaders = {}

global("TheCamera")
TheCamera = nil

global("TheFrontEnd")
TheFrontEnd = UIRoot()

inGamePlay = false

require "stacktrace"
require "debughelpers"
