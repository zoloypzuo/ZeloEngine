local assets=
{
	Asset("ANIM", "anim/cave_exit_lightsource.zip"),
}

local function OnEntityWake(inst)
    inst.SoundEmitter:PlaySound("dontstarve/cave/forestAMB_spot", "loop")
end

local function OnEntitySleep(inst)
	inst.SoundEmitter:KillSound("loop")
end

local function turnoff(inst, light)
    if light then
        light:Enable(false)
    end
    inst:Hide()
end

local phasefunctions = 
{
    day = function(inst)
        inst.Light:Enable(true)
        inst:Show()
        inst.components.lighttweener:StartTween(nil, 5, .9, .3, {180/255, 195/255, 150/255}, 2)
    end,

    dusk = function(inst) 
        inst.Light:Enable(true)
        inst.components.lighttweener:StartTween(nil, 5, .6, .6, {91/255, 164/255, 255/255}, 4)
    end,

    night = function(inst) 
        inst.components.lighttweener:StartTween(nil, 0, 0, 1, {0,0,0}, 6, turnoff)
    end,
}

local function timechange(inst)
    local c = GetClock()
    local p = c:GetPhase()
    phasefunctions[p](inst)
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

    inst:ListenForEvent("daytime", function() timechange(inst) end, GetWorld())
    inst:ListenForEvent("dusktime", function() timechange(inst) end, GetWorld())
    inst:ListenForEvent("nighttime", function() timechange(inst) end, GetWorld())

    inst:AddComponent("lighttweener")
    inst.components.lighttweener:StartTween(inst.entity:AddLight(), 5, .9, .3, {180/255, 195/255, 150/255}, 0)

    inst.AnimState:SetMultColour(255/255,177/255,32/255,0)

    return inst
end

return Prefab( "common/cavelight", fn, assets) 
