local assets=
{
	Asset("ANIM", "anim/pickaxe.zip"),
	Asset("ANIM", "anim/goldenpickaxe.zip"),
	Asset("ANIM", "anim/swap_pickaxe.zip"),
	Asset("ANIM", "anim/swap_goldenpickaxe.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_pickaxe", "swap_pickaxe")
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
    
    anim:SetBank("pickaxe")
    anim:SetBuild("pickaxe")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")
    
    -----
    inst:AddComponent("tool")
    inst.components.tool:SetAction(ACTIONS.MINE)
    -------
    inst:AddComponent("finiteuses")
    
    inst.components.finiteuses:SetMaxUses(TUNING.PICKAXE_USES)
    inst.components.finiteuses:SetUses(TUNING.PICKAXE_USES)
    inst.components.finiteuses:SetOnFinished( onfinished) 
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE, 1)
    -------
    
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.PICK_DAMAGE)
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    
    return inst
end


local function onequipgold(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_goldenpickaxe", "swap_goldenpickaxe")
	owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")     
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function golden(Sim)
	local inst = fn(Sim)
	inst.AnimState:SetBuild("goldenpickaxe")
	inst.AnimState:SetBank("goldenpickaxe")
    inst.components.finiteuses:SetConsumption(ACTIONS.MINE, 1 / TUNING.GOLDENTOOLFACTOR)
    inst.components.weapon.attackwear = 1 / TUNING.GOLDENTOOLFACTOR
    
    inst.components.equippable:SetOnEquip( onequipgold )
    
	return inst
end


return Prefab( "common/inventory/pickaxe", fn, assets),
		Prefab( "common/inventory/goldenpickaxe", golden, assets) 

