require "prefabutil"

local assets =
{
	Asset("ANIM", "anim/campfire.zip"),
    Asset("INV_IMAGE", "campfire"),
}

local prefabs =
{
    "campfirefire",
}    

local function onignite(inst)
    if not inst.components.cooker then
        inst:AddComponent("cooker")
    end
end

local function onextinguish(inst)
    if inst.components.cooker then
        inst:RemoveComponent("cooker")
    end
    if inst.components.fueled then
        inst.components.fueled:InitializeFuelLevel(0)
    end
end

local function destroy(inst)
	local time_to_wait = 1
	local time_to_erode = 1
	local tick_time = TheSim:GetTickTime()

	if inst.DynamicShadow then
        inst.DynamicShadow:Enable(false)
    end

	inst:StartThread( function()
		local ticks = 0
		while ticks * tick_time < time_to_wait do
			ticks = ticks + 1
			Yield()
		end

		ticks = 0
		while ticks * tick_time < time_to_erode do
			local erode_amount = ticks * tick_time / time_to_erode
			inst.AnimState:SetErosionParams( erode_amount, 0.1, 1.0 )
			ticks = ticks + 1
			Yield()
		end
		inst:Remove()
	end)
end

local function fn(Sim)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    
    anim:SetBank("campfire")
    anim:SetBuild("campfire")
    anim:PlayAnimation("idle",false)
    
    inst.AnimState:SetRayTestOnBB(true);
    inst:AddTag("campfire")
    
    MakeObstaclePhysics(inst, .2)    
    -----------------------

    -----------------------
    inst:AddComponent("propagator")
    -----------------------
    
    inst:AddComponent("burnable")
    --inst.components.burnable:SetFXLevel(2)
    inst.components.burnable:AddBurnFX("campfirefire", Vector3() )
    inst:ListenForEvent("onextinguish", onextinguish)
    inst:ListenForEvent("onignite", onignite)

    -------------------------
    inst:AddComponent("fueled")
    inst.components.fueled.maxfuel = TUNING.CAMPFIRE_FUEL_MAX
    inst.components.fueled.accepting = true
    
    inst.components.fueled:SetSections(4)
    
    inst.components.fueled.ontakefuelfn = function() inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel") end
    inst.components.fueled:SetUpdateFn( function()
        if inst.components.burnable and inst.components.fueled then
            if GetSeasonManager():IsRaining() then
                inst.components.fueled.rate = 1 + TUNING.CAMPFIRE_RAIN_RATE*GetSeasonManager():GetPrecipitationRate()
            else
                inst.components.fueled.rate = 1
            end

            inst.components.burnable:SetFXLevel(inst.components.fueled:GetCurrentSection(), inst.components.fueled:GetSectionPercent())
        end
    end)
    
    inst.components.fueled:SetSectionCallback(
        function(section)
            if section == 0 then
                inst.components.burnable:Extinguish() 
                anim:PlayAnimation("dead") 
                RemovePhysicsColliders(inst)             

				local ash = SpawnPrefab("ash")
				ash.Transform:SetPosition(inst.Transform:GetWorldPosition())

                inst.components.fueled.accepting = false
                inst:RemoveComponent("cooker")
                inst:RemoveComponent("propagator")
                destroy(inst)            
            else
                anim:PlayAnimation("idle") 
                inst.components.burnable:SetFXLevel(section, inst.components.fueled:GetSectionPercent() )
                inst.components.fueled.rate = 1
                
                local ranges = {1,2,3,4}
                local output = {2,5,5,10}
                inst.components.propagator.propagaterange = ranges[section]
                inst.components.propagator.heatoutput = output[section]
            end
        end)
        
    inst.components.fueled:InitializeFuelLevel(TUNING.CAMPFIRE_FUEL_START)
    
    -----------------------------
    
    inst:AddComponent("inspectable")
    inst.components.inspectable.getstatus = function(inst)
        local sec = inst.components.fueled:GetCurrentSection()
        if sec == 0 then 
            return "OUT"
        elseif sec <= 4 then
            local t= {"EMBERS","LOW","NORMAL","HIGH"} 
            return t[sec]
        end
    end
    
    --------------------
    
    inst.components.burnable:Ignite()
    inst:ListenForEvent( "onbuilt", function()
        anim:PlayAnimation("place")
        anim:PushAnimation("idle",false)
        inst.SoundEmitter:PlaySound("dontstarve/common/fireAddFuel")
    end)
    
    return inst
end

return Prefab( "common/objects/campfire", fn, assets, prefabs),
		MakePlacer( "common/campfire_placer", "campfire", "campfire", "preview" ) 
