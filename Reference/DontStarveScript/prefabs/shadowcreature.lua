require "brains/shadowcreaturebrain"
require "stategraphs/SGshadowcreature"

local prefabs =
{
    "nightmarefuel",
}

local function retargetfn(inst)
    local entity = FindEntity(inst, TUNING.SHADOWCREATURE_TARGET_DIST, function(guy) 
		return guy:HasTag("player") and guy.components.sanity:IsCrazy() and inst.components.combat:CanTarget(guy)
    end)
    return entity
end

local function onkilledbyother(inst, attacker)
	if attacker and attacker.components.sanity then
		attacker.components.sanity:DoDelta(inst.sanityreward or TUNING.SANITY_SMALL)
	end
end

SetSharedLootTable( 'shadow_creature',
{
    {'nightmarefuel',  1.0},
    {'nightmarefuel',  0.5},
})

local function CalcSanityAura(inst, observer)
	if inst.components.combat.target then
		return -TUNING.SANITYAURA_LARGE
	end	
	return 0
end

local function canbeattackedfn(inst, attacker)
	return inst.components.combat.target ~= nil or
		(attacker and attacker.components.sanity and attacker.components.sanity:IsCrazy())
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, 30, function(dude) return dude:HasTag("shadowcreature") and not dude.components.health:IsDead() end, 1)
end

local function MakeShadowCreature(data)

    local bank = data.bank 
    local build = data.build 
    
    local assets=
    {
	    Asset("ANIM", "anim/"..data.build..".zip"),
    }
    
    local sounds = 
    {
        attack = "dontstarve/sanity/creature"..data.num.."/attack",
        attack_grunt = "dontstarve/sanity/creature"..data.num.."/attack_grunt",
        death = "dontstarve/sanity/creature"..data.num.."/die",
        idle = "dontstarve/sanity/creature"..data.num.."/idle",
        taunt = "dontstarve/sanity/creature"..data.num.."/taunt",
        appear = "dontstarve/sanity/creature"..data.num.."/appear",
        disappear = "dontstarve/sanity/creature"..data.num.."/dissappear",
    }

    local function fn()
	    local inst = CreateEntity()
	    local trans = inst.entity:AddTransform()
	    local anim = inst.entity:AddAnimState()
        local physics = inst.entity:AddPhysics()
	    local sound = inst.entity:AddSoundEmitter()
        inst.Transform:SetFourFaced()
        inst:AddTag("shadowcreature")
    	
        MakeCharacterPhysics(inst, 10, 1.5)
        RemovePhysicsColliders(inst)
	    inst.Physics:SetCollisionGroup(COLLISION.SANITY)
	    inst.Physics:CollidesWith(COLLISION.SANITY)
	    inst.Physics:CollidesWith(COLLISION.WORLD)
        
         
        anim:SetBank(bank)
        anim:SetBuild(build)
        anim:PlayAnimation("idle_loop")
        anim:SetMultColour(1, 1, 1, 0.5)
        inst:AddComponent("locomotor") -- locomotor must be constructed before the stategraph
        inst.components.locomotor.walkspeed = data.speed
        inst.sounds = sounds
        inst:SetStateGraph("SGshadowcreature")

        inst:AddTag("monster")
	    inst:AddTag("hostile")
        inst:AddTag("shadow")
        inst:AddTag("notraptrigger")

        local brain = require "brains/shadowcreaturebrain"
        inst:SetBrain(brain)
        
	    inst:AddComponent("sanityaura")
	    inst.components.sanityaura.aurafn = CalcSanityAura
        
        inst:AddComponent("transparentonsanity")
        inst:AddComponent("health")
        inst.components.health:SetMaxHealth(data.health)
        
		inst.sanityreward = data.sanityreward
		
        inst:AddComponent("combat")
        inst.components.combat:SetDefaultDamage(data.damage)
        inst.components.combat:SetAttackPeriod(data.attackperiod)
        inst.components.combat:SetRetargetFunction(3, retargetfn)
        inst.components.combat.onkilledbyother = onkilledbyother
        inst.components.combat.canbeattackedfn = canbeattackedfn

        inst:AddComponent("lootdropper")
        inst.components.lootdropper:SetChanceLootTable('shadow_creature')
        
        inst:ListenForEvent("attacked", OnAttacked)

        return inst
    end
        
    return Prefab("monsters/"..data.name, fn, assets, prefabs)
end


local data = {{name="crawlinghorror", build = "shadow_insanity1_basic", bank = "shadowcreature1", num = 1, speed = TUNING.CRAWLINGHORROR_SPEED, health=TUNING.CRAWLINGHORROR_HEALTH, damage=TUNING.CRAWLINGHORROR_DAMAGE, attackperiod = TUNING.CRAWLINGHORROR_ATTACK_PERIOD, sanityreward = TUNING.SANITY_MED},
			  {name="terrorbeak", build = "shadow_insanity2_basic", bank = "shadowcreature2", num = 2, speed = TUNING.TERRORBEAK_SPEED, health=TUNING.TERRORBEAK_HEALTH, damage=TUNING.TERRORBEAK_DAMAGE, attackperiod = TUNING.TERRORBEAK_ATTACK_PERIOD, sanityreward = TUNING.SANITY_LARGE}}

local ret = {}
for k,v in pairs(data) do
	table.insert(ret, MakeShadowCreature(v))
end


return unpack(ret) 
