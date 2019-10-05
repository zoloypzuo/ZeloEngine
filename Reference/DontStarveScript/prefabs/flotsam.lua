local assets = {
    Asset("ANIM", "anim/flotsam.zip"),
    Asset("ANIM", "anim/flotsam_debris.zip"),
}

local debris_assets = {
    Asset("ANIM", "anim/boards.zip"),
}

local prefabs = {
    "flotsam_debris",
}

local debris_prefabs = {
    "boards",
    "rope",
    "twigs",
    "cutgrass",
    "log",
    "sunken_boat_trinket_1",
    "sunken_boat_trinket_2",
    "sunken_boat_trinket_3",
    "sunken_boat_trinket_4",
    "sunken_boat_trinket_5",
}

local flotsam_loot =
{
    ['log']                  = 2.00,
    ['twigs']                = 2.00,
    ['cutgrass']             = 2.00,

    ['boards']               = 1.00,
    ['rope']                 = 1.00,

    ['sunken_boat_trinket_1']  = 0.65,
    ['sunken_boat_trinket_2']  = 0.75,
    ['sunken_boat_trinket_3']  = 0.65,
    ['sunken_boat_trinket_4']  = 0.50,
    ['sunken_boat_trinket_5']  = 0.90,
}

local DEBRIS_WIDTH = 4

local function SpawnDebris(inst)
    local d = SpawnPrefab("flotsam_debris")
    d.entity:SetParent(inst.entity)
    d.localoffset = Vector3(math.random()*DEBRIS_WIDTH - DEBRIS_WIDTH/2, -0.5, math.random()*DEBRIS_WIDTH - DEBRIS_WIDTH/2)
    d.Transform:SetPosition(d.localoffset.x, d.localoffset.y, d.localoffset.z)
    d:AddTag("NOCLICK")
    d:ListenForEvent("onremove", function() d:Remove() end, inst)

    return d
end

local function UpdateDebris(inst)
    if not inst.debris then
        inst.debris = {}
    end

    local currentcount = 0

    for k,v in pairs(inst.debris) do
        currentcount = currentcount + 1
    end

    local num_debris = inst.components.flotsamfisher.lootleft
    local tospawn = num_debris - currentcount

    --print("HAS", currentcount, "WANTS", num_debris, "DELTA BY", tospawn)

    if tospawn < 0 then
        local todestroy = math.abs(tospawn)
        while todestroy > 0 do
            local d = GetRandomItem(inst.debris)
            if d then
                inst.debris[d] = nil
                d:Remove()
            end
            todestroy = todestroy - 1
        end
    else
        for i = 1, tospawn do
            local d = SpawnDebris(inst)
            inst.debris[d] = d
        end
    end
end

local function OnFish(inst, fisher)
    UpdateDebris(inst)
end

local function OnTimer(inst, timerdata)
    if timerdata.name == "decay" then
        inst.components.flotsamfisher:DeltaFish(-1)
        if inst.components.flotsamfisher.lootleft > 0 then
            UpdateDebris(inst)
            inst.components.timer:StartTimer("decay", TUNING.FLOTSAM_DECAY_TIME)
        end
    end
end

local function fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    inst.AnimState:SetBank("flotsam")
    inst.AnimState:SetBuild("flotsam")
    inst.AnimState:PlayAnimation("idle")
	inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
	inst.AnimState:SetLayer( LAYER_BACKGROUND )

    inst:AddTag("FARSELECT")

    inst:AddComponent("drifter")
    inst.components.drifter.radius = DEBRIS_WIDTH/2 + 3

    inst:AddComponent("flotsamfisher")
    inst.components.flotsamfisher.flotsam_loot = flotsam_loot
    inst.components.flotsamfisher.onfishfn = OnFish
    inst.components.flotsamfisher.lootleft = math.random(2, 4)

    inst:AddComponent("inspectable")

    UpdateDebris(inst)

    inst:AddComponent("timer")
    inst.components.timer:StartTimer("decay", TUNING.FLOTSAM_DECAY_TIME)
    inst:ListenForEvent("timerdone", OnTimer)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/teasertheparrot/wreckage", "flotsam_loop")

    return inst
end


local debris_anims = {
    "idle",
    "idle2",
    "idle3",
    "idle4",
    "idle5",
    "idle6",
    "idle7",
    "idle8",
    "idle9",
}

local function debris_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    inst.AnimState:SetBank("flotsam_debris")
    inst.AnimState:SetBuild("flotsam_debris")
    inst.AnimState:PlayAnimation(debris_anims[math.random(#debris_anims)], true)

    inst.localoffset = Vector3(0,0,0)
    inst:DoPeriodicTask(0, function(inst)
        local x,y,z = inst.entity:GetParent().Transform:GetWorldPosition()
        inst.Transform:SetPosition(
                inst.localoffset.x + math.sin(GetTime()*3 + inst.localoffset.x + x)*.2,
                inst.localoffset.y + math.sin(GetTime()*3)*.1,
                inst.localoffset.z + math.sin(GetTime()*3 + inst.localoffset.z + z)*.2)
    end)

    return inst
end

return Prefab("forest/common/flotsam", fn, assets, prefabs),
        Prefab("forest/common/flotsam_debris", debris_fn, debris_assets, debris_prefabs)
