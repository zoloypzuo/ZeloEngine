local assets = 
{
   Asset("ANIM", "anim/star.zip")
}

--Needs to save/load time alive.

local function kill_light(inst)
    inst.AnimState:PlayAnimation("disappear")
    inst:DoTaskInTime(0.6, function() inst.SoundEmitter:KillAllSounds() inst:Remove() end)    
end

local function resumestar(inst, time)
    if inst.death then
        inst.death:Cancel()
        inst.death = nil
    end
    inst.death = inst:DoTaskInTime(time, kill_light)
    inst.timeleft = time
end

local function onsave(inst, data)
    data.timealive = inst:GetTimeAlive()
    data.init_time = inst.init_time
end

local function onload(inst, data)
        if data.timealive and data.init_time then
            inst.init_time = data.init_time
            local timeleft = (inst.init_time or 120) - data.timealive
            if timeleft > 0 then
            resumestar(inst, timeleft)
        else
            kill_light(inst)
        end
    end
end

local function pulse_light(inst)
    local s = GetSineVal(0.05, true, inst)
    local rad = Lerp(4, 5, s)
    local intentsity = Lerp(0.8, 0.7, s)
    local falloff = Lerp(0.8, 0.7, s) 
    inst.Light:SetFalloff(falloff)
    inst.Light:SetIntensity(intentsity)
    inst.Light:SetRadius(rad)
    inst.Light:Enable(true)
end



local function fn(Sim)
	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
    local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()

    anim:SetBank("star")
    anim:SetBuild("star")
    anim:PlayAnimation("appear")
    anim:PushAnimation("idle_loop", true)

    MakeInventoryPhysics(inst)
  
    inst:AddComponent("inspectable")

    inst:AddComponent("cooker")

    inst:AddComponent("propagator")
    inst.components.propagator.heatoutput = 15
    inst.components.propagator.spreading = true
    inst.components.propagator:StartUpdating()

    inst:AddComponent("heater")
    inst.components.heater.heat = 180

    local light = inst.entity:AddLight()
    light:SetColour(223/255, 208/255, 69/255)
    light:Enable(false)

    inst.SoundEmitter:PlaySound("dontstarve/common/staff_star_create")
    inst.SoundEmitter:PlaySound("dontstarve/common/staff_star_LP", "loop")    

    inst:AddComponent("sanityaura")
    inst.components.sanityaura.aura = TUNING.SANITYAURA_SMALL
    inst.init_time = 120
    inst.task = inst:DoPeriodicTask(0.1, pulse_light)
    inst.death = inst:DoTaskInTime(inst.init_time, kill_light)

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end

return Prefab( "common/stafflight", fn, assets) 
