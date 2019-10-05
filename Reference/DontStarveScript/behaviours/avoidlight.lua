AvoidLight = Class(BehaviourNode, function(self, inst)
    BehaviourNode._ctor(self, "AvoidLight")
    self.inst = inst
    self.waiting = false
    self.phasechangetime = 0
end)



function AvoidLight:Wait(t)
    self.waittime = t+GetTime()
    self:Sleep(t)
end


function AvoidLight:PickNewAngle()
    
    local angles = {}

    if self.inst.Physics:CheckGridOffset(0,-1) then table.insert(angles, -90) end
    if self.inst.Physics:CheckGridOffset(0,1) then table.insert(angles, 90) end
    if self.inst.Physics:CheckGridOffset(-1,0) then table.insert(angles, 180) end
    if self.inst.Physics:CheckGridOffset(1,0) then table.insert(angles, 0) end
    
    local angle = 0

    local light = self.inst.LightWatcher:GetLightAngle()
    if light then
        table.sort(angles, function(a,b) return anglediff(a, light) < anglediff(b,light) end)
        angle = angles[1]
    else
        angle = angles[math.random(#angles)]
    end
    
    angle = angle + math.random()*90-45
    return angle
end

function AvoidLight:Visit()

    if self.status == READY then
        self.status = RUNNING
        --self.inst.Steering:SetActive(true)
    end
    
    if self.status == RUNNING then
        local in_light = self.inst.LightWatcher:IsInLight()
        
        local t = GetTime()
        if t > self.phasechangetime or (self.waiting and in_light) then
            
            self.waiting = not self.waiting
            
            if self.waiting then
                self.phasechangetime = .2+math.random()*.25
                self.inst.components.locomotor:Stop()
            else
                self.angle = self:PickNewAngle()
                self.phasechangetime = t + 1+math.random()*3
            end
            
        end
        
        if not self.waiting then
            
            local light = self.inst.LightWatcher:GetLightAngle()
            if light then
                
                self.inst.entity:LocalToWorldSpace(1,0,0)
                
                self.angle = light + 180 + math.random()*60-30
            end
            self.inst.components.locomotor:WalkInDirection(self.angle)
            self:Wait(.1)
        end
            
        
    end
end



