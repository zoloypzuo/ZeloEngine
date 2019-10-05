local assets=
{
	Asset("ANIM", "anim/shovel.zip"),
	Asset("ANIM", "anim/goldenshovel.zip"),
	Asset("ANIM", "anim/swap_shovel.zip"),
	Asset("ANIM", "anim/swap_goldenshovel.zip"),
}
    
local function onfinished(inst)
    inst:Remove()
end
    
local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_shovel", "swap_shovel")
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
    
    anim:SetBank("shovel")
    anim:SetBuild("shovel")
    anim:PlayAnimation("idle")
    
    
    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.DIG)
    
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SHOVEL_USES)
    inst.components.finiteuses:SetUses(TUNING.SHOVEL_USES)
    inst.components.finiteuses:SetOnFinished( onfinished) 
    inst.components.finiteuses:SetConsumption(ACTIONS.DIG, 1)
    -------
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SHOVEL_DAMAGE)
    
    inst:AddInherentAction(ACTIONS.DIG)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    
    return inst
end

local function onequipgold(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_goldenshovel", "swap_goldenshovel")
	owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")     
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end


local function golden(Sim)
	local inst = fn(Sim)
	inst.AnimState:SetBuild("goldenshovel")
	inst.AnimState:SetBank("goldenshovel")
    inst.components.finiteuses:SetConsumption(ACTIONS.DIG, 1 / TUNING.GOLDENTOOLFACTOR)
    inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, .125 / TUNING.GOLDENTOOLFACTOR)
    inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR
    
    inst.components.equippable:SetOnEquip( onequipgold )
    
	return inst
end


return Prefab( "common/inventory/shovel", fn, assets),
	   Prefab( "common/inventory/goldenshovel", golden, assets) 

