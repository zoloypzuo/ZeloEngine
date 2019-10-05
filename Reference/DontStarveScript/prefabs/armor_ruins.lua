require("prefabs/amulet")

local assets=
{
	Asset("ANIM", "anim/armor_ruins.zip"),
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_ruins", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)

    if inst.socket_onequip then
        inst.socket_onequip(inst, owner)
    end
end

local function onunequip(inst, owner) 
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)

    if inst.socket_onunequip then
        inst.socket_onunequip(inst, owner)
    end
end

local function fn()
	local inst = CreateEntity()
    
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("armor_ruins")
    inst.AnimState:SetBuild("armor_ruins")
    inst.AnimState:PlayAnimation("anim")
    
    inst:AddTag("ruins")
    inst:AddTag("metal")

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
	inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/metalarmour"
    
    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORRUINS, TUNING.ARMORRUINS_ABSORPTION)
    
    inst:AddComponent("dapperness")
    inst.components.dapperness.dapperness = TUNING.DAPPERNESS_MED

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY
    
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    return inst
end

return Prefab( "common/inventory/armorruins", fn, assets) 
