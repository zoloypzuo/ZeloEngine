-- main_function
-- created on 2021/8/6
-- author @zoloypzuo
PI = 3.14

-- main loop hook
function Initialize()
    print("initialize")
    require("main_initialize")
end

function Finalize()
    print("finalize")
end

local update = require("main_update")
function Update()
    update()
end

function GlobalErrorHandler(message)
    -- handle lua error when C call lua function
    -- print error and stack trace
    StackTraceToLog()
    return message
end

-- PREFABS AND ENTITY INSTANTIATION
local function RegisterPrefabs(...)
    -- register prefab list to C++
    for _, prefab in ipairs({ ... }) do
        Prefabs[prefab.name] = prefab
    end
end

function LoadPrefabFile(filename)
    --print("Loading prefab file " .. filename)
    local ret = { require(filename) }

    if ret then
        for _, val in ipairs(ret) do
            if type(val) == "table" and val.is_a and val:is_a(Prefab) then
                RegisterPrefabs(val)
            end
        end
    end

    return ret
end

function PrefabExists(name)
    return Prefabs[name] ~= nil
end

local renames = {
    --feather = "feather_crow",
}

function SpawnPrefab(name)
    name = string.sub(name, string.find(name, "[^/]*$"))
    name = renames[name] or name

    if not PrefabExists(name) then
        LoadPrefabFile(name)
    end

    local guid = TheSim:SpawnPrefab(name)

    local entity = Ents[guid]
    entity.name = name .. tostring(guid)

    return entity
end

function SpawnSaveRecord(saved, newents)
    --print(string.format("SpawnSaveRecord [%s, %s, %s]", tostring(saved.id), tostring(saved.prefab), tostring(saved.data)))

    local inst = SpawnPrefab(saved.prefab)

    if inst then
        inst.Transform:SetPosition(saved.x or 0, saved.y or 0, saved.z or 0)
        if newents then

            --this is kind of weird, but we can't use non-saved ids because they might collide
            if saved.id then
                newents[saved.id] = { entity = inst, data = saved.data }
            else
                newents[inst] = { entity = inst, data = saved.data }
            end

        end

        -- Attach scenario. This is a special component that's added based on save data, not prefab setup.
        if saved.scenario or (saved.data and saved.data.scenariorunner) then
            if inst.components.scenariorunner == nil then
                inst:AddComponent("scenariorunner")
            end
            if saved.scenario then
                inst.components.scenariorunner:SetScript(saved.scenario)
            end
        end
        inst:SetPersistData(saved.data, newents)

    else
        print(string.format("SpawnSaveRecord [%s, %s] FAILED", tostring(saved.id), saved.prefab))
    end

    return inst
end

function CreateEntity()
    local ent = TheSim:CreateEntity()
    local guid = ent:GetGUID()
    local scr = EntityScript(ent)
    Ents[guid] = scr
    NumEnts = NumEnts + 1
    return scr
end

function OnRemoveEntity(entityguid)

    PhysicsCollisionCallbacks[entityguid] = nil

    local ent = Ents[entityguid]
    if ent then
        BrainManager:OnRemoveEntity(ent)
        SGManager:OnRemoveEntity(ent)

        ent:KillTasks()
        NumEnts = NumEnts - 1
        Ents[entityguid] = nil

        if NewUpdatingEnts[entityguid] then
            NewUpdatingEnts[entityguid] = nil
            num_updating_ents = num_updating_ents - 1
        end

        if UpdatingEnts[entityguid] then
            UpdatingEnts[entityguid] = nil
            num_updating_ents = num_updating_ents - 1
        end

        if WallUpdatingEnts[entityguid] then
            WallUpdatingEnts[entityguid] = nil
        end
    end
end

function PushEntityEvent(guid, event, data)
    local inst = Ents[guid]
    if inst then
        inst:PushEvent(event, data)
    end
end

------TIME FUNCTIONS

function GetTickTime()
    return 1 -- TODO
    -- return TheSim:GetTickTime()
end

local ticktime = GetTickTime()
function GetTime()
    return 1 -- TODO
    -- return TheSim:GetTick() * ticktime
end

function GetTick()
    return 1 -- TODO
    -- return TheSim:GetTick()
end

function GetTimeReal()
    return 1 -- TODO
    -- return TheSim:GetRealTime()
end

---SCRIPTING
local Scripts = {}

function LoadScript(filename)
    if not Scripts[filename] then
        local scriptfn = loadfile("scripts/" .. filename)
        assert(type(scriptfn) == "function", scriptfn)
        Scripts[filename] = scriptfn()
    end
    return Scripts[filename]
end

function RunScript(filename)
    local fn = LoadScript(filename)
    if fn then
        fn()
    end
end

-- time scale & pause

local paused = false
local default_time_scale = 1

function IsPaused()
    return paused
end

global("PlayerPauseCheck")  -- function not defined when this file included


function SetDefaultTimeScale(scale)
    default_time_scale = scale
    if not paused then
        TheSim:SetTimeScale(default_time_scale)
    end
end

function SetPause(val, reason)
    if val ~= paused then
        if val then
            paused = true
            TheSim:SetTimeScale(0)
            TheMixer:PushMix("pause")
        else
            paused = false
            TheSim:SetTimeScale(default_time_scale)
            TheMixer:PopMix("pause")
            --ShowHUD(true)
        end
        if GetWorld() then
            GetWorld():PushEvent("pause", val)
        end
        if PlayerPauseCheck then
            -- probably don't need this check
            PlayerPauseCheck(val, reason)  -- must be done after SetTimeScale
        end
    end
end

function IsPaused()
    return paused
end


-- Resource
function ResourceMetaDataLoader(name)
    local errmsg = ""
    --local module_path = string.gsub(name, "%.", "/")
    local module_path = name
    for path in string.gmatch(package.path, "([^;]+)") do
        local filename = string.gsub(path, "%?", module_path)
        local file = io.open(filename, "rb")
        if file then
            -- Compile and return the module
            return assert(loadstring(assert(file:read("*a")), filename))
        end
        errmsg = errmsg .. "\n\tno file '" .. filename .. "' (checked with ResourceMetaDataLoader)"
    end
    return errmsg
    -- Install the loader so that it's called just before the normal Lua loader
end

function RegisterResourceLoader(resource_type, loader)
    ResourceLoaders[resource_type] = loader
end

function LoadResource(name)
    if not ResourceMap[name] then
        -- asset not loaded
        --print("LoadResource", name)
        local asset_meta_data = require(name)
        local asset_type = asset_meta_data.type
        local asset_file = asset_meta_data.file
        local loader = ResourceLoaders[asset_type]
        assert(loader ~= nil)
        local res = loader(asset_file, asset_meta_data)
        assert(res ~= nil)
        ResourceMap[name] = res
    end
    return ResourceMap[name]
end

function UnloadResource(name)
    ResourceMap[name] = nil
end

require("framework.events")
MainFunctionEvent = EventProcessor()

local function RegisterMainFunctionEvent(name)
    local fn = _G[name]
    _G[name] = function(...)
        local result = fn(...)
        MainFunctionEvent:HandleEvent(name, result, ...)
        return result
    end
end

RegisterMainFunctionEvent("SpawnPrefab")
RegisterMainFunctionEvent("CreateEntity")

function LoadAvatar()
    local avatar = CreateEntity()

    avatar.name = "avatar"

    avatar.entity:AddTransform()
    avatar.components.transform:SetPosition(0, 0, 5)
    avatar.components.transform:SetScale(0.8, 0.8, 0.8)

    local camera = avatar.entity:AddCamera()
    camera.fov = PI / 2
    camera.aspect = 800 / 600
    camera.zNear = 0.05
    camera.zFar = 100

    avatar.entity:AddFreeMove()
    avatar.entity:AddFreeLook()
end

function registerConfigClass(klass_name)
    local klass = _G[klass_name]
    local mt = getmetatable(klass)
    mt.__call = function(class_tbl, data)
        local o = class_tbl.new()
        for k, v in pairs(data) do
            o[k] = v
        end
        return o
    end
end