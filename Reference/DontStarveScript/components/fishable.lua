local Fishable = Class(function(self, inst)
    self.inst = inst
    self.fish = {}
    self.maxfish = 10
    self.fishleft = 10
    self.hookedfish = {}
    self.fishrespawntime = nil
    self.respawntask = nil
	self.frozen = false
end)

function Fishable:GetDebugString()
    local str = string.format("fishleft: %d", self.fishleft)
    return str
end


function Fishable:AddFish(prefab)
    self.fish[prefab] = prefab
end

function Fishable:SetRespawnTime(time)
    self.fishrespawntime = time
end

local function RespawnFish(inst)
    local fishable = inst.components.fishable
    if fishable then
        fishable.respawntask = nil
        if fishable.fishleft < fishable.maxfish then
            fishable.fishleft = fishable.fishleft + 1
            if fishable.fishleft < fishable.maxfish then
                fishable:RefreshFish()
            end
        end
    end
end

function Fishable:HookFish()
    local fishprefab = GetRandomKey(self.fish)
    local fish = SpawnPrefab(fishprefab)
    if fish and self.fishleft > 0 then
        self.hookedfish[fish] = fish
        self.inst:AddChild(fish)
        fish.entity:Hide()
        if fish.Physics then
            fish.Physics:SetActive(false)
        end
        self.fishleft = self.fishleft - 1
    end
    return fish
end

function Fishable:ReleaseFish(fish)
    if self.hookedfish[fish] == fish then
        fish:Remove()
        self.hookedfish[fish] = nil
        self.fishleft = self.fishleft + 1
    end
end

function Fishable:RemoveFish(fish)
    if self.hookedfish[fish] == fish then
        self.hookedfish[fish] = nil
        self.inst:RemoveChild(fish)
        fish.entity:Show()
        if fish.Physics then
            fish.Physics:SetActive(true)
        end
        if not self.respawntask then
            self:RefreshFish()
        end
        return fish
    end
end

function Fishable:IsFrozenOver()
	return self.frozen
end

function Fishable:Freeze()
	self.frozen = true
end

function Fishable:Unfreeze()
	self.frozen = false
end


function Fishable:RefreshFish()
    if self.fishrespawntime then
        self.respawntask = self.inst:DoTaskInTime(self.fishrespawntime, RespawnFish)
    end
end

function Fishable:GetFishPercent()
    return self.fishleft / self.maxfish 
end

function Fishable:FishedBy(fisherman)
    if self.fish then
        local spawnPos = Vector3(fisherman.Transform:GetWorldPosition()) - TheCamera:GetRightVec()
        local fishprefab = GetRandomKey(self.fish)
        local fish = SpawnPrefab(fishprefab)
        if fish then
            fish.Transform:SetPosition(spawnPos:Get() )
        end
    end
end

function Fishable:OnSave()
    if self.fishleft < self.maxfish then
        return {fish = self.fishleft}
    end
end

function Fishable:OnLoad(data)
    if data then
        self.fishleft = data.fish
        self:RefreshFish()
    end
end

return Fishable
