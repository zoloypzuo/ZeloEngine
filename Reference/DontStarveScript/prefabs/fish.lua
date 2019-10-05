local assets=
{
	Asset("ANIM", "anim/fish.zip"),
	Asset("ANIM", "anim/fish01.zip"),
}


local prefabs =
{
    "fish_cooked",
    "spoiled_food",
}

local function stopkicking(inst)
    inst.AnimState:PlayAnimation("dead")
end

local function makefish(build)

    local function commonfn()
	    local inst = CreateEntity()
	    inst.entity:AddTransform()
        
        MakeInventoryPhysics(inst)
        
	    inst.entity:AddAnimState()
        inst.AnimState:SetBank("fish")
        inst.AnimState:SetBuild("fish")
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
        inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT
        inst.data = {}

        return inst
    end

    local function rawfn()
	    local inst = commonfn(build)
        inst.AnimState:PlayAnimation("idle", true)


		inst.components.edible.healthvalue = TUNING.HEALING_TINY
		inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
		inst.components.perishable:SetPerishTime(TUNING.PERISH_SUPERFAST)
        
        inst:AddComponent("cookable")
        inst.components.cookable.product = "fish_cooked"
        inst:AddComponent("dryable")
        inst.components.dryable:SetProduct("smallmeat_dried")
        inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
        inst:DoTaskInTime(5, stopkicking)
        inst.components.inventoryitem:SetOnPickupFn(function(pickupguy) stopkicking(inst) end)
        inst.OnLoad = function() stopkicking(inst) end
        
        return inst
    end

    local function cookedfn()
	    local inst = commonfn(build)
        inst.AnimState:PlayAnimation("cooked")
        
		inst.components.edible.healthvalue = TUNING.HEALING_TINY
		inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
        inst.components.edible.foodstate = "COOKED"        
		inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

        return inst
    end
    return rawfn, cookedfn
end

local function fish(name, build)
    local raw, cooked = makefish(build)
    return Prefab( "common/inventory/"..name, raw, assets, prefabs),
        Prefab( "common/inventory/"..name.."_cooked", cooked, assets)
end

return fish("fish", "fish01") 

