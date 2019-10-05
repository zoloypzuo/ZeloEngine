local Grue = Class(function(self, inst)
    self.inst = inst
    self.soundevent = nil
    self.warndelay = 1
    
    inst:ListenForEvent("enterdark", 
        function(inst, data) 
            self:Start()
        end)

    inst:ListenForEvent("enterlight", 
        function(inst, data) 
            self:Stop()
        end)

    inst:ListenForEvent("invincibletoggle",
        function(inst, data) 
            if self:CheckForStart() then
                self:Start()
            end
        end)

    self.inst:DoTaskInTime(0, function()   
        if self:CheckForStart() then
            self:Start()
        end
    end)
end)

function Grue:CheckForStart()
    return not self.inst.components.health:IsInvincible() and not self.inst.LightWatcher:IsInLight() and not self.inst.components.health:IsDead()
end

function Grue:Start()
    self.inst:StartUpdatingComponent(self) 
    self.nextHitTime = 5+math.random()*5
    self.nextSoundTime = self.nextHitTime* (.4 + math.random()*.4)
end

function Grue:SetSounds(warn, attack)
    self.soundwarn = warn
    self.soundattack = attack
end


function Grue:Stop()
    self.inst:StopUpdatingComponent(self) 
end

function Grue:OnUpdate(dt)
    if self.inst.components.health:IsDead() or self.inst.components.health:IsInvincible() then
        self:Stop()
        return
    end
    
    if self.nextHitTime > 0 then
        self.nextHitTime = self.nextHitTime - dt
    end
    
    if self.nextSoundTime > 0 then
        self.nextSoundTime = self.nextSoundTime - dt
        
        if self.nextSoundTime <= 0 then
            if self.soundwarn then
                self.inst.SoundEmitter:PlaySound(self.soundwarn)
            end
            self.inst:DoTaskInTime(self.warndelay, function() self.inst:PushEvent("heargrue") end)
        end
        
    end
    
    if self.nextHitTime <= 0 then
    
        self.nextHitTime = self.nextHitTime - dt
        self.nextSoundTime = self.nextSoundTime - dt
        self.inst.components.combat:GetAttacked(nil, TUNING.GRUEDAMAGE)
		self.inst.components.sanity:DoDelta(-TUNING.SANITY_MEDLARGE)
        
        self.nextHitTime = 5+math.random()*6
        self.nextSoundTime = self.nextHitTime* (.4 + math.random()*.4)
        if self.soundattack then
            self.inst.SoundEmitter:PlaySound(self.soundattack)
        end
        
        self.inst:PushEvent("attackedbygrue")
    end
end


return Grue
