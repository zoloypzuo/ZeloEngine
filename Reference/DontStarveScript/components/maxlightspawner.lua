local MaxLightSpawner = Class(function (self,inst)
	self.inst = inst
	self.lights = {}
	self.numlights = 0
	self.maxlights = 2
	self.angleoffset = 0
	self.radius = 3
	self.lightname = "maxwelllight"
end)

function MaxLightSpawner:TakeOwnership(light)
	self.lights[light] = light
	self.numlights = self.numlights + 1
end

function MaxLightSpawner:OnSave()
	local data = {}
	for k,v in pairs(self.lights) do
		if not data.lights then
			data.lights = {v.GUID}
		else
			table.insert(data.lights, v.GUID)
		end
	end
	return data, data.lights
end

function MaxLightSpawner:OnLoad(data)
	if data.childid then
		data.lights = {data.childid}
	end
end

function MaxLightSpawner:LoadPostPass(newents, savedata)
	if savedata.lights then
		for k,v in pairs(savedata.lights) do
			local light = newents[v]
			if light then
				light = light.entity
				self:TakeOwnership(light)
			end
		end
	end
end

function MaxLightSpawner:SpawnLight(location)
	local light = SpawnPrefab("maxwelllight")
	if light ~= nil then
		light.Transform:SetPosition(location.x, location.y, location.z)
		self:TakeOwnership(light)
	end
	return light
end

function MaxLightSpawner:SpawnAllLights()
	if self.numlights < self.maxlights then
		local pt = Vector3(self.inst.Transform:GetWorldPosition())	
		local theta = self.angleoffset * (PI / 180)	
		for i = 1, self.maxlights do
			local offset = Vector3(self.radius * math.cos(theta), 0, -self.radius * math.sin(theta))
			local placementpoint = pt + offset
			self:SpawnLight(placementpoint)
			theta = theta - (2 * PI / self.maxlights)
		end
	end	
end

return MaxLightSpawner