local Harvestable = Class(function(self, inst)
    self.inst = inst
    self.canbeharvested = nil
    self.produce = 0
    self.growtime = nil
    self.product = nil
    self.ongrowfn = nil
    self.maxproduce = 1
end)

function Harvestable:SetUp(product, max, time, onharvest, ongrow)
    self:SetProduct(product, max)
    self:SetGrowTime(time)
    self:SetOnGrowFn(ongrow)
    self:SetOnHarvestFn(onharvest)
    self:StartGrowing()
end

function Harvestable:SetOnGrowFn(fn)
    self.ongrowfn = fn
end

function Harvestable:SetOnHarvestFn(fn)
    self.onharvestfn = fn
end

function Harvestable:SetProduct(product, max)
    self.product = product
    self.maxproduce = max or 1
    self.produce = 0
end

function Harvestable:SetGrowTime(time)
    self.growtime = time
end

function Harvestable:CanBeHarvested()
    return self.produce > 0
end

function Harvestable:OnSave()
    local data = {}
    local time = GetTime()
    if self.targettime and self.targettime > time then
        data.time = self.targettime - time
    end
    data.produce = self.produce
    return data
end

function Harvestable:OnLoad(data)
    --print(self.inst, "Harvestable:OnLoad")
    self.produce = data.produce
    if data.time then
        self:StartGrowing(data.time)
    end
end


function Harvestable:GetDebugString()
    local str = string.format("%d "..self.product.." grown", self.produce)
    if self.targettime then
        str = str.." ("..tostring(self.targettime - GetTime())..")"
    end
	return str
end

function Harvestable:Grow()
    if self.produce < self.maxproduce then
        self.produce = self.produce + 1
        if self.ongrowfn then
            self.ongrowfn(self.inst, self.produce)
        end
        if self.produce < self.maxproduce then
            self:StartGrowing()
        else
            self:StopGrowing()
        end
    end
end

function Harvestable:StartGrowing(time)
    self:StopGrowing()
    local growtime = time or self.growtime
    if growtime then
		self.task = self.inst:DoTaskInTime(growtime, function() self:Grow() end, "grow")
		self.targettime = GetTime() + growtime
	end
end

function Harvestable:StopGrowing()
    if self.task then
		self.task:Cancel()
		self.task = nil
		self.targettime = nil
	end
end

function Harvestable:Harvest(picker)
    if self:CanBeHarvested() then
        local produce = self.produce
        self.produce = 0
        
        if self.onharvestfn then
            self.onharvestfn(self.inst, picker, produce)
        end
        
        if picker.components.inventory and self.product then
	        picker:PushEvent("harvestsomething", {object = self.inst})
            for i = 1, produce, 1 do
                local loot = SpawnPrefab(self.product)
                if loot then
                    picker.components.inventory:GiveItem(loot)
                end
            end
        end
        self:StartGrowing()
        return true
    end
end


function Harvestable:CollectSceneActions(doer, actions)
    if self:CanBeHarvested() then
        table.insert(actions, ACTIONS.HARVEST)
    end
end

return Harvestable