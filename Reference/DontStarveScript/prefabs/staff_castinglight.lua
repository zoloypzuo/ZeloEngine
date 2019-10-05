local easing = require("easing")


local function OnUpdate(inst)
	inst.LightTimer = inst.LightTimer + FRAMES
	inst.Light:SetRadius(easing.inQuint(inst.LightTimer, 0.3, 10, inst.LightDuration))
	inst.Light:SetIntensity(easing.inQuint(inst.LightTimer, 0.8, -0.6, inst.LightDuration))
	inst.Light:SetFalloff(easing.inQuint(inst.LightTimer, 0.9, -0.4, inst.LightDuration))
	if inst.LightTimer >= inst.LightDuration then
		inst:Remove()
	end	
end

local function SetUp(inst, colour, duration, delay)
	--Set colour
	inst.LightTimer = 0
	inst.LightDuration = duration

	inst.entity:AddLight()
	inst.Light:SetColour(colour[1], colour[2], colour[3])
	inst.Light:SetRadius(0.3)
	inst.Light:SetIntensity(.8)
	inst.Light:SetFalloff(0.9)
	local delay = delay or 0
	inst:DoTaskInTime(delay, function() inst:DoPeriodicTask(FRAMES, OnUpdate) end)	
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()

	inst.setupfn = SetUp

	inst.persists = false

	return inst
end

return Prefab("common/staff_castinglight", fn)