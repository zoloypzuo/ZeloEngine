local assets =
{
	Asset("ANIM", "anim/pig_torch.zip"),
	Asset("SOUND", "sound/common.fsb"),
}

local prefabs = 
{
	"pigtorch_flame",
	"pigtorch_fuel",
	"pigguard",
}

local function onhammered(inst, worker)
	inst.components.lootdropper:DropLoot()
	SpawnPrefab("collapse_small").Transform:SetPosition(inst.Transform:GetWorldPosition())
	inst.SoundEmitter:PlaySound("dontstarve/common/destroy_wood")
	inst:Remove()
end

local function onhit(inst,worker)
	if inst.components.spawner.child and inst.components.spawner.child.components.combat then
	    inst.components.spawner.child.components.combat:SuggestTarget(worker)
	end
	inst.AnimState:PlayAnimation("hit")
	inst.AnimState:PushAnimation("idle")
end

local function onextinguish(inst)
    if inst.components.fueled then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
	inst.entity:AddSoundEmitter()

	MakeObstaclePhysics(inst, 0.33)

	inst:AddComponent("inspectable")


	inst:AddComponent("burnable")
	inst.components.burnable:AddBurnFX("pigtorch_flame", Vector3(-5, 40, 0), "fire_marker")
    inst:ListenForEvent("onextinguish", onextinguish) --in case of creepy hands

    inst:AddComponent("fueled")
    inst.components.fueled.accepting = true
    inst.components.fueled.maxfuel = TUNING.PIGTORCH_FUEL_MAX
    inst.components.fueled:SetSections(3)
    inst.components.fueled.fueltype = "PIGTORCH"    
    inst.components.fueled:SetUpdateFn( function()
        if GetSeasonManager():IsRaining() then
            inst.components.fueled.rate = 1 + TUNING.PIGTORCH_RAIN_RATE*GetSeasonManager():GetPrecipitationRate()
        else
            inst.components.fueled.rate = 1
        end
        
        if inst.components.burnable and inst.components.fueled then
            inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
        end
    end)
    inst.components.fueled:SetSectionCallback( function(section)
        if section == 0 then
            inst.components.burnable:Extinguish()
        else
            if not inst.components.burnable:IsBurning() then
                inst.components.burnable:Ignite()
            end
            
            inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent())
        end
    end)
    inst.components.fueled:InitializeFuelLevel(TUNING.PIGTORCH_FUEL_MAX)

	anim:SetBank("pigtorch")
	anim:SetBuild("pig_torch")
	anim:PlayAnimation("idle", true)


	inst:AddTag("structure")
	inst:AddComponent("lootdropper")
	inst.components.lootdropper:SetLoot({"log", "log", "log", "poop"})
	inst:AddComponent("workable")
	inst.components.workable:SetWorkAction(ACTIONS.HAMMER)
	inst.components.workable:SetWorkLeft(4)
	inst.components.workable:SetOnFinishCallback(onhammered)
	inst.components.workable:SetOnWorkCallback(onhit)
	
	inst:AddComponent( "spawner" )
    inst.components.spawner:Configure( "pigguard", TUNING.TOTAL_DAY_TIME*4)
    inst.components.spawner:SetOnlySpawnOffscreen(true)
	--MakeSnowCovered(inst, .01)
	return inst
end

local function pigtorch_fuel()
	local inst = CreateEntity()
	inst.entity:AddTransform()
    inst:AddComponent("fuel")
    inst.components.fuel.fuelvalue = TUNING.PIGTORCH_FUEL_MAX
    inst.components.fuel.fueltype = "PIGTORCH"
    inst:AddComponent("inventoryitem")
    inst.components.inventoryitem:SetOnDroppedFn(function() inst:Remove() end )
	return inst
end

return Prefab("forest/objects/pigtorch", fn, assets, prefabs),
       Prefab("forest/object/pigtorch_fuel", pigtorch_fuel) 
