local Grower = Class(function(self, inst)
    self.inst = inst
    self.crops = {}
    self.isempty = true
    self.level = 1
    self.croppoints = {}
    self.growrate = 1
    self.cycles_left = 1
    self.max_cycles_left = 6
    
end)

function Grower:IsEmpty()
    return self.isempty
end

function Grower:IsFullFertile()
	return self.cycles_left >= self.max_cycles_left
end

function Grower:GetFertilePercent()
	return self.cycles_left / self.max_cycles_left
end

function Grower:IsFertile()
	return self.cycles_left > 0
end


function Grower:OnSave()
    local data = {crops = {}}

    for k,v in pairs(self.crops) do
        local save_record = k:GetSaveRecord()
        table.insert(data.crops, save_record)
    end
    data.cycles_left = self.cycles_left
    return data
end   
   
function Grower:Fertilize(obj)
	
	local was_fertile = self:IsFertile()	
	
	if obj.components.fertilizer then
		self.cycles_left = self.cycles_left + obj.components.fertilizer.soil_cycles
	end
	
	obj:Remove()
	
	if self.setfertility then
		self.setfertility(self.inst, self:GetFertilePercent())
	end
end

function Grower:OnLoad(data, newents)
    
    if data.crops then
        for k,v in pairs(data.crops) do
			self.isempty = false
			self.inst:AddTag("NOCLICK")
            local child = SpawnSaveRecord(v, newents)
            child.components.crop.grower = self.inst
            child.Transform:SetPosition(v.x or 0, v.y or 0, v.z or 0)
            child.persists = false
            self.crops[child] = true
			child.components.crop:Resume()            
        end
    end
    
    self.cycles_left = data.cycles_left or self.cycles_left
    
	if self.setfertility then
		self.setfertility(self.inst, self:GetFertilePercent())
	end
end

function Grower:PlantItem(item)
    
    if not item.components.plantable or item.components.plantable.minlevel > self.level then
        return false
    end
    
    self:Reset()
    
    local prefab = nil
    if item.components.plantable.product and type(item.components.plantable.product) == "function" then
		prefab = item.components.plantable.product(item)
    else
		prefab = item.components.plantable.product or item.prefab
	end
    
	for k,v in ipairs(self.croppoints) do
		local plant1 = SpawnPrefab("plant_normal")
		plant1.persists = false
		self.inst:AddTag("NOCLICK")
	    
		plant1.components.crop:StartGrowing(prefab, item.components.plantable.growtime*self.growrate, self.inst)
		local pos = Vector3(self.inst.Transform:GetWorldPosition()) + v
		plant1.Transform:SetPosition(pos:Get())
	    
		self.crops[plant1] = true
	end
    
    self.isempty = false
    
    if self.onplantfn then
		self.onplantfn(item)
    end
	item:Remove()
	
    return true
end

function Grower:RemoveCrop(crop)
    crop:Remove()
    self.crops[crop] = nil

    for k,v in pairs(self.crops) do
        return 
    end
    
    self.isempty = true
    self.inst:RemoveTag("NOCLICK")
    self.cycles_left = self.cycles_left - 1
    
	if self.setfertility then
		self.setfertility(self.inst, self:GetFertilePercent())
	end
end

function Grower:GetDebugString()
	return "Cycles left" .. tostring(self.cycles_left) .. " / " .. tostring(self.max_cycles_left)
end

function Grower:Reset()
    self.isempty = true
    for k,v in pairs(self.crops) do
        k:Remove()
    end
    self.crops = {}
    self.inst:RemoveTag("NOCLICK")

end


return Grower
