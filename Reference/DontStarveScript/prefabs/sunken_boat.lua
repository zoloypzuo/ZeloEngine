--Should be empty during winter.

local assets =
{
    Asset("ANIM", "anim/parrot_pirate.zip"),
    Asset("SOUND", "sound/updates.fsb"),
}

SetSharedLootTable( 'sunken_boat',
{
    {'boards',                1.00},
    {'boards',                1.00},
    {'boards',                1.00},
    {'redgem',                1.00},
    {'bluegem',               1.00},
    {'goldnugget',            1.00},
    {'goldnugget',            1.00},
    {'goldnugget',            1.00},
    {'sunken_boat_trinket_4', 1.00},
})

SetSharedLootTable( 'sunken_boat_burnt',
{
    {'boards',                1.00},
    {'boards',                0.50},
    {'bluegem',               0.50},
    {'goldnugget',            1.00},
    {'goldnugget',            0.50},
    {'sunken_boat_trinket_4', 1.00},
})

local function HasBird(inst)
    return inst.bird
end

local function CanLand(inst)
    --Not burning
    return not (inst.components.burnable and inst.components.burnable:IsBurning())
    and not (GetWorld() and GetWorld().components.seasonmanager and GetWorld().components.seasonmanager:IsWinter())
    --Not winter
end

local function SquawkScript(str)
    local script = { }
    if math.random() < 0.33 then
        table.insert(script, Line(STRINGS.SUNKEN_BOAT_SQUAWKS[math.random(#STRINGS.SUNKEN_BOAT_SQUAWKS)], 1.5, nil))
    end
    table.insert(script, Line(str, 2.5, false))
    if math.random() < 0.33 then
        table.insert(script, Line(STRINGS.SUNKEN_BOAT_SQUAWKS[math.random(#STRINGS.SUNKEN_BOAT_SQUAWKS)], 1.5, nil))
    end
    return script
end

local rand_loot =
{
    "flint",
    "goldnugget",
    "petals_evil",
}

local function dropitem(inst, item)
    local nug = SpawnPrefab(item)

    if not nug then return end

    local pt = Vector3(inst.Transform:GetWorldPosition()) + Vector3(0,3.5,0)
    nug.Transform:SetPosition(pt:Get())
    local offset = FindWalkableOffset(pt, math.random()*2*math.pi, 15, 12)
    if offset then
        local sp = math.random()*4
        offset:Normalize()
        offset.x = offset.x*2 + offset.x*sp
        offset.z = offset.z*2 + offset.z*sp
        nug.Physics:SetVel(offset.x, math.random()*2+8, offset.z)
    end
end

local function OnGetItemFromPlayer(inst, giver, item)

    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end

    local giftprefab = GetRandomItem(rand_loot)
    local delay = 0
    local fly_off_time = 4

    if item:HasTag("sunken_boat_special") then
        --Spawn some special item, say some special string.
        local str, loot = item:GiveCluefn()
        inst.components.talker.colour = Vector3(1 ,0.5, 0.5)
        inst.components.talker:Say(str)
        giftprefab = loot
        delay = TUNING.TOTAL_DAY_TIME * 4.75
        fly_off_time = 6
    else
		local str = SquawkScript(STRINGS.SUNKEN_BOAT_ACCEPT_TRADE[math.random(#STRINGS.SUNKEN_BOAT_ACCEPT_TRADE)])
        inst.components.talker.colour = Vector3(1 ,1, 1)
        inst.components.talker:Say(str)
        delay = TUNING.TOTAL_DAY_TIME * 0.75
    end

    if item.components.tradable.goldvalue > 0 then
        for k = 1, item.components.tradable.goldvalue do
            dropitem(inst, giftprefab)
        end

        dropitem(inst, "feather_robin")
    end

    inst:PushEvent("getitem")

    inst.components.trader:Disable()

    inst:DoTaskInTime(fly_off_time, function()
        inst:TakeOff(delay)
    end)
end

local function OnRefuseItem(inst, giver, item)
    inst:PushEvent("rejectitem")
	inst.components.talker.colour = Vector3(1 ,1, 1)
    local str = SquawkScript(STRINGS.SUNKEN_BOAT_REFUSE_TRADE[math.random(#STRINGS.SUNKEN_BOAT_REFUSE_TRADE)])
    inst.components.talker:Say(str)
end

local function GetBird(inst)
    inst.bird = true
    inst.waitingtoland = false
    inst:PushEvent("getbird")
    --Add Trader
    inst.components.trader:Enable()
end

local function LoseBird(inst)
    inst.bird = false
    inst:PushEvent("losebird")

    --Remove Trader
    inst.components.trader:Disable()
end

local function TakeOff(inst, delay)
    LoseBird(inst)

    delay = delay or TUNING.TOTAL_DAY_TIME

    inst.components.timer:StopTimer("land")
    inst.components.timer:StartTimer("land", delay)

    local bird = SpawnPrefab("sunken_boat_bird")
    bird.Transform:SetPosition(inst:GetPosition():Get())

    bird.AnimState:PlayAnimation("takeoff_vertical_pre")

    bird.animoverfn = function()
        bird:RemoveEventCallback("animover", bird.animoverfn)

        bird.AnimState:PlayAnimation("takeoff_vertical_loop", true)

        bird:DoTaskInTime(2, function() bird:Remove() end)

        bird:DoPeriodicTask(7 * FRAMES, function()
            inst.SoundEmitter:PlaySound("dontstarve/birds/flyin")
        end)

        bird:DoPeriodicTask(0, function()
            local currentpos = bird:GetPosition()
            local flightspeed = 7.5
            local posdelta = Vector3(0, flightspeed, 0) * FRAMES
            local newpos = currentpos + posdelta
            bird.Transform:SetPosition(newpos:Get())
        end)
    end

    bird:ListenForEvent("animover", bird.animoverfn)
end

local function Land(inst)

    if not CanLand(inst) then
        --Don't bother landing.
        return
    end

    local bird = SpawnPrefab("sunken_boat_bird")
    local pos = inst:GetPosition()
    pos.y = 20
    bird.Transform:SetPosition(pos:Get())

    bird.AnimState:PlayAnimation("glide", true)

    bird.flapsoundtask = bird:DoPeriodicTask(7 * FRAMES, function()
        inst.SoundEmitter:PlaySound("dontstarve/birds/flyin")
    end)

    bird.landingtask = bird:DoPeriodicTask(0, function()
        --fly downwards
        local currentpos = bird:GetPosition()
        local flightspeed = -10
        local posdelta = Vector3(0, flightspeed, 0) * FRAMES
        local newpos = currentpos + posdelta

        bird.Transform:SetPosition(newpos:Get())

        --check for ground
        if newpos.y <= 0.1 then
            bird.flapsoundtask:Cancel()
            bird.landingtask:Cancel()
            bird.AnimState:PlayAnimation("land")
            bird:ListenForEvent("animover", function()
                if inst.landfn then
                    inst:RemoveEventCallback("daytime", inst.landfn, GetWorld())
                end
                bird:DoTaskInTime(0, bird.Remove) --need to delay this to accommodate stategraph
                GetBird(inst)
            end)
        end
    end)
end

local function ontimerdone(inst, data)
    if data.name == "land" then
        --Set up event to get bird to land
        if GetClock():IsDay() then
            inst:Land()
        else
            inst.waitingtoland = true
            inst.landfn = function() inst:Land() end
            inst:ListenForEvent("daytime", inst.landfn, GetWorld())
        end
    end
end

local function onhammered(inst, worker)
    inst.components.lootdropper:DropLoot()
    SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
    inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
    inst:Remove()
end

local function OnSave(inst, data)
    data.bird = inst.bird
    data.waitingtoland = inst.waitingtoland
end

local function OnLoad(inst, data)
    if data and data.bird then
        inst.AnimState:PlayAnimation("idle")
        inst:DoTaskInTime(0, GetBird)
    elseif not data or (data and not data.bird) then
        inst.AnimState:PlayAnimation("idle_empty")
        inst:DoTaskInTime(0, LoseBird)
    end

    if data and data.waitingtoland then
        inst.waitingtoland = true
        inst.landfn = function() inst:Land() end
        inst:ListenForEvent("daytime", inst.landfn, GetWorld())
    end
end

local debris_anims = {
    "debris_1",
    "debris_2",
    "debris_3",
}
-- hand-coded list so that we have stable positions across loads
local debris_offsets = {
    Vector3(1,0,1.5),
    Vector3(2,0,0.5),
    Vector3(0.5,0,-1.5),
    Vector3(-1,0,-2.5),
    Vector3(-2,0,0.5),
    Vector3(-1,0,2.5),
    Vector3(0,0,-2.5),
    Vector3(.5,0,1.5),
    Vector3(-1.5,0,-2.5),
}

local debris_num = 1
local function debris_fn()
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst:AddTag("NOCLICK")

    inst.persists = false

    inst.AnimState:SetBank("parrot_pirate")
    inst.AnimState:SetBuild("parrot_pirate")
    inst.AnimState:PlayAnimation(debris_anims[debris_num], true)
    debris_num = ( debris_num % #debris_anims ) + 1

    MakeSmallBurnable(inst)
    MakeSmallPropagator(inst)

    return inst
end

function IgniteFn(inst)
    if inst.components.burnable then
        inst.components.burnable:Ignite()
        if inst:HasBird() then
            inst:TakeOff()
        end
    end
end

function BurntFn(inst)
    --change prefabs
    local pos = inst:GetPosition()
    local burnt = SpawnPrefab("sunken_boat_burnt")
    inst:Remove()
    burnt.Transform:SetPosition(pos:Get())
end

function ExtinguishFn(inst)
    if not inst.waitingtoland then
        inst.waitingtoland = true
        inst.landfn = function() inst:Land() end
        inst:ListenForEvent("daytime", inst.landfn, GetWorld())
    end
end

local function getstatus(inst)
    if not inst:HasBird() then
        return "ABANDONED"
    end
end

local function OnSeasonChange(inst, data)
    if data.season == SEASONS.WINTER then
        inst:TakeOff()
    else
        if not inst.waitingtoland and not inst:HasBird() then
            inst.waitingtoland = true
            inst.landfn = function() inst:Land() end
            inst:ListenForEvent("daytime", inst.landfn, GetWorld())
        end
    end
end

local function fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    local minimap = inst.entity:AddMiniMapEntity()

    minimap:SetIcon("parrot_pirate.png")

    MakeObstaclePhysics(inst, 1.0, 1)

    inst.AnimState:SetBank("parrot_pirate")
    inst.AnimState:SetBuild("parrot_pirate")
    inst.AnimState:PlayAnimation("idle", true)

    inst:AddTag("structure")

    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = getstatus

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('sunken_boat')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(4)
    inst.components.workable:SetOnFinishCallback(onhammered)

    inst:AddComponent("talker")
    inst.components.talker.fontsize = 35
    inst.components.talker.font = TALKINGFONT
    inst.components.talker.offset = Vector3(0,-550,0)

    inst:AddComponent("timer")
    inst:ListenForEvent("timerdone", ontimerdone)

    inst:AddComponent("trader")

    inst.components.trader:SetAcceptTest(
        function(inst, item)
            return inst:HasBird() and item.components.tradable.goldvalue > 0
        end)

    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

    inst:AddComponent("sleeper")

    inst:AddComponent("locomotor")

    inst.bird = true

    MakeSnowCovered(inst, 0.01)
    MakeLargeBurnable(inst)
    inst.components.burnable:SetOnIgniteFn(IgniteFn)
    inst.components.burnable:SetOnBurntFn(BurntFn)
    inst.components.burnable:SetOnExtinguishFn(ExtinguishFn)
    MakeLargePropagator(inst)

    inst:ListenForEvent("seasonChange", function(world, data) OnSeasonChange(inst, data) end, GetWorld())

    inst.HasBird = HasBird
    inst.Land = Land
    inst.TakeOff = TakeOff
    inst.OnLoad = OnLoad
    inst.OnSave = OnSave
    inst.SquawkScript = SquawkScript

    inst:SetStateGraph("SGsunken_boat")

    local debris = {}
    inst:DoTaskInTime(0, function()
        local pos = Vector3(inst.Transform:GetWorldPosition())
        local numdebrispawned = 0
        for i=1,#debris_offsets do
            if GetGroundTypeAtPosition(pos + debris_offsets[i]) ~= GROUND.IMPASSABLE then
                local newdebris = SpawnPrefab("sunken_boat_debris")
                newdebris.Transform:SetPosition((pos+debris_offsets[i]):Get())
                table.insert(debris, newdebris)
                numdebrispawned = numdebrispawned + 1
                if numdebrispawned == 3 then
                    break
                end
            end
        end
    end)

    inst:DoTaskInTime(0, function()
        if inst:HasBird() and GetWorld().components.seasonmanager and
        GetWorld().components.seasonmanager:IsWinter() then
            inst:TakeOff()
        end
    end)

    inst.OnRemoveEntity = function(inst)
        for i,v in ipairs(debris) do
            v:Remove()
        end
    end

    return inst
end

local function bird_fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()

    inst.AnimState:SetBank("parrot_pirate")
    inst.AnimState:SetBuild("parrot_pirate")
    inst.AnimState:PlayAnimation("takeoff_vertical_pre")

    inst.persists = false

    return inst
end

local function burnt_fn()
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local minimap = inst.entity:AddMiniMapEntity()
    inst.entity:AddSoundEmitter()

    MakeObstaclePhysics(inst, 1.5, 1)

    inst:AddTag("burnt")
    inst:AddTag("structure")

    inst.AnimState:SetBank("parrot_pirate")
    inst.AnimState:SetBuild("parrot_pirate")
    inst.AnimState:PlayAnimation("burnt")

    inst:AddComponent("inspectable")

    inst:AddComponent("named")
    inst.components.named:SetName(STRINGS.NAMES["SUNKEN_BOAT"])

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('sunken_boat_burnt')

    inst:AddComponent("workable")
    inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
    inst.components.workable:SetWorkLeft(1)
    inst.components.workable:SetOnFinishCallback(onhammered)

    return inst
end

return Prefab("sunken_boat", fn, assets),
Prefab("sunken_boat_bird", bird_fn, assets),
Prefab("sunken_boat_burnt", burnt_fn, assets),
Prefab("sunken_boat_debris", debris_fn, assets)
