local Pollinator = Class(function(self, inst)
    self.inst = inst
    self.flowers = {}
    self.distance = 5
    self.maxdensity = 4
    self.collectcount = 5
    self.target = nil
    self.inst:AddTag("pollinator")
end)

function Pollinator:GetDebugString()
    return string.format("flowers: %d, cancreate: %s", #self.flowers, tostring(self:HasCollectedEnough() ) )
end

function Pollinator:Pollinate(flower)
    if self:CanPollinate(flower) then
        table.insert(self.flowers, flower)
        self.target = nil
    end
end

function Pollinator:CanPollinate(flower)
	return flower and flower:HasTag("flower") and not table.contains(self.flowers, flower)
end

function Pollinator:HasCollectedEnough()
    return #self.flowers >= self.collectcount
end

function Pollinator:CreateFlower()
    if self:HasCollectedEnough() then
		local parentFlower = GetRandomItem(self.flowers)
		local flower = SpawnPrefab(parentFlower.prefab)
        flower.Transform:SetPosition(self.inst.Transform:GetWorldPosition())
        self.flowers = {}
    end
end

function Pollinator:CheckFlowerDensity()
    if IsDLCEnabled(PORKLAND_DLC) then
        local pt = self.inst:GetPosition()
        local tile = GetWorld().Map:GetTileAtPoint(pt.x,pt.y,pt.z)
        if tile == GROUND.INTERIOR then        
            return false
        end
    end
    local x,y,z = self.inst.Transform:GetWorldPosition()
    local nearbyflowers = TheSim:FindEntities(x,y,z, self.distance, "flower")
    return #nearbyflowers < self.maxdensity
end

return Pollinator
