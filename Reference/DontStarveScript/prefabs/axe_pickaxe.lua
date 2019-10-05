local assets=
{
	Asset("ANIM", "anim/multitool_axe_pickaxe.zip"),
	Asset("ANIM", "anim/swap_multitool_axe_pickaxe.zip"),
    Asset("INV_IMAGE", "multitool_axe_pickaxe"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_multitool_axe_pickaxe", "swap_object")
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
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("multitool_axe_pickaxe")
    anim:SetBuild("multitool_axe_pickaxe")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.MULTITOOL_DAMAGE)
    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP, 1.33)
    inst.components.tool:SetAction(ACTIONS.MINE, 1.33)
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.MULTITOOL_AXE_PICKAXE_USES)
    inst.components.finiteuses:SetUses(TUNING.MULTITOOL_AXE_PICKAXE_USES)
    inst.components.finiteuses:SetOnFinished( onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE, 3)
    -------
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip( onequip )
    
    inst.components.equippable:SetOnUnequip( onunequip)

    
    return inst
end

return Prefab( "common/inventory/multitool_axe_pickaxe", fn, assets)