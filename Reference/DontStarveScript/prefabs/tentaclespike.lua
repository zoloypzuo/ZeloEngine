local assets=
{
	Asset("ANIM", "anim/tentacle_spike.zip"),
	Asset("ANIM", "anim/swap_spike.zip"),
    Asset("INV_IMAGE", "tentaclespike"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_spike", "swap_spike")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
end


local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("spike")
    anim:SetBuild("tentacle_spike")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SPIKE_DAMAGE)
    
    -------
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SPIKE_USES)
    inst.components.finiteuses:SetUses(TUNING.SPIKE_USES)
    
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

return Prefab( "common/inventory/tentaclespike", fn, assets) 
