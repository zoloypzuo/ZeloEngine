require "stategraphs/SGtentacle"

local assets=
{
	Asset("ANIM", "anim/tentacle.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
}

local prefabs =
{
    "monstermeat",
    "tentaclespike",
    "tentaclespots",
}

SetSharedLootTable( 'tentacle',
{
    {'monstermeat',   1.0},
    {'monstermeat',   1.0},
    {'tentaclespike', 0.5},
    {'tentaclespots', 0.2},
})

local function retargetfn(inst)
    return FindEntity(inst, TUNING.TENTACLE_ATTACK_DIST, function(guy) 
        if guy.components.combat and guy.components.health and not guy.components.health:IsDead() then
            return (guy.components.combat.target == inst or guy:HasTag("character") or guy:HasTag("monster") or guy:HasTag("animal")) and not guy:HasTag("prey") and not (guy.prefab == inst.prefab)
        end
    end)
end


local function shouldKeepTarget(inst, target)
    if target and target:IsValid() and target.components.health and not target.components.health:IsDead() then
        local distsq = target:GetDistanceSqToInst(inst)
        return distsq < TUNING.TENTACLE_STOPATTACK_DIST*TUNING.TENTACLE_STOPATTACK_DIST
    else
        return false
    end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.Physics:SetCylinder(0.25,2)
    
    inst.AnimState:SetBank("tentacle")
    inst.AnimState:SetBuild("tentacle")
    inst.AnimState:PlayAnimation("idle")
 	inst.entity:AddSoundEmitter()

    inst:AddTag("monster")    
    inst:AddTag("hostile")
    inst:AddTag("wet")
    inst:AddTag("WORM_DANGER")    

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_HEALTH)
    
    
    inst:AddComponent("combat")
    inst.components.combat:SetRange(TUNING.TENTACLE_ATTACK_DIST)
    inst.components.combat:SetDefaultDamage(TUNING.TENTACLE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TENTACLE_ATTACK_PERIOD)
    inst.components.combat:SetRetargetFunction(GetRandomWithVariance(2, 0.5), retargetfn)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    
    MakeLargeFreezableCharacter(inst)
    
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED
    
    
    inst:AddComponent("inspectable")
    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetChanceLootTable('tentacle')
    
    inst:SetStateGraph("SGtentacle")

    inst:AddComponent("hiddendanger")

    return inst
end

return Prefab( "marsh/monsters/tentacle", fn, assets, prefabs) 
