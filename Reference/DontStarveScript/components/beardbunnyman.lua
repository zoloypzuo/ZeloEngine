local WereBeast = Class(function(self, inst)
    self.inst = inst
    self.onsetwerefn = nil
    self.onsetnormalfn = nil
    self.targettick = nil
    self.targettime = nil
    self.weretime = TUNING.SEG_TIME*4
    
    self.triggeramount = nil
    self.triggerthreshold = nil
    
    self.inst:ListenForEvent("nighttime", function(global, data)
	    if GetClock():GetMoonPhase() == "full" and self.inst.entity:IsVisible() and not self:IsInWereState() then
	        self.inst:DoTaskInTime(GetRandomWithVariance(1, 2), self:SetWere())
	    end
	end, GetWorld())
	
    self.inst:ListenForEvent("daytime", function(global, data)
        if self:IsInWereState() and self.inst.entity:IsVisible() then
	        self.inst:DoTaskInTime(GetRandomWithVariance(1, 2), self:SetNormal())
	    end
    end, GetWorld())
end)

local willTransform = {}
local function WerebeastUpdate(dt)
	local tick = TheSim:GetTick()
	if willTransform[tick] then
		for k,v in pairs(willTransform[tick]) do
			if v:IsValid() and v.components.werebeast and v.components.werebeast:IsInWereState() and not v.sg:HasStateTag("transform") then
				v.components.werebeast:SetNormal()
				v.components.werebeast.targettime = nil
				v.components.werebeast.targettick = nil
			end
		end
		willTransform[tick] = nil
	end	
end

function WereBeast:GetDebugString()
    if self.triggerlimit then
        return string.format("triggers %2.2f / %2.2f", self.triggeramount, self.triggerlimit)
    end
    return "no triggers"
end

function WereBeast:SetOnWereFn(fn)
	self.onsetwerefn = fn
end

function WereBeast:SetOnNormalFn(fn)
	self.onsetnormalfn = fn
end

function WereBeast:SetTriggerLimit(limit)
    self.triggerlimit = limit
    self:ResetTriggers()
end

function WereBeast:TriggerDelta(amount)
    self.triggeramount = math.max(0, self.triggeramount + amount)
    if self.triggerlimit and self.triggeramount >= self.triggerlimit then
        self.inst.components.werebeast:SetWere()
    end
end

function WereBeast:ResetTriggers()
    self.triggeramount = 0
end

function WereBeast:SetWere(time)
	if self.onsetwerefn then
		self.onsetwerefn(self.inst)
	end
    self.inst:PushEvent("transformwere")
	if self.triggerlimit then
	    self.triggeramount = 0
	end
	local weretime = time or self.weretime
	self.targettime = GetTime() + weretime
	self.targettick = GetTickForTime(self.targettime)
	
    if not willTransform[self.targettick] then
		willTransform[self.targettick] = {[self.inst] = self.inst}
    else
		willTransform[self.targettick][self.inst] = self.inst
    end
end

function WereBeast:SetNormal()
	if self.onsetnormalfn then
		self.onsetnormalfn(self.inst)
	end
    self.inst:PushEvent("transformnormal")
	if self.triggerlimit then
	    self.triggeramount = 0
	end
	if willTransform[self.targettick] then
	    willTransform[self.targettick][self.inst] = nil
	end
	self.targettime = nil
	self.targettick = nil
end

function WereBeast:IsInWereState()
	return self.targettime ~= nil
end

function WereBeast:OnSave()
    local time = GetTime()
    if self.targettime and self.targettime > time then
        return {time = math.floor(self.targettime - time) }
    end
end   
   
function WereBeast:OnLoad(data)
    if data and data.time then
		self:SetWere(data.time)
    end
end

RegisterStaticComponentUpdate("werebeast", WerebeastUpdate)

return WereBeast