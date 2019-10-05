local brain = require "brains/smallbirdbrain"
require "stategraphs/SGsmallbird"

local WAKE_TO_FOLLOW_DISTANCE = 10
local SLEEP_NEAR_LEADER_DISTANCE = 7

local assets =
{
	Asset("ANIM", "anim/smallbird_basic.zip"),
	--Asset("SOUND", "sound/smallbird.fsb"),
}

local prefabs=
{
    "teenbird",
}

local teen_assets =
{
	Asset("ANIM", "anim/ds_tallbird_basic.zip"),
	Asset("ANIM", "anim/tallbird_teen_basic.zip"),
	Asset("ANIM", "anim/tallbird_teen_build.zip"),
	--Asset("SOUND", "sound/smallbird.fsb"),
}

local function GetStatus(inst)
    --print("smallbird - GetStatus")
    if inst.components.hunger then
        if inst.components.hunger:IsStarving(inst) then
            --print("STARVING")
            return "STARVING"
        elseif inst.components.hunger:GetPercent() < .5 then
            --print("HUNGRY")
            return "HUNGRY"
        end
    end
end

local function ShouldWakeUp(inst)
    return DefaultWakeTest(inst) or inst.components.hunger:IsStarving(inst) or not inst.components.follower:IsNearLeader(WAKE_TO_FOLLOW_DISTANCE)
end

local function ShouldSleep(inst)
    return DefaultSleepTest(inst) and not inst.components.hunger:IsStarving(inst) and inst.components.follower:IsNearLeader(SLEEP_NEAR_LEADER_DISTANCE)
end

local function CanEatTest(inst, item)
    --print("smallbird - CanEatTest", inst.name, item.components.edible.foodtype, item, item.prefab)
    local canEat = (item.components.edible.foodtype == "SEEDS") or (item.prefab == "berries")
    --print("   canEat?", canEat)
    return canEat
end

local function ShouldAcceptItem(inst, item)
    --print("smallbird - ShouldAcceptItem", inst.name, item.name)
    if item.components.edible and inst.components.hunger and inst.components.eater then
        return inst.components.eater:CanEat(item) and inst.components.hunger:GetPercent() < .9
    end
end

local function OnGetItemFromPlayer(inst, giver, item)
    --print("smallbird - OnGetItemFromPlayer")

    if inst.components.sleeper then
        inst.components.sleeper:WakeUp()
    end

    --I eat food
    if item.components.edible then
        if inst.components.combat.target and inst.components.combat.target == giver then
            inst.components.combat:SetTarget(nil)
        end
        if inst.components.eater:Eat(item) then
            --print("   yummy!")
            -- yay!?
        end
    end

end

local function OnEat(inst, food)
    -- there is no health metre, so eating anything heals to full health
    if inst:HasTag("teenbird") then
        inst.components.health:DoDelta(inst.components.health.maxhealth * .33, nil, food.prefab)
        inst.components.combat:SetTarget(nil)
    else
        inst.components.health:DoDelta(inst.components.health.maxhealth, nil, food.prefab)
    end
end

local function OnRefuseItem(inst, item)
    --print("smallbird - OnRefuseItem")
    --inst.sg:GoToState("refuse")
end

local function FollowPlayer(inst)
    --print("smallbird - FollowPlayer")

	local player = GetPlayer()
	if player and player.components.leader then
        --print("   adding follower")
		player.components.leader:AddFollower(inst)
	end
	
end

local function SetTeenAttackDefault(inst)
    --print("teenbird - Set phasers to 'KILL'")
    inst:RemoveTag("peck_attack")
    inst.components.combat:SetDefaultDamage(TUNING.TEENBIRD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TEENBIRD_ATTACK_PERIOD)
end

local function SetTeenAttackPeck(inst)
    --print("teenbird - Set phasers to 'PECK'")
    inst:AddTag("peck_attack")
    inst.components.combat:SetDefaultDamage(TUNING.TEENBIRD_DAMAGE_PECK)
    inst.components.combat:SetAttackPeriod(TUNING.TEENBIRD_PECK_PERIOD)
end

local function OnNewTarget(inst, data)
    --print("teenbird - OnNewTarget", data.target, inst.components.follower.leader)
    if data.target and data.target:HasTag("player") then
        -- combat component will restore target to player, give them the benefit of the doubt and use peck instead of attack to begin with
        SetTeenAttackPeck(inst)
    else
        SetTeenAttackDefault(inst)
    end
end

local function TeenRetarget(inst)
    return FindEntity(inst, TUNING.TEENBIRD_TARGET_DIST, function(guy)
        if inst.components.combat:CanTarget(guy)  and (not guy.LightWatcher or guy.LightWatcher:IsInLight()) then
            if inst.components.follower.leader ~= nil then
                return (guy:HasTag("monster") or (guy == inst.components.follower.leader and guy:HasTag("player") and inst.components.hunger and inst.components.hunger:IsStarving()))
            else
                return guy:HasTag("monster")
            end
        end
    end)
end

local function TeenKeepTarget(inst, target)
    return inst.components.combat:CanTarget(target) and (not target.LightWatcher or target.LightWatcher:IsInLight())
end

local function OnAttacked(inst, data)
    --print("smallbird - OnAttacked !!!")

    if inst:HasTag("teenbird") and data.attacker ~= nil and (data.attacker == inst.components.follower.leader or data.attacker:HasTag("player")) then
        --print("  what did I ever do to you!?")
        -- well i was just annoyed, but now you done pissed me off!
        SetTeenAttackDefault(inst)
    end

    inst.components.combat:SuggestTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 10, function(dude) return dude:HasTag("smallbird") and not dude.components.health:IsDead() end, 5)
end

local function SetTeen(inst)
    --print("smallbird - SetTeen")

    inst.sg:GoToState("growup") -- calls back to SpawnTeen
end

local function SpawnTeen(inst)
    --print("smallbird - SpawnTeen")

    local teenbird = SpawnPrefab("teenbird")
    teenbird.Transform:SetPosition(inst.Transform:GetWorldPosition())
    teenbird.sg:GoToState("idle")

    if inst.components.follower.leader then
        teenbird.components.follower:SetLeader(inst.components.follower.leader)
    end

    inst:Remove()
end

local function SetAdult(inst)
    --print("smallbird - SetAdult")

    inst.sg:GoToState("growup") -- calls back to SpawnAdult
end

local function SpawnAdult(inst)
    --print("smallbird - SpawnAdult")

    local tallbird = SpawnPrefab("tallbird")
    tallbird.Transform:SetPosition(inst.Transform:GetWorldPosition())
    tallbird.sg:GoToState("idle")
    tallbird.components.combat:BlankOutAttacks(6 + math.random()*4)

    inst:Remove()
end


local function GetPeepChance(inst)
    local peep_percent = 0.1
    if inst.components.hunger then
        if inst.components.hunger:IsStarving() then
            peep_percent = 1
        elseif inst.components.hunger:GetPercent() < .25 then
            peep_percent = 0.9
        elseif inst.components.hunger:GetPercent() < .5 then
            peep_percent = 0.75
        end
    end
    --print("smallbird - GetPeepChance", peep_percent)
    return peep_percent
end

local function GetSmallGrowTime(inst)
	return TUNING.SMALLBIRD_GROW_TIME
end

local function GetTallGrowTime(inst)
	return TUNING.TEENBIRD_GROW_TIME
end

local function OnHealthDelta(inst, data)
    if data.cause == "hunger" and data.newpercent < .5 and inst.components.follower.leader then
        --print("teenbird - STARVING i'm blowing this popsicle stand!", data.newpercent)

        if inst.components.combat.target == inst.components.follower.leader then
            inst.components.combat:SetTarget(nil)
        end

        inst.components.follower:SetLeader(nil)
    end
end

local function create_common(inst)
    --print("smallbird - create_common")

	--inst = inst or CreateEntity()
	
    inst:AddTag("animal")
    inst:AddTag("companion")
    inst:AddTag("character")
    inst:AddTag("smallbird")

	inst.entity:AddSoundEmitter()
	inst.entity:AddDynamicShadow()
    
	MakeCharacterPhysics(inst, 10, .25)
    
    inst.Physics:SetCollisionGroup(COLLISION.CHARACTERS)
    inst.Physics:ClearCollisionMask()
    inst.Physics:CollidesWith(COLLISION.WORLD)
    inst.Physics:CollidesWith(COLLISION.OBSTACLES)
    inst.Physics:CollidesWith(COLLISION.CHARACTERS)

    inst.Transform:SetFourFaced()

	inst:SetBrain(brain)	

    inst.userfunctions = 
    {
        FollowPlayer = FollowPlayer,
        GetPeepChance = GetPeepChance,
        SpawnTeen = SpawnTeen,
        SpawnAdult = SpawnAdult,
    }

    ------------------------------------------
    inst:AddComponent("health")
    inst:AddComponent("hunger")

    inst:AddComponent("combat")
	inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus

    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 6

    inst:AddComponent("follower")

    inst:AddComponent("eater")
    inst.components.eater:SetOmnivore()
    inst.components.eater:SetOnEatFn(OnEat)

    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)
    inst.components.sleeper.testperiod = GetRandomWithVariance(6, 2)
    inst.components.sleeper:SetSleepTest(ShouldSleep)
    inst.components.sleeper:SetWakeTest(ShouldWakeUp)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem

    inst:AddComponent("lootdropper")

    --print("smallbird - create_common END")
    return inst
end

local function create_smallbird()
    --print("smallbird - create_smallbird")

	local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("smallbird")
    inst.AnimState:SetBuild("smallbird_basic")
    inst.AnimState:PlayAnimation("idle")

    create_common(inst)

    inst:SetStateGraph("SGsmallbird")

    inst:AddTag("smallcreature")

	inst.DynamicShadow:SetSize( 1.25, .75 )
    MakeSmallBurnableCharacter(inst, "head")
    MakeSmallFreezableCharacter(inst, "head")
    
    inst.components.health:SetMaxHealth(TUNING.SMALLBIRD_HEALTH)
    
    inst.components.hunger:SetMax(TUNING.SMALLBIRD_HUNGER)
    inst.components.hunger:SetRate(TUNING.SMALLBIRD_HUNGER/TUNING.SMALLBIRD_STARVE_TIME)
    inst.components.hunger:SetKillRate(TUNING.SMALLBIRD_HEALTH/TUNING.SMALLBIRD_STARVE_KILL_TIME)

	inst.components.combat.hiteffectsymbol = "head"
    inst.components.combat:SetRange(TUNING.SMALLBIRD_ATTACK_RANGE)
    inst.components.combat:SetDefaultDamage(TUNING.SMALLBIRD_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SMALLBIRD_ATTACK_PERIOD)

    inst.components.lootdropper:SetLoot({"smallmeat"})

    inst.components.eater:SetCanEatTestFn(CanEatTest)

    local growth_stages = {
        {name="small", time = GetSmallGrowTime, fn = function() end },
        {name="tall", fn = SetTeen}
    }

	inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable:SetStage(1)
    inst.components.growable:StartGrowing()

    --print("smallbird - create_smallbird END")
	return inst
end

local function create_teen_smallbird()
    --print("smallbird - create_teen_smallbird")

    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.AnimState:SetBank("tallbird")
    inst.AnimState:SetBuild("tallbird_teen_build")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:Hide("beakfull")

    create_common(inst)
	
    inst:AddTag("teenbird")

    inst:SetStateGraph("SGtallbird")


    inst.Transform:SetScale(.8, .8, .8)

    inst.Physics:SetCylinder(.5, 1)

	inst.DynamicShadow:SetSize( 2.75, 1 )
    MakeLargeBurnableCharacter(inst, "head")
    MakeMediumFreezableCharacter(inst, "head")
    
    inst.components.health:SetMaxHealth(TUNING.TEENBIRD_HEALTH)
    inst:ListenForEvent("healthdelta", OnHealthDelta)
    
    inst.components.hunger:SetMax(TUNING.TEENBIRD_HUNGER)
    inst.components.hunger:SetRate(TUNING.TEENBIRD_HUNGER/TUNING.TEENBIRD_STARVE_TIME)
    inst.components.hunger:SetKillRate(TUNING.TEENBIRD_HEALTH/TUNING.TEENBIRD_STARVE_KILL_TIME)

	inst.components.combat.hiteffectsymbol = "head"
    inst.components.combat:SetRange(TUNING.TEENBIRD_ATTACK_RANGE)
    inst.components.combat:SetRetargetFunction(3, TeenRetarget)
    inst.components.combat:SetKeepTargetFunction(TeenKeepTarget)
    SetTeenAttackDefault(inst)

    inst:ListenForEvent("newcombattarget", OnNewTarget)
    
    inst.components.lootdropper:SetLoot({"meat"})

    --inst.components.eater:SetCanEatTestFn(CanEatTest)

    local growth_stages = {
        {name="tall", time = GetTallGrowTime, fn = function() end },
        {name="adult", fn = SetAdult}
    }

	inst:AddComponent("growable")
    inst.components.growable.stages = growth_stages
    inst.components.growable:SetStage(1)
    inst.components.growable:StartGrowing()

    --print("smallbird - create_teen_smallbird END")
	return inst
end

return Prefab( "common/smallbird", create_smallbird, assets, prefabs),
	   Prefab( "common/teenbird", create_teen_smallbird, teen_assets) 
