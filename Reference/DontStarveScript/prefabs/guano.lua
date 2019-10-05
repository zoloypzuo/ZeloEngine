local assets =
{
    Asset("ANIM", "anim/guano.zip"),
}

local prefabs =
{
    "flies",
    "poopcloud",
}

local function OnBurn(inst)
    DefaultBurnFn(inst)
    if inst.flies then
        inst.flies:Remove()
        inst.flies = nil
    end   
end

local function FuelTaken(inst, taker)
    local cloud = SpawnPrefab("poopcloud")
    if cloud then
        cloud.Transform:SetPosition(taker.Transform:GetWorldPosition() )
    end
end

local function fn(Sim)
    local inst = CreateEntity()
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("guano")
    inst.AnimState:SetBuild("guano")
    inst.AnimState:PlayAnimation("dump")
    inst.AnimState:PushAnimation("idle")
    
    inst:AddComponent("stackable")
 
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")

    inst:AddComponent("fertilizer")
    inst.components.fertilizer.fertilizervalue = TUNING.GUANO_FERTILIZE
    inst.components.fertilizer.soil_cycles = TUNING.GUANO_SOILCYCLES
    
    
    inst.components.inventoryitem:SetOnDroppedFn(function() inst.flies = inst:SpawnChild("flies") end )
    inst.components.inventoryitem:SetOnPickupFn(function() if inst.flies then inst.flies:Remove() inst.flies = nil end end )
    inst.components.inventoryitem:SetOnPutInInventoryFn(function() if inst.flies then inst.flies:Remove() inst.flies = nil end end )
    
    inst.flies = inst:SpawnChild("flies")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.MED_FUEL
    inst.components.fuel:SetOnTakenFn(FuelTaken)
    
    MakeSmallBurnable(inst, TUNING.MED_BURNTIME)
    inst.components.burnable:SetOnIgniteFn(OnBurn)
    MakeSmallPropagator(inst)
    
    ---------------------        
    
    
    return inst
end

return Prefab( "common/inventory/guano", fn, assets, prefabs) 
