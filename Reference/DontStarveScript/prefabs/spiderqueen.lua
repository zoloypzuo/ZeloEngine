require "brains/spiderqueenbrain"
require "stategraphs/SGspiderqueen"

local assets =
{
	Asset("ANIM", "anim/spider_queen_build.zip"),
	Asset("ANIM", "anim/spider_queen.zip"),
	Asset("ANIM", "anim/spider_queen_2.zip"),
	--Asset("ANIM", "anim/spider_queen_3.zip"),
	--Asset("SOUND", "sound/spider.fsb"),
}

local prefabs =
{
    "monstermeat",
    "silk",
    "spiderhat",
    "spidereggsack",
}

local loot =
{
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "monstermeat",
    "silk",
    "silk",
    "silk",
    "silk",
    "spidereggsack",
    "spiderhat",
}

local SHARE_TARGET_DIST = 30

local function Retarget(inst)
    if not inst.components.health:IsDead() and not inst.components.sleeper:IsAsleep() then
        local oldtarget = inst.components.combat.target

        local newtarget = FindEntity(inst, 10, 
            function(guy) 
                if inst.components.combat:CanTarget(guy) then
                    return guy:HasTag("character")
                end
            end)
        
        if newtarget and newtarget ~= oldtarget then
			inst.components.combat:SetTarget(newtarget)
        end
    end
end

local function OnAttacked(inst, data)
    inst.components.combat:SetTarget(data.attacker)
    inst.components.combat:ShareTarget(data.attacker, SHARE_TARGET_DIST, function(dude) return dude.prefab == "spiderqueen" and not dude.components.health:IsDead() end, 2)
end
    
local function fn(Sim)
	local inst = CreateEntity()

    inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
	inst.entity:AddLightWatcher()
	local shadow = inst.entity:AddDynamicShadow()
	shadow:SetSize( 7, 3 )
    inst.Transform:SetFourFaced()
    
    
    ----------
    
    inst:AddTag("monster")
    inst:AddTag("hostile")
    inst:AddTag("epic")    
    inst:AddTag("largecreature")
    inst:AddTag("spiderqueen")    
    inst:AddTag("spider")    
    
    MakeCharacterPhysics(inst, 1000, 1)

    
    inst.AnimState:SetBank("spider_queen")
    inst.AnimState:SetBuild("spider_queen_build")
    inst.AnimState:PlayAnimation("idle", true)
    
    inst:SetStateGraph("SGspiderqueen")
    
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot(loot)
    
    ---------------------        
    MakeLargeBurnableCharacter(inst, "body")
    MakeLargeFreezableCharacter(inst, "body")
    inst.components.burnable.flammability = TUNING.SPIDER_FLAMMABILITY
    ---------------------       
    
    
    ------------------
    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.SPIDERQUEEN_HEALTH)

    ------------------
    
    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.SPIDERQUEEN_ATTACKRANGE)
    inst.components.combat:SetDefaultDamage(TUNING.SPIDERQUEEN_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.SPIDERQUEEN_ATTACKPERIOD)
    inst.components.combat:SetRetargetFunction(3, Retarget)
    
    ------------------

	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_HUGE

   
    ------------------
    
    inst:AddComponent("sleeper")
    inst.components.sleeper:SetResistance(4)
    ------------------
    
    inst:AddComponent("locomotor")
	inst.components.locomotor:SetSlowMultiplier( 1 )
	inst.components.locomotor:SetTriggersCreep(false)
	inst.components.locomotor.pathcaps = { ignorecreep = true }
	inst.components.locomotor.walkspeed = TUNING.SPIDERQUEEN_WALKSPEED

    ------------------
    
    inst:AddComponent("eater")
    inst.components.eater:SetCarnivore()
    inst.components.eater:SetCanEatHorrible()
    inst.components.eater.strongstomach = true -- can eat monster meat!
    
    ------------------
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("leader")
    
    ------------------
    
    local brain = require "brains/spiderqueenbrain"
    inst:SetBrain(brain)

    inst:ListenForEvent("attacked", OnAttacked)

    return inst
end


return Prefab( "forest/monsters/spiderqueen", fn, assets, prefabs) 
    
