--[[
	The starting shell to the nightmare cycle for the ruins.
	At the moment the code is near identical to the clock for the day/night cycle above ground.
	Era times or segment numbers could change based on how insane the player is
]]



local NightmareClock = Class(function(self, inst)
	self.inst = inst
	self.task = nil
	--[[
		Calm = Day
		Warn = Dusk
		Nightmare = Night
		Dawn = Nightmare -> Calm
	]]
	self.calmsegs = 23
	self.warnsegs = 5
	self.nightmaresegs = 10
	self.dawnsegs = 2

	self.totalsegs = 40
	self.segtime = 15

	self.calmColour = Point(0, 0, 0)
	self.warnColour = Point(0, 0, 0)
	self.nightmareColour = Point(0, 0, 0)
	self.dawnColour = Point(0, 0, 0)

	self.currentColour = self.calmColour

	self.lerpToColour = self.calmColour
	self.lerpFromColour = self.calmColour

    self.lerptimeleft = 0
    self.totallerptime = 0
    self.override_timeLeftInEra = nil

    self.inst:StartUpdatingComponent(self)

	self.previous_phase = "dawn"

	self:StartCalm()
end)

function NightmareClock:RandomizeSegments()
	local newCalm = math.random(19, 23)
	local newNightmare = (self.calmsegs + self.nightmaresegs) - newCalm

	local newWarn = math.random(4,6)
	local newDawn = (self.warnsegs + self.dawnsegs) - newWarn

	self:SetSegs(newCalm, newWarn, newNightmare, newDawn)
end

function NightmareClock:GetDebugString()
    return string.format("%s: %2.2f ", self.phase, self:GetTimeLeftInEra())
end

function NightmareClock:GetTimeLeftInEra()
	return self.timeLeftInEra
end

function NightmareClock:GetTimeInEra()
    return self.totalEraTime - self.timeLeftInEra 
end

function NightmareClock:GetNormEraTime()
    local ret = self.totalEraTime > 0 and (1 - self.timeLeftInEra / self.totalEraTime) or 1
    return ret
end

function NightmareClock:SetNormEraTime(percent)
	if self.phase == "calm" then
		self.totalEraTime = self:GetCalmTime()
	elseif self.phase == "warn" then
		self.totalEraTime = self:GetWarnTime()
	elseif self.phase == "nightmare" then
		self.totalEraTime = self:GetNightmareTime()
	else
		self.totalEraTime = self:GetDawnTime()
	end
	
	self.timeLeftInEra = (1-percent)*self.totalEraTime
end

function NightmareClock:GetNormTime()
    
    local ret = 0
    if self.phase == "day" then
		return (self.calmsegs / self.totalsegs)*self:GetNormEraTime()
    elseif self.phase == "dusk" then
		return (self.calmsegs / self.totalsegs) + (self.warnsegs / self.totalsegs)*self:GetNormEraTime()
    elseif self.phase == "nightmare" then
		return (self.calmsegs / self.totalsegs) + (self.warnsegs / self.totalsegs) + (self.nightmaresegs / self.totalsegs)*self:GetNormEraTime()
    else
		return (self.calmsegs / self.totalsegs) + (self.warnsegs / self.totalsegs) + (self.nightmaresegs / self.totalsegs) + (self.dawnsegs/ self.totalsegs)*self:GetNormEraTime()
    end
end

function NightmareClock:SetSegs(calm, warn, nightmare, dawn)
	assert(calm + warn + nightmare + dawn == self.totalsegs, "invalid number of time segs in NightmareClock:SetSegs")
	
	local norm_time = self:GetNormEraTime()
	
	self.calmsegs = calm
	self.warnsegs = warn
	self.nightmaresegs = nightmare
	self.dawnsegs = dawn
	
	if self.phase == "calm" then
		self.totalEraTime = self.calmsegs*self.segtime
	elseif self.phase == "warn" then
		self.totalEraTime = self.warnsegs*self.segtime
	elseif self.phase == "nightmare" then
		self.totalEraTime = self.nightmaresegs*self.segtime
	else
		self.totalEraTime = self.dawnsegs*self.segtime
	end
	
	self:SetNormEraTime(norm_time)
	self.inst:PushEvent("nightmaresegschanged")
end

function NightmareClock:OnSave()
	return {
	phase = self.phase,
	normeratime = self:GetNormEraTime()
	}
end

function NightmareClock:OnLoad(data)
	if data.phase == "nightmare" then
		self:StartNightmare(true)
	elseif data.phase == "warn" then
		self:StartWarn(true)
	elseif data.phase == "calm" then
		self:StartCalm(true)
	else
		self:StartDawn(true)
	end

	self.inst:PushEvent("phasechange", {oldphase = self.phase, newphase = self.phase})

	local normeratime = data.normeratime or 0
	self:SetNormEraTime(normeratime)

end

function NightmareClock:GetCalmTime()
	return self.calmsegs*self.segtime
end

function NightmareClock:GetNightmareTime()
	return self.nightmaresegs*self.segtime
end

function NightmareClock:GetWarnTime()
	return self.warnsegs*self.segtime
end

function NightmareClock:GetDawnTime()
	return self.dawnsegs * self.segtime
end

function NightmareClock:IsCalm()
	return self.phase == "calm"
end

function NightmareClock:IsNightmare()
	return self.phase == "nightmare"
end

function NightmareClock:IsWarn()
	return self.phase == "warn"
end

function NightmareClock:IsDawn()
	return self.phase == "dawn"
end

function NightmareClock:GetPhase()
	return self.phase
end

function NightmareClock:GetNextPhase()
	if self:IsCalm() then
		return "warn"
	elseif self:IsWarn() then
		return "nightmare"
	elseif self:IsNightmare() then
		return "dawn"
	else
		return "calm"
	end
end

function NightmareClock:GetPrevPhase()
	if self:IsCalm() then
		return "dawn"
	elseif self:IsWarn() then
		return "calm"
	elseif self:IsNightmare() then
		return "warn"
	else
		return "nightmare"
	end
end

function NightmareClock:StartCalm(instant)



	self.timeLeftInEra = self:GetCalmTime()
	self.totalEraTime = self.timeLeftInEra
    
    if self.phase ~= self.previous_phase then
        self.previous_phase = self.phase
    	self:LerpAmbientColour(self.currentColour, self.calmColour, instant and 0 or TUNING.TRANSITIONTIME.CALM)
	end
	
	self.phase = "calm"
	self.inst:PushEvent(self.phase.."start", {phase = self.phase})
end

function NightmareClock:StartWarn(instant)
	self.timeLeftInEra = self:GetWarnTime()
	self.totalEraTime = self.timeLeftInEra
    
    if self.phase ~= self.previous_phase then
        self.previous_phase = self.phase   
    	self:LerpAmbientColour(self.currentColour, self.warnColour, instant and 0 or TUNING.TRANSITIONTIME.WARN)
	end

	self.phase = "warn"
	self.inst:PushEvent(self.phase.."start", {phase = self.phase})
end

function NightmareClock:StartNightmare(instant)
	self.timeLeftInEra = self:GetNightmareTime()
	self.totalEraTime = self.timeLeftInEra

    if self.phase ~= self.previous_phase then
        self.previous_phase = self.phase   
    	self:LerpAmbientColour(self.currentColour, self.nightmareColour, instant and 0 or TUNING.TRANSITIONTIME.NIGHTMARE)
	end
	
	self.phase = "nightmare"
	self.inst:PushEvent(self.phase.."start", {phase = self.phase})

end

function NightmareClock:StartDawn(instant)
	self.timeLeftInEra = self:GetDawnTime()
	self.totalEraTime = self.timeLeftInEra

    if self.phase ~= self.previous_phase then
        self.previous_phase = self.phase   
    	self:LerpAmbientColour(self.currentColour, self.dawnColour, instant and 0 or TUNING.TRANSITIONTIME.DAWN)
	end
	
	self.phase = "dawn"
	self.inst:PushEvent(self.phase.."start", {phase = self.phase})

end

function NightmareClock:NextPhase()
	local oldphase = self.phase
	if self:IsCalm() then
		self:StartWarn()
	elseif self:IsWarn() then
		self:StartNightmare()
	elseif self:IsNightmare() then
		self:StartDawn()
	else
		self:RandomizeSegments()
		self:StartCalm()
	end

	self.inst:PushEvent("phasechange", {oldphase = oldphase, newphase = self.phase})
end

function NightmareClock:OnUpdate(dt)
	self.timeLeftInEra = self.timeLeftInEra - dt

	if self.override_timeLeftInEra ~= nil then
		self.timeLeftInEra = self.override_timeLeftInEra
	end
	if self.timeLeftInEra <= 0 then
		local time_left_over = -self.timeLeftInEra
		self:NextPhase()

		if time_left_over > 0 then
			self:OnUpdate(time_left_over)
			return
		end
	end

    if self.lerptimeleft > 0 then
        local percent = 1 - (self.lerptimeleft / self.totallerptime)
        local r = percent*self.lerpToColour.x + (1 - percent)*self.lerpFromColour.x
        local g = percent*self.lerpToColour.y + (1 - percent)*self.lerpFromColour.y
        local b = percent*self.lerpToColour.z + (1 - percent)*self.lerpFromColour.z
        self.currentColour = Point(r,g,b)
        self.lerptimeleft = self.lerptimeleft - dt
    end

    if GetWorld():IsCave() and self.inst.topology.level_number == 2 then
        TheSim:SetAmbientColour(self.currentColour.x, self.currentColour.y, self.currentColour.z )
    end

	self.inst:PushEvent("nightmareclocktick", {phase = self.phase, normalizedtime = self:GetNormTime()})

end


function NightmareClock:LerpAmbientColour(src, dest, time)
	self.lerptimeleft = time
	self.totallerptime = time

    if time == 0 then
		self.currentColour = dest
    else
		self.lerpFromColour = src
		self.lerpToColour = dest
	end

    if not self.currentColour then
		self.currentColour = src
    end
	--This will probably clash with the clock
    if GetWorld():IsCave() and self.inst.topology and self.inst.topology.level_number == 2 then
        TheSim:SetAmbientColour(self.currentColour.x, self.currentColour.y, self.currentColour.z )
    end
end

function NightmareClock:LerpFactor()
	if self.totallerptime == 0 then
		return 1
	else
		return math.min( 1.0, 1.0 - self.lerptimeleft / self.totallerptime )
	end
end

function NightmareClock:LongUpdate(dt)
	self:OnUpdate(dt)

	self.lerptimeleft = 0
	if self:IsCalm() then
		self.currentColour = self.calmColour
	elseif self:IsWarn() then
		self.currentColour = self.warnColour
	elseif self:IsNightmare() then
		self.currentColour = self.nightmareColour
	else
		self.currentColour = self.dawnColour
	end

	--This will probably clash with the clock
    if GetWorld():IsCave() and self.inst.topology.level_number == 2 then
        TheSim:SetAmbientColour(self.currentColour.x, self.currentColour.y, self.currentColour.z )
    end
end

return NightmareClock