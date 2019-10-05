local assets=
{
	Asset("ANIM", "anim/armor_grass.zip"),
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour") 
end


local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_grass", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
end

local function fn(Sim)
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("armor_grass")
    inst.AnimState:SetBuild("armor_grass")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddTag("grass")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/grassarmour"

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORGRASS, TUNING.ARMORGRASS_ABSORPTION)
    
    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end


return Prefab( "common/inventory/armorgrass", fn, assets) 
