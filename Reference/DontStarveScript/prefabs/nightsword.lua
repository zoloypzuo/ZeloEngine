local assets=
{
	Asset("ANIM", "anim/nightmaresword.zip"),
	Asset("ANIM", "anim/swap_nightmaresword.zip"),
    
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_nightmaresword", "swap_nightmaresword")
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
    
    inst.AnimState:SetBank("nightmaresword")
    inst.AnimState:SetBuild("nightmaresword")
    inst.AnimState:PlayAnimation("idle")
    inst.AnimState:SetMultColour(1, 1, 1, 0.6)
    
    inst:AddTag("shadow")
    inst:AddTag("sharp")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.NIGHTSWORD_DAMAGE)
    
    -------
    
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.NIGHTSWORD_USES)
    inst.components.finiteuses:SetUses(TUNING.NIGHTSWORD_USES)
    
    inst.components.finiteuses:SetOnFinished( onfinished )

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst:AddComponent("dapperness")
    inst.components.dapperness.dapperness = TUNING.CRAZINESS_MED,
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

return Prefab( "common/inventory/nightsword", fn, assets) 
