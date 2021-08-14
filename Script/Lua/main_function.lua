-- main_function
-- created on 2021/8/6
-- author @zoloypzuo
PI = 3.14

-- main loop hook
function Initialize()
    print("initialize")
    TheSim = Game.GetSingletonPtr()

    -- ground
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(-5, -2, 0)
        plane.components.transform:SetScale(10, 1, 10)
    end
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(5, -2, 0)
        plane.components.transform:SetScale(10, 1, 10)
    end
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(-5, -2, 10)
        plane.components.transform:SetScale(10, 1, 10)
    end
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(5, -2, 10)
        plane.components.transform:SetScale(10, 1, 10)
    end

    -- front wall
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(-5, 3, -5)
        plane.components.transform:SetScale(10, 1, 10)
        plane.components.transform:Rotate(1, 0, 0, PI / 2)
    end
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(5, 3, -5)
        plane.components.transform:SetScale(10, 1, 10)
        plane.components.transform:Rotate(1, 0, 0, PI / 2)
    end

    -- back wall
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(-5, 3, 15)
        plane.components.transform:SetScale(10, 1, 10)
        plane.components.transform:Rotate(1, 0, 0, -PI / 2)
    end
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(5, 3, 15)
        plane.components.transform:SetScale(10, 1, 10)
        plane.components.transform:Rotate(1, 0, 0, -PI / 2)
    end

    -- left wall
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(-10, 3, 0)
        plane.components.transform:SetScale(10, 1, 10)
        plane.components.transform:Rotate(0, 0, 1, -PI / 2)
    end
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(-10, 3, 10)
        plane.components.transform:SetScale(10, 1, 10)
        plane.components.transform:Rotate(0, 0, 1, -PI / 2)
    end

    -- right wall
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(10, 3, 0)
        plane.components.transform:SetScale(10, 1, 10)
        plane.components.transform:Rotate(0, 0, 1, PI / 2)
    end
    do
        local plane = SpawnPrefab("plane")
        plane.components.transform:SetPosition(10, 3, 10)
        plane.components.transform:SetScale(10, 1, 10)
        plane.components.transform:Rotate(0, 0, 1, PI / 2)
    end

    --do
    --    local monkey = SpawnPrefab("monkey")
    --end

    --do
        -- for i=0,10 do
        --     local monkey = SpawnPrefab("monkey")
        --     monkey.components.transform:SetPosition(0, i * 3, -2.5)
        -- end
    --end

    do
        local avatar = SpawnPrefab("monkey")
        avatar.components.transform:SetPosition(0, 0, 5)
        avatar.components.transform:SetScale(0.8, 0.8, 0.8)

        local camera = avatar.entity:AddCamera()
        camera.fov = PI / 2
        camera.aspect = 800 / 600
        camera.zNear = 0.05
        camera.zFar = 100

        local attenuation = Attenuation.new()
        attenuation.constant = 0
        attenuation.linear = 0
        attenuation.exponent = 0.2
        local spotLight = avatar.entity:AddSpotLight()
        spotLight.color = vec3.new(1, 1, 1)
        spotLight.intensity = 2.8
        spotLight.cutoff = 0.7
        spotLight.attenuation = attenuation

        avatar.entity:AddFreeMove()
        avatar.entity:AddFreeLook()

        TheSim:SetActiveCamera(camera)
    end

    do
        local sun = SpawnPrefab("monkey")
        sun.components.transform:SetPosition(-2, 4, -1)
        local light = sun.entity:AddDirectionalLight()
        light.color = vec3.new(1)
        light.intensity = 2.8
    end
end

function Finalize()
    print("finalize")
end

function Update()
    --print("update")
end

function GlobalErrorHandler(message)
    print(message)
    StackTraceToLog()
    return message
end

-- PREFABS AND ENTITY INSTANTIATION
local function RegisterPrefabs(...)
    -- register prefab list to C++
    for _, prefab in ipairs({ ... }) do
        print("Register " .. tostring(prefab))
        Prefabs[prefab.name] = prefab
    end
end

function LoadPrefabFile(filename)
    print("Loading prefab file " .. filename)
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

    -- TheSim:ProfilerPush("SpawnPrefab "..name)
    name = string.sub(name, string.find(name, "[^/]*$"))
    name = renames[name] or name

    if not PrefabExists(name) then
        LoadPrefabFile(name)
    end

    local guid = TheSim:SpawnPrefab(name)

    -- TheSim:ProfilerPop()
    return Ents[guid]
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
    -- return TheSim:GetTickTime()
end

local ticktime = GetTickTime()
function GetTime()
    -- return TheSim:GetTick() * ticktime
end

function GetTick()
    -- return TheSim:GetTick()
end

function GetTimeReal()
    -- return TheSim:GetRealTime()
end