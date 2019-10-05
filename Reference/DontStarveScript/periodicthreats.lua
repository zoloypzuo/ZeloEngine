-- WORM ATTACKS --
local worm_waittime = function(data) 
	--The older the world, the more often the attacks.
	--Day 150+ gives the most often.
	local clock = GetWorld().components.clock
	local days = math.random(10)
	if clock then
		days = Lerp(12, 5, clock:GetNumCycles()/150)
		days = math.min(days, 10)
		days = math.max(days, 3)
	end

	return (TUNING.TOTAL_DAY_TIME * 2) + (days * TUNING.TOTAL_DAY_TIME) 
end
local worm_warntime = function(data)
	--The older the world, the shorter the warning.
	local time = math.random(15, 40)
	local clock = GetWorld().components.clock
	if clock then
		time = Lerp(40, 15, clock:GetNumCycles()/150)
		time = math.min(time, 40)
		time = math.max(time, 15)
	end

	return time
end
local worm_eventtime = function() return 30 end

local worm_waittimer = 60

local worm_warntimer = function(data)
	local time = math.random(2,7)
	if data.timer then
		--The closer you are to 0, the faster the sounds should play.
		local warntime = worm_warntime()
		time = Lerp(2, 7, data.timer/warntime)
		time = math.min(time, 7)
		time = math.max(time, 2)
	end
	return time
end

local worm_eventtimer = function() return math.random(2,6) end

local worm_numtospawn = function(data)
	--The older the world, the more that spawn. (2-6)
	--Day 150+ do max
	local clock = GetWorld().components.clock
	local num = math.random(1,3)
	if clock then
		num = Lerp(1, 3, clock:GetNumCycles()/150)
		num = math.min(num, 3)
		num = math.max(num, 1)
	end
	num = RoundDown(num)
	return num
end

local worm_onspawnfn = function(inst) 
	if inst.components.combat then
		inst.components.combat:SetTarget(GetPlayer()) 
	end

	if inst.HomeTask then
		inst.HomeTask:Cancel()
		inst.HomeTask = nil
	end

	inst.sg:GoToState("idle_enter")
end

local WORM = {
	radius = function() return math.random(15,20) end,
	prefab = "worm",

	waittime = worm_waittime,
	waittimer = worm_waittimer,

	warntime = worm_warntime,
	warntimer = worm_warntimer,

	eventtime = worm_eventtime,
	eventtimer = worm_eventtimer,

	warnsound = "dontstarve/creatures/worm/distant",
	onspawnfn = worm_onspawnfn, 
	numtospawnfn = worm_numtospawn,
	trackspawns = true,
}

return {
	["WORM"] = WORM,
}