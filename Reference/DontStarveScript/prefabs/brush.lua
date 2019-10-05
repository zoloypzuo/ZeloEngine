local assets =
{
    Asset("ANIM", "anim/beefalobrush.zip"),
    Asset("ANIM", "anim/swap_beefalobrush.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_beefalobrush", "swap_beefalobrush")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function onunequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function fn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("beefalobrush")
    inst.AnimState:SetBuild("beefalobrush")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BRUSH_DAMAGE)
    inst.components.weapon.attackwear = 3

    inst:AddComponent("brush")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BRUSH_USES)
    inst.components.finiteuses:SetUses(TUNING.BRUSH_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.BRUSH, 1)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

return Prefab("brush", fn, assets)
