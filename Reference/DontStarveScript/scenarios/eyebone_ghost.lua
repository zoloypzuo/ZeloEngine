local function FindGraves(inst)
    local pt = Vector3(inst.Transform:GetWorldPosition())   
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 20)
    local grave_mounds = {}
    for k,v in pairs(ents) do
    	print(v.prefab)
        if v:HasTag("grave") and v.mound then
            grave_mounds[v.mound] = v.mound
        end
    end

    return grave_mounds
end

local function SpawnGhostsOnGraves(graves, scenariorunner)
	local player = GetPlayer()
	local settarget = function(inst, player)
		if inst and inst.brain then
       		inst.brain.followtarget = player
        end
	end
	for k,v in pairs(graves) do
		local pt = Vector3(v.Transform:GetWorldPosition())
		local ghost = SpawnPrefab("ghost")
		print("spawn ghost")
		ghost.Transform:SetPosition(pt.x, pt.y, pt.z)
		ghost:DoTaskInTime(1, settarget, player)
	end	
end

local function OnLoad(inst, scenariorunner)
	inst.moundlist = FindGraves(inst)
	inst.scene_pickupfn = function()
		SpawnGhostsOnGraves(inst.moundlist, scenariorunner)
		scenariorunner:ClearScenario()
	end
	inst:ListenForEvent("onpickup", inst.scene_pickupfn)
end

local function OnDestory(inst)
	if inst.scene_pickupfn then
		inst:RemoveEventCallback("onpickup", inst.scene_pickupfn)
		inst.scene_pickupfn = nil
	end
end	


return
{
	OnLoad = OnLoad,
	OnDestory = OnDestory
}