
--this is an update that always runs on wall time (not sim time)
function WallUpdate(dt)
	TheSim:ProfilerPush("LuaWallUpdate")
	if GetPlayer() then
		local x,y,z = GetPlayer().Transform:GetWorldPosition()
		TheSim:SetActiveAreaCenterpoint(x,y,z)
	end

	TheSim:ProfilerPush("updating wall components")
    for k,v in pairs(WallUpdatingEnts) do
        if v.wallupdatecomponents then
            for cmp in pairs(v.wallupdatecomponents) do
                if cmp.OnWallUpdate then
                    cmp:OnWallUpdate( dt )
                end
            end
        end
    end
    
	for k,v in pairs(NewWallUpdatingEnts) do
		WallUpdatingEnts[k] = v
		NewWallUpdatingEnts[k] = nil
    end
    
	TheSim:ProfilerPop()


	TheSim:ProfilerPush("mixer")
    TheMixer:Update(dt)
	TheSim:ProfilerPop()	

	if not IsPaused() then
		TheSim:ProfilerPush("camera")
		TheCamera:Update(dt)
		TheSim:ProfilerPop()	
	end
    
	CheckForUpsellTimeout(dt)

	TheSim:ProfilerPush("input")
    TheInput:OnUpdate()
	TheSim:ProfilerPop()	

	TheSim:ProfilerPush("fe")
	TheFrontEnd:Update(dt)
	TheSim:ProfilerPop()	
	
	TheSim:ProfilerPop()
end

function PostUpdate(dt)
	TheSim:ProfilerPush("LuaPostUpdate")
	EmitterManager:PostUpdate()
	TheSim:ProfilerPop()
end


local StaticComponentLongUpdates = {}
function RegisterStaticComponentLongUpdate(classname, fn)
	StaticComponentLongUpdates[classname] = fn
end


local StaticComponentUpdates = {}
function RegisterStaticComponentUpdate(classname, fn)
	StaticComponentUpdates[classname] = fn
end

function ProcessStopUpdatingComponents()
    for k,v in pairs(StopUpdatingComponents) do
        v:StopUpdatingComponent_Deferred(k)
    end
    StopUpdatingComponents = {}
end

-- TODO: Remove these in an update or two, they're just here to improve the information in SubmitProfile()
local PERF_updatedents = {}
local PERF_updatedcomponents = {}
local PERF_updatedentcomponents = {}

function GetLastPerfEntLists()
	return {UpdateEnts = PERF_updatedents,
		UpdateComponents = PERF_updatedcomponents,
		UpdateEntComponents = PERF_updatedentcomponents}
end

local last_tick_seen = -1
--This is where the magic happens
function Update( dt )
    HandleClassInstanceTracking()
	TheSim:ProfilerPush("LuaUpdate")    
	CheckDemoTimeout()
    
    if PLATFORM == "NACL" then
        AccumulatedStatsHeartbeat(dt)
    end
	
    
    local tick = TheSim:GetTick()
    if tick > last_tick_seen then

    	TheSim:ProfilerPush("scheduler")
        for i = last_tick_seen +1, tick do
            RunScheduler(i)
        end
		TheSim:ProfilerPop()
		
		TheSim:ProfilerPush("static components")
		for k,v in pairs(StaticComponentUpdates) do
			v(dt)
		end
        TheSim:ProfilerPop()

        -- Sometimes a component may have been set to stop since last call to
        -- this function, for example, in it's OnEntitySleep callback, so we
        -- must process these here in addition to after the loop.
        ProcessStopUpdatingComponents()

		-- This makes the profiler display much easier to read
		--local sortedents = {}
		--for k,ent in pairs(UpdatingEnts) do
			--table.insert(sortedents, ent)
		--end
		--table.sort(sortedents, function(a,b) return (a.prefab or "") < (b.prefab or "") end)
		--local lastprefab = nil

		PERF_updatedents = {}
		PERF_updatedcomponents = {}
		PERF_updatedentcomponents = {}

		TheSim:ProfilerPush("updating components")
		for k,ent in pairs(UpdatingEnts) do
        --for i,ent in ipairs(sortedents) do
			local prefab = ent.prefab or "<nil>"
			--if lastprefab ~= prefab then
				--if lastprefab ~= nil then
					--TheSim:ProfilerPop()
				--end
				--TheSim:ProfilerPush(prefab)
				--lastprefab = prefab
			--end

			if ent.updatecomponents then

				PERF_updatedents[prefab] = PERF_updatedents[prefab] and PERF_updatedents[prefab] + 1 or 1

				for cmp in pairs(ent.updatecomponents) do
					--TheSim:ProfilerPush(ent:GetComponentName(cmp))

					local name = ent:GetComponentName(cmp)
					PERF_updatedcomponents[name] = PERF_updatedcomponents[name] and PERF_updatedcomponents[name] + 1 or 1
					if PERF_updatedentcomponents[prefab] == nil then PERF_updatedentcomponents[prefab] = {} end
					PERF_updatedentcomponents[prefab][name] = PERF_updatedentcomponents[prefab][name] and PERF_updatedentcomponents[prefab][name] + 1 or 1

					if cmp.OnUpdate and not StopUpdatingComponents[cmp] then
						cmp:OnUpdate( dt )
					end
					--TheSim:ProfilerPop()
				end
			end
        end
		--if lastprefab ~= nil then
			--TheSim:ProfilerPop()
		--end

		for k,v in pairs(NewUpdatingEnts) do
			UpdatingEnts[k] = v
		end
		NewUpdatingEnts = {}

        ProcessStopUpdatingComponents()

		TheSim:ProfilerPop() -- updating components

        for i = last_tick_seen + 1, tick do
            TheSim:ProfilerPush("LuaSG")
            SGManager:Update(i)
            TheSim:ProfilerPop()
            
            TheSim:ProfilerPush("LuaBrain")
            BrainManager:Update(i)
            TheSim:ProfilerPop()
        end
    else
		print ("Saw this before")
    end
    last_tick_seen = tick
    
	TheSim:ProfilerPop()        
end


--this is for advancing the sim long periods of time (to skip nights, come back from caves, etc)
function LongUpdate(dt, ignore_player)
	--print ("LONG UPDATE", dt, ignore_player)
	local function doupdate(dt)
		for k,v in pairs(StaticComponentLongUpdates) do
			v(dt)
		end

		local player = GetPlayer()

		if player and ignore_player then
			if player.components.beard then
				player.components.beard.pause = true
			end

			if player.components.beaverness then
				player.components.beaverness.ignoremoon = true
			end
		end


		for k,v in pairs(Ents) do
			
			local should_ignore = false
			if ignore_player then
				
				if v.components.inventoryitem then
					local grand_owner = v.components.inventoryitem:GetGrandOwner()
					if grand_owner == player then
						should_ignore = true
					end
					if grand_owner and grand_owner.prefab == "chester" then
						local leader = grand_owner.components.follower.leader
						if leader and leader == player then
							should_ignore = true
						end
					end
				end
				
				if v.components.follower and v.components.follower.leader == player then
					should_ignore = true
				end

				if player == v then
					should_ignore = true
				end
			end
				
			if not should_ignore then
				v:LongUpdate(dt)	
			end
			
		end	

		if player and ignore_player then
			if player.components.beard then
				player.components.beard.pause = nil
			end

			if player.components.beaverness then
				player.components.beaverness.ignoremoon = nil
			end
		end

	end

	ExecutingLongUpdate = true
	doupdate(dt)
	ExecutingLongUpdate = false

end
