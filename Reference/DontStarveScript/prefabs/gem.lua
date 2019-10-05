local assets=
{
	Asset("ANIM", "anim/gems.zip"),
    Asset("INV_IMAGE", "icegem"),
}

local function buildgem(colour)
    local fn = function()
        local Sparkle = function(inst)
            inst.AnimState:PlayAnimation(colour.."gem_sparkle")
            inst.AnimState:PushAnimation(colour.."gem_idle")
            inst.sparkletask = inst:DoTaskInTime(4 + math.random(), inst.sparklefn)
        end

        local StartSparkling = function(inst)
            inst.sparkletask = inst:DoTaskInTime(1, inst.sparklefn)
        end

        local StopSparkling = function(inst)
            if inst.sparkletask then
                inst.sparkletask:Cancel()
                inst.sparkletask = nil
            end
        end

    	local inst = CreateEntity()
    	inst.entity:AddTransform()
    	inst.entity:AddAnimState()
        inst.entity:AddSoundEmitter()
            
        inst.AnimState:SetBank("gems")
        inst.AnimState:SetBuild("gems")
        inst.AnimState:PlayAnimation(colour.."gem_idle")
        MakeInventoryPhysics(inst)

        inst:AddComponent("edible")
        inst.components.edible.foodtype = "ELEMENTAL"
        inst:AddComponent("tradable")
        inst.components.edible.hungervalue = 5
        
	    inst:AddComponent("repairer")
	    inst.components.repairer.repairmaterial = "gem"
	    inst.components.repairer.workrepairvalue = TUNING.REPAIR_GEMS_WORK

        inst:AddComponent("stackable")
    	inst.components.stackable.maxsize = TUNING.STACK_SIZE_SMALLITEM

        inst:AddComponent("inspectable")
        
        inst:AddComponent("inventoryitem")

        inst.sparklefn = Sparkle
        
        StartSparkling(inst)
        return inst
    end

    return fn
end

return Prefab( "common/inventory/purplegem", buildgem("purple"), assets),
 Prefab( "common/inventory/bluegem", buildgem("blue"), assets),
 Prefab( "common/inventory/redgem", buildgem("red"), assets),
 Prefab( "common/inventory/orangegem", buildgem("orange"), assets),
 Prefab( "common/inventory/yellowgem", buildgem("yellow"), assets),
 Prefab( "common/inventory/greengem", buildgem("green"), assets)

