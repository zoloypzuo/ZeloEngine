local HomeSeeker = Class(function(self, inst)
    self.inst = inst
    self.onhomeremoved = function()
        self:SetHome(nil)
        self.inst:RemoveComponent("homeseeker")
    end
end)

function HomeSeeker:HasHome()
    return self.home and self.home:IsValid() and not self.home:HasTag("burned") and not (self.home.components.burnable and self.home.components.burnable:IsBurning())
end

function HomeSeeker:GetDebugString()
    return string.format("home: %s", tostring(self.home))
end

function HomeSeeker:SetHome(home)
    if self.home then
        self.inst:RemoveEventCallback("onremove", self.onhomeremoved, self.home)
    end
    if home and home:IsValid() then
        self.home = home
    else
        self.home = nil
    end
    if self.home then
        self.inst:ListenForEvent("onremove", self.onhomeremoved, self.home)
    end
end

function HomeSeeker:GoHome(shouldrun)

    if self:HasHome() then
        local bufferedaction = BufferedAction(self.inst, self.home, ACTIONS.GOHOME)
        if self.inst.components.locomotor then
            self.inst.components.locomotor:PushAction(bufferedaction, shouldrun)
        else
            self.inst:PushBufferedAction(bufferedaction)
        end
    end
end

function HomeSeeker:ForceGoHome()
    if self:HasHome() then
        if self.home.components.spawner then
            self.home.components.spawner:GoHome(self.inst)
        elseif self.home.components.childspawner then
            self.home.components.childspawner:GoHome(self.inst)
        end
    end
end

function HomeSeeker:GetHomePos()
    return self.home and self.home:IsValid() and Point(self.home.Transform:GetWorldPosition())
end

function HomeSeeker:GetHome()
    return self.home
end

return HomeSeeker
