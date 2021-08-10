-- main_function
-- created on 2021/8/6
-- author @zoloypzuo

-- main loop hook
function Initialize()
    print("initialize")
    TheSim = Game.GetSingletonPtr()
    local plane = SpawnPrefab("plane")
end

function Finalize()
    print("finalize")
end

function Update()
    --print("update")
end

-- PREFABS AND ENTITY INSTANTIATION
local function RegisterPrefabs(...)
    -- register prefab list to C++
    for _, prefab in ipairs({ ... }) do
        print("Register " .. tostring(prefab))
        Prefabs[prefab.name] = prefab
        TheSim:RegisterPrefab(prefab.name, prefab.assets, prefab.deps)
    end
end

function LoadPrefabFile(filename)
    print("Loading prefab file " .. filename)
    local ret = { require(filename) }

    if ret then
        for i, val in ipairs(ret) do
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

    -- TheSim:ProfilerPush("SpawnPrefab "..name)
    print(tostring(TheSim), tostring(TheSim.SpawnPrefab))
    name = string.sub(name, string.find(name, "[^/]*$"))
    name = renames[name] or name
    local guid = TheSim:SpawnPrefab(name)

    -- TheSim:ProfilerPop()
    return Ents[guid]
end

function CallPrefabFn(name)
    local prefab = Prefabs[name]
    return prefab.fn()
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
