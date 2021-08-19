-- main.lua
-- created on 2021/5/5
-- author @zoloypzuo

-- LUA_PATH
--package.path = ""

-- resource
package.path = package.path .. ";" .. RESOURCE_DIR .. "/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/Models/?.lua"
package.path = package.path .. ";" .. RESOURCE_DIR .. "/Entities/Textures/?.lua"

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

--debug key init
global("CHEATS_ENABLED")
CHEATS_ENABLED = false
if CHEATS_ENABLED then
    require "debugcommands"
    require "debugkeys"
end

print("running main.lua\n")

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

local function mesh_loader(name)
    local mesh_loader = MeshLoader.new(assets.mesh);
    local mesh_render_data_list = {mesh_loader:GetMeshRendererData()}
    for _, render_data in ipairs(mesh_render_data_list) do
        local mesh_renderer = inst.entity:AddMeshRenderer()
        mesh_renderer.mesh = mesh
        mesh_renderer.material = material
    end
end

local function mesh_gen_loader(name)
    return Mesh.new(MeshGenerators[name].new())
end

ResourceMap = {}
ResourceLoaders = {
    MESH = mesh_loader;
    MESH_GEN = mesh_gen_loader;
    TEX = Texture.new;
}

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
