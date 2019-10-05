local assets=
{
	Asset("ANIM", "anim/armor_slurper.zip"),
}

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_slurper", "swap_body")
    if owner.components.hunger then
        owner.components.hunger.burnrate = TUNING.ARMORSLURPER_SLOW_HUNGER
    end

    inst.components.fueled:StartConsuming()
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if owner.components.hunger then
        owner.components.hunger.burnrate = 1
    end

    inst.components.fueled:StopConsuming()
end

local function onperish(inst)
    inst:Remove()
end

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("armor_slurper")
    inst.AnimState:SetBuild("armor_slurper")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddTag("fur")
    inst:AddTag("ruins")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/fur"
    
    inst:AddComponent("dapperness")
    inst.components.dapperness.dapperness = TUNING.DAPPERNESS_SMALL

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "USAGE"
    inst.components.fueled:InitializeFuelLevel(TUNING.HUNGERBELT_PERISHTIME)
    inst.components.fueled:SetDepletedFn(onperish)
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

return Prefab( "common/inventory/armorslurper", fn, assets) 
