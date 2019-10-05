local assets=
{
	Asset("ANIM", "anim/cane.zip"),
	Asset("ANIM", "anim/swap_cane.zip"),
    Asset("INV_IMAGE", "cane"),
    
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_cane", "swap_cane")
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
    
    anim:SetBank("cane")
    anim:SetBuild("cane")
    anim:PlayAnimation("idle")
    
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.CANE_DAMAGE)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    inst.components.equippable.walkspeedmult = TUNING.CANE_SPEED_MULT
    
    return inst
end


return Prefab( "common/inventory/cane", fn, assets) 

