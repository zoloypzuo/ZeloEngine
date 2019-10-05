local Catcher = Class(function(self, inst)
    self.inst = inst
    self.actiondistance = 10
    self.catchdistance = 2
    self.canact = false
    self.watchlist = {}
end)

---this is the distance at which the action to catch the projectile appears
function Catcher:SetActionDistance(dist)
    self.actiondistance = dist
end

--this is the distance at which the projectile will be caught, if ready
function Catcher:SetCatchDistance(dist)
    self.catchdistance = dist
end

function Catcher:StartWatching(projectile)
    self.watchlist[projectile] = true
    self.inst:StartUpdatingComponent(self)
end

function Catcher:StopWatching(projectile)
    self.watchlist[projectile] = nil
    if next(self.watchlist) == nil then
        self.inst:StopUpdatingComponent(self)
    end
end

function Catcher:CanCatch()
    return next(self.watchlist) ~= nil and self.canact
end

function Catcher:PrepareToCatch()
    self.inst:PushEvent("readytocatch")
end

function Catcher:ReadyToCatch()
    return self.inst.sg:HasStateTag("readytocatch")
end

function Catcher:CollectSceneActions(doer, actions)
	if self:CanCatch() then
		table.insert(actions, ACTIONS.CATCH)
	end
end


function Catcher:OnUpdate()
    if not self.inst:IsValid() then
        return
    end
    
    local canact = false
    for k,v in pairs(self.watchlist) do
        if k and k:IsValid() and k.components.projectile and k.components.projectile:IsThrown() then
            local distsq = k:GetDistanceSqToInst(self.inst)
            if distsq <= self.catchdistance*self.catchdistance then
                if self:ReadyToCatch() then
                    self.inst:PushEvent("catch", {projectile = k})
                    k:PushEvent("caught", {catcher = self.inst})
                    k.components.projectile:Catch(self.inst)
                    self:StopWatching(k)
                end
            end
            canact = canact or distsq < self.actiondistance*self.actiondistance
        else
            self:StopWatching(k)
        end
    end
    self.canact = canact
end


return Catcher
