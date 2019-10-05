local assets=
{
	Asset("ANIM", "anim/eel.zip"),
    Asset("ANIM", "anim/eel01.zip")
}


local prefabs =
{
    "eel_cooked",
    "spoiled_food",
}

local function stopkicking(inst)
    inst.AnimState:PlayAnimation("dead")
end

local function makeeel(build)

    local function commonfn()
	    local inst = CreateEntity()
	    inst.entity:AddTransform()
        
        MakeInventoryPhysics(inst)
        
	    inst.entity:AddAnimState()
        inst.AnimState:SetBank("eel")
        inst.AnimState:SetBuild("eel")
        
        inst.build = build --This is used within SGwilson, sent from an event in fishingrod.lua
        
        inst:AddTag("meat")

        inst:AddComponent("edible")
        inst.components.edible.ismeat = true
        inst.components.edible.foodtype = "MEAT"
        
        inst:AddComponent("stackable")
		inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("bait")

        
		inst:AddComponent("perishable")
		inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
		inst.components.perishable:StartPerishing()
		inst.components.perishable.onperishreplacement = "spoiled_food"
        
        
        inst:AddComponent("inspectable")
        
        inst:AddComponent("inventoryitem")
        
        inst:AddComponent("tradable")
        inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.RAREMEAT
        inst.data = {}

        return inst
    end

    local function rawfn()
	    local inst = commonfn(build)
        inst.AnimState:PlayAnimation("idle", true)


		inst.components.edible.healthvalue = TUNING.HEALING_SMALL
		inst.components.edible.hungervalue = TUNING.CALORIES_TINY
		inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
        
        inst:AddComponent("cookable")
        inst.components.cookable.product = "eel_cooked"
        inst:AddComponent("dryable")
        inst.components.dryable:SetProduct("smallmeat_dried")
        inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
        inst:DoTaskInTime(2 + math.random() * 2, stopkicking)
        inst.components.inventoryitem:SetOnPickupFn(function(pickupguy) stopkicking(inst) end)
        inst.OnLoad = function() stopkicking(inst) end
        
        return inst
    end

    local function cookedfn()
	    local inst = commonfn(build)
        inst.AnimState:PlayAnimation("cooked")
        
		inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL        
		inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
        inst.components.edible.foodstate = "COOKED"        
		inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

        return inst
    end
    return rawfn, cookedfn
end

local function eel(name, build)
    local raw, cooked = makeeel(build)
    return Prefab( "common/inventory/"..name, raw, assets, prefabs),
        Prefab( "common/inventory/"..name.."_cooked", cooked, assets)
end

return eel("eel", "eel01") 

