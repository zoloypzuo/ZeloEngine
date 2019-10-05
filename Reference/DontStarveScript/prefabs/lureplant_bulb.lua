require "prefabutil"
local assets =
{
	Asset("ANIM", "anim/eyeplant_bulb.zip"),
    Asset("ANIM", "anim/eyeplant_trap.zip"),
}

local function ondeploy(inst, pt) 
    local lp = SpawnPrefab("lureplant") 
    if lp then 
        lp.Transform:SetPosition(pt.x, pt.y, pt.z) 
        inst.components.stackable:Get():Remove()
        lp.sg:GoToState("spawn")
    end 
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()
    MakeInventoryPhysics(inst)

    inst.AnimState:SetBank("eyeplant_bulb")
    inst.AnimState:SetBuild("eyeplant_bulb")
    inst.AnimState:PlayAnimation("idle")
    
    inst:AddComponent("stackable")
	inst.components.stackable.maxsize = TUNING.STACK_SIZE_LARGEITEM    
    inst:AddComponent("inspectable")
    
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.LARGE_FUEL
    
	MakeSmallBurnable(inst, TUNING.LARGE_BURNTIME)
    MakeSmallPropagator(inst)
    
    inst:AddComponent("inventoryitem")
    
    inst:AddComponent("deployable")
    inst.components.deployable.test = function() return true end
    inst.components.deployable.ondeploy = ondeploy
    

    return inst
end

return Prefab( "common/inventory/lureplantbulb", fn, assets),
MakePlacer( "common/lureplantbulb_placer", "eyeplant_trap", "eyeplant_trap", "idle_hidden" )

