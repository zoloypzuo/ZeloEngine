local assets=
{
	Asset("ANIM", "anim/heat_rock.zip"),
	Asset("INV_IMAGE", "heat_rock1"),
	Asset("INV_IMAGE", "heat_rock2"),
	Asset("INV_IMAGE", "heat_rock3"),
	Asset("INV_IMAGE", "heat_rock4"),
	Asset("INV_IMAGE", "heat_rock5"),
}


local function HeatFn(inst, observer)
	return inst.components.temperature:GetCurrent()
end

local function GetStatus(inst)
	if inst.currentTempRange == 1 then
		return "COLD"
	elseif inst.currentTempRange == 5 then
		return "HOT"
	elseif inst.currentTempRange == 4 or inst.currentTempRange == 3 then
		return "WARM"
	end
end

-- These represent the boundaries between the images
local temperature_thresholds = { 0, 25, 40, 50 }

local function GetRangeForTemperature(temp)
	local range = 1
	for i,v in ipairs(temperature_thresholds) do
		if temp > v then
			range = range + 1
		end
	end
	return range
end

local function UpdateImages(inst, range)
	inst.currentTempRange = range
	inst.AnimState:PlayAnimation(tostring(range), true)
	inst.components.inventoryitem:ChangeImageName("heat_rock"..tostring(range))
	if range == 5 then
		inst.AnimState:SetBloomEffectHandle( "shaders/anim.ksh" )
		inst.Light:Enable(true)
	else
		inst.AnimState:ClearBloomEffectHandle()
		inst.Light:Enable(false)
	end
end

local function AdjustLighting(inst)
	local hottest = inst.components.temperature.maxtemp - temperature_thresholds[#temperature_thresholds]
	local current = inst.components.temperature.current - temperature_thresholds[#temperature_thresholds]
	local ratio = current/hottest
	inst.Light:SetIntensity(0.5 * ratio)
end

local function TemperatureChange(inst, data)
	AdjustLighting(inst)
	local range = GetRangeForTemperature(inst.components.temperature.current)
	if range ~= inst.currentTempRange then
		UpdateImages(inst, range)
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	inst.entity:AddTransform()
	inst.entity:AddAnimState()

    MakeInventoryPhysics(inst)
    
    inst.AnimState:SetBank("heat_rock")
    inst.AnimState:SetBuild("heat_rock")
    
    inst:AddComponent("inspectable")
	inst.components.inspectable.getstatus = GetStatus
    
    inst:AddComponent("inventoryitem")

	inst:AddComponent("temperature")
	inst.components.temperature.maxtemp = 60
	inst.components.temperature.current = 1
	inst.components.temperature.inherentinsulation = TUNING.INSULATION_MED

	inst:AddComponent("heater")
	inst.components.heater.heatfn = HeatFn
	inst.components.heater.carriedheatfn = HeatFn
	
    inst.entity:AddLight()
	inst.Light:SetRadius(.6)
    inst.Light:SetFalloff(1)
    inst.Light:SetIntensity(.5)
    inst.Light:SetColour(235/255,165/255,12/255)
	inst.Light:Enable(false)
	inst.Light:SetDisableOnSceneRemoval(false)

	inst:ListenForEvent("temperaturedelta", TemperatureChange)
	inst.currentTempRange = 0
	UpdateImages(inst, 1)

	-- InventoryItems automatically enable their lights when dropped, so we need to counteract that
	inst:ListenForEvent("ondropped", function(inst)
		if inst.currentTempRange ~= 5 then
			inst.Light:Enable(false)
		end
	end)

	return inst
end

return Prefab( "common/inventory/heatrock", fn, assets) 
