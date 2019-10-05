local FireFX = Class(function(self, inst)
    self.inst = inst
    self.level = nil
    self.inst:StartUpdatingComponent(self) 
    self.playingsound = nil
    self.percent = 1
    self.levels = {}
    self.playignitesound = true
    self.bigignitesoundthresh = 3
    self.usedayparamforsound = false
    self.current_radius = 1
end)


local sin = math.sin
local gettime = GetTime
local clock = GetClock()

function FireFX:OnUpdate(dt)
    local time = gettime()*30
	local flicker = ( sin( time ) + sin( time + 2 ) + sin( time + 0.7777 ) ) / 2.0 -- range = [-1 , 1]
	flicker = ( 1.0 + flicker ) / 2.0 -- range = 0:1
    local rad = self.current_radius + flicker*.05
    self.inst.Light:SetRadius( rad )

    if self.usedayparamforsound then
		local isday = clock:IsDay()
		if isday ~= self.isday then
			self.isday = isday
			local val = isday and 1 or 2
			self.inst.SoundEmitter:SetParameter( "fire", "daytime", val )
		end
    end
    
end

function FireFX:UpdateRadius()
    local lowval_r = 0
    local highval_r = self.levels[self.level].radius
	
    if self.level > 1 then
        lowval_r = self.levels[self.level-1].radius
    end
	self.current_radius = self.percent*(highval_r-lowval_r)+lowval_r
	
    self.inst.Light:SetRadius(self.current_radius)
end

function FireFX:SetPercentInLevel(percent)
    self.percent = percent
	self:UpdateRadius()
	    
    local lowval_i = self.levels[1].intensity
    local highval_i = self.levels[self.level].intensity

    if self.level > 1 then
		lowval_i = self.levels[self.level-1].intensity
    end

    self.inst.Light:SetIntensity(percent*(highval_i-lowval_i)+lowval_i)
    
end

function FireFX:SetLevel(lev)
    if lev ~= self.level and lev > 0 then
    
        if self.inst.SoundEmitter and self.playignitesound then
            if not self.level or lev > self.level then
                if lev >= self.bigignitesoundthresh then
                    self.inst.SoundEmitter:PlaySound("dontstarve/common/fireBurstLarge")
                else
                    self.inst.SoundEmitter:PlaySound("dontstarve/common/fireBurstSmall")
                end
            end
        end
            
        if not self.level then
            self.level = math.min(lev, #self.levels)
            if self.levels[self.level] and self.levels[self.level].pre then
                self.inst.AnimState:PlayAnimation(self.levels[self.level].pre)
                self.inst.AnimState:PushAnimation(self.levels[self.level].anim, true)
            else
                self.inst.AnimState:PlayAnimation(self.levels[self.level].anim, true)
            end
        else
            self.level = math.min(lev, #self.levels)
            self.inst.AnimState:PlayAnimation(self.levels[self.level].anim, true)
        end
    
    
        self.current_radius = self.levels[self.level].radius
        self.inst.Light:Enable(true)
        self.inst.Light:SetIntensity(self.levels[self.level].intensity)
        self.inst.Light:SetRadius(self.levels[self.level].radius)
        self.inst.Light:SetFalloff(self.levels[self.level].falloff)
        self.inst.Light:SetColour(self.levels[self.level].colour[1],self.levels[self.level].colour[2],self.levels[self.level].colour[3])
        
        if self.playingsound ~= self.levels[self.level].sound then
            if self.playingsound then
                self.inst.SoundEmitter:KillSound(self.playingsound)
            end
            self.playingsound = self.levels[self.level].sound
            self.inst.SoundEmitter:PlaySound(self.levels[self.level].sound, "fire")
        end
        
        if self.levels[self.level].soundintensity then
            self.inst.SoundEmitter:SetParameter("fire", "intensity", self.levels[self.level].soundintensity)
        end
        
    end
end

--- Kill the fx.
-- Returns true if there's a 'going out' animation and the owning entity shouldn't be removed instantly
function FireFX:Extinguish()
    self.inst.SoundEmitter:KillSound("fire")
    
	local should_play_extinguish = not self.extinguishsoundtest or self.extinguishsoundtest()
    if should_play_extinguish then
		self.inst.SoundEmitter:PlaySound("dontstarve/common/fireOut")
        if self.levels[self.level] and self.levels[self.level].pst then
            self.inst.AnimState:PlayAnimation(self.levels[self.level].pst)
            return true
        end
	end
end

return FireFX