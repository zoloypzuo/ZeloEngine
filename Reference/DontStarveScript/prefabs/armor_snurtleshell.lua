local assets =
{
	Asset("ANIM", "anim/armor_slurtleshell.zip"),
    Asset("INV_IMAGE", "armorsnurtleshell"),
}

local function OnBlocked(owner) 
    owner.SoundEmitter:PlaySound("dontstarve/wilson/hit_armour")
end

local function ProtectionLevels(inst, data)
    local equippedArmor = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if data.statename == "shell_idle" or data.statename == "shell_hit" or data.statename == "shell_enter" then
        equippedArmor.components.armor:SetAbsorption(TUNING.FULL_ABSORPTION)
    else
        equippedArmor.components.armor:SetAbsorption(TUNING.ARMORSNURTLESHELL_ABSORPTION)
        equippedArmor.components.useableitem:StopUsingItem()
    end
end

local function shouldstopuse(inst, data)
    local equippedArmor = inst.components.inventory and inst.components.inventory:GetEquippedItem(EQUIPSLOTS.BODY)
    if equippedArmor and not (data.statename == "shell_idle" or data.statename == "shell_hit") then
        equippedArmor.components.useableitem:StopUsingItem()
        inst:RemoveEventCallback("newstate", shouldstopuse, inst)
        if inst.task then
            inst.task:Cancel()
            inst.task = nil
        end
    end
end

local function droptargets(inst)
    local pt = inst:GetPosition()
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 20)

    for k,v in pairs(ents) do
        if v.components.combat and v.components.combat.target and v.components.combat.target == inst then
            v.components.combat:SetTarget(nil)
        end
    end

   if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
end

local function onuse(inst)
    local owner = inst.components.inventoryitem.owner
    if owner then
        owner.sg:GoToState("shell_enter")
        inst.task = inst:DoTaskInTime(5, function() droptargets(inst) end)
    end
end

local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_body", "armor_slurtleshell", "swap_body")
    inst:ListenForEvent("blocked", OnBlocked, owner)
    inst:ListenForEvent("newstate", ProtectionLevels, owner) 
end

local function onunequip(inst, owner)
    owner.AnimState:ClearOverrideSymbol("swap_body")
    inst:RemoveEventCallback("blocked", OnBlocked, owner)
    inst:RemoveEventCallback("newstate", ProtectionLevels, owner)

end



local function fn()
	local inst = CreateEntity()

	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("armor_slurtleshell")
    inst.AnimState:SetBuild("armor_slurtleshell")
    inst.AnimState:PlayAnimation("anim")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem.foleysound = "dontstarve/movement/foley/shellarmour"

    inst:AddTag("shell")

    inst:AddComponent("armor")
    inst.components.armor:InitCondition(TUNING.ARMORSNURTLESHELL, TUNING.ARMORSNURTLESHELL_ABSORPTION)

    inst:AddComponent("equippable")
    inst.components.equippable.equipslot = EQUIPSLOTS.BODY

    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )

    inst:AddComponent("useableitem")
    inst.components.useableitem:SetOnUseFn(onuse)



	return inst
end

return Prefab("common/inventory/armorsnurtleshell", fn, assets) 
