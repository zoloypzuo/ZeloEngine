local Propagator = Class(function(self, inst)
    self.inst = inst
    self.flashpoint = 100
    self.currentheat = 0
    self.decayrate = 1
    
    self.propagaterange = 3
    self.heatoutput = 5
    
    self.damages = false
    self.damagerange = 3

    self.acceptsheat = false
    self.spreading = false
    self.delay = false

end)


function Propagator:SetOnFlashPoint(fn)
    self.onflashpoint = fn
end

function Propagator:Delay(time)
    self.delay = true
    self.inst:DoTaskInTime(time, function() self.delay = false end)
end

function Propagator:StopUpdating()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function Propagator:StartUpdating()
    if not self.task and self.inst:IsValid() then
        local dt = .5
        self.task = self.inst:DoPeriodicTask(dt, function() self:OnUpdate(dt) end, dt + math.random()*.67)
    end
end

function Propagator:StartSpreading()
    self.spreading = true
    self:StartUpdating()
end

function Propagator:StopSpreading()
    self.spreading = false
    self:StopUpdating()
end

function Propagator:AddHeat(amount)
    
    if self.delay then
        return;
    end
    
    if self.currentheat <= 0 then
        self:StartUpdating()        
    end
    
    self.currentheat = self.currentheat + amount

    if self.currentheat > self.flashpoint then
        self.acceptsheat = false
        if self.onflashpoint then
            self.onflashpoint(self.inst)
        end
    end
end

function Propagator:Flash()
    if self.acceptsheat and not self.delay then
        self:AddHeat(self.flashpoint+1)
    end
end

function Propagator:OnUpdate(dt)
    if self.currentheat > 0 then
        self.currentheat = self.currentheat - dt*self.decayrate
    end

    if self.spreading then
        
        local pos = Vector3(self.inst.Transform:GetWorldPosition())
        local ents = TheSim:FindEntities(pos.x, pos.y, pos.z, self.propagaterange)
        
        for k,v in pairs(ents) do
            if not v:IsInLimbo() then

			    if v ~= self.inst and v.components.propagator and v.components.propagator.acceptsheat then
                    v.components.propagator:AddHeat(self.heatoutput*dt)
			    end
    			
			    if self.damages and v.components.health and v.components.health.vulnerabletoheatdamage then
				    local dsq = distsq(pos, Vector3(v.Transform:GetWorldPosition()))
				    if dsq < self.damagerange*self.damagerange then
					    --local percent_damage = math.min(.5, 1- (math.min(1, dsq / self.damagerange*self.damagerange)))
					    v.components.health:DoFireDamage(self.heatoutput*dt)
				    end
			    end
			end
        end
    end
        
    if not self.spreading and self.currentheat <= 0 then
        self:StopSpreading()
    end
    
end

return Propagator
