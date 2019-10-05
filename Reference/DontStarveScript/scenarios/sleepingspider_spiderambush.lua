local function OnWakeUp(inst, scenariorunner)
-- Spawn spider queen here, disable scenario.

	inst.components.sleeper.hibernate = false

	local pt = Vector3(inst.Transform:GetWorldPosition())
    local theta = math.random() * 2 * PI
    local radius = 15
    local steps = 3
    local ground = GetWorld()
    local player = GetPlayer()
    
    local settarget = function(inst, player)
        if inst and inst.brain then
       		inst.brain.followtarget = player
        end
   	end

    -- Walk the circle trying to find a valid spawn point
    for i = 1, steps do
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        local wander_point = pt + offset
       
        if ground.Map and ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z) ~= GROUND.IMPASSABLE then
        	local particle = SpawnPrefab("poopcloud")
            particle.Transform:SetPosition( wander_point.x, wander_point.y, wander_point.z )

        	local spider = SpawnPrefab("spider_warrior")
            spider.Transform:SetPosition( wander_point.x, wander_point.y, wander_point.z )
            spider:DoTaskInTime(1, settarget, player)
        end
        theta = theta - (2 * PI / steps)
    end

	scenariorunner:ClearScenario()
end


local function OnCreate(inst, scenariorunner)
--Anything that needs to happen only once. IE: Putting loot in a chest.
--"I'm different."
end


local function OnLoad(inst, scenariorunner)
--Anything that needs to happen every time the game loads.
	if inst.sg then
		inst.sg:GoToState("sleep")
		inst.components.sleeper.hibernate = true
	end

    inst.scene_attackedfn = function() OnWakeUp(inst, scenariorunner) end
	inst:ListenForEvent("attacked", inst.scene_attackedfn)

end


local function OnDestroy(inst)
    --Stop any event listeners here.
    if inst.scene_attackedfn then
        inst:RemoveEventCallback("attacked", inst.scene_attackedfn)
        inst.scene_attackedfn = nil
    end
end

return 
{
	OnCreate = OnCreate,
	OnLoad = OnLoad,
	OnDestroy = OnDestroy
}