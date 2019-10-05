local assets=
{
	Asset("ANIM", "anim/fishingrod.zip"),
	Asset("ANIM", "anim/swap_fishingrod.zip"),
}

local function onfinished(inst)
    inst:Remove()
end
    

local function onequip (inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_fishingrod", "swap_fishingrod")
    owner.AnimState:OverrideSymbol("fishingline", "swap_fishingrod", "fishingline")
    owner.AnimState:OverrideSymbol("FX_fishing", "swap_fishingrod", "FX_fishing")
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal")
    owner.AnimState:ClearOverrideSymbol("fishingline")
    owner.AnimState:ClearOverrideSymbol("FX_fishing")
end

local function onfished(inst)
    if inst.components.finiteuses then
        inst.components.finiteuses:Use(1)
    end
end

    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("fishingrod")
    anim:SetBuild("fishingrod")
    anim:PlayAnimation("idle")
    
    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.FISHINGROD_DAMAGE)
    inst.components.weapon.attackwear = 4
    -----
    inst:AddComponent("fishingrod")
    inst.components.fishingrod:SetWaitTimes(4, 40)
    inst.components.fishingrod:SetStrainTimes(0, 5)
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.FISHINGROD_USES)
    inst.components.finiteuses:SetUses(TUNING.FISHINGROD_USES)
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst:ListenForEvent("fishingcollect", onfished)

    ---------
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    
    inst.components.equippable:SetOnUnequip( onunequip )
    
    
    return inst
end

return Prefab( "common/inventory/fishingrod", fn, assets) 
