local OptionsWatcher = Class(function(self, inst)
	self.inst = inst
	self.watches = {}
	self.inst:StartUpdatingComponent(self)
end)

function OptionsWatcher:OnUpdate()
	for i,v in pairs(self.watches) do
		local value = Profile:GetDLCSetting(i.dlcname, i.name)
		if value ~= i.value then
			-- broadcast a message
			print("Setting "..i.dlcname..":"..i.name.." set to "..tostring(value))
			GetWorld():PushEvent(i.name, {value = value})
			i.value = value
		end
	end
end

function OptionsWatcher:AddWatch(dlcname, name)
	local value = Profile:GetDLCSetting(dlcname, name)
	local watch = {dlcname = dlcname, name = name}
	self.watches[watch] = watch
	return watch
end

function OptionsWatcher:RemoveWatch(watch)
	self.watches[watch] = nil
end

return OptionsWatcher
