local assets=
{
	Asset("ANIM", "anim/cave_exit_lightsource.zip"),
}

local START_RAD = 4
local TOTAL_TIME = 30
local dt = 1/30


local function update(inst)
	if not inst.rad then
		inst.rad = START_RAD
	end
	inst.rad = inst.rad - dt*(START_RAD/TOTAL_TIME)
	inst.Light:SetRadius(inst.rad)
	if inst.rad <= 0 then
		inst:Remove()
	end
end

local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

	inst.OnEntitySleep = OnEntitySleep
	inst.OnEntityWake = OnEntityWake

    anim:SetBank("cavelight")
    anim:SetBuild("cave_exit_lightsource")
    anim:PlayAnimation("idle_loop", true)

    inst:AddTag("NOCLICK")
    --anim:PlayAnimation("down")
    --anim:PushAnimation("idle_loop", true)

    local light = inst.entity:AddLight()
    light:SetFalloff(0.3)
    light:SetIntensity(.9)
    light:SetRadius(START_RAD)
    light:SetColour(180/255, 195/255, 150/255)
    light:Enable(true)

    inst.AnimState:SetMultColour(255/255,177/255,32/255,0)
	inst:DoPeriodicTask(dt, update, 2)
	inst.persists = false
	
    return inst
end

return Prefab( "common/exitcavelight", fn, assets)
