local assets=
{
	Asset("ANIM", "anim/umbrella.zip"),
	Asset("ANIM", "anim/swap_umbrella.zip"),
    Asset("ANIM", "anim/swap_parasol.zip"),    
    Asset("ANIM", "anim/parasol.zip"),    
}
  
local function UpdateSound(inst)
    local soundShouldPlay = GetSeasonManager():IsRaining() and inst.components.equippable:IsEquipped()
    if soundShouldPlay ~= inst.SoundEmitter:PlayingSound("umbrellarainsound") then
        if soundShouldPlay then
		    inst.SoundEmitter:PlaySound("dontstarve/rain/rain_on_umbrella", "umbrellarainsound") 
        else
		    inst.SoundEmitter:KillSound("umbrellarainsound")
		end
    end
end  

local function onfinished(inst)
    inst:Remove()
end

local function onperish(inst)
    if inst.components.inventoryitem and inst.components.inventoryitem:IsHeld() then
        local owner = inst.components.inventoryitem.owner
        inst:Remove()
        
        if owner then
            owner:PushEvent("umbrellaranout")
        end
    else
        inst:Remove()
    end
end    

local function onequip_grass(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_parasol", "swap_parasol")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    UpdateSound(inst)
    
    owner.DynamicShadow:SetSize(1.7, 1)
end

local function onunequip_grass(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    UpdateSound(inst)

    owner.DynamicShadow:SetSize(1.3, 0.6)
end

local function grass(Sim)
    local inst = CreateEntity()
    local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    MakeInventoryPhysics(inst)
    
    inst:AddTag("nopunch")
    inst:AddTag("umbrella")

    inst.AnimState:SetBank("parasol")
    inst.AnimState:SetBuild("parasol")
    inst.AnimState:PlayAnimation("idle")

    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("dapperness")
    inst.components.dapperness.dapperness = TUNING.DAPPERNESS_TINY
    inst.components.dapperness.mitigates_rain = true

    inst:AddComponent("equippable")
    inst.components.equippable.dapperness = TUNING.DAPPERNESS_SMALL
    inst.components.equippable:SetOnEquip( onequip_grass )
    inst.components.equippable:SetOnUnequip( onunequip_grass ) 

    inst:AddComponent("insulator")

    inst:AddComponent("perishable")
    inst.components.perishable:SetPerishTime(TUNING.GRASS_UMBRELLA_PERISHTIME)
    inst.components.perishable:StartPerishing()
    inst.components.perishable:SetOnPerishFn(onperish)
    inst:AddTag("show_spoilage")

    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    
    inst:ListenForEvent("rainstop", function() UpdateSound(inst) end, GetWorld()) 
    inst:ListenForEvent("rainstart", function() UpdateSound(inst) end, GetWorld()) 

    MakeSmallBurnable(inst, TUNING.SMALL_BURNTIME)
    MakeSmallPropagator(inst)

    return inst
end
    
local function onequip(inst, owner) 
    owner.AnimState:OverrideSymbol("swap_object", "swap_umbrella", "swap_umbrella")
    owner.AnimState:Show("ARM_carry")
    owner.AnimState:Hide("ARM_normal")
    UpdateSound(inst)
end

local function onunequip(inst, owner) 
    owner.AnimState:Hide("ARM_carry") 
    owner.AnimState:Show("ARM_normal") 
    UpdateSound(inst)
end
    
    
local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()    
    MakeInventoryPhysics(inst)
    
    anim:SetBank("umbrella")
    anim:SetBuild("umbrella")
    anim:PlayAnimation("idle")
    
    inst:AddTag("sharp")

    inst:AddComponent("dapperness")
    inst.components.dapperness.mitigates_rain = true
    -------
    inst:AddComponent("finiteuses")
    inst.components.finiteuses:SetMaxUses(TUNING.UMBRELLA_USES)
    inst.components.finiteuses:SetUses(TUNING.UMBRELLA_USES)
    inst.components.finiteuses:SetOnFinished( onfinished) 
    --inst.components.finiteuses:SetConsumption(ACTIONS.TERRAFORM, .125)
    -------

    inst:AddComponent("weapon")
    inst.components.weapon:SetDamage(TUNING.UMBRELLA_DAMAGE)
    
    inst:AddComponent("inspectable")
    inst:AddComponent("inventoryitem")
    inst:AddComponent("equippable")
    inst.components.equippable:SetOnEquip( onequip )
    inst.components.equippable:SetOnUnequip( onunequip )
    
    inst:ListenForEvent("rainstop", function() UpdateSound(inst) end, GetWorld()) 
	inst:ListenForEvent("rainstart", function() UpdateSound(inst) end, GetWorld()) 
    
    
    return inst
end



return Prefab( "common/inventory/umbrella", fn, assets),
Prefab( "common/inventory/grass_umbrella", grass, assets) 

