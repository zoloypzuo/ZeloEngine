local function DoTest(inst)
    local playerprox = inst.components.playerprox
    if playerprox then
        local player = GetPlayer()
        if player and inst and not player:HasTag("notarget") then
            local close = nil
            local distsq = player:GetDistanceSqToInst(inst)
            if playerprox.isclose then
                close = distsq < playerprox.far*playerprox.far
            else
                close = distsq < playerprox.near*playerprox.near
            end
            
            if playerprox.isclose ~= close then
                playerprox.isclose = close
                if playerprox.isclose and playerprox.onnear then
                    playerprox.onnear(inst)
                end

                if not playerprox.isclose and playerprox.onfar then
                    playerprox.onfar(inst)
                end
                
            end
        end
    end
end

local PlayerProx = Class(function(self, inst)
    self.inst = inst
    self.near = 2
    self.far = 3
    self.period = .333
    self.onnear = nil
    self.onfar = nil
    self.isclose = nil
    
    self.task = nil
        
    self:Schedule()
end)

function PlayerProx:GetDebugString()
    return self.isclose and "NEAR" or "FAR"
end

function PlayerProx:SetOnPlayerNear(fn)
    self.onnear = fn
end

function PlayerProx:SetOnPlayerFar(fn)
    self.onfar = fn
end

function PlayerProx:IsPlayerClose()
	return self.isclose
end

function PlayerProx:SetDist(near, far)
    self.near = near
    self.far = far
end

function PlayerProx:Schedule()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
	if not self.inst:IsAsleep() then
	    self.task = self.inst:DoPeriodicTask(self.period, DoTest, math.random() * self.period)
	end
end

function PlayerProx:OnEntitySleep()
    
    if self.onfar then
        self.onfar(self.inst)
    end

    self.isclose = nil

    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

function PlayerProx:OnEntityWake()
    self:Schedule()
end

function PlayerProx:OnRemoveEntity()
    if self.task then
        self.task:Cancel()
        self.task = nil
    end
end

return PlayerProx
