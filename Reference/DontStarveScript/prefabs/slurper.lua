require "brains/slurtlebrain"
require "stategraphs/SGslurper"

local assets = 
{
	Asset("ANIM", "anim/slurper_basic.zip"),
	Asset("ANIM", "anim/hat_slurper.zip"),
	Asset("SOUND", "sound/slurper.fsb"),
	Asset("INV_IMAGE", "slurper"),	
}

local prefabs = 
{
	"slurper_pelt"
}


local freq = 750
local slurp_channels =
{
	"set_music",
	"set_ambience",
	"set_sfx/set_ambience",
	"set_sfx/movement",
	"set_sfx/creature",
	"set_sfx/player",
	"set_sfx/voice",
	"set_sfx/sfx"
}	

SetSharedLootTable( 'slurper',
{
    {'lightbulb',  	 1.0},
    {'lightbulb',  	 1.0},
    {'slurper_pelt', 0.5},
})

local function slurphunger(inst, owner)
    if (owner.components.hunger and owner.components.hunger.current > 0 )then
        owner.components.hunger:DoDelta(-3)        
    elseif (owner.components.health and not owner.components.hunger) then
    	owner.components.health:DoDelta(-5,false,"slurper")
    end
end

local function OnAttacked(inst, data)
	inst.components.combat:SetTarget(data.attacker)
end

local function CanHatTarget(inst, target)
	local compatibletarget = target and target.components.inventory and (target:HasTag("player") or target:HasTag("manrabbit") or target:HasTag("pig"))
	if not compatibletarget then return false end
	local hat = target.components.inventory:GetEquippedItem(EQUIPSLOTS.HEAD)
	if hat and hat.prefab == inst.prefab then return false end
	return true
end

local function Retarget(inst)
	--Find us a tasty target with a hunger component and the ability to equip hats.
	--Otherwise just find a target that can equip hats.

	--Too far, don't find a target
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > 30*30) then
        return
    end	

    local newtarget = FindEntity(inst, 15, function(guy) 
    	return (guy:HasTag("character") or guy:HasTag("monster")) and inst.components.combat:CanTarget(guy)
    end)

    return newtarget
end

local function KeepTarget(inst, target)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )
    if (homePos and distsq(homePos, myPos) > 30*30) then
    	--You've chased too far. Go home.
        return false
    end

    return true
end

local function OnEquip(inst, owner)
	--Start feeding!

	if not CanHatTarget(inst, owner) then
		owner.components.inventory:Unequip(EQUIPSLOTS.HEAD)
		return
	end

	inst.Light:Enable(true)
    inst.components.lighttweener:StartTween(nil, 3, 0.8, 0.4, nil, 2)


	inst.SoundEmitter:PlaySound("dontstarve/creatures/slurper/attach")

    owner.AnimState:OverrideSymbol("swap_hat", "hat_slurper", "swap_hat")
    owner.AnimState:Show("HAT")
    owner.AnimState:Show("HAT_HAIR")
    owner.AnimState:Hide("HAIR_NOHAT")
    owner.AnimState:Hide("HAIR")
    
    if owner:HasTag("player") then
		owner.AnimState:Hide("HEAD")
		owner.AnimState:Show("HEAD_HAIR")

		for k,v in pairs(slurp_channels) do
			TheMixer:SetLowPassFilter(v, freq, 1)
		end
		inst.SoundEmitter:PlaySound("dontstarve/creatures/slurper/headslurp", "player_slurp_loop")
	else
		inst.SoundEmitter:PlaySound("dontstarve/creatures/slurper/headslurp_creatures", "creature_slurp_loop")
	end

	inst.shouldburp = true
	inst.task = inst:DoPeriodicTask(2, function() slurphunger(inst, owner) end)

	inst.cansleep = false

end

local function OnUnequip(inst, owner)

	inst.Light:Enable(true)	
    inst.components.lighttweener:StartTween(nil, 1, 0.5, 0.7,nil, 2)

	inst.SoundEmitter:PlaySound("dontstarve/creatures/slurper/dettach")

    owner.AnimState:Hide("HAT")
    owner.AnimState:Hide("HAT_HAIR")
    owner.AnimState:Show("HAIR_NOHAT")
    owner.AnimState:Show("HAIR")

	if owner:HasTag("player") then
        owner.AnimState:Show("HEAD")
		owner.AnimState:Hide("HEAD_HAIR")

		for k,v in pairs(slurp_channels) do
			TheMixer:ClearLowPassFilter(v, 1)
		end
		inst.SoundEmitter:KillSound("player_slurp_loop")
	else
		inst.SoundEmitter:KillSound("creature_slurp_loop")
	end
	
	if inst.task then inst.task:Cancel() inst.task = nil end

	local season = GetSeasonManager()
	if season then
		season:SetAppropriateDSP()
	end

	inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()) )

	inst:DoTaskInTime(10, function() inst.cansleep = true end)

end

local function SleepTest(inst)

    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition())
    
	return not (inst.components.combat and inst.components.combat.target)
        and not (inst.components.burnable and inst.components.burnable:IsBurning() )
        and not (inst.components.freezable and inst.components.freezable:IsFrozen() )
        and not (inst.components.inventoryitem and inst.components.inventoryitem.owner)
        and (homePos and distsq(homePos, myPos) < 5 * 5)
        and inst.cansleep == true
end

local function WakeTest(inst)
    local homePos = inst.components.knownlocations:GetLocation("home")
    local myPos = Vector3(inst.Transform:GetWorldPosition() )

	return (inst.components.combat and inst.components.combat.target)
        or (inst.components.burnable and inst.components.burnable:IsBurning() )
        or (inst.components.freezable and inst.components.freezable:IsFrozen() )
        or (inst.components.inventoryitem and inst.components.inventoryitem.owner)
        or (homePos and distsq(homePos, myPos) > 5*5)
        or inst.cansleep == false
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()	
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 2, 1.25 )
	
	inst.Transform:SetFourFaced()

	MakeCharacterPhysics(inst, 10, 0.5)
    MakeMediumBurnableCharacter(inst)
    MakeMediumFreezableCharacter(inst)

    inst:AddTag("animal")

    anim:SetBank("slurper")    
	anim:SetBuild("slurper_basic")
	anim:PlayAnimation("idle_loop", true)

	inst:AddComponent("inspectable")

	inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.canbepickedup = false
	inst.components.inventoryitem.cangoincontainer = false
	inst.components.inventoryitem.nobounce = true

	inst:AddComponent("equippable")
	inst.components.equippable.equipslot = EQUIPSLOTS.HEAD
	inst.components.equippable:SetOnUnequip(OnUnequip)
	inst.components.equippable:SetOnEquip(OnEquip)

    inst:AddComponent("locomotor")
    inst.components.locomotor:SetSlowMultiplier( 1 )
    inst.components.locomotor:SetTriggersCreep(false)
    inst.components.locomotor.pathcaps = { ignorecreep = false }
    inst.components.locomotor.walkspeed = 9

    inst:AddComponent("combat")
    inst.components.combat:SetAttackPeriod(5)
    inst.components.combat:SetRange(8)
    inst.components.combat:SetKeepTargetFunction(KeepTarget)
    inst.components.combat:SetDefaultDamage(30)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    inst:ListenForEvent("attacked", OnAttacked)

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(200)
    inst.components.health.canmurder = false

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('slurper')
	-- inst:AddComponent("eater")
	-- inst.components.eater:SetVegetarian()
	-- inst.components.eater:SetOnEatFn(oneat)

 	local light = inst.entity:AddLight()

    inst:AddComponent("lighttweener")
    inst.components.lighttweener:StartTween(light, 1, 0.5, 0.7, {237/255, 237/255, 209/255}, 0)
    light:Enable(true)

	inst:AddComponent("sleeper")
	inst.components.sleeper:SetSleepTest(SleepTest)
	inst.components.sleeper:SetWakeTest(WakeTest)
	--inst.components.sleeper:SetNocturnal()

	local brain = require "brains/slurperbrain"
	inst:SetBrain(brain)
	inst:SetStateGraph("SGslurper")

    inst:AddComponent("knownlocations")    

	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_SMALL

    inst.HatTest = CanHatTarget

    inst.cansleep = true

    inst:DoTaskInTime(1*FRAMES, function() inst.components.knownlocations:RememberLocation("home", Vector3(inst.Transform:GetWorldPosition()), true) end)

	return inst
end

return Prefab("cave/monsters/slurper", fn, assets, prefabs)
