--install our crazy loader!
local loadfn = function(modulename)
    local errmsg = ""
    local modulepath = string.gsub(modulename, "%.", "/")
    for path in string.gmatch(package.path, "([^;]+)") do
        local filename = string.gsub(path, "%?", modulepath)
        filename = string.gsub(filename, "\\", "/")
        local result = kleiloadlua(filename)
        if result then
            return result
        end
        errmsg = errmsg .. "\n\tno file '" .. filename .. "' (checked with custom loader)"
    end
    return errmsg
end
table.insert(package.loaders, 1, loadfn)

require("strict")
require("debugprint")
-- add our print loggers
AddPrintLogger(function(...)
    TheSim:LuaPrint(...)
end)

require("config")
require("languages/language")
require("mainfunctions")
require("preloadsounds")
require("mods")
require("json")
require("vector3")
require("tuning")
require("strings")
require("stringutil")
require("dlcsupport_strings")
require("constants")
require("class")
require("actions")
require("debugtools")
require("simutil")
require("util")
require("scheduler")
require("stategraph")
require("behaviourtree")
require("prefabs")
require("entityscript")
require("profiler")
require("recipes")
require("brain")
require("emitters")
require("dumper")
require("input")
require("upsell")
require("stats")
require("frontend")

require("fileutil")
require("screens/scripterrorscreen")
require("prefablist")
require("standardcomponents")
require("update")
require("fonts")
require("physics")
require("modindex")
require("mathutil")
require("components/lootdropper")
require("saveindex") -- Added by Altgames for Android focus lost handling
require("worldtiledefs")
require("bugreport")

--debug key init
if CHEATS_ENABLED then
    require "debugcommands"
    require "debugkeys"
end

print("running main.lua\n")

math.randomseed(TheSim:GetRealTime())

--instantiate the mixer
local Mixer = require("mixer")
TheMixer = Mixer.Mixer()
require("mixes")
TheMixer:PushMix("start")

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

TheGlobalInstance = nil

global("TheCamera")
TheCamera = nil
global("SplatManager")
SplatManager = nil
global("ShadowManager")
ShadowManager = nil
global("RoadManager")
RoadManager = nil
global("EnvelopeManager")
EnvelopeManager = nil
global("PostProcessor")
PostProcessor = nil

global("FontManager")
FontManager = nil
global("MapLayerManager")
MapLayerManager = nil
global("Roads")
Roads = nil
global("TheFrontEnd")
TheFrontEnd = nil

inGamePlay = false

require "stacktrace"
require "debughelpers"

