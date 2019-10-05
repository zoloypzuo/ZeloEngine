local assets = 
{
	Asset("ANIM", "anim/cave_exit_lightsource.zip"),
}

local lightColour = {180/255, 195/255, 150/255}

local function TurnOn(inst)
	inst.AnimState:PlayAnimation("on")
	inst.AnimState:PushAnimation("idle_loop", false)
    inst.components.lighttweener:StartTween(inst.Light, 0, .9, .9, nil, 0)    
    inst.components.lighttweener:StartTween(inst.Light, 1.5, nil, nil, nil, FRAMES*6)
end

local function TurnOff(inst)
	inst.AnimState:PlayAnimation("off")
    inst.components.lighttweener:StartTween(inst.Light, 0, nil, nil, nil, FRAMES*6)
	inst:ListenForEvent("animover", function() inst:Remove() end)	
end

local function fn()
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()

	inst.TurnOn = TurnOn
	inst.TurnOff = TurnOff

	anim:SetBank("cavelight")
	anim:SetBuild("cave_exit_lightsource")

	inst:AddTag("NOCLICK")

	local light = inst.entity:AddLight()
	light:SetRadius(5)
	light:SetIntensity(0.9)
	light:SetFalloff(0.3)
	light:SetColour(lightColour[1], lightColour[2], lightColour[3])


	inst:AddComponent("lighttweener")

	return inst
end

return Prefab("fx/chesterlight", fn, assets)