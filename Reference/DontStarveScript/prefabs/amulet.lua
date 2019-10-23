local assets = {
    Asset("ANIM", "anim/amulets.zip"),
    Asset("ANIM", "anim/torso_amulets.zip"),
}

--[[ Each amulet has a seperate onequip and onunequip function so we can also
add and remove event listeners, or start/stop update functions here. ]]

---RED
local function healowner(inst, owner)
    if (owner.components.health and owner.components.health:IsHurt())
            and (owner.components.hunger and owner.components.hunger.current > 5) then
        owner.components.health:DoDelta(TUNING.REDAMULET_CONVERSION, false, "redamulet")
        owner.components.hunger:DoDelta(-TUNING.REDAMULET_CONVERSION)
        inst.components.finiteuses:Use(1)
    end
end

local function onequip_red(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "redamulet")
    inst.task = inst:DoPeriodicTask(30, function()
        healowner(inst, owner)
    end)
end

local function onunequip_red(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
end

---BLUE
local function onequip_blue(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "blueamulet")

    inst.freezefn = function(attacked, data)
        if data and data.attacker and data.attacker.components.freezable then
            data.attacker.components.freezable:AddColdness(0.67)
            data.attacker.components.freezable:SpawnShatterFX()
            inst.components.fueled:DoDelta(-(inst.components.fueled.maxfuel * 0.03))
        end
    end

    inst:ListenForEvent("attacked", inst.freezefn, owner)

    if inst.components.fueled then
        inst.components.fueled:StartConsuming()
    end

end

local function onunequip_blue(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")

    inst:RemoveEventCallback("attacked", inst.freezefn, owner)

    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
end

---PURPLE
local function induceinsanity(val, owner)
    if owner.components.sanity then
        owner.components.sanity.inducedinsanity = val
    end
    if owner.components.sanitymonsterspawner then
        --Ensure the popchangetimer fully ticks over by running max tick time twice.
        owner.components.sanitymonsterspawner:UpdateMonsters(20)
        owner.components.sanitymonsterspawner:UpdateMonsters(20)
    end

    local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 100, nil, nil, { 'rabbit', 'manrabbit' })

    for k, v in pairs(ents) do
        if v.CheckTransformState ~= nil then
            v.CheckTransformState(v)
        end
    end

end

local function onequip_purple(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "purpleamulet")
    if inst.components.fueled then
        inst.components.fueled:StartConsuming()
    end
    induceinsanity(true, owner)
end

local function onunequip_purple(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end
    induceinsanity(nil, owner)
end

---GREEN

local function onequip_green(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "greenamulet")
    owner.components.builder.ingredientmod = TUNING.GREENAMULET_INGREDIENTMOD
    inst.onitembuild = function()
        inst.components.finiteuses:Use(1)
    end
    inst:ListenForEvent("consumeingredients", inst.onitembuild, owner)

end

local function onunequip_green(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    owner.components.builder.ingredientmod = 1
    inst:RemoveEventCallback("consumeingredients", inst.onitembuild, owner)
end

---ORANGE
local function SpawnEffect(inst)
    local pt = inst:GetPosition()
    local fx = SpawnPrefab("small_puff")
    fx.Transform:SetPosition(pt.x, pt.y, pt.z)
    fx.Transform:SetScale(0.5, 0.5, 0.5)
end

local function getitem(player, amulet, item)
    --Amulet will only ever pick up items one at a time. Even from stacks.
    SpawnEffect(item)
    amulet.components.finiteuses:Use(1)

    if item.components.stackable then
        item = item.components.stackable:Get()
    end

    if item.components.trap and item.components.trap:IsSprung() then
        item.components.trap:Harvest(player)
        return
    end

    player.components.inventory:GiveItem(item)
end

local function pickup(inst, owner)
    local pt = owner:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, TUNING.ORANGEAMULET_RANGE)

    for k, v in pairs(ents) do
        if v.components.inventoryitem and v.components.inventoryitem.canbepickedup and v.components.inventoryitem.cangoincontainer and not
        v.components.inventoryitem:IsHeld() then

            if not owner.components.inventory:IsFull() then
                --Your inventory isn't full, you can pick something up.
                getitem(owner, inst, v)
                return

            elseif v.components.stackable then
                --Your inventory is full, but the item you're trying to pick up stacks. Check for an exsisting stack.
                --An acceptable stack should: Be of the same item type, not be full already and not be in the "active item" slot of inventory.
                local stack = owner.components.inventory:FindItem(function(item)
                    return (item.prefab == v.prefab and not item.components.stackable:IsFull()
                            and item ~= owner.components.inventory.activeitem)
                end)
                if stack then
                    getitem(owner, inst, v)
                    return
                end
            end
        end
    end

end

local function onequip_orange(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "orangeamulet")
    inst.task = inst:DoPeriodicTask(TUNING.ORANGEAMULET_ICD, function()
        pickup(inst, owner)
    end)
end

local function onunequip_orange(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
end

---YELLOW
local function onequip_yellow(inst, owner)
    owner.AnimState:OverrideSymbol("swap_body", "torso_amulets", "yellowamulet")

    if inst.components.fueled then
        inst.components.fueled:StartConsuming()
    end

    inst.Light:Enable(true)

    owner.AnimState:SetBloomEffectHandle("shaders/anim.ksh")

end

local function onunequip_yellow(inst, owner)
    owner.AnimState:ClearBloomEffectHandle()
    owner.AnimState:ClearOverrideSymbol("swap_body")
    if inst.components.fueled then
        inst.components.fueled:StopConsuming()
    end

    inst.Light:Enable(false)
end

---COMMON FUNCTIONS

local function onfinished(inst)
    inst:Remove()
end

local function unimplementeditem(inst)
    local player = GetPlayer()
    player.components.talker:Say(GetString(player.prefab, "ANNOUNCE_UNIMPLEMENTED"))
    if player.components.health.currenthealth > 1 then
        player.components.health:DoDelta(-player.components.health.currenthealth * 0.5)
    end

    if inst.components.useableitem then
        inst.components.useableitem:StopUsingItem()
    end
end

local function commonfn()
    local inst = CreateEntity()

    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("amulets")
    inst.AnimState:SetBuild("amulets")

    inst:AddComponent("inspectable")

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst:AddComponent("dapperness")
    inst.components.dapperness.dapperness = TUNING.DAPPERNESS_SMALL

    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/jewlery"

    return inst
end

local function red(inst)
    local inst = commonfn(inst)
    inst.AnimState:PlayAnimation("redamulet")
    inst.components.inventoryitem.keepondeath = true
    inst.components.equippable:SetOnEquip(onequip_red)
    inst.components.equippable:SetOnUnequip(onunequip_red)
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetMaxUses(TUNING.REDAMULET_USES)
    inst.components.finiteuses:SetUses(TUNING.REDAMULET_USES)
    return inst
end

local function blue(inst)
    local inst = commonfn(inst)
    inst.AnimState:PlayAnimation("blueamulet")
    inst.components.equippable:SetOnEquip(onequip_blue)
    inst.components.equippable:SetOnUnequip(onunequip_blue)
    inst:AddComponent("heater")
    inst.components.heater.iscooler = true
    inst.components.heater.equippedheat = TUNING.BLUEGEM_COOLER

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "MAGIC"
    inst.components.fueled:InitializeFuelLevel(TUNING.BLUEAMULET_FUEL)
    inst.components.fueled:SetDepletedFn(onfinished)
    return inst
end

local function purple(inst)
    local inst = commonfn(inst)

    inst:AddComponent("fueled")
    inst.components.fueled.fueltype = "MAGIC"
    inst.components.fueled:InitializeFuelLevel(TUNING.PURPLEAMULET_FUEL)
    inst.components.fueled:SetDepletedFn(onfinished)

    inst.AnimState:PlayAnimation("purpleamulet")
    inst.components.equippable:SetOnEquip(onequip_purple)
    inst.components.equippable:SetOnUnequip(onunequip_purple)

    inst.components.dapperness.dapperness = -TUNING.DAPPERNESS_MED

    return inst
end

local function green(inst)
    local inst = commonfn(inst)
    inst.AnimState:PlayAnimation("greenamulet")
    inst.components.equippable:SetOnEquip(onequip_green)
    inst.components.equippable:SetOnUnequip(onunequip_green)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetMaxUses(TUNING.GREENAMULET_USES)
    inst.components.finiteuses:SetUses(TUNING.GREENAMULET_USES)

    return inst
end

local function orange(inst)
    local inst = commonfn(inst)
    inst.AnimState:PlayAnimation("orangeamulet")
    -- inst.components.inspectable.nameoverride = "unimplemented"
    -- inst:AddComponent("useableitem")
    -- inst.components.useableitem:SetOnUseFn(unimplementeditem)
    inst.components.equippable:SetOnEquip(onequip_orange)
    inst.components.equippable:SetOnUnequip(onunequip_orange)

    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetOnFinished(onfinished)
    inst.components.finiteuses:SetMaxUses(TUNING.ORANGEAMULET_USES)
    inst.components.finiteuses:SetUses(TUNING.ORANGEAMULET_USES)

    return inst
end

local function yellow(inst)
    local inst = commonfn(inst)
    inst.AnimState:PlayAnimation("yellowamulet")

    inst.components.equippable:SetOnEquip(onequip_yellow)
    inst.components.equippable:SetOnUnequip(onunequip_yellow)
    inst.components.equippable.walkspeedmult = 1.2
    inst.components.inventoryitem:SetOnDroppedFn(function(inst)
        inst.Light:Enable(false)
    end)
    inst.entity:AddLight()
    inst.Light:Enable(false)
    inst.Light:SetRadius(2)
    inst.Light:SetFalloff(0.7)
    inst.Light:SetIntensity(.65)
    inst.Light:SetColour(223 / 255, 208 / 255, 69 / 255)

    inst:AddComponent("fueled")
    inst.components.fueled.accepting = true
    inst.components.fueled.fueltype = "NIGHTMARE"
    inst.components.fueled:InitializeFuelLevel(TUNING.YELLOWAMULET_FUEL)
    inst.components.fueled:SetDepletedFn(onfinished)
    return inst
end

return Prefab("common/inventory/amulet", red, assets),
Prefab("common/inventory/blueamulet", blue, assets),
Prefab("common/inventory/purpleamulet", purple, assets),
Prefab("common/inventory/orangeamulet", orange, assets),
Prefab("common/inventory/greenamulet", green, assets),
Prefab("common/inventory/yellowamulet", yellow, assets)
