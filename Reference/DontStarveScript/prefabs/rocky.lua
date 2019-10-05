require "brains/rockybrain"
require "stategraphs/SGrocky"

local assets =
{
	Asset("ANIM", "anim/rocky.zip"),
    Asset("SOUND", "sound/rocklobster.fsb"),
}

local prefabs =
{
	"rocks",
}


local colours =
{
    {1,1,1},
    --{174/255,158/255,151/255},
    {167/255,180/255,180/255},
    {159/255,163/255,146/255}
}


local function ShouldSleep(inst)

    return inst.components.sleeper:GetTimeAwake() > TUNING.TOTAL_DAY_TIME*2
    --return false
end

local function ShouldWake(inst)
    return inst.components.sleeper:GetTimeAsleep() > TUNING.TOTAL_DAY_TIME*.5
end


local function OnAttacked(inst, data)

    local attacker = data.attacker
    inst.components.combat:SetTarget(attacker)
    inst.components.combat:ShareTarget(attacker, 20, function(dude) return dude.prefab == inst.prefab end, 2)

end


local function grow(inst, dt)

    if inst.components.scaler.scale < TUNING.ROCKY_MAX_SCALE then
        local new_scale = math.min(inst.components.scaler.scale + TUNING.ROCKY_GROW_RATE*dt, TUNING.ROCKY_MAX_SCALE)
        inst.components.scaler:SetScale(new_scale)
    else
        if inst.growtask then
            inst.growtask:Cancel()
            inst.growtask = nil
        end
    end
end

local function applyscale(inst, scale)
    inst.components.combat:SetDefaultDamage(TUNING.ROCKY_DAMAGE*scale)
    local percent = inst.components.health:GetPercent()
    inst.components.health:SetMaxHealth(TUNING.ROCKY_HEALTH*scale)
    inst.components.health:SetPercent(percent)
    --MakeCharacterPhysics(inst, 200*scale, 1*scale)
    inst.components.locomotor.walkspeed = TUNING.ROCKY_WALK_SPEED*(1/scale)
end


local function ShouldAcceptItem(inst, item)
    if item.components.edible and item.components.edible.foodtype == "ELEMENTAL" then
        return true
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    if item.components.edible and item.components.edible.foodtype == "ELEMENTAL" then
            if inst.components.combat.target and inst.components.combat.target == giver then
                inst.components.combat:SetTarget(nil)
            elseif giver.components.leader then
                inst.SoundEmitter:PlaySound("dontstarve/common/makeFriend")
                giver.components.leader:AddFollower(inst)
                inst.components.follower:AddLoyaltyTime(TUNING.ROCKY_LOYALTY)
                inst.sg:GoToState("rocklick")
            end
    end

    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnRefuseItem(inst, item)
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
    inst:PushEvent("refuseitem")
end

local loot = {"rocks", "rocks", "meat", "flint", "flint"}

local function onsave(inst,data)
    data.colour = inst.colour_idx
end

local function onload(inst,data)
    if data and data.colour and data.colour > 0 and data.colour <= #colours then
        inst.colour_idx = data.colour
        inst.AnimState:SetMultColour(colours[inst.colour_idx][1],colours[inst.colour_idx][2],colours[inst.colour_idx][3],1)
    end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()

	--orange(186/255,158/255,139/255,1), blue(159/255,185/255,187/255,1), green(163/255,181/255,128/255,1)
    

    inst.colour_idx = math.random(#colours)
    inst.AnimState:SetMultColour(colours[inst.colour_idx][1],colours[inst.colour_idx][2],colours[inst.colour_idx][3],1)
	inst.Transform:SetFourFaced()

	MakeCharacterPhysics(inst, 200, 1)

    inst:AddTag("rocky")
    inst:AddTag("character")
    inst:AddTag("animal")

    anim:SetBank("rocky")
	anim:SetBuild("rocky")
	anim:PlayAnimation("idle_loop", true)

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(3)
    inst.components.combat:SetRange(4)
    inst.components.combat:SetDefaultDamage(100)

    inst.entity:AddDynamicShadow()
    inst.DynamicShadow:SetSize( 1.75, 1.75 )
    

    inst:AddComponent("knownlocations")
    inst:AddComponent("herdmember")
    inst.components.herdmember.herdprefab = "rockyherd"
    inst:AddComponent("inventory")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)



    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.PIG_LOYALTY_MAXTIME    
    
    inst:AddComponent("scaler")
    inst.components.scaler.OnApplyScale = applyscale


    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper:SetWakeTest(ShouldWake)
    inst.components.sleeper:SetSleepTest(ShouldSleep)


    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.ROCKY_HEALTH)

	inst:AddComponent("inspectable")

    inst:AddComponent("eater")
    inst.components.eater:SetElemental()

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = false }
    inst.components.locomotor.walkspeed = TUNING.ROCKY_WALK_SPEED



    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader:Enable()


	local brain = require "brains/rockybrain"
    inst:SetBrain(brain)
	inst:SetStateGraph("SGrocky")

    inst:ListenForEvent("attacked", OnAttacked)

    local scaleRange = TUNING.ROCKY_MAX_SCALE - TUNING.ROCKY_MIN_SCALE
    local start_scale = TUNING.ROCKY_MIN_SCALE + math.random() * scaleRange

    inst.components.scaler:SetScale(start_scale)
    local dt = 60+math.random()*10
    inst.growtask = inst:DoPeriodicTask(dt, grow, nil, dt)
    inst.components.scaler:SetScale(TUNING.ROCKY_MIN_SCALE)
	
    inst.OnLongUpdate = grow

    inst.OnSave = onsave
    inst.OnLoad = onload

    return inst
end

return Prefab("cave/monsters/rocky", fn, assets, prefabs)
