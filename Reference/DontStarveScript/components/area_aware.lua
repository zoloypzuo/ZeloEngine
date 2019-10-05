local AreaAwareness = Class(function(self, inst)
    self.inst = inst
    self.areas = {}
    self.checkinterval = 1
    self.current_area = {idx = -1, type = nil, poly = nil, story = nil, story_depth = nil}
    self.tile = nil
end)

function AreaAwareness:UpdatePosition()
	--self.checkpositiontask = self.inst:DoTaskInTime(self.checkinterval, function() self:UpdatePosition() end)    

	local pos = Vector3(self.inst.Transform:GetWorldPosition())
    local ground = GetWorld()  
    local tile = ground.Map:GetTileAtPoint(pos.x, pos.y, pos.z)
    
    self.tile = tile

	if tile == GROUND.IMPASSABLE then
		return
	end

	for i, area in ipairs(self.areas) do
		if TheSim:WorldPointInPoly(pos.x, pos.z, area.poly) then
			if area.type ~= self.current_area.type or area.story ~= self.current_area.story or area.idx ~= self.current_area.idx then
				self.inst:PushEvent("changearea", area)
			end
			self.current_area = area
		end
	end
end

function AreaAwareness:GetDebugString()
    local s = string.format("%s: %s [%d] depth: %s", tostring(self.current_area.story), tostring(self.current_area.type), self.current_area.idx, tostring(self.current_area.story_depth) or "nil")
    return s
end

function AreaAwareness:StartCheckingPosition(checkinterval)    
	self.checkpositiontask = self.inst:DoPeriodicTask(checkinterval or self.checkinterval, function() self:UpdatePosition() end)
end

function AreaAwareness:RegisterArea(node)
	table.insert(self.areas, {idx=node.idx, type=node.type, poly=node.poly, story=node.story, story_depth=node.story_depth, cent=node.cent})
end

return AreaAwareness
