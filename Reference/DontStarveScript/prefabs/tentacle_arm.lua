require "stategraphs/SGtentacle_arm"

-- TODO
--      change gotoState to eventpush
--      move newcombat event handling to stategraph
--      unset persistant flag
local assets=
{
	Asset("ANIM", "anim/tentacle_arm.zip"),
    Asset("ANIM", "anim/tentacle_arm_build.zip"),

    Asset("SOUND", "sound/tentacle.fsb"),
}

local prefabs =
{
    "monstermeat",
}

local function retargetfn(inst)
    return FindEntity(inst, TUNING.TENTACLE_PILLAR_ARM_ATTACK_DIST, function(guy) 
        if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
            return (   guy:HasTag("character")
                    or guy:HasTag("monster")
                    or guy:HasTag("animal"))
                    and not guy:HasTag("WORM_DANGER")
                    and not guy:HasTag("prey")
                    and not (guy.prefab == inst.prefab)
        end
    end)
end

local function onfar(inst)
    inst:PushEvent("retract")
end

local function onnear(inst)
    inst:PushEvent("emerge")
    Dbg(inst,true,"ON NEAR - emerge")
    --[[ Very bad practice to directly set a state from outside the statemachine!
    if inst.sg:HasStateTag("idle")  and not inst.sg:HasStateTag("emerge")
       and not inst.sg:HasStateTag("attack") and not inst.components.health:IsDead() then
        inst.sg:GoToState("emerge")
    end
    --]]
end

local function shouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        --dprint(TUNING.TENTACLE_PILLAR_ARM_STOPATTACK_DIST," shouldkeeptarget:",distsq<TUNING.TENTACLE_PILLAR_ARM_STOPATTACK_DIST*TUNING.TENTACLE_PILLAR_ARM_STOPATTACK_DIST)
        
        return distsq < TUNING.TENTACLE_PILLAR_ARM_STOPATTACK_DIST*TUNING.TENTACLE_PILLAR_ARM_STOPATTACK_DIST
    else
        return false
    end
end

local function OnHit(inst, attacker, damage) 

    if attacker.components.combat and attacker ~= GetPlayer() and math.random() > 0.5 then
        -- Followers should stop hitting the pillar
        attacker.components.combat:SetTarget(nil)
        if inst.components.health.currenthealth and inst.components.health.currenthealth < 0 then
            inst.components.health:DoDelta(damage*.6, false, attacker)
        end
    end
end

local function fn(Sim)
    local ARM_SCALE = 0.95
	local inst = CreateEntity()

	inst.persists = false           -- don't need to save these
    inst.entity:AddTransform()
    inst.Transform:SetScale(ARM_SCALE, ARM_SCALE, ARM_SCALE)

    inst.entity:AddPhysics()
    inst.Physics:SetCylinder(0.6,2)
    
	inst.entity:AddAnimState()
    inst.AnimState:SetBank("tentacle_arm")
    inst.AnimState:SetScale(ARM_SCALE,ARM_SCALE)
    inst.AnimState:SetBuild("tentacle_arm_build")
    inst.AnimState:PlayAnimation("breach_pre")
 	inst.entity:AddSoundEmitter()
    -- inst.AnimState:SetMultColour(.2, 1, .2, 1.0)

    inst:AddTag("monster")    
    inst:AddTag("hostile")
    inst:AddTag("wet")
    inst:AddTag("WORM_DANGER")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_PILLAR_ARM_HEALTH)
    
    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.TENTACLE_PILLAR_ARM_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.TENTACLE_PILLAR_ARM_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TENTACLE_PILLAR_ARM_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(1, 0.5), retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    inst.components.combat:SetOnHit(OnHit)
    
    MakeLargeFreezableCharacter(inst)
    
    inst:AddComponent("playerprox")
    inst.components.playerprox:SetDist(4, 15)
    inst.components.playerprox:SetOnPlayerNear(onnear)
    inst.components.playerprox:SetOnPlayerFar(onfar)

	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    -- inst.components.lootdropper:SetLoot({"monstermeat", "monstermeat"})
    -- inst.components.lootdropper:AddChanceLoot("tentaclespike", 0.5)
    -- inst.components.lootdropper:AddChanceLoot("tentaclespots", 0.2)
    
    inst:SetStateGraph("SGtentacle_arm")

    return inst
end

return Prefab( "cave/monsters/tentacle_pillar_arm", fn, assets, prefabs )

