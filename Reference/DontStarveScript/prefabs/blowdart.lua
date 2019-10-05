local assets=
{
	Asset("ANIM", "anim/blow_dart.zip"),
	Asset("ANIM", "anim/swap_blowdart.zip"),
	Asset("ANIM", "anim/swap_blowdart_pipe.zip"),
}

local prefabs = 
{
    "impact",
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_blowdart", "swap_blowdart")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_object")
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end

local function onhit(inst, attacker, target)
    local impactfx = SpawnPrefab("impact")
    if impactfx and attacker then
	    local follower = impactfx.entity:AddFollower()
	    follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0 )
        impactfx:FacePoint(attacker.Transform:GetWorldPosition())
    end
    inst:Remove()
end

local function onthrown(inst, data)
    inst.AnimState:SetOrientation( ANIM_ORIENTATION.OnGround )
end

local function common()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("blow_dart")
    anim:SetBuild("blow_dart")
    
    inst:AddTag("blowdart")
    inst:AddTag("sharp")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(0)
    inst.components.weapon:SetRange(8, 10)
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(60)
    inst.components.projectile:SetOnHitFn(onhit)
    inst:ListenForEvent("onthrown", onthrown)
    -------
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("stackable")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)
    inst.components.equippable.equipstack = true
    
    return inst
end

local function sleepthrown(inst)
    inst.AnimState:PlayAnimation("dart_purple")
end
local function sleepcanattack(inst, target)
    return target.components.sleeper
end
local function sleepattack(inst, attacker, target)
    if target.components.sleeper and not (inst.components.freezable and inst.components.freezable:IsFrozen() ) then
        target.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_impact_sleep")
        target.components.sleeper:AddSleepiness(1, 15)
        if target.components.combat then
            target.components.combat:SuggestTarget(attacker)
        end
        if target.sg and not target.sg:HasStateTag("sleeping") and target.sg.sg.states.hit then
            target.sg:GoToState("hit")
        end
    end
end
local function sleep()
    local inst = common()
    
    inst:AddTag("sleepdart")
    inst.AnimState:PlayAnimation("idle_purple")
    inst.components.weapon:SetOnAttack(sleepattack)
    inst.components.weapon:SetCanAttack(sleepcanattack)
    inst.components.projectile:SetOnThrownFn(sleepthrown)
   
    return inst
end

local function firethrown(inst)
    inst.AnimState:PlayAnimation("dart_red")
end
-- local function firecanattack(inst, target)
--     return target.components.burnable and not target.components.burnable:IsBurning()
-- end
local function fireattack(inst, attacker, target)
    target.SoundEmitter:PlaySound("dontstarve/wilson/blowdart_impact_fire")
    target:PushEvent("attacked", {attacker = attacker, damage = 0})
    if target.components.burnable then
        target.components.burnable:Ignite()
    end
    if target.components.freezable then
        target.components.freezable:Unfreeze()
    end
    if target.components.health then
        target.components.health:DoFireDamage(0)
    end
    if target.components.combat then
        target.components.combat:SuggestTarget(attacker)
    end
    if target.sg and target.sg.sg.states.hit then
        target.sg:GoToState("hit")
    end
end

local function fire()
    local inst = common()

    inst:AddTag("firedart")
    inst.AnimState:PlayAnimation("idle_red")
    inst.components.weapon:SetOnAttack(fireattack)
    --inst.components.weapon:SetCanAttack(firecanattack)
    inst.components.projectile:SetOnThrownFn(firethrown)
    
    return inst
end

local function pipeequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_blowdart_pipe", "swap_blowdart_pipe")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function pipethrown(inst)
    inst.AnimState:PlayAnimation("dart_pipe")
end

local function pipe()
    local inst = common()

    inst.AnimState:PlayAnimation("idle_pipe")

    inst.components.equippable:SetOnEquip(pipeequip)
    inst.components.weapon:SetDamage(TUNING.PIPE_DART_DAMAGE)
    inst.components.projectile:SetOnThrownFn(pipethrown)
    
    return inst
end

local function OnWalrusDartMiss(inst, owner, target)
    inst:Remove()
end

-- walrus blowdart is for use by walrus creature, not player
local function walrus()
    local inst = common()
    inst.persists = false

    inst:AddTag("noclick")

    RemovePhysicsColliders(inst)

    inst.AnimState:PlayAnimation("idle_pipe")

    inst.components.projectile:SetOnThrownFn(pipethrown)
    inst.components.projectile:SetRange(TUNING.WALRUS_DART_RANGE)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetOnMissFn(OnWalrusDartMiss)
    inst.components.projectile:SetLaunchOffset(Vector3(3, 2, 0))
    
    return inst
end

return Prefab( "common/inventory/blowdart_sleep", sleep, assets, prefabs),
       Prefab( "common/inventory/blowdart_fire", fire, assets, prefabs),
       Prefab( "common/inventory/blowdart_pipe", pipe, assets, prefabs),
       Prefab( "common/inventory/blowdart_walrus", walrus, assets, prefabs) 
