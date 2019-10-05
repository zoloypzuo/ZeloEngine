local easing = require("easing")

local SeasonManager = Class(function(self, inst)
	self.inst = inst
	self.current_season = SEASONS.SUMMER
	self.current_temperature = 10
	self.noise_time = 0	
	self.ground_snow_level = 0
	self.atmo_moisture = 0
	self.moisture_limit = TUNING.TOTAL_DAY_TIME +  math.random()*TUNING.TOTAL_DAY_TIME*3
	self.moisture_floor = 0
	self.precip = false
	self.precip_rate = 0
	self.peak_precip_intensity = 1
	self.preciptype = "rain"
	self.base_atmo_moiseture_rate = 1
	
	self.wintersegs = {day=6, dusk=6, night=4}
	self.summersegs = {day=10, dusk=4, night=2}

	self.nextlightningtime = 5
	self.lightningdelays = {min=nil, max=nil}
	self.lightningmode = "rain"

	self.seasonmode = "cycle"
	self.winterlength = TUNING.WINTER_LENGTH
	self.summerlength = TUNING.SUMMER_LENGTH
	
	self.percent_season = 0
	
	self.precipmode = "dynamic"
	
	local freq = 5000
	self.winterdsp =
	{
		["set_music"] = 2000,
		--["set_ambience"] = freq,
		--["set_sfx/HUD"] = freq,
		--["set_sfx/movement"] = freq,
		["set_sfx/creature"] = freq,
		["set_sfx/player"] = freq,
		["set_sfx/sfx"] = freq,
		["set_sfx/voice"] = freq,
		["set_sfx/set_ambience"] = freq,
	}

	self:StartSummer()
	self:Start()


	self.inst:ListenForEvent( "daycomplete", function() self:OnDayComplete() end )
	self.inst:ListenForEvent( "rainstart", function() self:OnRainStart() end )
	self.inst:ListenForEvent( "rainstop", function() self:OnRainStop() end )
	self:UpdateSegs()

end)


function SeasonManager:SetCaves()
	self.seasonmode = "caves"
	self.current_season = SEASONS.CAVES

end
function SeasonManager:SetMoiustureMult(mult)
	self.base_atmo_moiseture_rate = mult
end


function SeasonManager:EndlessWinter(summerlength, winterrampup)
	self.seasonmode = "endlesswinter"
	self.endless_pre = summerlength
	self.endless_ramp = winterrampup
	self.percent_season = .5
	self:UpdateSegs()
end

function SeasonManager:EndlessSummer(winterlength, summerrampup)
	self.seasonmode = "endlesssummer"
	self.endless_pre = winterlength
	self.endless_ramp = summerrampup
	self.percent_season = .5
	self:UpdateSegs()
end

function SeasonManager:AlwaysSummer()
	self.seasonmode = "alwayssummer"
	self.percent_season = .5
	self:UpdateSegs()
end

function SeasonManager:AlwaysWinter()
	self.seasonmode = "alwayswinter"
	self.percent_season = .5
	self:StartWinter()
	self:UpdateSegs()
end

function SeasonManager:Cycle()
	self.seasonmode = "cycle"
	self:UpdateSegs()
end

function SeasonManager:AlwaysWet()
	self.precipmode = "always"
end

function SeasonManager:AlwaysDry()
	self.precipmode = "never"
end

function SeasonManager:OverrideLightningDelays(min, max)
    self.lightningdelays.min = min
    self.lightningdelays.max = max
    if self.precip and self.preciptype == "rain" and min and max then
		self.nextlightningtime = GetRandomMinMax(min, max)
    end
end

function SeasonManager:DefaultLightningDelays()
    self.lightningdelays.min = nil
    self.lightningdelays.max = nil
end

function SeasonManager:LightningWhenRaining()
	self.lightningmode = "rain"
end

function SeasonManager:LightningWhenSnowing()
	self.lightningmode = "snow"
end

function SeasonManager:LightningWhenPrecipitating()
	self.lightningmode = "precip"
end

function SeasonManager:LightningAlways()
	self.lightningmode = "always"
end

function SeasonManager:LightningNever()
	self.lightningmode = "never"
end


function SeasonManager:OnRainStart()
	self.inst.SoundEmitter:PlaySound("dontstarve/rain/rainAMB", "rain")
end

function SeasonManager:OnRainStop()
	self.inst.SoundEmitter:KillSound("rain")
end


function SeasonManager:OnDayComplete()
	if self.seasonmode == "cycle" then
	
		if self:GetSeasonLength() > 0 then
			self.percent_season = self.percent_season + 1/self:GetSeasonLength()
		else
			self.percent_season = 1
		end
		
		if self.percent_season >= 1 then
			if self.current_season == SEASONS.SUMMER then
				self:StartWinter()
			else
				self:StartSummer()
			end
		else
			self:UpdateSegs()		
		end
	elseif self.seasonmode == "endlesswinter" then
		local day = self:GetDaysIntoSeason()
		if self:IsSummer() and day >= self.endless_pre then
			self:StartWinter()
			day = 0
		end
		
		if self:IsWinter() then
			if day > self.endless_ramp then
				self.percent_season = .5
			else
				self.percent_season = .5 * (day / self.endless_ramp)
			end
		else
			self.percent_season = .5 + (day / self.endless_pre)*.5
		end
		self:UpdateSegs()
	elseif self.seasonmode == "endlesssummer" then
		local day = self:GetDaysIntoSeason()
		if self:IsWinter() and day >= self.endless_pre then
			self:StartSummer()
			day = 0
		end
		
		if self:IsSummer() then
			if day > self.endless_ramp then
				self.percent_season = .5
			else
				self.percent_season = .5 * (day / self.endless_ramp)
			end
		else
			self.percent_season = .5 + (day / self.endless_pre)*.5
		end
		self:UpdateSegs()
	end
	
	
end

function SeasonManager:UpdateSegs()
	if self.seasonmode == "caves" then return end

	if self.seasonmode == "cycle" or self.seasonmode == "endlesswinter" then

		local p = math.sin(PI*self.percent_season)*.5
		if self:IsSummer() then
			p = p + .5
		else
			p = .5 - p
		end
		
		local daysegs = math.floor(easing.linear(1-p, self.summersegs.day, self.wintersegs.day-self.summersegs.day, 1) + .5)
		local nightsegs = math.floor(easing.linear(1-p, self.summersegs.night, self.wintersegs.night - self.summersegs.night, 1) + .5)
		local dusksegs = 16 - daysegs - nightsegs

		GetClock():SetSegs(daysegs, dusksegs, nightsegs )
	else
		if self:IsWinter() then
			GetClock():SetSegs(self.wintersegs.day, self.wintersegs.dusk, self.wintersegs.night)
		else
			GetClock():SetSegs(self.summersegs.day, self.summersegs.dusk, self.summersegs.night)
		end
	end

end


function SeasonManager:SetSeasonLengths(summer, winter)
	local per = self:GetPercentSeason()
	self.winterlength = winter
	self.summerlength = summer
	self:SetPercentSeason(per)
	self:UpdateSegs()
end


function SeasonManager:SetSegs(summer, winter)
	self.summersegs = summer
	self.wintersegs = winter
	self:UpdateSegs()
end


function SeasonManager:SetAppropriateDSP()
	if USE_SEASON_DSP then
		if self:IsWinter() then
			self:ApplyDSP(.5)
		else
			self:ClearDSP(.5)
		end
	end
end


function SeasonManager:ApplyDSP(time_to_take)
	for k,v in pairs(self.winterdsp) do
		TheMixer:SetLowPassFilter(k, v, time_to_take)
	end
end

function SeasonManager:ClearDSP(time_to_take)
	for k,v in pairs(self.winterdsp) do
		TheMixer:ClearLowPassFilter(k, time_to_take)
	end
end


function SeasonManager:GetCurrentTemperature()
	return self.current_temperature
end

function SeasonManager:GetDaysLeftInSeason()
	if self.seasonmode == "cycle" then
    	return (1-self.percent_season)* self:GetSeasonLength()
    elseif self.seasonmode == "endlesswinter" then
		if self:IsWinter() then
			return 10000
		else
			return self.endless_pre - GetClock():GetNumCycles()
		end
    elseif self.seasonmode == "endlesssummer" then
		if self:IsSummer() then
			return 10000
		else
			return self.endless_pre - GetClock():GetNumCycles()
		end
    else
    	return 10000
    end
end

function SeasonManager:GetDaysIntoSeason()
	if self.seasonmode == "cycle" then
	    return (self.percent_season)* self:GetSeasonLength()
	 elseif self.seasonmode == "endlesswinter" then
		if self:IsWinter() then
			return GetClock():GetNumCycles() - self.endless_pre
		else
			return GetClock():GetNumCycles()
		end
	 elseif self.seasonmode == "endlesssummer" then
		if self:IsSummer() then
			return GetClock():GetNumCycles() - self.endless_pre
		else
			return GetClock():GetNumCycles()
		end
    else
		return 10000
	end
end

function SeasonManager:OnSave()
    return 
    {
		noise_time = self.noise_time,
		percent_season = self.percent_season,
		current_season = self.current_season,
		ground_snow_level = self.ground_snow_level,
		atmo_moisture = self.atmo_moisture,
		moisture_limit = self.moisture_limit,
		precip = self.precip,
		precip_rate = self.precip_rate,
		preciptype = self.preciptype,
		moisture_floor = self.moisture_floor,
		peak_precip_intensity = self.peak_precip_intensity,
		nextlightningtime = self.nextlightningtime
	}
end


function SeasonManager:GetSeasonString()
	if self.current_season == SEASONS.SUMMER then return "summer" else return "winter" end
end


function SeasonManager:GetDebugString()
    return string.format("%s %2.2f days, %2.2fC, moisture:%2.2f(%2.2f/%2.2f), precip_rate: %2.2f/%2.2f, ground_snow:%2.2f, lightning:%2.2f",
        self:GetSeasonString(), self:GetDaysLeftInSeason(), self.current_temperature, self.atmo_moisture, self.moisture_floor, self.moisture_limit, self.precip_rate, self.peak_precip_intensity, self.ground_snow_level, self.nextlightningtime)
end


function SeasonManager:OnLoad(data)
	self.noise_time = data.noise_time or self.noise_time
	self.percent_season = data.percent_season or self.percent_season
	self.current_season = data.current_season or self.current_season
	self.ground_snow_level = data.ground_snow_level or self.ground_snow_level
	self.atmo_moisture = data.atmo_moisture or self.atmo_moisture
	self.moisture_limit = data.moisture_limit or self.moisture_limit
	self.precip = data.precip or self.precip
	self.precip_rate = data.precip_rate or self.precip_rate
	self.preciptype = data.preciptype or self.preciptype
	self.moisture_floor = data.moisture_floor or self.moisture_floor
	self.peak_precip_intensity = data.peak_precip_intensity or self.peak_precip_intensity
	self.nextlightningtime = data.nextlightningtime or self.nextlightningtime
	
	self.inst:PushEvent("snowcoverchange", {snow = self.ground_snow_level})
	if self:IsWinter() then
		self:ApplyDSP(0)
		self.inst:PushEvent( "seasonChange", {season = self.current_season} )		
	end
	
	if self.precip and self.preciptype == "rain" then
		self.inst.SoundEmitter:PlaySound("dontstarve/rain/rainAMB", "rain")
	end

	self:UpdateSegs()
end


function SeasonManager:Start()
	self.inst:StartUpdatingComponent(self)
end


function SeasonManager:SetPercentSeason(per)
	self.percent_season = per
end

function SeasonManager:GetPercentSeason()
	
	if self.seasonmode == "cycle" or self.seasonmode == "endlesswinter" then
		return self.percent_season
    else
		return .5
	end
end


function SeasonManager:GetWeatherLightPercent()

	local dyn_range = .5
	
	if self:IsWinter() then
		dyn_range = GetClock():IsDay() and .05 or 0
	else
		dyn_range = GetClock():IsDay() and .4 or .25
	end
	
	if self.precipmode == "always" then
		return 1 - dyn_range
	elseif self.precipmode == "never" then
		return 1
	else
		local percent = 1 - math.min(1, math.max(0, (self.atmo_moisture - self.moisture_floor)/ (self.moisture_limit - self.moisture_floor)))

		if self.precip then
			percent = easing.inQuad(percent, 0, 1, 1)
		end


		return percent*dyn_range + (1-dyn_range)
	end
end


function SeasonManager:UpdateDynamicPrecip(dt)
	local percent_season = self:GetPercentSeason()
	local atmo_moisture_rate = self.base_atmo_moiseture_rate
	if self:IsWinter() then
		--we really want it to snow in early winter, so that we can get an initial ground cover
		if self:GetDaysIntoSeason() > 1 and self:GetDaysIntoSeason() < 3 then
			atmo_moisture_rate = 50
		end
	else
		--it rains less in the middle of summer
		local p = 1-math.sin(PI*percent_season)
		local min_summer_rate = .25
		local max_summer_rate = 1
		atmo_moisture_rate = (min_summer_rate +p*(max_summer_rate - min_summer_rate))*self.base_atmo_moiseture_rate
	end
	
	local RATE_SCALE = 10
	--do delta atmo_moisture and toggle precip on or off 
	if self.precip then
		self.atmo_moisture = self.atmo_moisture - self.precip_rate*dt*RATE_SCALE
		if self.atmo_moisture < 0 then
			self.atmo_moisture = 0
		end

		if self.atmo_moisture < self.moisture_floor then
			self:StopPrecip()
		end

		local percent = math.max(0, math.min(1, (self.atmo_moisture - self.moisture_floor) / (self.moisture_limit - self.moisture_floor)))
		local min_rain = .1
		self.precip_rate = (min_rain + (1-min_rain)*math.sin(percent*PI))
	else
		self.atmo_moisture = math.min(self.moisture_limit, self.atmo_moisture + atmo_moisture_rate*dt)
		self.precip_rate = 0
		
		if self.atmo_moisture >= self.moisture_limit then
			self.atmo_moisture = self.moisture_limit
			self:StartPrecip()
		end
	end
end

function SeasonManager:ForcePrecip()
	self.atmo_moisture = self.moisture_limit
end


function SeasonManager:DoMediumLightning()
	GetClock():DoLightningLighting()
	self.inst:DoTaskInTime(.25+math.random()*.5, function() 

		local inst = CreateEntity()
		inst.entity:AddTransform()
		inst.entity:AddSoundEmitter()
		inst.persists = false
		local theta = math.random(0, 2*PI)
		local radius = 10


		local offset = Vector3(GetPlayer().Transform:GetWorldPosition()) +  Vector3(radius * math.cos( theta ), 0, radius * math.sin( theta ))
		inst.Transform:SetPosition(offset.x,offset.y,offset.z)
		inst.SoundEmitter:PlaySound("dontstarve/rain/thunder_close")
	end )
end


function SeasonManager:DoLightningStrike(pos)
    local rod = nil
    local player = nil
    local rods = TheSim:FindEntities(pos.x, pos.y, pos.z, 40, {"lightningrod"})
    for k,v in pairs(rods) do
        if not rod or distsq(pos, Vector3(v.Transform:GetWorldPosition())) < distsq(pos, Vector3(rod.Transform:GetWorldPosition() )) then
            rod = v
        end
    end
    
    if rod then
        pos = Vector3(rod.Transform:GetWorldPosition() )
    elseif GetPlayer().components.playerlightningtarget and  GetPlayer().components.playerlightningtarget:CanBeHit() then
    	player = GetPlayer()
    	pos = Vector3(GetPlayer().Transform:GetWorldPosition() )
    end


	local lightning = SpawnPrefab("lightning")
	lightning.Transform:SetPosition(pos:Get())

    if rod then
        rod:PushEvent("lightningstrike") 
    else
        if player then
        	player:PushEvent("lightningstrike")
        end

        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, 3)
        for k,v in pairs(ents) do
		    if not v:IsInLimbo() then
		        if v.components.burnable and not v.components.fueled then
	        	    v.components.burnable:Ignite()
	    	    end
	        end
        end
    end

end


function SeasonManager:GetPOP()
	if self.precip then 
		return 1
	end

	if self.precipmode == "dynamic" then
		return (self.atmo_moisture - self.moisture_floor) / (self.moisture_limit - self.moisture_floor)
	elseif self.precipmode == "always" then
		return 1
	elseif self.precipmode == "never" then
		return 0
	end

	return 0
end


function SeasonManager:OnUpdate( dt )
	
	
	
	--print ("time to pass:", dt)
	if self.seasonmode == "caves" then return end

    if self.precip and self.preciptype == "rain" then
	    self.inst.SoundEmitter:SetParameter("rain", "intensity", self.precip_rate)
    end
    
	if self.lightningmode == "always"
	   or (self.precip and self.lightningmode == "precip")
	   or (self.precip and self.preciptype == self.lightningmode) then
		self.nextlightningtime = self.nextlightningtime - dt

		if self.nextlightningtime <= 0 then

			local min = self.lightningdelays.min or easing.linear(self.precip_rate, 30, 10, 1)
			local max = self.lightningdelays.max or (min + easing.linear(self.precip_rate, 30, 10, 1) )
			self.nextlightningtime = GetRandomMinMax(min, max)
			

			if self.precip_rate > 0.75 or self.lightningmode == "always" then
				local pos = Vector3(GetPlayer().Transform:GetWorldPosition())
				local rad = math.random(2, 10)
				local angle = math.random(0, 2*PI)
				pos = pos + Vector3(rad*math.cos(angle), 0, rad*math.sin(angle))
				self:DoLightningStrike(pos)
			elseif self.precip_rate > 0.5 then
				self:DoMediumLightning()
			else
				GetPlayer().SoundEmitter:PlaySound("dontstarve/rain/thunder_far")
			end
		end
	end

	if not self.snow then
		self.snow = SpawnPrefab( "snow" )
		self.snow.entity:SetParent( GetPlayer().entity )
		self.snow.particles_per_tick = 0
	end
	
	if not self.rain then
		self.rain = SpawnPrefab( "rain" )
		self.rain.entity:SetParent( GetPlayer().entity )
		self.rain.particles_per_tick = 0
		self.rain.splashes_per_tick = 0
	end


	--figure out our temperature
	local min_temp = -20
	local max_temp = 30
	local crossover_temp = 8
	local day_heat = 5
	local night_cold = -6
	
	local season_temp = 0
	local percent_season = self:GetPercentSeason()
	
	if self.current_season == SEASONS.WINTER then
		season_temp = -math.sin(PI*percent_season)*(crossover_temp- min_temp) + crossover_temp
	else
		season_temp = math.sin(PI*percent_season)*(max_temp - crossover_temp) + crossover_temp
	end

	
	local time_temp = 0
	local normtime = GetClock():GetNormEraTime()
	if GetClock():IsDay() then
		time_temp = day_heat*math.sin(normtime*PI)
	elseif GetClock():IsNight() then
		time_temp = night_cold*math.sin(normtime*PI)
	end
	
	local noise_scale = .025
	local noise_mag = 8
	local temperature_noise = (2*noise_mag)*perlin(0,0,self.noise_time*noise_scale) - noise_mag
	
	self.current_temperature = temperature_noise + season_temp + time_temp
	
	self.noise_time = self.noise_time + dt
	
	if self.precipmode == "dynamic" then
		self:UpdateDynamicPrecip(dt)
	elseif self.precipmode == "always" then
		if not self.precip then
			self:StartPrecip()
		end
		self.precip_rate = .1+perlin(0,self.noise_time*.1,0)*.9
	elseif self.precipmode == "never" then
		if self.precip then
			self:StopPrecip()
		end
	end


	--update the precip particle effects, and switch between the precip types if appropriate
	if self.precip then
		local tick_time = TheSim:GetTickTime()
		if self.preciptype == "snow" then
			self.snow.particles_per_tick = 20 * self.precip_rate
			self.rain.particles_per_tick = 0
			self.rain.splashes_per_tick = 0

			local stop_snow_thresh = self:IsWinter() and 10 or 0
			if self.current_temperature > stop_snow_thresh then
				self.preciptype = "rain"
				self.inst:PushEvent("rainstart")
				self.inst:PushEvent("snowstop")
			end
		else
			self.rain.particles_per_tick = (5 + self.peak_precip_intensity * 25) * self.precip_rate
			self.rain.splashes_per_tick = 1 + 2*self.peak_precip_intensity * self.precip_rate
			self.snow.particles_per_tick = 0

			local start_snow_thresh = self:IsWinter() and 5 or -5
			if self.current_temperature < start_snow_thresh then
				self.preciptype = "snow"
				self.inst:PushEvent("rainstop")
				self.inst:PushEvent("snowstart")
			end
		end
	end

	local SNOW_ACCUM_RATE = 1/300
	local MIN_SNOW_MELT_RATE = 1/120
	local SNOW_MELT_RATE = 1/20

	--accumulate snow on the ground
	
	local last_ground_snow = self.ground_snow_level
	if self.precip and self.preciptype == "snow" then
		self.ground_snow_level = self.ground_snow_level + self.precip_rate*dt*SNOW_ACCUM_RATE
		if self.ground_snow_level > 1 then
			self.ground_snow_level = 1
		end
		
		if math.floor(last_ground_snow*100) ~= math.floor(self.ground_snow_level*100) then
			self.inst:PushEvent("snowcoverchange", {snow = self.ground_snow_level})	
		end
	end
	
	--make snow melt
	if self.ground_snow_level > 0 and self.current_temperature > 0 and not (self.precip and self.preciptype == "snow") then
		local percent = math.min(1, (self.current_temperature) / (20))
		local melt_rate = percent *SNOW_MELT_RATE + MIN_SNOW_MELT_RATE
		self.ground_snow_level = self.ground_snow_level - melt_rate*dt
		if self.ground_snow_level <= 0 then
			self.ground_snow_level = 0
		end
		
		if math.floor(last_ground_snow*100) ~= math.floor(self.ground_snow_level*100) then
			self.inst:PushEvent("snowcoverchange", {snow = self.ground_snow_level})	
		end
	end
	
	GetWorld().Map:SetOverlayLerp( self.ground_snow_level * 3)
	
	if (last_ground_snow < SNOW_THRESH) ~= (self.ground_snow_level < SNOW_THRESH) then
		for k,v in pairs(Ents) do
			if v:HasTag("SnowCovered") then
				if self.ground_snow_level < SNOW_THRESH then
					v.AnimState:Hide("snow")
				else
					v.AnimState:Show("snow")
				end
			end
		end
	end
	--]]
end

function SeasonManager:GetPrecipitationRate()
	return self.precip_rate
end

function SeasonManager:GetMoistureLimit()
	return self.moisture_limit
end

function SeasonManager:StartWinter()
	self.current_season = SEASONS.WINTER
	if self.seasonmode == "cycle" or self.seasonmode == "endlesswinter" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end
	self.inst:PushEvent( "seasonChange", {season = self.current_season} )
	self:ApplyDSP(5)
	self:UpdateSegs()
end

function SeasonManager:StartSummer()
	self.current_season = SEASONS.SUMMER
	if self.seasonmode == "cycle" or self.seasonmode == "endlesswinter" then
		self.percent_season = 0
	else
		self.percent_season = .5
	end
	self.inst:PushEvent( "seasonChange", {season = self.current_season} )
	self:ClearDSP(5)
	
	self:UpdateSegs()
end

function SeasonManager:StartPrecip()
	if not self.precip then
		self.nextlightningtime = GetRandomMinMax(self.lightningdelays.min or 5, self.lightningdelays.max or 15)
		self.precip = true
		
		self.moisture_floor = (.25 + math.random()*.5)*self.atmo_moisture
		
		self.peak_precip_intensity = math.random()

		local snow_thresh = self:IsWinter() and 5 or -5

		if self.current_temperature < snow_thresh then
			self.preciptype = "snow"
			self.inst:PushEvent("snowstart")
		else
			self.preciptype = "rain"
			self.inst:PushEvent("rainstart")
		end
	end
end

function SeasonManager:GetSeasonLength()
	return self.current_season == SEASONS.WINTER and self.winterlength or self.summerlength
end

function SeasonManager:IsSummer()
	return self.current_season == SEASONS.SUMMER
end

function SeasonManager:IsWinter()
	return self.current_season == SEASONS.WINTER
end


function SeasonManager:GetSnowPercent()
    return self.ground_snow_level
end

function SeasonManager:Advance()
	if self.seasonmode == "cycle" then
		self.percent_season = self.percent_season + 1/self:GetSeasonLength()
		
		if self.percent_season > 1 then
			self.percent_season = 0
			if self:IsWinter() then
				self:StartSummer()
			else
				self:StartWinter()
			end
		end
		self:UpdateSegs()
	end
end

function SeasonManager:GetTemperature()
	return self.current_temperature
end

function SeasonManager:Retreat()
	if self.seasonmode == "cycle" then
		
		self.percent_season = self.percent_season - 1/self:GetSeasonLength()
		if self.percent_season < 0 then
			self.percent_season = 1 - 1/self:GetSeasonLength()
			if self:IsWinter() then
				self:StartSummer()
			else
				self:StartWinter()
			end
		end
		self:UpdateSegs()
	end
end

function SeasonManager:StopPrecip()
	if self.precip then
		self.snow.particles_per_tick = 0
		self.rain.particles_per_tick = 0
		self.rain.splashes_per_tick = 0
		self.precip = false
		
		if self.preciptype == "rain" then
			self.inst:PushEvent("rainstop")
		else
			self.inst:PushEvent("snowstop")
		end
		
		--self.moisture_limit = self.atmo_moisture + math.random()*500 + 60
		
		if self:IsWinter() then
			self.moisture_limit = TUNING.TOTAL_DAY_TIME +  math.random()*TUNING.TOTAL_DAY_TIME*3
		else
			self.moisture_limit = TUNING.TOTAL_DAY_TIME*2 +  math.random()*TUNING.TOTAL_DAY_TIME*6
		end
	end
end


function SeasonManager:IsRaining()
	return self.precip and self.preciptype == "rain"
end

function SeasonManager:GetSeason()
	return self.current_season
end

function SeasonManager:LongUpdate(dt)
	self:OnUpdate(dt)
end

return SeasonManager
