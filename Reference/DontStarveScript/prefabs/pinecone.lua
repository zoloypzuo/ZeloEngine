require "prefabutil"
local assets = {
    Asset("ANIM", "anim/pinecone.zip"),
}

local function growtree(inst)
    print("GROWTREE")
    inst.growtask = nil
    inst.growtime = nil
    local tree = SpawnPrefab("evergreen_short")
    if tree then
        tree.Transform:SetPosition(inst.Transform:GetWorldPosition())
        tree:growfromseed()--PushEvent("growfromseed")
        inst:Remove()
    end
end

local function plant(inst, growtime)
    inst:RemoveComponent("inventoryitem")
    inst.AnimState:PlayAnimation("idle_planted")
    inst.SoundEmitter:PlaySound("dontstarve/wilson/plant_tree")
    inst.growtime = GetTime() + growtime
    print("PLANT", growtime)
    inst.growtask = inst:DoTaskInTime(growtime, growtree)
end

local function ondeploy (inst, pt)
    inst = inst.components.stackable:Get()
    inst.Transform:SetPosition(pt:Get())
    local timeToGrow = GetRandomWithVariance(TUNING.PINECONE_GROWTIME.base, TUNING.PINECONE_GROWTIME.random)
    plant(inst, timeToGrow)

    --tell any nearby leifs to chill out
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.LEIF_PINECONE_CHILL_RADIUS, { "leif" })

    local played_sound = false
    for k, v in pairs(ents) do

        local chill_chance = TUNING.LEIF_PINECONE_CHILL_CHANCE_FAR
        if distsq(pt, Vector3(v.Transform:GetWorldPosition())) < TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS * TUNING.LEIF_PINECONE_CHILL_CLOSE_RADIUS then
            chill_chance = TUNING.LEIF_PINECONE_CHILL_CHANCE_CLOSE
        end

        if math.random() < chill_chance then
            if v.components.sleeper then
                v.components.sleeper:GoToSleep(1000)
            end
        else
            if not played_sound then
                v.SoundEmitter:PlaySound("dontstarve/creatures/leif/taunt_VO")
                played_sound = true
            end
        end

    end

end

local function stopgrowing(inst)
    if inst.growtask then
        inst.growtask:Cancel()
        inst.growtask = nil
    end
    inst.growtime = nil
end

local notags = { 'NOBLOCK', 'player', 'FX' }
local function test_ground(inst, pt)
    local tiletype = GetGroundTypeAtPosition(pt)
    local ground_OK = tiletype ~= GROUND.ROCKY and tiletype ~= GROUND.ROAD and tiletype ~= GROUND.IMPASSABLE and
            tiletype ~= GROUND.UNDERROCK and tiletype ~= GROUND.WOODFLOOR and
            tiletype ~= GROUND.CARPET and tiletype ~= GROUND.CHECKER and tiletype < GROUND.UNDERGROUND

    if ground_OK then
        local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 4, nil, notags) -- or we could include a flag to the search?
        local min_spacing = inst.components.deployable.min_spacing or 2

        for k, v in pairs(ents) do
            if v ~= inst and v:IsValid() and v.entity:IsVisible() and not v.components.placer and v.parent == nil then
                if distsq(Vector3(v.Transform:GetWorldPosition()), pt) < min_spacing * min_spacing then
                    return false
                end
            end
        end
        return true
    end
    return false
end

local function describe(inst)
    if inst.growtime then
        return "PLANTED"
    end
end

local function displaynamefn(inst)
    if inst.growtime then
        return STRINGS.NAMES.PINECONE_SAPLING
    end
    return STRINGS.NAMES.PINECONE
end

local function OnSave(inst, data)
    if inst.growtime then
        data.growtime = inst.growtime - GetTime()
    end
end

local function OnLoad(inst, data)
    if data and data.growtime then
        plant(inst, data.growtime)
    end
end

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("pinecone")
    inst.AnimState:SetBuild("pinecone")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("edible")
    inst.components.edible.foodtype = "WOOD"
    inst.components.edible.woodiness = 2

    inst:AddComponent("stackable")
    inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = describe

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.SMALL_FUEL

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    inst:ListenForEvent("onignite", stopgrowing)
    MakeSmallPropagator(inst)

    inst:AddComponent("inventoryitem")

    inst:AddComponent("deployable")
    inst.components.deployable.test = test_ground
    inst.components.deployable.ondeploy = ondeploy

    inst.displaynamefn = displaynamefn

    inst.OnSave = OnSave
    inst.OnLoad = OnLoad

    return inst
end

return Prefab("common/inventory/pinecone", fn, assets),
MakePlacer("common/pinecone_placer", "pinecone", "pinecone", "idle_planted")


