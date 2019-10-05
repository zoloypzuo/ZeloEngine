local assets =
{
	Asset("ANIM", "anim/nightmare_crack_ruins.zip"),
	Asset("ANIM", "anim/nightmare_crack_upper.zip"),
}

local prefabs =
{
	"nightmarebeak",
	"crawlingnightmare",
    "nightmarefissurefx",
    "upper_nightmarefissurefx"
}

local transitionTime = 1

local topLightColour = {239/255, 194/255, 194/255}

local function returnchildren(inst)
    for k,child in pairs(inst.components.childspawner.childrenoutside) do
        if child.components.combat then
            child.components.combat:SetTarget(nil)
        end

        if child.components.lootdropper then
            child.components.lootdropper:SetLoot({})
        end

        if child.components.health then
            child.components.health:Kill()
        end
    end
end

local function spawnchildren(inst)
    if inst.components.childspawner then
        inst.components.childspawner:StartSpawning()
        inst.components.childspawner:StopRegen()
    end 
end

local function killchildren(inst)
    if inst.components.childspawner then
        inst.components.childspawner:StopSpawning()
        inst.components.childspawner:StartRegen()
        returnchildren(inst)
    end 
end

local function dofx(inst)
    fx = SpawnPrefab("statue_transition")
    if fx then
        fx.Transform:SetPosition(inst.Transform:GetWorldPosition())
        fx.AnimState:SetScale(1,1.5,1)
    end
end

local function turnoff(inst, light)
    if light then
        light:Enable(false)
    end
end

local function spawnfx(inst)
    if not inst.fx then
        inst.fx = SpawnPrefab(inst.fxprefab)
        local pos = inst:GetPosition()
        inst.fx.Transform:SetPosition(pos.x, -0.1, pos.z)
    end
end

local states =
{
    calm = function(inst, instant)
        inst.SoundEmitter:KillSound("loop")

        RemovePhysicsColliders(inst)

        inst.Light:Enable(true)
        inst.components.lighttweener:StartTween(nil, 0, nil, nil, nil, (instant and 0) or .33, turnoff) 
        if not instant then
            inst.AnimState:PushAnimation("close_2") 
            inst.AnimState:PushAnimation("idle_closed")

            inst.fx.AnimState:PushAnimation("close_2") 
            inst.fx.AnimState:PushAnimation("idle_closed")
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_close")
        else
            inst.AnimState:PlayAnimation("idle_closed")
            inst.fx.AnimState:PlayAnimation("idle_closed")            
        end


        killchildren(inst)
    end,

    warn = function(inst, instant)

        ChangeToObstaclePhysics(inst)
        inst.Light:Enable(true)
        inst.components.lighttweener:StartTween(nil, 2, nil, nil, nil, (instant and 0) or  0.5)
        inst.AnimState:PlayAnimation("open_1") 
        inst.fx.AnimState:PlayAnimation("open_1")
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_warning")
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")
    end,

    nightmare = function(inst, instant)

        ChangeToObstaclePhysics(inst)
        inst.Light:Enable(true)
        inst.components.lighttweener:StartTween(nil, 5, nil, nil, nil, (instant and 0) or 0.5)
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open")
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")


        if not instant then
            inst.AnimState:PlayAnimation("open_2")
            inst.AnimState:PushAnimation("idle_open")

            inst.fx.AnimState:PlayAnimation("open_2")
            inst.fx.AnimState:PushAnimation("idle_open")
            inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open")
        else
            inst.AnimState:PlayAnimation("idle_open")

            inst.fx.AnimState:PlayAnimation("idle_open")
        end

        spawnchildren(inst)
    end,

    dawn = function(inst, instant)
        ChangeToObstaclePhysics(inst)
        inst.Light:Enable(true)
        inst.components.lighttweener:StartTween(nil, 2, nil, nil, nil, (instant and 0) or 0.5)
        inst.SoundEmitter:KillSound("loop")
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open")
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_fissure_open_LP", "loop")

        inst.AnimState:PlayAnimation("close_1")
        inst.fx.AnimState:PlayAnimation("close_1")
       
        inst.SoundEmitter:PlaySound("dontstarve/cave/nightmare_spawner_open")

        spawnchildren(inst)
    end
}


local function phasechange(inst, data)
    local statefn = states[data.newphase]

    if statefn then
        spawnfx(inst)
        inst.state = data.newphase
        inst:DoTaskInTime(math.random() * 2, statefn)
    end
end

local function getsanityaura(inst)
    if inst.state == "calm" then
        return 0
    elseif inst.state == "warn" then
        return -TUNING.SANITY_SMALL
    else
        return -TUNING.SANITY_MED
    end
end

local function nextphase(inst)
    spawnfx(inst)
    local nexttime = 0
    if inst.state =="calm" then
        inst.state = "warn"
        nexttime = math.random(TUNING.FISSURE_WARNTIME_MIN, TUNING.FISSURE_WARNTIME_MAX)
    elseif inst.state == "warn" then
        inst.state = "nightmare"
        nexttime = math.random(TUNING.FISSURE_NIGHTMARETIME_MIN, TUNING.FISSURE_NIGHTMARETIME_MAX)
    elseif inst.state == "nightmare" then
        inst.state = "dawn"
        nexttime = math.random(TUNING.FISSURE_DAWNTIME_MIN, TUNING.FISSURE_DAWNTIME_MAX)
    else
        inst.state = "calm"
        nexttime = math.random(TUNING.FISSURE_CALMTIME_MIN, TUNING.FISSURE_CALMTIME_MAX)
    end


    local statefn = states[inst.state]

    if statefn then
        inst:DoTaskInTime(math.random() * 2, statefn)
    end

    if inst.task then inst.task:Cancel() inst.task = nil end
    inst.taskinfo = nil

    inst.task, inst.taskinfo = inst:ResumeTask(nexttime, nextphase)

end

local function onload(inst, data)
    if not data then
        return
    end
    if data.state then
        inst.state = data.state
        spawnfx(inst)
        states[inst.state](inst, true)
    end

    if data.timeleft then
        if inst.task then inst.task:Cancel() inst.task = nil end
        inst.taskinfo = nil
        inst.task, inst.taskinfo = inst:ResumeTask(data.timeleft, nextphase)
    end
end


local function onsave(inst, data)
    if inst.state then
        data.state = inst.state
    end

    if inst.taskinfo then
        data.timeleft = inst:TimeRemainingInTask(inst.taskinfo)
    end
end

local function commonfn(type)

	local inst = CreateEntity()
	local trans = inst.entity:AddTransform()
	local anim = inst.entity:AddAnimState()
    inst.entity:AddSoundEmitter()
    
    MakeObstaclePhysics(inst, 1.2)
    RemovePhysicsColliders(inst)

    anim:SetBuild(type)
    anim:SetBank(type)
    anim:PlayAnimation("idle_closed")

    inst:AddComponent( "childspawner" )
    inst.components.childspawner:SetRegenPeriod(5)
    inst.components.childspawner:SetSpawnPeriod(30)
    inst.components.childspawner:SetMaxChildren(1)
    inst.components.childspawner.childname = "crawlingnightmare"
    inst.components.childspawner:SetRareChild("nightmarebeak", 0.35)

    inst:AddComponent("lighttweener")
    inst.entity:AddLight()

    inst.OnLoad = onload
    inst.OnSave = onsave

    return inst
end


local function upper()
    local inst = commonfn("nightmare_crack_upper")
    inst.components.lighttweener:StartTween(inst.Light, 1, .9, 0.9, topLightColour, 0, turnoff)
    --Not hooked into nightmare clock. We want this to be more random/ less often than the clock.
    inst.state = "calm"
    inst.task, inst.taskinfo = inst:ResumeTask(math.random(TUNING.FISSURE_CALMTIME_MIN, TUNING.FISSURE_CALMTIME_MAX), nextphase)
    inst.fxprefab = "upper_nightmarefissurefx"
    return inst
end

local function lower()
	local inst = commonfn("nightmare_crack_ruins")
    inst.components.lighttweener:StartTween(inst.Light, 1, .9, 0.9, {1,1,1}, 0, turnoff)
    inst.state = "calm"
    inst.fxprefab = "nightmarefissurefx"
    inst:ListenForEvent("phasechange", function(world, data) phasechange(inst, data) end, GetWorld())
	return inst
end


return Prefab( "cave/objects/fissure", upper, assets, prefabs),
Prefab("cave/objects/fissure_lower", lower, assets, prefabs)


