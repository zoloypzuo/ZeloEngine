require "prefabutil"
local brain = require "brains/chesterbrain"
require "stategraphs/SGchester"

local WAKE_TO_FOLLOW_DISTANCE = 14
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets =
{
    Asset("ANIM", "anim/ui_chester_shadow_3x4.zip"),
    Asset("ANIM", "anim/ui_chest_3x3.zip"),

    Asset("ANIM", "anim/chester.zip"),
    Asset("ANIM", "anim/chester_build.zip"),
    Asset("ANIM", "anim/chester_shadow_build.zip"),
    Asset("ANIM", "anim/chester_snow_build.zip"),

    Asset("SOUND", "sound/chester.fsb"),
    Asset("INV_IMAGE", "chester_eyebone"),
    Asset("INV_IMAGE", "chester_eyebone_closed"),
    Asset("INV_IMAGE", "chester_eyebone_closed_shadow"),
    Asset("INV_IMAGE", "chester_eyebone_closed_snow"),
    Asset("INV_IMAGE", "chester_eyebone_shadow"),
    Asset("INV_IMAGE", "chester_eyebone_snow"),
    Asset("MINIMAP_IMAGE", "chestershadow"),
    Asset("MINIMAP_IMAGE", "chestersnow"),
}

local prefabs =
{
    "chester_eyebone",
    "die_fx",
    "chesterlight",
    "sparklefx",
}

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    --print(inst, "ShouldSleep", DefaultSleepTest(inst), not inst.sg:HasStateTag("open"), inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE))
    return DefaultSleepTest(inst) and not inst.sg:HasStateTag("open") 
    and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE) 
    and GetWorld().components.clock:GetMoonPhase() ~= "full"
end


local function ShouldKeepTarget(inst, target)
    return false -- chester can't attack, and won't sleep if he has a target
end


local function OnOpen(inst)
    if not inst.components.health:IsDead() then
        if inst.MorphTask then
            inst.MorphTask:Cancel()
            inst.MorphTask = nil
        end
        inst.sg:GoToState("open")
    end
end 

local function OnClose(inst) 
    if not inst.components.health:IsDead() then
        inst.sg:GoToState("close")
    end
end 

-- eye bone was killed/destroyed
local function OnStopFollowing(inst) 
    --print("chester - OnStopFollowing")
    inst:RemoveTag("companion") 
end

local function OnStartFollowing(inst) 
    --print("chester - OnStartFollowing")
    inst:AddTag("companion") 
end

local slotpos_3x3 = {}

for y = 2, 0, -1 do
    for x = 0, 2 do
        table.insert(slotpos_3x3, Vector3(80*x-80*2+80, 80*y-80*2+80,0))
    end
end

local slotpos_3x4 = {}

for y = 2.5, -0.5, -1 do
    for x = 0, 2 do
        table.insert(slotpos_3x4, Vector3(75*x-75*2+75, 75*y-75*2+75,0))
    end
end

local function MorphShadowChester(inst, dofx)
    inst:AddTag("spoiler")
    inst.components.container:SetNumSlots(#slotpos_3x4)
    inst.components.container.widgetslotpos = slotpos_3x4
    inst.components.container.widgetanimbank = "ui_chester_shadow_3x4"
    inst.components.container.widgetanimbuild = "ui_chester_shadow_3x4"
    inst.components.container.widgetpos = Vector3(0,220,0)
    inst.components.container.widgetpos_controller = Vector3(0,220,0)
    inst.components.container.side_align_tip = 160

    local leader = inst.components.follower.leader    
    if leader then
        inst.components.follower.leader:MorphShadowEyebone()
    end

    inst.AnimState:SetBuild("chester_shadow_build")
    inst.ChesterState = "SHADOW"
    inst.MiniMapEntity:SetIcon("chestershadow.png")
end

local function MorphSnowChester(inst, dofx)
    inst:AddTag("fridge")
    inst:AddTag("lowcool")

    local leader = inst.components.follower.leader
    if leader then
        inst.components.follower.leader:MorphSnowEyebone()
    end

    inst.AnimState:SetBuild("chester_snow_build")
    inst.ChesterState = "SNOW"
    inst.MiniMapEntity:SetIcon("chestersnow.png")
end

local function MorphNormalChester(inst, dofx)
    inst:RemoveTag("fridge")
    inst:RemoveTag("lowcool")
    inst:RemoveTag("spoiler")
    inst.AnimState:SetBuild("chester_build")

    local leader = inst.components.follower.leader    
    if leader then
        inst.components.follower.leader:MorphNormalEyebone()
    end

    inst.ChesterState = "NORMAL"
    inst.MiniMapEntity:SetIcon("chester.png")
end

local function CanMorph(inst)
    local clock = GetWorld().components.clock

    if not clock:IsNight() or clock:GetMoonPhase() ~= "full" or inst.ChesterState ~= "NORMAL" then
        return false, false
    end

    local container = inst.components.container

    local canShadow = true
    local canSnow = true

    for i = 1, container:GetNumSlots() do
        local item = container:GetItemInSlot(i)
        
        if not item then
            canShadow = false
            canSnow = false
            break
        end

        if item.prefab ~= "nightmarefuel" then
            canShadow = false
        end

        if item.prefab ~= "bluegem" then
            canSnow = false
        end
    end
    return canShadow, canSnow
end

local function MorphChester(inst)
    local clock = GetWorld().components.clock

    if not clock:IsNight() or inst.ChesterState ~= "NORMAL" or clock:GetMoonPhase() ~= "full" then
        return
    end

    local container = inst.components.container

    local canShadow, canSnow = inst:CanMorph()

    if canShadow then
        container:ConsumeByName("nightmarefuel", container:GetNumSlots())
        MorphShadowChester(inst, true)
    elseif canSnow then
        container:ConsumeByName("bluegem", container:GetNumSlots())
        MorphSnowChester(inst, true)
    end
end

local function CheckForMorph(inst)
    local shadow, snow = inst:CanMorph()
    if shadow or snow then
        if inst.MorphTask then
            inst.MorphTask:Cancel()
            inst.MorphTask = nil
        end
        inst.MorphTask = inst:DoTaskInTime(6, function(inst)
            inst.sg:GoToState("transition")
        end)
    end
end

local function OnSave(inst, data)
    data.ChesterState = inst.ChesterState
end

local function OnPreLoad(inst, data)
    if not data then return end
    if data.ChesterState == "SHADOW" then
        MorphShadowChester(inst)
    elseif data.ChesterState == "SNOW" then
        MorphSnowChester(inst)
    end
end

local function create_chester()
    --print("chester - create_chester")

    local inst = CreateEntity()
    
    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("scarytoprey")
    inst:AddTag("chester")
    inst:AddTag("notraptrigger")
    inst:AddTag("cattoy")

    inst.entity:AddTransform()

    local minimap = inst.entity:AddMiniMapEntity()
    minimap:SetIcon( "chester.png" )

    --print("   AnimState")
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("chester")
    inst.AnimState:SetBuild("chester_build")

    --print("   sound")
    inst.entity:AddSoundEmitter()

    --print("   shadow")
    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize( 2, 1.5 )

    --print("   Physics")
    MakeCharacterPhysics(inst, 75, .5)
    
    --print("   Collision")
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst.Transform:SetFourFaced()


    --print("   Userfuncs")

    ------------------------------------------

    --print("   combat")
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "chester_body"
    inst.components.combat:SetKeepTargetFunction(ShouldKeepTarget)
    --inst:ListenForEvent("attacked", OnAttacked)

    --print("   health")
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.CHESTER_HEALTH)
    inst.components.health:StartRegen(TUNING.CHESTER_HEALTH_REGEN_AMOUNT, TUNING.CHESTER_HEALTH_REGEN_PERIOD)
    inst:AddTag("noauradamage")


    --print("   inspectable")
    inst:AddComponent("inspectable")
	inst.components.inspectable:RecordViews()
    --inst.components.inspectable.getstatus = GetStatus

    --print("   locomotor")
    inst:AddComponent("locomotor")
    inst.components.locomotor.walkspeed = 3
    inst.components.locomotor.runspeed = 7

    --print("   follower")
    inst:AddComponent("follower")
    inst:ListenForEvent("stopfollowing", OnStopFollowing)
    inst:ListenForEvent("startfollowing", OnStartFollowing)

    --print("   knownlocations")
    inst:AddComponent("knownlocations")

    --print("   burnable")
    MakeSmallBurnableCharacter(inst, "chester_body")
    
    --("   container")
    inst:AddComponent("container")
    inst.components.container:SetNumSlots(#slotpos_3x3)
    
    inst.components.container.onopenfn = OnOpen
    inst.components.container.onclosefn = OnClose
    
    inst.components.container.widgetslotpos = slotpos_3x3
    inst.components.container.widgetanimbank = "ui_chest_3x3"
    inst.components.container.widgetanimbuild = "ui_chest_3x3"
    inst.components.container.widgetpos = Vector3(0,200,0)
    inst.components.container.side_align_tip = 160

    --print("   sleeper")
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    --print("   sg")
    inst:SetStateGraph("SGchester")
    inst.sg:GoToState("idle")

    --print("   brain")
    inst:SetBrain(brain)

    inst.ChesterState = "NORMAL"
    inst.CanMorph = CanMorph
    inst.MorphChester = MorphChester
    inst:ListenForEvent("nighttime", function() CheckForMorph(inst) end, GetWorld())
    inst:ListenForEvent("onclose", function() CheckForMorph(inst) end)

    inst.OnSave = OnSave
    inst.OnPreLoad = OnPreLoad

    inst:DoTaskInTime(1.5, function(inst)
        -- We somehow got a chester without an eyebone. Kill it! Kill it with fire!
        if not TheSim:FindFirstEntityWithTag("chester_eyebone") then
            inst:Remove()
        end
    end)

    --print("chester - create_chester END")
    return inst
end

return Prefab( "common/chester", create_chester, assets, prefabs) 
