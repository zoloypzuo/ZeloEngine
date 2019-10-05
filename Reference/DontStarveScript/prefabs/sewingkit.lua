local assets=
{
	Asset("ANIM", "anim/sewing_kit.zip"),
}

local function onfinished(inst)
	inst:Remove()
end


local function onsewn(inst, target, doer)
	if doer.SoundEmitter then
		doer.SoundEmitter:PlaySound("dontstarve/HUD/repair_clothing")
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("sewing_kit")
    inst.AnimState:SetBuild("sewing_kit")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SEWINGKIT_USES)
    inst.components.finiteuses:SetUses(TUNING.SEWINGKIT_USES)
    inst.components.finiteuses:SetOnFinished( onfinished )
    
    inst:AddComponent("sewing")
    inst.components.sewing.repair_value = TUNING.SEWINGKIT_REPAIR_VALUE
    inst.components.sewing.onsewn = onsewn
    ---------------------       
    
    
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    return inst
end

return Prefab( "common/inventory/sewing_kit", fn, assets) 

