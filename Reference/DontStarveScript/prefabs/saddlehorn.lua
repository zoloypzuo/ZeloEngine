local assets =
{
    Asset("ANIM", "anim/saddlehorn.zip"),
    Asset("ANIM", "anim/swap_saddlehorn.zip"),
}

local function onequip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_saddlehorn", "swap_saddlehorn")
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

    inst.AnimState:SetBank("saddlehorn")
    inst.AnimState:SetBuild("saddlehorn")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.SADDLEHORN_DAMAGE)
    inst.components.weapon.attackwear = 3

    inst:AddComponent("unsaddler")

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.SADDLEHORN_USES)
    inst.components.finiteuses:SetUses(TUNING.SADDLEHORN_USES)
    inst.components.finiteuses:SetOnFinished(inst.Remove)
    inst.components.finiteuses:SetConsumption(ACTIONS.UNSADDLE, 1)

    inst:AddComponent("inspectable")

    inst:AddComponent("inventoryitem")

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(onequip)
    inst.components.equippable:SetOnUnequip(onunequip)

    return inst
end

return Prefab("saddlehorn", fn, assets)
