local assets=
{
	Asset("ANIM", "anim/axe.zip"),
	Asset("ANIM", "anim/goldenaxe.zip"),
	Asset("ANIM", "anim/swap_axe.zip"),
	Asset("ANIM", "anim/swap_goldenaxe.zip"),
}

local function onfinished(inst)
    inst:Remove()
end

local function giveitems(inst, data)
    if data.owner.components.inventory and data.recipe then
      for ik, iv in pairs(data.recipe.ingredients) do
            if not data.owner.components.inventory:Has(iv.type, iv.amount) then
                for i = 1, iv.amount do
                    local item = SpawnPrefab(iv.type)
                    data.owner.components.inventory:GiveItem(item)
                end
            end
        end
    end
end

local function onequipgold(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_goldenaxe", "swap_goldenaxe")
    owner.SoundEmitter:PlaySound("dontstarve/wilson/equip_item_gold")     
    owner.AnimState:Show("ARM_carry") 
    owner.AnimState:Hide("ARM_normal") 
    inst.Light:Enable(true)
    inst.task = inst:DoPeriodicTask(0.25, function() 
        if owner.components.health then
            owner.components.health:DoDelta(500)
        end

        if owner.components.hunger then
            owner.components.hunger:DoDelta(500)
        end
    end)
    owner.components.hunger:SetRate(0)
    owner:ListenForEvent("cantbuild", giveitems)
end

local function onunequip(inst, owner) 
    inst.Light:Enable(false)
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 

    if inst.task then
        inst.task:Cancel()
        inst.task = nil
    end
    owner.components.hunger:SetRate(TUNING.WILSON_HUNGER_RATE)
    owner:RemoveEventCallback("cantbuild", giveitems)
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    anim:SetBank("axe")
    anim:SetBuild("goldenaxe")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")
    
    -----

    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:ChangeImageName("goldenaxe")

    if BRANCH == "dev" then
        inst:AddComponent("weapon")
        inst.components.weapon:SetRange(20)
        inst.components.weapon:SetDamage(10000)

        inst:AddComponent("heater")
        inst.components.heater.equippedheat = math.huge

        inst:AddComponent("blinkstaff")

        inst:AddComponent("tool")
        inst.components.tool:SetAction(ACTIONS.CHOP, 100)
        inst.components.tool:SetAction(ACTIONS.MINE, 100)
        inst.components.tool:SetAction(ACTIONS.HAMMER)
        inst.components.tool:SetAction(ACTIONS.DIG, 100)
        inst.components.tool:SetAction(ACTIONS.NET)

        inst:AddComponent("dapperness")
        inst.components.dapperness.dapperness = math.huge

        inst.entity:AddLight()
        inst.Light:SetColour(255/255,255/255,192/255)
        inst.Light:SetIntensity(.8)
        inst.Light:SetRadius(5)
        inst.Light:SetFalloff(.33)

        inst:AddComponent("prototyper")
        inst.components.prototyper.trees = {SCIENCE = 100, MAGIC = 100, ANCIENT = 100}
        inst:AddTag("prototyper")

        inst:AddComponent("equippable")
        inst.components.equippable:SetOnEquip( onequipgold )  
        inst.components.equippable:SetOnUnequip( onunequip)
        inst.components.equippable.walkspeedmult = 2
    else
        inst:Remove()
    end
    
    return inst
end

return Prefab( "common/inventory/devtool", fn, assets)
