require "stategraphs/SGshadowtentacle"

local assets=
{
	Asset("ANIM", "anim/tentacle_arm.zip"),
    Asset("ANIM", "anim/tentacle_arm_black_build.zip"),
    Asset("SOUND", "sound/tentacle.fsb"),
}

local function shouldKeepTarget(inst, target)
    return true
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    inst.entity:AddPhysics()
    inst.Physics:SetCylinder(0.25,2)
    
    inst.Transform:SetScale(0.5, 0.5, 0.5)

    inst.AnimState:SetMultColour(1,1,1,0.5)

    inst.AnimState:SetBank("tentacle_arm")
    inst.AnimState:SetBuild("tentacle_arm_black_build")
    inst.AnimState:PlayAnimation("idle", true)
 	inst.entity:AddSoundEmitter()

    inst:AddTag("shadow")
    inst:AddTag("notarget")

    inst:AddComponent("health")
    inst.components.health:SetMaxHealth(TUNING.TENTACLE_HEALTH)
    
    inst:AddComponent("combat")
    inst.components.combat:SetRange(2)
    inst.components.combat:SetDefaultDamage(TUNING.TENTACLE_DAMAGE)
    inst.components.combat:SetAttackPeriod(TUNING.TENTACLE_ATTACK_PERIOD)
    inst.components.combat:SetKeepTargetFunction(shouldKeepTarget)
    inst.components.combat.canbeattackedfn = function() return false end
    
    MakeLargeFreezableCharacter(inst)
    
	inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = -TUNING.SANITYAURA_MED

    inst:AddComponent("lootdropper")
    inst.components.lootdropper:SetLoot({})
    
    inst:SetStateGraph("SGshadowtentacle")

    inst:DoTaskInTime(9, function() inst:Remove() end)

    return inst
end

return Prefab( "cave/ruins/shadowtentacle", fn, assets)