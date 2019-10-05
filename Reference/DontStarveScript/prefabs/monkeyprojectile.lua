local assets=
{
	Asset("ANIM", "anim/monkey_projectile.zip"),
}

local prefabs =
{
    "poop",
}

local function OnHit(inst, owner, target)
    local pt = Vector3(inst.Transform:GetWorldPosition())

    if target.components.sanity then
        target.components.sanity:DoDelta(-TUNING.SANITY_SMALL)
    end

    local poop = SpawnPrefab("poop")
    poop.Transform:SetPosition(pt.x, pt.y, pt.z)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/monkey/poopsplat")

    if target.sg and not target.sg:HasStateTag("frozen") and target.sg.sg.states.hit then
        target.sg:GoToState("hit")
    end

    inst:Remove()
end

local function OnMiss(inst, owner, target)
    local pt = Vector3(inst.Transform:GetWorldPosition())

    local poop = SpawnPrefab("poop")
    poop.Transform:SetPosition(pt.x, pt.y, pt.z)

    inst.SoundEmitter:PlaySound("dontstarve/creatures/monkey/poopsplat")

    inst:Remove()
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    local sound = inst.entity:AddSoundEmitter()
	inst.Transform:SetFourFaced()

    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)
    
    anim:SetBank("monkey_projectile")
    anim:SetBuild("monkey_projectile")
    anim:PlayAnimation("idle")
    
    inst:AddTag("projectile")
    inst.persists = false
    
    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(25)
    inst.components.projectile:SetHoming(false)
    inst.components.projectile:SetHitDist(1.5)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(OnMiss)
    inst.components.projectile.range = 30
    
    return inst
end

return Prefab( "common/inventory/monkeyprojectile", fn, assets, prefabs) 
