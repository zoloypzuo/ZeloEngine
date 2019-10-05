local function FindGraves(inst)
    local pt = Vector3(inst.Transform:GetWorldPosition())   
    local ents = TheSim:FindEntities(pt.x, pt.y, pt.z, 20)
    local grave_mounds = {}
    for k,v in pairs(ents) do
        if v and v:HasTag("grave") and v.mound then
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
		if v then
			local pt = Vector3(v.Transform:GetWorldPosition())
			local ghost = SpawnPrefab("ghost")
			ghost.Transform:SetPosition(pt.x, pt.y, pt.z)
			ghost:DoTaskInTime(1, settarget, player)
		end
	end
	scenariorunner:ClearScenario()
end

local function OnCreate(inst, scenariorunner)

end

local function OnGraveDug(inst, mound, scenariorunner)
	if mound.scene_workfinishedfn then
		inst:RemoveEventCallback("workfinished", mound.scene_workfinishedfn, mound)
		mound.scene_workfinishedfn = nil
	end

	inst.moundlist[mound] = nil
	if not next(inst.moundlist) then		
		SpawnGhostsOnGraves(FindGraves(inst), scenariorunner)
	end	
end

local function OnLoad(inst, scenariorunner)
	inst.moundlist = FindGraves(inst)
	for k,v in pairs(inst.moundlist) do
		if v.components.workable then
			v.scene_workfinishedfn = function() OnGraveDug(inst, v, scenariorunner) end
			inst:ListenForEvent("workfinished", v.scene_workfinishedfn, v)
		else
			inst.moundlist[v] = nil
		end
	end
end

local function OnDestroy(inst)

end

return
{
	OnCreate = OnCreate,
	OnLoad = OnLoad,
	OnDestroy = OnDestroy
}