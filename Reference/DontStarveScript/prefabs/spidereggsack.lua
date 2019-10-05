require "prefabutil"
local assets =
{
	Asset("ANIM", "anim/spider_egg_sac.zip"),
    Asset("SOUND", "sound/spider.fsb"),
}

local function ondeploy(inst, pt) 
    inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack")
    local tree = SpawnPrefab("spiderden") 
    if tree then 
        tree.Transform:SetPosition(pt.x, pt.y, pt.z) 
        inst.components.stackable:Get():Remove()
    end 
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("spider_egg_sac")
    inst.AnimState:SetBuild("spider_egg_sac")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    
	MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("inventoryitem")
    
    inst.components.inventoryitem:SetOnPickupFn(function() inst.SoundEmitter:PlaySound("dontstarve/creatures/spider/spider_egg_sack") end)
    
    inst:AddComponent("deployable")
    inst.components.deployable.test = function() return true end
    inst.components.deployable.ondeploy = ondeploy
    

    return inst
end

return Prefab( "common/inventory/spidereggsack", fn, assets),
	   MakePlacer( "common/spidereggsack_placer", "spider_cocoon", "spider_cocoon", "cocoon_small" ) 

