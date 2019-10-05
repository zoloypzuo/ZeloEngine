local player = nil
local world = nil
local ceiling = nil
function GetPlayer()
    if not player then
        player = TheSim:FindFirstEntityWithTag("player")
    end
    return player
end
function GetWorld() 
    if not world then
        world = TheSim:FindFirstEntityWithTag("ground") 
    end
    return world
end
function GetCeiling() 
    if not ceiling then
        ceiling = TheSim:FindFirstEntityWithTag("ceiling")
    end
    return ceiling
end
function GetMap() if GetWorld() then return GetWorld().Map end end
function GetClock() if GetWorld() and GetWorld().components then return GetWorld().components.clock end end
function GetNightmareClock() if GetWorld() and GetWorld().components then return GetWorld().components.nightmareclock end end
function GetSeasonManager() if GetWorld() and GetWorld().components then return GetWorld().components.seasonmanager end  end
function GetMoistureManager() if GetWorld() and GetWorld().components then return GetWorld().components.moisturemanager end  end

function FindEntity(inst, radius, fn, musttags, canttags, mustoneoftags)
    if inst and inst:IsValid() then
		local x,y,z = inst.Transform:GetWorldPosition()
			
		--print ("FIND", inst, radius, musttags and #musttags or 0, canttags and #canttags or 0, mustoneoftags and #mustoneoftags or 0)
		local ents = TheSim:FindEntities(x,y,z, radius, musttags, canttags, mustoneoftags) -- or we could include a flag to the search?
		for k, v in pairs(ents) do
			if v ~= inst and v:IsValid() and v.entity:IsVisible() and (not fn or fn(v, inst)) then
				return v
			end
		end
	end
end

function GetRandomInstWithTag(tag, inst, radius)
    local trans = inst.Transform
    local tags = (type(tag)=="string" and {tag}) or tag
    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, radius, tags)
    if #ents > 0 then
        return ents[math.random(1,#ents)]
    else
        return nil
    end
end

function GetClosestInstWithTag(tag, inst, radius)
        local trans = inst.Transform
        local tags = {tag}
        local x,y,z = trans:GetWorldPosition()
        local ents = TheSim:FindEntities(x,y,z, radius, tags)
        for k,v in pairs(ents) do
            if v ~= inst then return v end
        end
end


function DeleteCloseEntsWithTag(inst, tag, distance)
    local trans = inst.Transform
    local tags = {tag}
    local x,y,z = trans:GetWorldPosition()
    local ents = TheSim:FindEntities(x,y,z, distance, tags)
    --print("Found", GetTableSize(ents), "close",tag,"things")
    for k,v in pairs(ents) do
       -- print("\n Removing", v)
        v:Remove()
    end
end

function fadeout(inst, time)
   
    local mult = 1
    local ticktime = GetTickTime()
    
    local r,g,b,a = inst.AnimState:GetMultColour()
    local delta = ticktime/time
    while mult > 0 do
        inst.AnimState:SetMultColour(r,g,b,mult)
        Yield()
        mult = mult - delta
    end
    inst.AnimState:SetMultColour(r,g,b,0)
    inst:PushEvent("fadecomplete")
end

function PlayFX(position, bank, build, anim, sound, sounddelay, tint, tintalpha)
	--[[
    local inst = CreateEntity()
    
    
    inst:AddTag("FX")
    inst.entity:AddTransform()
    inst.entity:AddAnimState()
    inst.Transform:SetPosition(position.x,position.y,position.z)
    inst.AnimState:SetBank(bank)
    inst.AnimState:SetBuild(build)
    inst.AnimState:PlayAnimation(anim)
    inst:ListenForEvent("animover", function(inst) inst:Remove() end)
    if sound then
		inst.entity:AddSoundEmitter()
		
		if sounddelay then
			inst:DoTaskInTime(sounddelay, function() inst.SoundEmitter:PlaySound(sound) end)
		else
			inst.SoundEmitter:PlaySound(sound)
		end
    end
    if tint then
		inst.AnimState:SetMultColour(tint.x,tint.y,tint.z,tintalpha or 1)
    end

    return inst
    --]]
    return nil
end



function AnimateUIScale(item, total_time, start_scale, end_scale)
    item:StartThread(
    function()
        local scale = 1
        local time_left = total_time
        local start_time = GetTime()
        local end_time = start_time + total_time
        local transform = item.UITransform
        while true do
            local t = GetTime()
            
            local percent = (t - start_time) / total_time
            if percent > 1 then
                transform:SetScale(end_scale, end_scale, end_scale)
                return
            end
            local scale = (1 - percent)*start_scale + percent*end_scale
            transform:SetScale(scale, scale, scale)
            Yield()
        end
    end)
end



function GetGroundTypeAtPosition(pt)
    local ground = GetWorld()
    local tile = GROUND.GRASS
    
    if ground and ground.Map then
        tile = ground.Map:GetTileAtPoint(pt.x,pt.y,pt.z)
    end
	return tile
	
end

-- Use this function to fan out a search for a point that meets a condition.
-- If your condition is basically "walkable ground" use FindWalkableOffset instead.
-- test_fn takes a parameter "offset" which is check_angle*radius.
function FindValidPositionByFan(start_angle, radius, attempts, test_fn)
	local theta = start_angle -- radians
	
	attempts = attempts or 8

	local attempt_angle = (2*PI)/attempts
	local tmp_angles = {}
	for i=0,attempts-1 do
		local a = i*attempt_angle
		if a > PI then
			a = a-(2*PI)
		end
		table.insert(tmp_angles, a)
	end
	
	-- Make the angles fan out from the original point
	local angles = {}
	for i=1,math.ceil(attempts/2) do
		table.insert(angles, tmp_angles[i])
		local other_end = #tmp_angles - (i-1)
		if other_end > i then
			table.insert(angles, tmp_angles[other_end])
		end
	end

	
    --print("FindValidPositionByFan")

	for i, attempt in ipairs(angles) do
		local check_angle = theta + attempt
		if check_angle > 2*PI then check_angle = check_angle - 2*PI end

		local offset = Vector3(radius * math.cos( check_angle ), 0, -radius * math.sin( check_angle ))

        --print(string.format("    %2.2f", check_angle/DEGREES))

		if test_fn(offset) then
			local deflected = i > 1
            --print(string.format("    OK on try %u", i))
			return offset, check_angle, deflected
		end
	end
end

-- This function fans out a search from a starting position/direction and looks for a walkable
-- position, and returns the valid offset, valid angle and whether the original angle was obstructed.
function FindWalkableOffset(position, start_angle, radius, attempts, check_los, ignore_walls)
	--print("FindWalkableOffset:")

    if ignore_walls == nil then 
        ignore_walls = true 
    end

	local test = function(offset)
		local run_point = position+offset
		local ground = GetWorld()
		local tile = ground.Map:GetTileAtPoint(run_point.x, run_point.y, run_point.z)
		if tile == GROUND.IMPASSABLE or tile >= GROUND.UNDERGROUND then
			--print("\tfailed, unwalkable ground.")
			return false
		end
		if check_los and not ground.Pathfinder:IsClear(position.x, position.y, position.z,
		                                                 run_point.x, run_point.y, run_point.z,
		                                                 {ignorewalls = ignore_walls, ignorecreep = true}) then
			--print("\tfailed, no clear path.")
			return false
		end
		--print("\tpassed.")
		return true

	end

	return FindValidPositionByFan(start_angle, radius, attempts, test)
end

--[[ FROM DST ]]
local function _CanEntitySeeInStorm(inst)
    if inst.components.playervision ~= nil then
        --component available on clients as well,
        --but only accurate for your local player
        return inst.components.playervision:HasGoggleVision()
    end
    local inventory = inst.replica.inventory
    return inventory ~= nil and inventory:EquipHasTag("goggles")
end

function CanEntitySeeInStorm(inst)
    return inst ~= nil and inst:IsValid() and _CanEntitySeeInStorm(inst)
end

local function _GetEntitySandstormLevel(inst)
    --NOTE: GetSandstormLevel is available on players on server
    --      and clients, but only accurate for local players.
    --      stormwatcher is a server-side component.
    return (inst.GetSandstormLevel ~= nil and inst:GetSandstormLevel())
        or (inst.components.stormwatcher ~= nil and inst.components.stormwatcher.sandstormlevel)
        or 0
end

local function _CanEntitySeeInDark(inst)
    local inventory = inst.components.inventory
    return inventory ~= nil and inventory:EquipHasTag("nightvision")
end

function CanEntitySeePoint(inst, x, y, z)
    return inst ~= nil
        and inst:IsValid()
        and (TheSim:GetLightAtPoint(x, y, z) > TUNING.DARK_CUTOFF or
            _CanEntitySeeInDark(inst))
end

function CanEntitySeeTarget(inst, target)
    if target == nil or not target:IsValid() then
        return false
    end
    local x, y, z = target.Transform:GetWorldPosition()
    return CanEntitySeePoint(inst, x, y, z)
end
-- [[ END FROM DST]]
