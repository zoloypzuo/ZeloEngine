local FishingRod = Class(function(self, inst)
    self.inst = inst
    self.target = nil
    self.fisherman = nil
    self.hookedfish = nil
    self.caughtfish = nil
    self.minwaittime = 0
    self.maxwaittime = 10
    self.minstraintime = 0
    self.maxstraintime = 6
    self.fishtask = nil
end)

local function DoNibble(inst)
    local fishingrod = inst.components.fishingrod
    if fishingrod and fishingrod.fisherman then
        inst:PushEvent("fishingnibble")
        fishingrod.fisherman:PushEvent("fishingnibble")
        fishingrod.fishtask = nil
    end
end

local function DoLoseRod(inst)
    local fishingrod = inst.components.fishingrod
    if fishingrod and fishingrod.fisherman then
        inst:PushEvent("fishingloserod")
        fishingrod.fisherman:PushEvent("fishingloserod")
        fishingrod.fishtask = nil
    end
end

function FishingRod:GetDebugString()
    local str = string.format("target: %s", tostring(self.target) )
    if self.hookedfish then
        str = str.." hooked: "..tostring(self.hookedfish)
    end
    if self.caughtfish then
        str = str.." caught: "..tostring(self.caughtfish)
    end
    return str
end

function FishingRod:SetWaitTimes(min, max)
    self.minwaittime = min
    self.maxwaittime = max
end

function FishingRod:SetStrainTimes(min, max)
    self.minstraintime = min
    self.maxstraintime = max
end

function FishingRod:CollectUseActions(doer, target, actions)
    if target.components.fishable and not self:HasCaughtFish() then
		if not target.components.fishable:IsFrozenOver() then
			if target == self.target then
				table.insert(actions, ACTIONS.REEL)
			else
				table.insert(actions, ACTIONS.FISH)
			end
		end
    end

    if target.components.flotsamfisher and not self:HasCaughtFish() then
        if target == self.target then
            table.insert(actions, ACTIONS.REEL)
        else
            table.insert(actions, ACTIONS.FISHOCEAN)
        end
    end
end

function FishingRod:CollectEquippedActions(doer, target, actions)
    if target.components.fishable and not self:HasCaughtFish() then
		if not target.components.fishable:IsFrozenOver() then
			if target == self.target then
				table.insert(actions, ACTIONS.REEL)
			else
				table.insert(actions, ACTIONS.FISH)
			end
		end
    end

    if target.components.flotsamfisher and not self:HasCaughtFish() then
        if target == self.target then
            table.insert(actions, ACTIONS.REEL)
        else
            table.insert(actions, ACTIONS.FISHOCEAN)
        end
    end
end

function FishingRod:OnUpdate(dt)
    if self:IsFishing() then
        if not self.fisherman:IsValid()
           or (not self.fisherman.sg:HasStateTag("fishing") and not self.fisherman.sg:HasStateTag("catchfish") )
           or not self.inst.components.equippable
           or not self.inst.components.equippable.isequipped then
            self:StopFishing()
        end
    end
end


function FishingRod:IsFishing()
    return self.target ~= nil and self.fisherman ~= nil
end

function FishingRod:HasHookedFish()
    return self.target ~= nil and self.hookedfish ~= nil
end

function FishingRod:HasCaughtFish()
    return self.caughtfish ~= nil
end

function FishingRod:FishIsBiting()
    return self.fisherman and self.fisherman.sg:HasStateTag("nibble")
end

function FishingRod:StartFishing(target, fisherman)
    self:StopFishing()
    if target and target.components.fishable then
        self.target = target
        self.fisherman = fisherman
        self.inst:StartUpdatingComponent(self)
    end
    if target and target.components.flotsamfisher then
        self.target = target
        self.fisherman = fisherman
    end
end

function FishingRod:WaitForFish()
    if self.target and self.target.components.fishable then
        local fishleft = self.target.components.fishable:GetFishPercent()
        local nibbletime = nil
        if fishleft > 0 then
            nibbletime = self.minwaittime + (1.0 - fishleft)*(self.maxwaittime - self.minwaittime)
        end
        self:CancelFishTask()
        if nibbletime then
            self.fishtask = self.inst:DoTaskInTime(nibbletime, DoNibble)
        end
    end
end

function FishingRod:CancelFishTask()
    if self.fishtask then
        self.fishtask:Cancel()
    end
    self.fishtask = nil
end

function FishingRod:StopFishing()
    if self.target and self.fisherman then
        self.inst:PushEvent("fishingcancel")
        self.fisherman:PushEvent("fishingcancel")
        self.target = nil
        self.fisherman = nil
    end
    self:CancelFishTask()
    self.inst:StopUpdatingComponent(self)
    self.hookedfish = nil
    self.caughtfish = nil
end

function FishingRod:Hook()
    if self.target and self.target.components.fishable then
        self.hookedfish = self.target.components.fishable:HookFish()
        if self.inst.components.finiteuses then
            local roddurability = self.inst.components.finiteuses:GetPercent()
            local loserodtime = self.minstraintime + roddurability*(self.maxstraintime - self.minstraintime)
            self.fishtask = self.inst:DoTaskInTime(loserodtime, DoLoseRod)
        end
        self.inst:PushEvent("fishingstrain")
        self.fisherman:PushEvent("fishingstrain")
    end
end

function FishingRod:Release()
    if self.target and self.target.components.fishable and self.hookedfish then
        self.target.components.fishable:ReleaseFish(self.hookedfish)
        self:StopFishing()
    end
end

function FishingRod:Reel()
    if self.target and self.target.components.fishable and self.hookedfish then
        self.caughtfish = self.target.components.fishable:RemoveFish(self.hookedfish)
        self.hookedfish = nil
        self:CancelFishTask()
        if self.caughtfish then
            self.inst:PushEvent("fishingcatch", {build = self.caughtfish.build} )
            self.fisherman:PushEvent("fishingcatch", {build = self.caughtfish.build} )
        end
    end
end

function FishingRod:Collect()
    if self.caughtfish and self.fisherman then
        local spawnPos = Vector3(self.fisherman.Transform:GetWorldPosition() )
        local offset = spawnPos - Vector3(self.target.Transform:GetWorldPosition() )
        offset = offset:GetNormalized()
        spawnPos = spawnPos + offset
        self.caughtfish.Transform:SetPosition(spawnPos:Get() )
        self.inst:PushEvent("fishingcollect", {fish = self.caughtfish} )
        self.fisherman:PushEvent("fishingcollect", {fish = self.caughtfish} )
        self:StopFishing()
    end
end

function FishingRod:CollectFlotsam()
    if self.target and self.target.components.flotsamfisher and self.fisherman then
        self.target.components.flotsamfisher:Fish(self.fisherman)
        self.inst:PushEvent("fishingcollect", {fish = nil} )
        self.fisherman:PushEvent("fishingcollect", {fish = nil} )
        self:StopFishing()
    end
end

return FishingRod
