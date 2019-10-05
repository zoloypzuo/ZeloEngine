local assets=
{
	Asset("ANIM", "anim/meat.zip"),
	Asset("ANIM", "anim/meat_monster.zip"),
	Asset("ANIM", "anim/meat_small.zip"),
	Asset("ANIM", "anim/drumstick.zip"),
	Asset("ANIM", "anim/meat_rack_food.zip"),
    Asset("ANIM", "anim/batwing.zip"),
    Asset("ANIM", "anim/plant_meat.zip"),
}


local prefabs =
{
    "cookedmeat",
    "meat_dried",
    "spoiled_food",
}

local smallprefabs = 
{
    "cookedsmallmeat",
    "smallmeat_dried",
    "spoiled_food",
}

local monsterprefabs = 
{
    "cookedmonstermeat",
    "monstermeat_dried",
    "spoiled_food",
}

local drumstickprefabs = 
{
    "drumstick_cooked",
    "spoiled_food",
}

local batwingprefabs = 
{
    "batwing_cooked",
    "meat_dried",
    "spoiled_food",
}

local plantmeatprefabs =
{
    "plantmeat_cooked",
    "spoiled_food",
}

local function common(inst)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
    
    MakeInventoryPhysics(inst)
    
    inst:AddTag("meat")
	
    inst:AddComponent("edible")
    inst.components.edible.ismeat = true    
    inst.components.edible.foodtype = "MEAT"
    
    inst:AddComponent("stackable")
    inst:AddComponent("bait")
    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("tradable")
    inst.components.tradable.goldvalue = TUNING.GOLD_VALUES.MEAT

	inst:AddComponent("perishable")
	inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
	inst.components.perishable:StartPerishing()
	inst.components.perishable.onperishreplacement = "spoiled_food"

    return inst
end
    
local function monster(Sim)
	local inst = common()

    inst.AnimState:SetBank("monstermeat")
    inst.AnimState:SetBuild("meat_monster")
    inst.AnimState:PlayAnimation("idle")
    
    inst.components.edible.ismeat = true    
    inst.components.edible.foodtype = "MEAT"
    inst.components.edible.healthvalue = -TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_MED
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    
	inst.components.tradable.goldvalue = 0
	
    inst:AddComponent("selfstacker")

    inst:AddComponent("cookable")
    inst.components.cookable.product = "cookedmonstermeat"
    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("monstermeat_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
    return inst
end


local function cookedmonster(Sim)
	local inst = common()

    inst.AnimState:SetBank("monstermeat")
    inst.AnimState:SetBuild("meat_monster")
    inst.AnimState:PlayAnimation("cooked")
    inst.components.tradable.goldvalue = 0
    
    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    inst.components.edible.foodstate = "COOKED"

    inst.components.perishable:SetPerishTime(TUNING.PERISH_SLOW)

    return inst
end

local function driedmonster(Sim)
	local inst = common()

    inst.AnimState:SetBank("meat_rack_food")
    inst.AnimState:SetBuild("meat_rack_food")
    inst.AnimState:PlayAnimation("idle_dried_monster")
    
    inst.components.edible.healthvalue = -TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_TINY
    
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
	

    return inst
end

local function cooked(Sim)
	local inst = common()
    inst.AnimState:SetBank("meat")
    inst.AnimState:SetBuild("meat")
    inst.AnimState:PlayAnimation("cooked")
    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
    inst.components.edible.sanityvalue = 0
    inst.components.edible.foodstate = "COOKED"
	inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
        
    return inst
end

local function driedmeat(Sim)
	local inst = common()
    inst.AnimState:SetBank("meat_rack_food")
    inst.AnimState:SetBuild("meat_rack_food")
    inst.AnimState:PlayAnimation("idle_dried_large")
    inst.components.edible.healthvalue = TUNING.HEALING_MED
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
    inst.components.edible.sanityvalue = TUNING.SANITY_MED
	inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
        
    return inst
end



local function raw(Sim)
	local inst = common()
    inst.AnimState:SetBank("meat")
    inst.AnimState:SetBuild("meat")
    inst.AnimState:PlayAnimation("raw")
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_MED
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "cookedmeat"
    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("meat_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_MED)
    return inst
end

local function smallmeat()
	local inst = common()
    inst.AnimState:SetBank("meat_small")
    inst.AnimState:SetBuild("meat_small")
    inst.AnimState:PlayAnimation("raw")
    
    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    
    inst:AddComponent("cookable")
    inst.components.cookable.product = "cookedsmallmeat"
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("smallmeat_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
    
    return inst
end


   
local function cookedsmallmeat(Sim)
	local inst = common()
    inst.AnimState:SetBank("meat_small")
    inst.AnimState:SetBuild("meat_small")
    inst.AnimState:PlayAnimation("cooked")
    
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = 0
    inst.components.edible.foodstate = "COOKED"
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)
    
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    return inst
end
   
local function driedsmallmeat(Sim)
	local inst = common()
    inst.AnimState:SetBank("meat_rack_food")
    inst.AnimState:SetBuild("meat_rack_food")
    inst.AnimState:PlayAnimation("idle_dried_small")
    
    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = TUNING.SANITY_SMALL
    
    inst.components.perishable:SetPerishTime(TUNING.PERISH_PRESERVED)
    
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM
    
    return inst
end

local function drumstick()
	local inst = common()
    inst.AnimState:SetBank("drumstick")
    inst.AnimState:SetBuild("drumstick")
    inst.AnimState:PlayAnimation("raw")

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)
    
    inst:AddTag("drumstick")
    inst:AddComponent("cookable")
    inst.components.cookable.product = "drumstick_cooked"
    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("smallmeat_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_FAST)
    return inst
end

local function drumstick_cooked()
	local inst = common()
    inst.AnimState:SetBank("drumstick")
    inst.AnimState:SetBuild("drumstick")
    inst.AnimState:PlayAnimation("cooked")
    inst:AddTag("drumstick")

    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.foodstate = "COOKED"
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

local function batwing()
    local inst = common()
    inst.AnimState:SetBank("batwing")
    inst.AnimState:SetBuild("batwing")
    inst.AnimState:PlayAnimation("raw")

    inst.components.edible.healthvalue = TUNING.HEALING_SMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst:AddComponent("dryable")
    inst.components.dryable:SetProduct("smallmeat_dried")
    inst.components.dryable:SetDryTime(TUNING.DRY_MED)
    
    inst:AddTag("batwing")
    inst:AddComponent("cookable")
    inst.components.cookable.product = "batwing_cooked"
        
    return inst
end

local function batwing_cooked()
    local inst = common()
    inst.AnimState:SetBank("batwing")
    inst.AnimState:SetBuild("batwing")
    inst.AnimState:PlayAnimation("cooked")
    inst:AddTag("batwing")

    inst.components.edible.healthvalue = TUNING.HEALING_MEDSMALL
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.foodstate = "COOKED"
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

local function plantmeat()
    local inst = common()
    inst.AnimState:SetBank("plant_meat")
    inst.AnimState:SetBuild("plant_meat")
    inst.AnimState:PlayAnimation("raw")

    inst.components.edible.healthvalue = 0
    inst.components.edible.hungervalue = TUNING.CALORIES_SMALL
    inst.components.edible.sanityvalue = -TUNING.SANITY_SMALL
    
    inst.components.perishable:SetPerishTime(TUNING.PERISH_FAST)

    inst:AddComponent("cookable")
    inst.components.cookable.product = "plantmeat_cooked"
        
    return inst
end

local function plantmeat_cooked()
    local inst = common()
    inst.AnimState:SetBank("plant_meat")
    inst.AnimState:SetBuild("plant_meat")
    inst.AnimState:PlayAnimation("cooked")
    
    inst.components.edible.healthvalue = TUNING.HEALING_TINY
    inst.components.edible.hungervalue = TUNING.CALORIES_MEDSMALL
    inst.components.edible.foodstate = "COOKED"
    inst.components.perishable:SetPerishTime(TUNING.PERISH_MED)

    return inst
end

return Prefab( "common/inventory/meat", raw, assets, prefabs),
        Prefab( "common/inventory/cookedmeat", cooked, assets),
        Prefab( "common/inventory/meat_dried", driedmeat, assets),
        Prefab( "common/inventory/monstermeat", monster, assets, monsterprefabs),
        Prefab( "common/inventory/cookedmonstermeat", cookedmonster, assets),
        Prefab( "common/inventory/monstermeat_dried", driedmonster, assets),
        Prefab( "common/inventory/smallmeat", smallmeat, assets, smallprefabs),
        Prefab( "common/inventory/cookedsmallmeat", cookedsmallmeat, assets),
        Prefab( "common/inventory/smallmeat_dried", driedsmallmeat, assets),
        Prefab( "common/inventory/drumstick", drumstick, assets, drumstickprefabs),
        Prefab( "common/inventory/drumstick_cooked", drumstick_cooked, assets),
        Prefab("common/inventory/batwing", batwing, assets, batwingprefabs),
        Prefab("common/inventory/batwing_cooked", batwing_cooked, assets),
        Prefab("common/inventory/plantmeat", plantmeat, assets, plantmeatprefabs),
        Prefab("common/inventory/plantmeat_cooked", plantmeat_cooked, assets)


