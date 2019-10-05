local assets=
{
	Asset("ANIM", "anim/axe.zip"),
	Asset("ANIM", "anim/goldenaxe.zip"),
	Asset("ANIM", "anim/swap_axe.zip"),
	Asset("ANIM", "anim/swap_goldenaxe.zip"),
    Asset("INV_IMAGE", "axe"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_axe", "swap_axe")
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
    
    anim:SetBank("axe")
    anim:SetBuild("axe")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.AXE_DAMAGE)

    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.CHOP)
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.AXE_USES)
    inst.components.finiteuses:SetUses(TUNING.AXE_USES)
    inst.components.finiteuses:SetOnFinished( onfinished)
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1)
    -------
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")

    inst.components.equippable:SetOnEquip( onequip )
    
    inst.components.equippable:SetOnUnequip( onunequip)

    
    return inst
end

local function onequipgold(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_goldenaxe", "swap_goldenaxe")
	owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")     
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end
    
local function golden(Sim)
	local inst = fn(Sim)
	inst.AnimState:SetBuild("goldenaxe")
	inst.AnimState:SetBank("goldenaxe")
    inst.components.finiteuses:SetConsumption(ACTIONS.CHOP, 1 / TUNING.GOLDENTOOLFACTOR)
    inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR
    inst.components.equippable:SetOnEquip( onequipgold )
    
	return inst
end

return Prefab( "common/inventory/axe", fn, assets),
	   Prefab( "common/inventory/goldenaxe", golden, assets) 

