local assets=
{
	Asset("ANIM", "anim/eyeball_turret_attack.zip"),
    --Asset("SOUND", "sound/eyeballturret.fsb"),
}

local function OnHit(inst, owner, target)
    inst:Remove()
    inst.SoundEmitter:PlaySound("dontstarve/creatures/eyeballturret/shotexplo")
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("eyeball_turret_attack")
    anim:SetBuild("eyeball_turret_attack")
    anim:PlayAnimation("idle")
    
    inst:AddTag("projectile")
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
    
    return inst
end

return Prefab( "common/inventory/eye_charge", fn, assets) 
