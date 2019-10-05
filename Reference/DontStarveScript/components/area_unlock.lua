local AreaUnlock = Class(function(self, inst)
    self.inst = inst
    self.stories = {}
    self.inst:ListenForEvent( "changearea", function(inst, area) self:CheckUnlock(area) end)
end)


function AreaUnlock:CheckUnlock(area)    
	if self.stories[area.story] ~= nil and self.stories[area.story] == false then
		--print("Unlocking", area.story)
		self.stories[area.story] = true
	end
end

function AreaUnlock:RegisterStory(story)
	self.stories[story] = false
end

function AreaUnlock:GetUnlocked()
	local unlocked = {}
	for k,v in pairs(self.stories) do
		if v == true then
			table.insert(unlocked, k)
		end
	end
	return unlocked
end

return AreaUnlock