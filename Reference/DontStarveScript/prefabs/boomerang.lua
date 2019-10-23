local assets = {
    Asset("ANIM", "anim/boomerang.zip"),
    Asset("ANIM", "anim/swap_boomerang.zip"),
    Asset("INV_IMAGE", "boomerang"),
}

local prefabs = {
}

local function OnFinished(inst)
    inst.AnimState:PlayAnimation("used")
    inst:ListenForEvent("animover", function()
        inst:Remove()
    end)
end

local function OnEquip(inst, owner)
    owner.AnimState:OverrideSymbol("swap_object", "swap_boomerang", "swap_boomerang")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
end

local function OnDropped(inst)
    inst.AnimState:PlayAnimation("idle")
end

local function OnUnequip(inst, owner)
    owner.AnimState:Hide("ARM_carry")
    owner.AnimState:Show("ARM_normal")
end

local function OnThrown(inst, owner, target)
    if target ~= owner then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_throw")
    end
    inst.AnimState:PlayAnimation("spin_loop", true)
end

local function OnCaught(inst, catcher)
    if catcher then
        if catcher.components.inventory then
            if inst.components.equippable and not catcher.components.inventory:GetEquippedItem(inst.components.equippable.equipslot) then
                catcher.components.inventory:Equip(inst)
            else
                catcher.components.inventory:GiveItem(inst)
            end
            catcher:PushEvent("catch")
        end
    end
end

local function ReturnToOwner(inst, owner)
    if owner and not (inst.components.finiteuses and inst.components.finiteuses:GetUses() < 1) then
        owner.SoundEmitter:PlaySound("dontstarve/wilson/boomerang_return")
        inst.components.projectile:Throw(owner, owner)
    end
end

local function OnHit(inst, owner, target)
    if owner == target then
        OnDropped(inst)
    else
        ReturnToOwner(inst, owner)
    end
    local impactfx = SpawnPrefab("impact")
    if impactfx then
        local follower = impactfx.entity:AddFollower()
        follower:FollowSymbol(target.GUID, target.components.combat.hiteffectsymbol, 0, 0, 0)
        impactfx:FacePoint(inst.Transform:GetWorldPosition())
    end
end

local function fn(Sim)
    local inst = CreateEntity()
    local trans = inst .entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)
    RemovePhysicsColliders(inst)

    anim:SetBank("boomerang")
    anim:SetBuild("boomerang")
    anim:PlayAnimation("idle")
    anim:SetRayTestOnBB(true);

    inst:AddTag("projectile")
    inst:AddTag("thrown")

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.BOOMERANG_DAMAGE)
    inst.components.weapon:SetRange(TUNING.BOOMERANG_DISTANCE, TUNING.BOOMERANG_DISTANCE + 2)
    -------

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.BOOMERANG_USES)
    inst.components.finiteuses:SetUses(TUNING.BOOMERANG_USES)

    inst.components.finiteuses:SetOnFinished(OnFinished)

    inst:AddComponent("inspectable")

    inst:AddComponent("projectile")
    inst.components.projectile:SetSpeed(10)
    inst.components.projectile:SetCanCatch(true)
    inst.components.projectile:SetOnThrownFn(OnThrown)
    inst.components.projectile:SetOnHitFn(OnHit)
    inst.components.projectile:SetOnMissFn(ReturnToOwner)
    inst.components.projectile:SetOnCaughtFn(OnCaught)

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(OnDropped)

    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip(OnEquip)
    inst.components.equippable:SetOnUnequip(OnUnequip)

    return inst
end

return Prefab("common/inventory/boomerang", fn, assets)
