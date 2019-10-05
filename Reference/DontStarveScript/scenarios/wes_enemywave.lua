enemytypes = {"knight", "bishop", "rook"}
local cantrigger = false

local function OnEnemyKilled(inst, enemy, scenariorunner)
	if enemy.scene_killedfn then
		inst:RemoveEventCallback("death", enemy.scene_killedfn, enemy)
		enemy.scene_killedfn = nil
	end
	inst.wave[enemy] = nil
	if not next(inst.wave) then
		inst.onguardsdead(inst)
		GetPlayer().components.sanity:SetPercent(1)
		scenariorunner:ClearScenario()
	end	
end

local function ListenForDeath(inst, scenariorunner)
	for k,v in pairs(inst.wave) do
		if v.components.combat then
			v.scene_killedfn = function() OnEnemyKilled(inst, v, scenariorunner) end
			inst:ListenForEvent("death", v.scene_killedfn, v)
		end
	end
end

local function TrapInRocks(inst)
    GetPlayer().components.sanity:SetPercent(0.5)
end

local function StartWave(inst)
	local pt = Vector3(inst.Transform:GetWorldPosition())
    local theta = math.random() * 2 * PI
    local radius = 4
    local steps = math.random(4,5)
    local ground = GetWorld()
    local player = GetPlayer()
    local spawnedguards = {}
    local settarget = function(inst, player)
   		if inst and inst.brain then
       		inst.brain.followtarget = player
        end
   	end
    for i = 1, steps do
        local offset = Vector3(radius * math.cos( theta ), 0, -radius * math.sin( theta ))
        local wander_point = pt + offset
       
        if ground.Map and ground.Map:GetTileAtPoint(wander_point.x, wander_point.y, wander_point.z) ~= GROUND.IMPASSABLE then
			local particle = SpawnPrefab("poopcloud")
            particle.Transform:SetPosition( wander_point.x, wander_point.y, wander_point.z )

        	local enemy = SpawnPrefab(enemytypes[math.random(1, #enemytypes)])
            enemy.Transform:SetPosition( wander_point.x, wander_point.y, wander_point.z )
            enemy:DoTaskInTime(1, settarget, player)
            spawnedguards[enemy] = enemy
        end
        theta = theta - (2 * PI / steps)
    end
    inst:RemoveComponent("playerprox")

    return spawnedguards
end

local function OnStatueDestroyed(inst, statue)
	if statue then
		print("statuedestroyed")	
		inst.statues[statue] = nil
	end
	if not next(inst.statues) then
		cantrigger = true
	end
end

local function ListenForDestroy(inst)
	for k,v in pairs(inst.statues) do
		if v then
			print("listening")
			v:ListenForEvent("onremove", function() print("destroyed") OnStatueDestroyed(inst, v) end)
		end
	end
end

local function GetStatues(inst)
	local pt = Vector3(inst.Transform:GetWorldPosition())
	local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 100)
	local statues = {}
	for k,v in pairs(ents) do
		if v and v:HasTag("maxwell") then
			print("statuefound")
			statues[v] = v
		end
	end
	return statues
end

local function PlayerNear(inst)
	if cantrigger then
		inst.wave = StartWave(inst)
		ListenForDeath(inst, inst.sr)
		TrapInRocks(inst)
	else
		print("cant trigger")
	end
end

local function PlayerFar(inst)

end

local function OnLoad(inst, scenariorunner)
	inst.statues = GetStatues(inst)
	OnStatueDestroyed(inst, nil)
	ListenForDestroy(inst)
	inst:AddComponent("playerprox")
	inst.sr = scenariorunner
	inst.components.playerprox.onnear = PlayerNear
	inst.components.playerprox.near = 10
end

return
{
	OnLoad = OnLoad
}
