local assets=
{
	Asset("ANIM", "anim/staff_projectile.zip"),
}

local function OnHit(inst, owner, target)
    inst:Remove()
end

local function common()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("projectile")
    anim:SetBuild("staff_projectile")
    
    inst:AddTag("projectile")
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(50)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
    
    return inst
end

local function ice()
    local inst = common()
    inst.AnimState:PlayAnimation("ice_spin_loop", true)
    return inst
end

local function fire()
    local inst = common()
    inst.AnimState:PlayAnimation("fire_spin_loop", true)
	inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
    --colour projectile
    --inst.AnimState:SetMultColour(0, 0, 0, 1)
    return inst
end

return Prefab( "common/inventory/ice_projectile", ice, assets), 
       Prefab("common/inventory/fire_projectile", fire, assets) 
