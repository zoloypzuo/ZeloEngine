local assets=
{
	Asset("ANIM", "anim/bishop_projectile_yellow.zip"),
	Asset("SOUND", "sound/chess.fsb"),
}

local function OnHit(inst, owner, target)
    inst.SoundEmitter:PlaySound("dontstarve/creatures/bishop/shotexplo")
    inst.AnimState:PlayAnimation("impact")
    inst.Physics:Stop() 
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)    
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	inst.Transform:SetFourFaced()
	local anim = inst.entity:AddAnimState()
	local sound = inst.entity:AddSoundEmitter()
	
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("bishop_projectile_yellow")
    anim:SetBuild("bishop_projectile_yellow")
    anim:PlayAnimation("idle")
    
    inst:AddTag("projectile")

    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(30)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(2)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnHit)
    inst.components.projectile:SetLaunchOffset({x=1,y=1,z=0})
    
    return inst
end

return Prefab( "common/inventory/fryfocals_charge", fn, assets) 
