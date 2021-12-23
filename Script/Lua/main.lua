-- main.lua
-- created on 2021/5/5
-- author @zoloypzuo
print("start running main.lua")

global("CWD")
CWD = SCRIPT_DIR .. "/Lua"

-- global require

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
