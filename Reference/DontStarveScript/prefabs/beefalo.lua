require "brains/beefalobrain"
require "stategraphs/SGBeefalo"

local assets=
{
    Asset("ANIM", "anim/beefalo_basic.zip"),
    Asset("ANIM", "anim/beefalo_actions.zip"),
    Asset("ANIM", "anim/beefalo_actions_domestic.zip"),
    Asset("ANIM", "anim/beefalo_actions_quirky.zip"),
    Asset("ANIM", "anim/beefalo_build.zip"),
    Asset("ANIM", "anim/beefalo_shaved_build.zip"),
    Asset("ANIM", "anim/beefalo_baby_build.zip"),

    Asset("ANIM", "anim/beefalo_domesticated.zip"),
    Asset("ANIM", "anim/beefalo_personality_docile.zip"),
    Asset("ANIM", "anim/beefalo_personality_ornery.zip"),
    Asset("ANIM", "anim/beefalo_personality_pudgy.zip"),

    Asset("ANIM", "anim/beefalo_fx.zip"),

    Asset("SOUND", "sound/beefalo.fsb"),
}

local prefabs =
{
    "meat",
    "poop",
    "beefalowool",
    "horn",
}

SetSharedLootTable( 'beefalo',
{
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'meat',            1.00},
    {'beefalowool',     1.00},
    {'beefalowool',     1.00},
    {'beefalowool',     1.00},
    {'horn',            0.33},
})

local sounds = 
{
    walk = "dontstarve/beefalo/walk",
    grunt = "dontstarve/beefalo/grunt",
    yell = "dontstarve/beefalo/yell",
    swish = "dontstarve/beefalo/tail_swish",
    curious = "dontstarve/beefalo/curious",
    angry = "dontstarve/beefalo/angry",

    sleep = "dontstarve/beefalo/sleep",    
}

local tendencies =
{
    DEFAULT =
    {
    },

    ORNERY =
    {
        build = "beefalo_personality_ornery",
    },

    RIDER =
    {
        build = "beefalo_personality_docile",
    },

    PUDGY =
    {
        build = "beefalo_personality_pudgy",
        customactivatefn = function(inst)
            inst:AddComponent("sanityaura")
            inst.components.sanityaura.aura = TUNING.SANITYAURA_TINY
        end,
        customdeactivatefn = function(inst)
            inst:RemoveComponent("sanityaura")
        end,
    },
}

-- This takes an anim state so that it can apply to itself, or to its rider
local function ApplyBuildOverrides(inst, animstate)
    local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
    local basebuild = (inst:HasTag("baby") and "beefalo_baby_build")
            or (inst.components.beard.bits == 0 and "beefalo_shaved_build")
            or (inst.components.domesticatable:IsDomesticated() and "beefalo_domesticated")
            or "beefalo_build"
    if animstate ~= nil and animstate ~= inst.AnimState then
        animstate:AddOverrideBuild(basebuild)
    else
        animstate:SetBuild(basebuild)
    end

    if (herd and herd.components.mood and herd.components.mood:IsInMood())
        or (inst.components.mood and inst.components.mood:IsInMood()) then
        animstate:Show("HEAT")
    else
        animstate:Hide("HEAT")
    end

    if tendencies[inst.tendency].build ~= nil then
        animstate:AddOverrideBuild(tendencies[inst.tendency].build)
    elseif animstate == inst.AnimState then
        -- this presumes that all the face builds have the same symbols
        animstate:ClearOverrideBuild("beefalo_personality_docile")
    end
end

local function ClearBuildOverrides(inst, animstate)
    if animstate ~= inst.AnimState then
        animstate:ClearOverrideBuild("beefalo_build")
    end
    -- this presumes that all the face builds have the same symbols
    animstate:ClearOverrideBuild("beefalo_personality_docile")
end

local function OnEnterMood(inst)
    inst:AddTag("scarytoprey")
    inst:ApplyBuildOverrides(inst.AnimState)
    if inst.components.rideable and inst.components.rideable:GetRider() ~= nil then
        inst:ApplyBuildOverrides(inst.components.rideable:GetRider().AnimState)
    end
end

local function OnLeaveMood(inst)
    inst:RemoveTag("scarytoprey")
    inst:ApplyBuildOverrides(inst.AnimState)
    if inst.components.rideable ~= nil and inst.components.rideable:GetRider() ~= nil then
        inst:ApplyBuildOverrides(inst.components.rideable:GetRider().AnimState)
    end
end

local function Retarget(inst)
    if inst.components.herdmember
       and inst.components.herdmember:GetHerd()
       and inst.components.herdmember:GetHerd().components.mood
       and inst.components.herdmember:GetHerd().components.mood:IsInMood() then
        return FindEntity(inst, TUNING.BEEFALO_TARGET_DIST, function(guy)
            return not guy:HasTag("beefalo") and 
                    inst.components.combat:CanTarget(guy) and 
                    not guy:HasTag("wall")
                    and (guy.components.rider == nil
                            or guy.components.rider:GetMount() == nil
                            or not guy.components.rider:GetMount():HasTag("beefalo"))
        end)
    end
end

local function KeepTarget(inst, target)
    if inst.components.herdmember
       and inst.components.herdmember:GetHerd()
       and inst.components.herdmember:GetHerd().components.mood
       and inst.components.herdmember:GetHerd().components.mood:IsInMood() then
        local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
        if herd and herd.components.mood and herd.components.mood:IsInMood() then
            return distsq(Vector3(herd.Transform:GetWorldPosition() ), Vector3(inst.Transform:GetWorldPosition() ) ) < TUNING.BEEFALO_CHASE_DIST*TUNING.BEEFALO_CHASE_DIST
        end
    end
    return true
end

local function OnNewTarget(inst, data)
    if inst.components.follower and data and data.target and data.target == inst.components.follower.leader then
        inst.components.follower:SetLeader(nil)
    end
end

local function CanShareTarget(dude)
    return dude:HasTag("beefalo")
        and not dude:IsInLimbo()
        and not (dude.components.health:IsDead() or dude:HasTag("player"))
end

local function OnAttacked(inst, data)
    if inst._ridersleeptask ~= nil then
        inst._ridersleeptask:Cancel()
        inst._ridersleeptask = nil
    end
    inst._ridersleep = nil
    if inst.components.rideable:IsBeingRidden() then
        if not inst.components.domesticatable:IsDomesticated() or not inst.tendency == TENDENCY.ORNERY then
            inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_ATTACKED_DOMESTICATION)
            inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_ATTACKED_OBEDIENCE)
        end
        inst.components.domesticatable:DeltaTendency(TENDENCY.ORNERY, TUNING.BEEFALO_ORNERY_ATTACKED)
    else
        if data.attacker ~= nil and data.attacker:HasTag("player") then
            inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_DOMESTICATION)
            inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_ATTACKED_BY_PLAYER_OBEDIENCE)
        end
        inst.components.combat:SetTarget(data.attacker)
        inst.components.combat:ShareTarget(data.attacker, 30, CanShareTarget, 5)
    end
end

local function GetStatus(inst)
    return (inst.components.follower.leader ~= nil and "FOLLOWER")
        or (inst.components.beard ~= nil and inst.components.beard.bits == 0 and "NAKED")
        or (inst.components.domesticatable ~= nil and
            inst.components.domesticatable:IsDomesticated() and
            (inst.tendency == TENDENCY.DEFAULT and "DOMESTICATED" or inst.tendency))
        or nil
end

--[[

local function GetStatus(inst)
    if inst.components.follower.leader ~= nil then
        return "FOLLOWER"
    elseif inst.components.beard and inst.components.beard.bits == 0 then
        return "NAKED"
    end
end
]]
local function OnResetBeard(inst)
    inst.sg:GoToState("shaved")
    inst.components.brushable:SetBrushable(false)
    inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_SHAVED_OBEDIENCE)
end


local function CanShaveTest(inst)
    if inst.components.sleeper:IsAsleep() then
        return true
    else
        return false, "AWAKEBEEFALO"
    end
end

local function OnShaved(inst)
    inst:ApplyBuildOverrides(inst.AnimState)
end

local function OnHairGrowth(inst)
    if inst.components.beard.bits == 0 then
        inst.hairGrowthPending = true
        if inst.components.rideable ~= nil then
            inst.components.rideable:Buck()
        end
    end
end

local function OnBrushed(inst, doer, numprizes)
    if numprizes > 0 and inst.components.domesticatable ~= nil then
        inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_BRUSHED_DOMESTICATION)
        inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_BRUSHED_OBEDIENCE)
    end
end

local function ShouldAcceptItem(inst, item)
    return inst.components.eater:CanEat(item)
        and not inst.components.combat.target
end

local function OnGetItemFromPlayer(inst, giver, item)
    print(item.prefab,inst.components.eater:CanEat(item))
    if inst.components.eater:CanEat(item) then
        inst.components.eater:Eat(item, giver)
    end
end

local function OnRefuseItem(inst, item)
    inst.sg:GoToState("refuse")
    if inst.components.sleeper:IsAsleep() then
        inst.components.sleeper:WakeUp()
    end
end

local function OnDomesticated(inst, data)
    inst.components.rideable:Buck()
    inst.domesticationPending = true
end

local function DoDomestication(inst)
    inst.components.herdmember:Enable(false)
    inst.components.mood:Enable(true)
    inst.components.mood:ValidateMood()

    inst:SetTendency("domestication")
end

local function OnFeral(inst, data)
    inst.components.rideable:Buck()
    if inst.components.domesticatable:IsDomesticated() then
        inst.domesticationPending = true
    end
end

local function DoFeral(inst)
    inst.components.herdmember:Enable(true)
    inst.components.mood:Enable(false)
    inst.components.mood:ValidateMood()

    inst:SetTendency("feral")
end

local function UpdateDomestication(inst)
    if inst.components.domesticatable:IsDomesticated() then
        DoDomestication(inst)
    else
        DoFeral(inst)
    end
end

local function SetTendency(inst, changedomestication)
    -- tendency is locked in after we become domesticated
    local tendencychanged = false
    local oldtendency = inst.tendency
    if not inst.components.domesticatable:IsDomesticated() then
        local tendencysum = 0
        local maxtendency = nil
        local maxtendencyval = 0
        for k, v in pairs(inst.components.domesticatable.tendencies) do
            tendencysum = tendencysum + v
            if v > maxtendencyval then
                maxtendencyval = v
                maxtendency = k
            end
        end
        inst.tendency = (tendencysum < .1 or maxtendencyval * 2 < tendencysum) and TENDENCY.DEFAULT or maxtendency
        tendencychanged = inst.tendency ~= oldtendency
    end

    if changedomestication == "domestication" then
        if tendencies[inst.tendency].customactivatefn ~= nil then
            tendencies[inst.tendency].customactivatefn(inst)
        end
    elseif changedomestication == "feral"
        and tendencies[oldtendency].customdeactivatefn ~= nil then
        tendencies[oldtendency].customdeactivatefn(inst)
    end

    if tendencychanged or changedomestication ~= nil then
        if inst.components.domesticatable:IsDomesticated() then
            inst.components.domesticatable:SetMinObedience(TUNING.BEEFALO_MIN_DOMESTICATED_OBEDIENCE[inst.tendency])

            inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE[inst.tendency])
            inst.components.locomotor.runspeed = TUNING.BEEFALO_RUN_SPEED[inst.tendency]
        else
            inst.components.domesticatable:SetMinObedience(0)

            inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE.DEFAULT)
            inst.components.locomotor.runspeed = TUNING.BEEFALO_RUN_SPEED.DEFAULT
        end

        inst:ApplyBuildOverrides(inst.AnimState)
        if inst.components.rideable and inst.components.rideable:GetRider() ~= nil then
            inst:ApplyBuildOverrides(inst.components.rideable:GetRider().AnimState)
        end
    end
end

local function ShouldBeg(inst)
    local herd = inst.components.herdmember and inst.components.herdmember:GetHerd()
--[[
    print("=---")
    print(inst.components.domesticatable:GetDomestication())
    print(inst.components.hunger:GetPercent())
    print(herd.components.mood:IsInMood())
    print(inst.components.mood:IsInMood())
    ]]

    return inst.components.domesticatable ~= nil
        and inst.components.domesticatable:GetDomestication() > 0.0
        and inst.components.hunger ~= nil
        and inst.components.hunger:GetPercent() < TUNING.BEEFALO_BEG_HUNGER_PERCENT
        and (herd and herd.components.mood ~= nil and herd.components.mood:IsInMood() == false)
        and (inst.components.mood ~= nil and inst.components.mood:IsInMood() == false)
end

local function CalculateBuckDelay(inst)
    local domestication =
        inst.components.domesticatable ~= nil
        and inst.components.domesticatable:GetDomestication()
        or 0

    local moodmult =
        (   (inst.components.herdmember ~= nil and inst.components.herdmember.herd ~= nil and inst.components.herdmember.herd.components.mood ~= nil and inst.components.herdmember.herd.components.mood:IsInMood()) or
            (inst.components.mood ~= nil and inst.components.mood:IsInMood())   )
        and TUNING.BEEFALO_BUCK_TIME_MOOD_MULT
        or 1

    local beardmult =
        (inst.components.beard ~= nil and inst.components.beard.bits == 0)
        and TUNING.BEEFALO_BUCK_TIME_NUDE_MULT
        or 1

    local domesticmult =
        inst.components.domesticatable:IsDomesticated()
        and 1
        or TUNING.BEEFALO_BUCK_TIME_UNDOMESTICATED_MULT

    local basedelay = Remap(domestication, 0, 1, TUNING.BEEFALO_MIN_BUCK_TIME, TUNING.BEEFALO_MAX_BUCK_TIME)

    return basedelay * moodmult * beardmult * domesticmult
end

local function OnBuckTime(inst)
    --V2C: reschedule because :Buck() is not guaranteed!
    inst._bucktask = inst:DoTaskInTime(1 + math.random(), OnBuckTime)
    inst.components.rideable:Buck()
end

local function OnObedienceDelta(inst, data)
    inst.components.rideable:SetSaddleable(data.new >= TUNING.BEEFALO_SADDLEABLE_OBEDIENCE)

    if data.new > data.old and inst._bucktask ~= nil then
        --Restart buck timer if we gained obedience!
        inst._bucktask:Cancel()
        inst._bucktask = inst:DoTaskInTime(CalculateBuckDelay(inst), OnBuckTime)
    end
end

local function OnDeath(inst, data)
    if inst.components.rideable:IsBeingRidden() then
        --SG won't handle "death" event while we're being ridden
        --SG is forced into death state AFTER dismounting (OnRiderChanged)
        inst.components.rideable:Buck(true)
    end
end

local function DomesticationTriggerFn(inst)
    return inst.components.hunger:GetPercent() > 0
        or inst.components.rideable:IsBeingRidden() == true
end

local function OnStarving(inst, dt)
    -- apply no health damage; the stomach is just used by domesticatable
    inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_STARVE_OBEDIENCE * dt)
    --inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_STARVE_DOMESTICATION * dt)
end

local function OnHungerDelta(inst, data)
    local delta = data.newpercent - data.oldpercent
    if data.oldpercent > 0 and delta < 0 then
        -- basically, give domestication while we are digesting
        --inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_WELLFED_DOMESTICATION * -data.delta)
        if data.oldpercent > 0.5 then
            inst.components.domesticatable:DeltaTendency(TENDENCY.PUDGY, TUNING.BEEFALO_PUDGY_WELLFED * -delta)
        end
    end
end

local function OnEat(inst, food)
    print("ON EAT")
    local full = inst.components.hunger:GetPercent() >= 1
    if not full then
        inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_FEED_OBEDIENCE)

        inst.components.domesticatable:TryBecomeDomesticated()
    else
        inst.components.domesticatable:DeltaObedience(TUNING.BEEFALO_DOMESTICATION_OVERFEED_OBEDIENCE)
        inst.components.domesticatable:DeltaDomestication(TUNING.BEEFALO_DOMESTICATION_OVERFEED_DOMESTICATION)
        inst.components.domesticatable:DeltaTendency(TENDENCY.PUDGY, TUNING.BEEFALO_PUDGY_OVERFEED)
    end
    inst:PushEvent("eat", { full = full, food = food })
    inst.components.knownlocations:RememberLocation("loiteranchor", inst:GetPosition())
end

local function OnDomesticationDelta(inst, data)
    inst:SetTendency()
end

local function OnHealthDelta(inst, data)
    if data.oldpercent >= 0.2 and
        data.newpercent < 0.2 and
        inst.components.rideable.rider ~= nil then
        inst.components.rideable.rider:PushEvent("mountwounded")
    end
end

local function OnBeingRidden(inst, dt)
    inst.components.domesticatable:DeltaTendency(TENDENCY.RIDER, TUNING.BEEFALO_RIDER_RIDDEN * dt)
end

local function OnRiderDoAttack(inst, data)
    inst.components.domesticatable:DeltaTendency(TENDENCY.ORNERY, TUNING.BEEFALO_ORNERY_DOATTACK)
end

local function DoRiderSleep(inst, sleepiness, sleeptime)
    inst._ridersleeptask = nil
    inst.components.sleeper:AddSleepiness(sleepiness, sleeptime)
end

local function OnRiderChanged(inst, data)
    if inst._bucktask ~= nil then
        inst._bucktask:Cancel()
        inst._bucktask = nil
    end

    if inst._ridersleeptask ~= nil then
        inst._ridersleeptask:Cancel()
        inst._ridersleeptask = nil
    end

    if data.newrider ~= nil then
        if inst.components.sleeper ~= nil then
            inst.components.sleeper:WakeUp()
        end
        inst._bucktask = inst:DoTaskInTime(CalculateBuckDelay(inst), OnBuckTime)
        inst.components.knownlocations:RememberLocation("loiteranchor", inst:GetPosition())
    elseif inst.components.health:IsDead() then
        if inst.sg.currentstate.name ~= "death" then
            inst.sg:GoToState("death")
        end
    elseif inst.components.sleeper ~= nil then
        inst.components.sleeper:StartTesting()
        if inst._ridersleep ~= nil then
            local sleeptime = inst._ridersleep.sleeptime + inst._ridersleep.time - GetTime()
            if sleeptime > 2 then
                inst._ridersleeptask = inst:DoTaskInTime(0, DoRiderSleep, inst._ridersleep.sleepiness, sleeptime)
            end
            inst._ridersleep = nil
        end
    end
end

local function OnSaddleChanged(inst, data)
    if data.saddle ~= nil then
        inst:AddTag("companion")
    else
        inst:RemoveTag("companion")
    end
end

local function _OnRefuseRider(inst)
    if inst.components.sleeper:IsAsleep() and not inst.components.health:IsDead() then
        -- this needs to happen after the stategraph
        inst.components.sleeper:WakeUp()
    end
end

local function OnRefuseRider(inst, data)
    inst:DoTaskInTime(0, _OnRefuseRider)
end

local function OnRiderSleep(inst, data)
    inst._ridersleep = inst.components.rideable:IsBeingRidden() and {
        time = GetTime(),
        sleepiness = data.sleepiness,
        sleeptime = data.sleeptime,
    } or nil
end

local function MountSleepTest(inst)
    return not inst.components.rideable:IsBeingRidden() and DefaultSleepTest(inst)
end

local function ToggleDomesticationDecay(inst)
    inst.components.domesticatable:PauseDomesticationDecay((inst.components.saltlicker and inst.components.saltlicker.salted) or inst.components.sleeper:IsAsleep())
end

local function OnInit(inst)
    inst.components.mood:ValidateMood()
    inst:UpdateDomestication()
end

local function CustomOnHaunt(inst)
    inst.components.periodicspawner:TrySpawn()
    return true
end

local function OnSave(inst, data)
    data.tendency = inst.tendency
end

local function OnLoad(inst, data)
    if data ~= nil and data.tendency ~= nil then
        inst.tendency = data.tendency
    end
end

local function GetDebugString(inst)
    return string.format("tendency %s nextbuck %.2f", inst.tendency, GetTaskRemaining(inst._bucktask))
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	inst.sounds = sounds
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 6, 2 )
    inst.Transform:SetSixFaced()
    MakeCharacterPhysics(inst, 100, .5)
    
    inst:AddTag("beefalo")
    anim:SetBank("beefalo")
    anim:SetBuild("beefalo_build")
    anim:PlayAnimation("idle_loop", true)
    
    inst:AddTag("animal")
    inst:AddTag("largecreature")


    local hair_growth_days = 3

    inst:AddComponent("beard")
    -- assume the beefalo has already grown its hair
    inst.components.beard.bits = 3
    inst.components.beard.daysgrowth = hair_growth_days + 1 
    inst.components.beard.onreset = function()
        inst.sg:GoToState("shaved")
    end
    
    inst.components.beard.canshavetest = function() if not inst.components.sleeper:IsAsleep() then return false, "AWAKEBEEFALO" end return true end
    
    inst.components.beard.prize = "beefalowool"
    inst.components.beard:AddCallback(0, function()
        if inst.components.beard.bits == 0 then
            anim:SetBuild("beefalo_shaved_build")
        end
    end)
    inst.components.beard:AddCallback(hair_growth_days, function()
        if inst.components.beard.bits == 0 then
            inst.hairGrowthPending = true
        end
    end)
    
    inst:AddComponent("eater")
    inst.components.eater.foodprefs = { "VEGGIE","ROUGHAGE" }
    inst.components.eater.ablefoods = { "VEGGIE","ROUGHAGE" }
    --inst.components.eater:SetAbsorptionModifiers(4,1,1)
    inst.components.eater:SetOnEatFn(OnEat)
    
    inst:AddComponent("combat")
    inst.components.combat.hiteffectsymbol = "beefalo_body"
    inst.components.combat:SetDefaultDamage(TUNING.BEEFALO_DAMAGE.DEFAULT)
    inst.components.combat:SetRetargetFunction(1, Retarget)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
     
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.BEEFALO_HEALTH)

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('beefalo')    
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("knownlocations")
    inst:AddComponent("herdmember")



    inst:AddComponent("leader")
    inst:AddComponent("follower")
    inst.components.follower.maxfollowtime = TUNING.BEEFALO_FOLLOW_TIME
    inst.components.follower.canaccepttarget = false
    inst:ListenForEvent("newcombattarget", OnNewTarget)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("periodicspawner")
    inst.components.periodicspawner:SetPrefab("poop")
    inst.components.periodicspawner:SetRandomTimes(40, 60)
    inst.components.periodicspawner:SetDensityInRange(20, 2)
    inst.components.periodicspawner:SetMinimumSpacing(8)
    inst.components.periodicspawner:Start()

    MakeLargeBurnableCharacter(inst, "swap_fire")
    MakeLargeFreezableCharacter(inst, "beefalo_body")
    
    inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
    inst.components.locomotor.walkspeed = 1.5
    inst.components.locomotor.runspeed = 7
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(3)


    inst:AddComponent("brushable")
    inst.components.brushable.regrowthdays = 1
    inst.components.brushable.max = 1
    inst.components.brushable.prize = "beefalowool"
    inst.components.brushable:SetOnBrushed(OnBrushed)

    inst:AddComponent("rideable")
    inst.components.rideable:SetRequiredObedience(TUNING.BEEFALO_MIN_BUCK_OBEDIENCE)
    inst:ListenForEvent("saddlechanged", OnSaddleChanged)
    inst:ListenForEvent("refusedrider", OnRefuseRider)

    inst:AddComponent("trader")
    inst.components.trader:SetAcceptTest(ShouldAcceptItem)
    inst.components.trader.onaccept = OnGetItemFromPlayer
    inst.components.trader.onrefuse = OnRefuseItem
    inst.components.trader.deleteitemonaccept = false

    inst:AddComponent("hunger")
    inst.components.hunger:SetMax(TUNING.BEEFALO_HUNGER)
    inst.components.hunger:SetRate(TUNING.BEEFALO_HUNGER_RATE)
    inst.components.hunger:SetPercent(0)
    inst.components.hunger:SetOverrideStarveFn(OnStarving)

    inst:AddComponent("domesticatable")
    inst.components.domesticatable:SetDomesticationTrigger(DomesticationTriggerFn)

    inst:ListenForEvent("death", OnDeath) -- need to handle this due to being mountable
    
    inst:AddComponent("timer")
    inst:AddComponent("saltlicker")
    inst.components.saltlicker:SetUp(TUNING.SALTLICK_BEEFALO_USES)
    inst:ListenForEvent("saltchange", ToggleDomesticationDecay)
    inst:ListenForEvent("gotosleep", ToggleDomesticationDecay)
    inst:ListenForEvent("onwakeup", ToggleDomesticationDecay)    

    inst.ApplyBuildOverrides = ApplyBuildOverrides
    inst.ClearBuildOverrides = ClearBuildOverrides
    
    inst.tendency = TENDENCY.DEFAULT
    inst._bucktask = nil

    inst:AddComponent("mood")
    inst.components.mood:SetMoodTimeInDays(TUNING.BEEFALO_MATING_SEASON_LENGTH, TUNING.BEEFALO_MATING_SEASON_WAIT)
    inst.components.mood:SetInMoodFn(OnEnterMood)
    inst.components.mood:SetLeaveMoodFn(OnLeaveMood)
    inst.components.mood:CheckForMoodChange()
    inst.components.mood:Enable(false)    

    inst:ListenForEvent("entermood", OnEnterMood)
    inst:ListenForEvent("leavemood", OnLeaveMood)

    inst.UpdateDomestication = UpdateDomestication
    inst:ListenForEvent("domesticated", OnDomesticated)
    inst.DoFeral = DoFeral
    inst:ListenForEvent("goneferal", OnFeral)
    inst:ListenForEvent("obediencedelta", OnObedienceDelta)
    inst:ListenForEvent("domesticationdelta", OnDomesticationDelta)
    inst:ListenForEvent("beingridden", OnBeingRidden)
    inst:ListenForEvent("riderchanged", OnRiderChanged)
    inst:ListenForEvent("riderdoattackother", OnRiderDoAttack)
    inst:ListenForEvent("hungerdelta", OnHungerDelta)
    inst:ListenForEvent("ridersleep", OnRiderSleep)   

    inst.SetTendency = SetTendency
    inst:SetTendency()

    inst.ShouldBeg = ShouldBeg

    local brain = require "brains/beefalobrain"
    inst:SetBrain(brain)
    inst:SetStateGraph("SGBeefalo")

    inst:DoTaskInTime(0, OnInit)

    inst.debugstringfn = GetDebugString
    inst.OnSave = OnSave
    inst.OnLoad = OnLoad     
    return inst
end

return Prefab( "forest/animals/beefalo", fn, assets, prefabs) 
