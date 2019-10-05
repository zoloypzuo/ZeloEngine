local DistanceTracker = Class(function(self, inst)
	self.previous_pos = nil
	self.inst = inst
    inst:StartUpdatingComponent(self)    
end)

function DistanceTracker:OnUpdate(dt)
	local mypos = Point(self.inst.Transform:GetWorldPosition())
	local distance = 0
	if self.previous_pos then
		distance = math.sqrt( distsq( mypos, self.previous_pos ) )
	end
	self.previous_pos = mypos

	--local meters_to_furlongs = 1.0 / 201.168
	--local furlongs_travelled = distance * meters_to_furlongs

	--TheSim:SendGameStat( "furlongs_travelled", distance )
end

return DistanceTracker

