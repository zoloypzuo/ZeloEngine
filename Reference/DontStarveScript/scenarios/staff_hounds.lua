local function settrap_hounds(inst)
    local pt = Vector3(inst.Transform:GetWorldPosition())   
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 20)
    local staff_hounds = {}
    for k,v in pairs(ents) do
        if v and v.sg and v:HasTag("hound") then
            v.components.sleeper.hibernate = true
            v.sg:GoToState("forcesleep")
            table.insert(staff_hounds, v)        
        end
    end
    return staff_hounds
end

local function TriggerTrap(inst, scenariorunner, hounds)
	--Here we wake the dogs up if they exist then stop waiting to spring the trap.
    local player = GetPlayer()
    player.components.sanity:DoDelta(-TUNING.SANITY_HUGE)
    GetWorld().components.seasonmanager:ForcePrecip()
    for wakeup = 1, #hounds do
        hounds[wakeup].components.sleeper.hibernate = false
        inst:DoTaskInTime(math.random(1,3), function() hounds[wakeup].sg:GoToState("wake") end)
    end
	scenariorunner:ClearScenario()
end

local function OnLoad(inst, scenariorunner)
	local hounds = settrap_hounds(inst)
    inst.scene_putininventoryfn = function() TriggerTrap(inst, scenariorunner, hounds) end
	inst:ListenForEvent("onputininventory", inst.scene_putininventoryfn)
end

local function OnDestroy(inst)
    if inst.scene_putininventoryfn then
        inst:RemoveEventCallback("onputininventory", inst.scene_putininventoryfn)
        inst.scene_putininventoryfn = nil
    end
end

return
{
	OnLoad = OnLoad,
	OnDestroy = OnDestroy
}