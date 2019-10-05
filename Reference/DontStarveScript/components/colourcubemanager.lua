local easing = require("easing")

local ColourCubeManager = Class(function(self, inst)
	self.inst = inst

	self.IDENTITY_COLOURCUBE = "images/colour_cubes/identity_colourcube.tex"
	self.INSANITY_CCS =
	{
		DAY = "images/colour_cubes/insane_day_cc.tex",
		DUSK = "images/colour_cubes/insane_dusk_cc.tex",
		NIGHT = "images/colour_cubes/insane_night_cc.tex",
	}

	self.SEASON_CCS = {
		[SEASONS.SUMMER] = {	DAY = "images/colour_cubes/day05_cc.tex",
								DUSK = "images/colour_cubes/dusk03_cc.tex",
								NIGHT = "images/colour_cubes/night03_cc.tex",
						   },
		[SEASONS.WINTER] = {	DAY = "images/colour_cubes/snow_cc.tex",
								DUSK = "images/colour_cubes/snowdusk_cc.tex",
								NIGHT = "images/colour_cubes/night04_cc.tex",
							},
		[SEASONS.CAVES] = {		DAY = "images/colour_cubes/caves_default.tex",
								DUSK = "images/colour_cubes/caves_default.tex",
								NIGHT = "images/colour_cubes/caves_default.tex",
							},
	}

	self.NIGHTMARE_CCS = 
	{
		CALM = "images/colour_cubes/ruins_dark_cc.tex",
		WARN = "images/colour_cubes/ruins_dim_cc.tex",
		NIGHTMARE = "images/colour_cubes/ruins_light_cc.tex",
		DAWN = "images/colour_cubes/ruins_dim_cc.tex",
	}

	local cc, insanity_cc = self:GetDestColourCubes()
	self.current_cc = 
	{
		[0] = cc,
		[1] = insanity_cc,
	}

	PostProcessor:SetColourCubeData( 0, cc, cc )
	PostProcessor:SetColourCubeData( 1, insanity_cc, insanity_cc )

	self.transition_time_left = nil
	self.total_transition_time = 1

	self.inst:ListenForEvent("daytime", function() self:StartBlend(4) end, GetWorld())
	self.inst:ListenForEvent("dusktime", function() self:StartBlend(6) end, GetWorld())
	self.inst:ListenForEvent("nighttime", function() self:StartBlend(8) end, GetWorld())
	self.inst:ListenForEvent("seasonChange", function() self:StartBlend(10) end, GetWorld())
	self.inst:ListenForEvent("phasechange", function(inst, data) self:StartBlend(TUNING.TRANSITIONTIME[string.upper(data.newphase)]) end, GetWorld()) --nightmare events

	self.inst:StartUpdatingComponent(self)

end)

function ColourCubeManager:StartBlend(time_to_take, cc)
	
	if self.override then
		return
	end
	self.total_transition_time = time_to_take
	self.transition_time_left = time_to_take
	
	local old_cc = self.current_cc[0]
	local old_sanity_cc = self.current_cc[1]
	self.current_cc[0], self.current_cc[1] = self:GetDestColourCubes()

	PostProcessor:SetColourCubeData( 0, old_cc, self.current_cc[0] )
	PostProcessor:SetColourCubeLerp( 0, 0 )
	PostProcessor:SetColourCubeData( 1, old_sanity_cc, self.current_cc[1] )
	--print ("Channel 0:", old_cc, self.current_cc[0])
	--print ("Channel 1:", old_sanity_cc, self.current_cc[1])
	--print ("start lerp", time_to_take)
end

function ColourCubeManager:GetDestColourCubes()
	
	local season_idx = SEASONS.SUMMER

	if GetWorld() and GetWorld().components.seasonmanager then
		season_idx = GetWorld().components.seasonmanager:GetSeason()
	end
	
	local time_idx = "DAY"
	if GetWorld() and GetWorld().components.clock and not GetWorld().components.nightmareclock then
		if GetWorld().components.clock:IsDusk() then
			time_idx = "DUSK"
		elseif GetWorld().components.clock:IsNight() then
			time_idx = "NIGHT"
		end
	end

	local nightmare_idx = "CALM"
	if GetWorld() and GetWorld().components.nightmareclock then
		if GetWorld().components.nightmareclock:IsWarn() then
			nightmare_idx = "WARN"
		elseif GetWorld().components.nightmareclock:IsNightmare() then
			nightmare_idx = "NIGHTMARE"
		elseif GetWorld().components.nightmareclock:IsDawn() then
			nightmare_idx = "DAWN"
		end
	end

	-- It seems that in very rare cases (some combination of custom worldgen settings) season_idx is somehow becoming invalid and causing a crash indexing a field that doesn't exist
	--local cc = self.SEASON_CCS[ season_idx ][time_idx]
	local cc_season = self.SEASON_CCS[ season_idx ] or self.SEASON_CCS[ SEASONS.SUMMER ]
	local cc = cc_season[time_idx]
	
	if GetWorld() ~= nil and GetWorld():IsCave() and GetWorld().topology ~= nil and GetWorld().topology.level_number == 2 then
		--We're in the ruins, use the nightmare colour cubes
		cc = self.NIGHTMARE_CCS[nightmare_idx]
	end

	local insanity_cc = self.INSANITY_CCS[time_idx]

	return cc, insanity_cc
end

function ColourCubeManager:SetOverrideColourCube(cc)
	self.override = cc
	
	if self.override then
		PostProcessor:SetColourCubeData( 0, cc, cc )
		PostProcessor:SetColourCubeData( 1, cc, cc )
	else
		self.current_cc[0], self.current_cc[1] = self:GetDestColourCubes()
		PostProcessor:SetColourCubeData( 0, self.current_cc[0], self.current_cc[0] )
		PostProcessor:SetColourCubeData( 1, self.current_cc[1], self.current_cc[1] )
	end

end

function ColourCubeManager:OnUpdate(dt)

	if self.transition_time_left then
		self.transition_time_left = self.transition_time_left - dt
		local t = 0
		if self.transition_time_left <= 0 then
			self.transition_time_left = nil
			t = 1
		else
			t = 1 - self.transition_time_left / self.total_transition_time
		end
		PostProcessor:SetColourCubeLerp( 0, t )
	end

	if GetPlayer() and GetPlayer().components.sanity then
		local san = 1 - easing.outQuad( GetPlayer().components.sanity:GetPercent(), 0, 1, 1) 
		PostProcessor:SetColourCubeLerp( 1, san )
	end

end


return ColourCubeManager