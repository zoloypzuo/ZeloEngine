local assets=
{
	Asset("ANIM", "anim/spider_spit.zip"),
}

local prefabs =
{
    "spider_web_spit_creep",
    "splash_spiderweb"
}

local function OnHit(inst, owner, target)
    local pt = Vector3(inst.Transform:GetWorldPosition())
    inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("spider_spit")
    anim:SetBuild("spider_spit")
    anim:PlayAnimation("idle")
    
    inst:AddTag("projectile")
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(20)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
    
    return inst
end

return Prefab( "common/inventory/spider_web_spit", fn, assets, prefabs) 
